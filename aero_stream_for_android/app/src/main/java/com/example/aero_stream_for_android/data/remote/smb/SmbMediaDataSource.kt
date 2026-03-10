package com.example.aero_stream_for_android.data.remote.smb

import android.content.Context
import android.util.Log
import dagger.hilt.android.qualifiers.ApplicationContext
import com.example.aero_stream_for_android.data.scan.ScanMetadataResult
import com.example.aero_stream_for_android.data.smb.BucketScanResult
import com.example.aero_stream_for_android.data.smb.ScanAccumulator
import com.example.aero_stream_for_android.data.smb.ScanProgressEvent
import com.example.aero_stream_for_android.data.smb.SmbScanStage
import com.example.aero_stream_for_android.data.smb.SmbScanProgressTracker
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.SongMetadataState
import com.hierynomus.msdtyp.AccessMask
import com.hierynomus.mssmb2.SMB2CreateDisposition
import com.hierynomus.mssmb2.SMB2ShareAccess
import com.hierynomus.smbj.share.File as SmbjFile
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.currentCoroutineContext
import kotlinx.coroutines.delay
import kotlinx.coroutines.ensureActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Semaphore
import kotlinx.coroutines.sync.withPermit
import kotlinx.coroutines.withContext
import java.io.InputStream
import java.util.EnumSet
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.cancellation.CancellationException

/**
 * SMBサーバーから楽曲ファイルを探索・取得するデータソース。
 */
