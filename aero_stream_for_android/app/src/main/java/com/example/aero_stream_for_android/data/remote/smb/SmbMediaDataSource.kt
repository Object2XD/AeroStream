package com.example.aero_stream_for_android.data.remote.smb

import android.content.Context
import android.util.Log
import dagger.hilt.android.qualifiers.ApplicationContext
import com.example.aero_stream_for_android.data.smb.BucketScanResult
import com.example.aero_stream_for_android.data.smb.MetadataResult
import com.example.aero_stream_for_android.data.smb.ScanAccumulator
import com.example.aero_stream_for_android.data.smb.ScanProgressEvent
import com.example.aero_stream_for_android.data.smb.SmbScanStage
import com.example.aero_stream_for_android.data.smb.SmbScanProgressTracker
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.domain.model.Song
import com.hierynomus.msdtyp.AccessMask
import com.hierynomus.mssmb2.SMB2CreateDisposition
import com.hierynomus.mssmb2.SMB2ShareAccess
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
import java.util.concurrent.ConcurrentLinkedQueue
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

    /**
     * ディレクトリ探索とメタデータ抽出をパイプラインで並列実行する。
     * - Producer: ディレクトリを再帰的に探索し、見つかったファイルをChannelに送信
     * - Consumer: Semaphore(4) で最大4並列でメタデータを抽出
     */
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

        val fileChannel = Channel<SmbFileInfo>(capacity = Channel.BUFFERED)
        var totalScannedCount = 0
        val processingSemaphore = Semaphore(4)
        val listingSemaphore = Semaphore(8) // ディレクトリ探索の並列数を制限

        coroutineScope {
            // Producer: ディレクトリ探索 → Channel
            launch {
                try {
                    scanRecursiveToChannel(
                        config,
                        normalizeSmbRootPath(rootPath),
                        fileChannel,
                        progressTracker,
                        listingSemaphore
                    )
                } finally {
                    fileChannel.close()
                }
            }

            // Consumer: Channel からファイルを受信し、並列でメタデータ抽出(現在はパスのみ)
            launch {
                for (fileInfo in fileChannel) {
                    ensureActive()
                    launch {
                        processingSemaphore.withPermit {
                            try {
                                val existingSyncInfo = existingSyncInfos?.get(fileInfo.path)
                                val isUnchanged = existingSyncInfo != null
                                    && existingSyncInfo.fileSize == fileInfo.size
                                    && existingSyncInfo.smbLastWriteTime == fileInfo.lastWriteTime
                                    && fileInfo.lastWriteTime > 0L

                                if (isUnchanged) {
                                    progressTracker.onQuickScanHit(currentPath = fileInfo.path)
                                    // 変更なしの場合はDB更新をスキップするためフラグを渡す。
                                    // 実際のSongオブジェクト全体は必要ないが、最低限のID等のためにgetExistingSongを呼ぶか、ダミーを返す。
                                    // ここではダミーを返し、Repository側で無視させる。
                                    val dummySong = toSong(fileInfo).copy(smbConfigId = config.id)
                                    synchronized(this@SmbMediaDataSource) { totalScannedCount++ }
                                    onSongExtracted(dummySong, true)
                                    return@withPermit
                                }

                                progressTracker.emitAnalyzing(currentPath = fileInfo.path)

                                // メタデータ抽出の通信オーバーヘッドを避けるため、ファイル名から推測した基本情報のみを初期値とする
                                val newSong = toSong(fileInfo).copy(
                                    smbConfigId = config.id,
                                    sourceUpdatedAt = System.currentTimeMillis()
                                )

                                // 既存ファイルが更新された場合は、IDや再生履歴を引き継ぐ
                                val finalSong = if (existingSyncInfo != null) {
                                    val existingSong = getExistingSong(fileInfo.path)
                                    if (existingSong != null) {
                                        newSong.copy(
                                            id = existingSong.id,
                                            isCached = existingSong.isCached,
                                            cachedAt = existingSong.cachedAt,
                                            cacheLastPlayedAt = existingSong.cacheLastPlayedAt,
                                            lastPlayedAt = existingSong.lastPlayedAt,
                                            playCount = existingSong.playCount,
                                            title = if (existingSong.title != newSong.title && existingSong.title.isNotBlank()) existingSong.title else newSong.title,
                                            artist = if (existingSong.artist != newSong.artist && existingSong.artist.isNotBlank()) existingSong.artist else newSong.artist,
                                            albumArtist = existingSong.albumArtist.takeIf { it.isNotBlank() } ?: newSong.albumArtist,
                                            album = if (existingSong.album != newSong.album && existingSong.album.isNotBlank()) existingSong.album else newSong.album,
                                            duration = existingSong.duration,
                                            trackNumber = existingSong.trackNumber,
                                            albumArtUri = existingSong.albumArtUri
                                        )
                                    } else newSong
                                } else {
                                    newSong
                                }

                                synchronized(this@SmbMediaDataSource) { totalScannedCount++ }
                                onSongExtracted(finalSong, false)
                                progressTracker.onMetadataResult(currentPath = fileInfo.path, result = MetadataResult.Success(finalSong))
                            } catch (e: CancellationException) {
                                throw e
                            } catch (e: Exception) {
                                progressTracker.onProcessingError(currentPath = fileInfo.path)
                                Log.w(TAG, "Unexpected error processing ${fileInfo.path}", e)
                            }
                        }
                    }
                }
            }
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
        channel: Channel<SmbFileInfo>,
        progressTracker: SmbScanProgressTracker,
        semaphore: Semaphore
    ) {
        try {
            currentCoroutineContext().ensureActive()
            val listing = listDirectoryWithRetry(config, path)
            progressTracker.addDiscoveredFiles(listing.audioFiles.size)
            for (file in listing.audioFiles) {
                channel.send(file)
            }
            coroutineScope {
                for (dir in listing.directories) {
                    launch {
                        semaphore.withPermit {
                            scanRecursiveToChannel(config, dir.path, channel, progressTracker, semaphore)
                        }
                    }
                }
            }
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            progressTracker.onDirectorySkipped()
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
                        stage = SmbScanStage.ANALYZING,
                        scannedCount = accumulator.results.size,
                        failedCount = accumulator.failedCount,
                        skippedDirectories = accumulator.skippedDirectories,
                        currentPath = file.path
                    )
                )
                when (val result = MetadataResult.Success(toSong(file).copy(smbConfigId = config.id, sourceUpdatedAt = System.currentTimeMillis()))) {
                    is MetadataResult.Success -> {
                        accumulator.results.add(result.song.copy(smbLibraryBucket = bucketId))
                    }
                    else -> {}
                }
            }
            coroutineScope {
                listing.directories.forEach { directory ->
                    launch {
                        scanSongsRecursive(config, bucketId, directory.path, accumulator, onProgress)
                    }
                }
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
    private suspend fun listDirectoryWithRetry(
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

    private suspend fun extractSongMetadata(config: SmbConfig, fileInfo: SmbFileInfo): MetadataResult {
        return metadataExtractor.extractSongMetadata(
            config = config,
            fileInfo = fileInfo,
            openFileStream = ::openFileStream,
            toSong = ::toSong
        )
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