@Singleton
class SmbMediaDataSource @Inject constructor(
    @ApplicationContext private val context: Context,
    private val connectionManager: SmbConnectionManager
) {
    companion object {
        private const val TAG = "SmbMediaDataSource"
        private const val MAX_SCAN_RETRY = 2
        private const val DIRECTORY_SCAN_WORKER_COUNT = 4

        private val AUDIO_EXTENSIONS = setOf(
            "mp3", "m4a", "flac", "ogg", "wav", "aac", "wma", "opus",
            "aif", "aiff", "ape", "dsf", "dff", "wv"
        )

        /** リトライ不要な恒久的エラーかどうかを判定する */
        private fun isPermanentError(e: Exception): Boolean {
            val message = generateSequence(e as Throwable) { it.cause }
                .mapNotNull { it.message }
                .joinToString(" ")
            return message.contains("STATUS_ACCESS_DENIED", ignoreCase = true) ||
                message.contains("STATUS_OBJECT_NAME_NOT_FOUND", ignoreCase = true) ||
                message.contains("STATUS_OBJECT_PATH_NOT_FOUND", ignoreCase = true)
        }
    }

    private val metadataExtractor = SmbMetadataExtractor(
        context = context,
        loggerTag = TAG
    )

    /**
     * 指定パスのディレクトリ内の音楽ファイルとサブディレクトリを探索する。
     */
    suspend fun listDirectory(
        config: SmbConfig,
        path: String = ""
    ): SmbDirectoryListing = withContext(Dispatchers.IO) {
        val normalizedPath = normalizeSmbRootPath(path)
        val share = connectionManager.getShare(config)
        val items = share.list(normalizedPath)
        val directories = mutableListOf<SmbFileInfo>()
        val audioFiles = mutableListOf<SmbFileInfo>()

        for (item in items) {
            val name = item.fileName
            // skip . and ..
            if (name == "." || name == "..") continue

            val fullPath = if (normalizedPath.isEmpty()) name else "$normalizedPath\\$name"
            val isDirectory = item.fileAttributes and 0x10L != 0L // FILE_ATTRIBUTE_DIRECTORY

            if (isDirectory) {
                directories.add(SmbFileInfo(name, fullPath, isDirectory = true))
            } else {
                val ext = name.substringAfterLast('.', "").lowercase()
                if (ext in AUDIO_EXTENSIONS) {
                    audioFiles.add(
                        SmbFileInfo(
                            name = name,
                            path = fullPath,
                            isDirectory = false,
                            size = item.endOfFile,
                            extension = ext,
                            lastWriteTime = runCatching { item.lastWriteTime.toDate().time }.getOrDefault(0L)
                        )
                    )
                }
            }
        }

        SmbDirectoryListing(
            path = normalizedPath,
            directories = directories,
            audioFiles = audioFiles
        )
    }

    /**
     * SMBサーバー上のディレクトリを再帰的にスキャンし、全楽曲ファイルを返す。
     */
    suspend fun scanAllMusic(
        config: SmbConfig,
        rootPath: String = ""
    ): List<SmbFileInfo> = withContext(Dispatchers.IO) {
        val results = mutableListOf<SmbFileInfo>()
        scanRecursive(config, rootPath, results)
        results
    }

    suspend fun enumerateAudioFilesParallel(
        config: SmbConfig,
        rootPath: String = "",
        onFile: suspend (SmbFileInfo) -> Unit,
        onDirectorySkipped: () -> Unit = {}
    ) = withContext(Dispatchers.IO) {
        val normalizedRoot = normalizeSmbRootPath(rootPath)
        val channel = Channel<SmbFileInfo>(capacity = Channel.UNLIMITED)
        val semaphore = Semaphore(DIRECTORY_SCAN_WORKER_COUNT)

        coroutineScope {
            val producer = launch {
                try {
                    semaphore.withPermit {
                        scanRecursiveToChannel(
                            config = config,
                            path = normalizedRoot,
                            isRoot = true,
                            channel = channel,
                            onDirectorySkipped = onDirectorySkipped,
                            semaphore = semaphore
                        )
                    }
                } finally {
                    channel.close()
                }
            }

            for (file in channel) {
                onFile(file)
            }
            producer.join()
        }
    }

    suspend fun scanAllMusicAsSongs(
        config: SmbConfig,
        rootPath: String = "",
        onProgress: (ScanProgressEvent) -> Unit = {},
        onSongExtracted: suspend (song: Song, isUnchanged: Boolean) -> Unit = { _, _ -> },
        existingSyncInfos: Map<String, com.example.aero_stream_for_android.data.local.db.dao.SmbSyncInfoProjection>? = null,
        getExistingSong: suspend (String) -> Song? = { null }
    ): Int = withContext(Dispatchers.IO) {
        val progressTracker = SmbScanProgressTracker(onProgress)
        progressTracker.emitListing(currentPath = normalizeSmbRootPath(rootPath))
        val files = scanAllMusic(config, rootPath)
        files.forEach { fileInfo ->
            progressTracker.onFileDiscovered(fileInfo.path)
        }
        progressTracker.markDiscoveryCompleted(rootPath)

        var totalScannedCount = 0
        for (fileInfo in files) {
            ensureActive()
            val existingSyncInfo = existingSyncInfos?.get(fileInfo.path)
            val isUnchanged = existingSyncInfo != null &&
                existingSyncInfo.fileSize == fileInfo.size &&
                existingSyncInfo.smbLastWriteTime == fileInfo.lastWriteTime &&
                fileInfo.lastWriteTime > 0L

            if (isUnchanged) {
                val existingSong = getExistingSong(fileInfo.path) ?: toSong(fileInfo)
                onSongExtracted(existingSong.copy(smbConfigId = config.id), true)
                totalScannedCount++
                progressTracker.onExistingRowStaged(fileInfo.path)
                continue
            }

            val result = extractSongMetadata(config, fileInfo)
            val song = when (result) {
                is ScanMetadataResult.Success -> result.song
                is ScanMetadataResult.Fallback -> result.song
                ScanMetadataResult.Error -> toSong(fileInfo).copy(
                    smbConfigId = config.id,
                    sourceUpdatedAt = System.currentTimeMillis(),
                    metadataState = SongMetadataState.FALLBACK
                )
            }
            onSongExtracted(song, false)
            totalScannedCount++
            progressTracker.onExtractedRowStaged(fileInfo.path, result)
        }

        totalScannedCount
    }

    suspend fun listLibraryBuckets(config: SmbConfig): List<SmbLibraryBucket> = withContext(Dispatchers.IO) {
        val rootPath = normalizeSmbRootPath(config.rootPath)
        val listing = listDirectory(config, rootPath)
        buildList {
            if (listing.audioFiles.isNotEmpty()) {
                add(
                    SmbLibraryBucket(
                        id = ROOT_BUCKET_ID,
                        displayName = bucketDisplayName(ROOT_BUCKET_ID),
                        shareRelativePath = rootPath,
                        containsDirectFiles = true
                    )
                )
            }
            listing.directories.forEach { directory ->
                add(
                    SmbLibraryBucket(
                        id = deriveSmbLibraryBucket(rootPath, directory.path) ?: directory.name,
                        displayName = directory.name,
                        shareRelativePath = directory.path
                    )
                )
            }
        }.distinctBy { it.id }.sortedBy { it.displayName.lowercase() }
    }

    suspend fun scanMusicUnderPathAsSongs(
        config: SmbConfig,
        bucketId: String,
        shareRelativePath: String,
        onProgress: (ScanProgressEvent) -> Unit = {}
    ): BucketScanResult = withContext(Dispatchers.IO) {
        val accumulator = ScanAccumulator()
        scanSongsRecursive(
            config = config,
            bucketId = bucketId,
            path = normalizeSmbRootPath(shareRelativePath),
            accumulator = accumulator,
            onProgress = onProgress
        )
        BucketScanResult(
            songs = accumulator.results.toList(),
            failedCount = accumulator.failedCount,
            skippedDirectories = accumulator.skippedDirectories
        )
    }

    private suspend fun scanRecursive(
        config: SmbConfig,
        path: String,
        results: MutableList<SmbFileInfo>
    ) {
        try {
            currentCoroutineContext().ensureActive()
            val listing = listDirectoryWithRetry(config, path)
            results.addAll(listing.audioFiles)
            for (dir in listing.directories) {
                scanRecursive(config, dir.path, results)
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.w(TAG, "Failed to scan directory (scanRecursive): $path", e)
        }
    }

    /**
     * ディレクトリを再帰的にスキャンし、見つかったファイルをチャネルに送信する。
     * パイプライン処理用のプロデューサー。
     */
    private suspend fun scanRecursiveToChannel(
        config: SmbConfig,
        path: String,
        isRoot: Boolean,
        channel: Channel<SmbFileInfo>,
        onDirectorySkipped: () -> Unit,
        semaphore: Semaphore
    ) {
        try {
            currentCoroutineContext().ensureActive()
            val listing = listDirectoryWithRetry(config, path)
            for (file in listing.audioFiles) {
                channel.send(file)
            }
            coroutineScope {
                for (dir in listing.directories) {
                    launch {
                        semaphore.withPermit {
                            scanRecursiveToChannel(
                                config = config,
                                path = dir.path,
                                isRoot = false,
                                channel = channel,
                                onDirectorySkipped = onDirectorySkipped,
                                semaphore = semaphore
                            )
                        }
                    }
                }
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            if (isRoot) throw e
            onDirectorySkipped()
            Log.w(TAG, "Failed to scan directory: $path", e)
        }
    }

    private suspend fun scanSongsRecursive(
        config: SmbConfig,
        bucketId: String,
        path: String,
        accumulator: ScanAccumulator,
        onProgress: (ScanProgressEvent) -> Unit
    ) {
        try {
            currentCoroutineContext().ensureActive()
            val listing = listDirectoryWithRetry(config, path)
            listing.audioFiles.forEach { file ->
                currentCoroutineContext().ensureActive()
                onProgress(
                    ScanProgressEvent(
                        stage = SmbScanStage.EXTRACTING,
                        scannedCount = accumulator.results.size,
                        stagedCount = accumulator.results.size,
                        processedCount = accumulator.results.size,
                        failedCount = accumulator.failedCount,
                        skippedDirectories = accumulator.skippedDirectories,
                        currentPath = file.path
                    )
                )
                val result = extractSongMetadata(config, file)
                val song = when (result) {
                    is ScanMetadataResult.Success -> result.song
                    is ScanMetadataResult.Fallback -> {
                        accumulator.failedCount++
                        result.song
                    }
                    ScanMetadataResult.Error -> {
                        accumulator.failedCount++
                        toSong(file).copy(
                            smbConfigId = config.id,
                            sourceUpdatedAt = System.currentTimeMillis(),
                            metadataState = SongMetadataState.FALLBACK
                        )
                    }
                }
                accumulator.results.add(song.copy(smbLibraryBucket = bucketId, smbConfigId = config.id))
            }
            listing.directories.forEach { directory ->
                scanSongsRecursive(config, bucketId, directory.path, accumulator, onProgress)
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            accumulator.skippedDirectories++
            accumulator.skippedPaths.add(path)
            Log.w(TAG, "Failed to scan directory (scanSongsRecursive): $path", e)
        }
    }

    /**
     * リトライ付きでディレクトリをリストする。
     * 一時的なエラーの場合は最大 [MAX_SCAN_RETRY] 回リトライする。
     */
    suspend fun listDirectoryWithRetry(
        config: SmbConfig,
        path: String
    ): SmbDirectoryListing {
        var lastException: Exception? = null
        repeat(MAX_SCAN_RETRY + 1) { attempt ->
            try {
                return listDirectory(config, path)
            } catch (e: CancellationException) {
                throw e
            } catch (e: Exception) {
                lastException = e
                if (isPermanentError(e)) {
                    throw e
                }
                if (attempt < MAX_SCAN_RETRY) {
                    val delayMs = (attempt + 1) * 2000L
                    Log.w(TAG, "Retrying listDirectory($path) after ${delayMs}ms (attempt ${attempt + 1})", e)
                    connectionManager.resetIfBroken(config)
                    delay(delayMs)
                }
            }
        }
        throw lastException!!
    }

    /**
     * SMBファイルのInputStreamを取得する（ストリーミング再生用）。
     */
    suspend fun openFileStream(
        config: SmbConfig,
        filePath: String
    ): InputStream = withContext(Dispatchers.IO) {
        val share = connectionManager.getShare(config)
        val file = share.openFile(
            filePath,
            EnumSet.of(AccessMask.GENERIC_READ),
            null,
            EnumSet.of(SMB2ShareAccess.FILE_SHARE_READ),
            SMB2CreateDisposition.FILE_OPEN,
            null
        )
        file.inputStream
    }

    suspend fun openRandomAccessReader(
        config: SmbConfig,
        filePath: String
    ): SmbRandomAccessReader = withContext(Dispatchers.IO) {
        val share = connectionManager.getShare(config)
        val smbFile = share.openFile(
            filePath,
            EnumSet.of(AccessMask.GENERIC_READ),
            null,
            EnumSet.of(SMB2ShareAccess.FILE_SHARE_READ),
            SMB2CreateDisposition.FILE_OPEN,
            null
        )
        SmbjRandomAccessReader(smbFile)
    }

    /**
     * SMBファイルの情報を取得する。
     */
    suspend fun getFileSize(config: SmbConfig, filePath: String): Long = withContext(Dispatchers.IO) {
        val share = connectionManager.getShare(config)
        val info = share.getFileInformation(filePath)
        info.standardInformation.endOfFile
    }

    /**
     * SmbFileInfoからSongドメインモデルに変換する。
     * メタデータ解析は別途行う必要がある。
     */
    fun toSong(fileInfo: SmbFileInfo, id: Long = 0): Song {
        val nameWithoutExt = fileInfo.name.substringBeforeLast('.')
        // ファイル名から "Artist - Title" パターンを抽出試行
        val parts = nameWithoutExt.split(" - ", limit = 2)
        val (artist, title) = if (parts.size == 2) {
            parts[0].trim() to parts[1].trim()
        } else {
            "Unknown Artist" to nameWithoutExt
        }

        return Song(
            id = id,
            title = title,
            artist = artist,
            album = fileInfo.path.substringBeforeLast('\\').substringAfterLast('\\').ifBlank { "SMB" },
            duration = 0L, // メタデータ解析が必要
            source = MusicSource.SMB,
            smbPath = fileInfo.path,
            smbConfigId = null,
            fileSize = fileInfo.size,
            smbLastWriteTime = fileInfo.lastWriteTime,
            metadataState = SongMetadataState.FALLBACK,
            mimeType = when (fileInfo.extension) {
                "mp3" -> "audio/mpeg"
                "m4a", "aac" -> "audio/mp4"
                "flac" -> "audio/flac"
                "ogg", "opus" -> "audio/ogg"
                "wav" -> "audio/wav"
                "wma" -> "audio/x-ms-wma"
                "aif", "aiff" -> "audio/aiff"
                "ape" -> "audio/x-ape"
                "dsf" -> "audio/dsf"
                "dff" -> "audio/dff"
                "wv" -> "audio/x-wavpack"
                else -> "audio/*"
            }
        )
    }

    suspend fun extractSongMetadata(config: SmbConfig, fileInfo: SmbFileInfo): ScanMetadataResult {
        return metadataExtractor.extractSongMetadata(
            config = config,
            fileInfo = fileInfo,
            openFileStream = ::openFileStream,
            openRandomAccessReader = ::openRandomAccessReader,
            toSong = ::toSong
        )
    }

    private class SmbjRandomAccessReader(
        private val smbFile: SmbjFile
    ) : SmbRandomAccessReader {
        override fun readAt(position: Long, buffer: ByteArray, offset: Int, size: Int): Int {
            return smbFile.read(buffer, position, offset, size)
        }

        override fun close() {
            smbFile.close()
        }
    }
}

/**
 * SMBファイル/ディレクトリの情報。
 */
data class SmbFileInfo(
    val name: String,
    val path: String,
    val isDirectory: Boolean,
    val size: Long = 0L,
    val extension: String = "",
    val lastWriteTime: Long = 0L
)

/**
 * SMBディレクトリのリスティング結果。
 */
data class SmbDirectoryListing(
    val path: String,
    val directories: List<SmbFileInfo>,
    val audioFiles: List<SmbFileInfo>
)
