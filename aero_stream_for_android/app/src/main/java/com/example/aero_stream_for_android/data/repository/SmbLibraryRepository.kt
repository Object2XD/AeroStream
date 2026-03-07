package com.example.aero_stream_for_android.data.repository

import android.util.Log
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.remote.smb.SmbMediaDataSource
import com.example.aero_stream_for_android.data.remote.smb.normalizeSmbRootPath
import com.example.aero_stream_for_android.data.smb.ScanProgressEvent
import com.example.aero_stream_for_android.data.smb.SmbLibraryScanManager
import com.example.aero_stream_for_android.data.smb.SmbScanProgress
import com.example.aero_stream_for_android.data.smb.SmbScanStage
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.Artist
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.domain.model.Song
import android.net.Uri
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock

data class RefreshResult(
    val success: Boolean,
    val scannedCount: Int,
    val failedCount: Int,
    val skippedDirectories: Int = 0,
    val message: String
)

@Singleton
class SmbLibraryRepository @Inject constructor(
    private val musicRepository: MusicRepository,
    private val songDao: SongDao,
    private val smbMediaDataSource: SmbMediaDataSource,
    private val scanManager: SmbLibraryScanManager
) {
    companion object {
        private const val TAG = "SmbLibraryRepository"
        private const val INCREMENTAL_BATCH_SIZE = 500
    }

    fun getSongs(smbConfigId: String): Flow<List<Song>> =
        musicRepository.getSongsBySourceAndSmbConfig(MusicSource.SMB, smbConfigId)

    fun getAlbums(smbConfigId: String): Flow<List<Album>> =
        musicRepository.getAlbumsBySourceAndSmbConfig(MusicSource.SMB, smbConfigId)

    fun getArtists(smbConfigId: String): Flow<List<Artist>> =
        musicRepository.getArtistsBySourceAndSmbConfig(MusicSource.SMB, smbConfigId)

    fun getLastRefreshTime(smbConfigId: String): Flow<Long?> =
        songDao.getLastSourceUpdatedAt(MusicSource.SMB.name, smbConfigId)

    fun observeScanProgress(smbConfigId: String): Flow<SmbScanProgress> =
        scanManager.observeScanProgress(smbConfigId)

    suspend fun enqueueScan(smbConfigId: String, quickScan: Boolean = true) {
        scanManager.enqueueScan(smbConfigId, quickScan)
    }

    suspend fun cancelScan(smbConfigId: String) {
        scanManager.cancelScan(smbConfigId)
    }

    suspend fun refreshLibrary(
        config: SmbConfig,
        quickScan: Boolean = true,
        isCancelled: () -> Boolean = { false },
        onProgress: (ScanProgressEvent) -> Unit = {}
    ): RefreshResult {
        return try {
            onProgress(
                ScanProgressEvent(
                    stage = SmbScanStage.CONNECTING
                )
            )

            val rootPath = normalizeSmbRootPath(config.rootPath)

            // クイックスキャン: 既存曲の差分比較用にパス・更新日時等の軽量データを取得
            val existingSyncInfos = if (quickScan) {
                songDao.getSmbSyncInfoList(MusicSource.SMB.name, config.id)
                    .associateBy { it.smbPath }
            } else {
                null
            }

            // フルスキャン時のみスキャン前に旧データを削除
            if (!quickScan) {
                songDao.deleteAllBySourceAndSmbConfig(MusicSource.SMB.name, config.id)
            }

            // インクリメンタル保存用バッファ
            val pendingBatch = mutableListOf<com.example.aero_stream_for_android.data.local.db.entity.SongEntity>()
            val batchMutex = Mutex()
            var totalSaved = 0
            val seenPaths = java.util.concurrent.ConcurrentHashMap.newKeySet<String>()

            val scannedCount = smbMediaDataSource.scanAllMusicAsSongs(
                config = config,
                rootPath = rootPath,
                onProgress = onProgress,
                onSongExtracted = { song, isUnchanged ->
                    val smbPath = song.smbPath
                    if (smbPath != null) {
                        seenPaths.add(smbPath)
                    }

                    if (!isUnchanged) {
                        val toInsert = batchMutex.withLock {
                            val timestamped = song.copy(
                                smbConfigId = config.id,
                                sourceUpdatedAt = System.currentTimeMillis()
                            )
                            pendingBatch.add(timestamped.toEntity())
                            if (pendingBatch.size >= INCREMENTAL_BATCH_SIZE) {
                                val batch = pendingBatch.toList()
                                pendingBatch.clear()
                                batch
                            } else {
                                null
                            }
                        }
                        if (toInsert != null) {
                            songDao.insertSongs(toInsert)
                            totalSaved += toInsert.size
                        }
                    }
                },
                existingSyncInfos = existingSyncInfos,
                getExistingSong = { path ->
                    val entity = songDao.getSongBySmbPath(path)
                    entity?.let {
                        Song(
                            id = it.id,
                            title = it.title,
                            artist = it.artist,
                            albumArtist = it.albumArtist,
                            album = it.album,
                            duration = it.duration,
                            albumArtUri = it.albumArtUri?.let { uri -> android.net.Uri.parse(uri) },
                            source = MusicSource.valueOf(it.source),
                            smbPath = it.smbPath,
                            smbConfigId = it.smbConfigId,
                            smbLibraryBucket = it.smbLibraryBucket,
                            localPath = it.localPath,
                            contentUri = it.contentUri?.let { uri -> android.net.Uri.parse(uri) },
                            trackNumber = it.trackNumber,
                            fileSize = it.fileSize,
                            mimeType = it.mimeType,
                            smbLastWriteTime = it.smbLastWriteTime,
                            isCached = it.isCached,
                            cachedAt = it.cachedAt,
                            cacheLastPlayedAt = it.cacheLastPlayedAt,
                            sourceUpdatedAt = it.sourceUpdatedAt,
                            lastPlayedAt = it.lastPlayedAt,
                            playCount = it.playCount
                        )
                    }
                }
            )

            if (isCancelled()) {
                return RefreshResult(
                    success = false,
                    scannedCount = scannedCount,
                    failedCount = 0,
                    message = "スキャンがキャンセルされました"
                )
            }

            onProgress(
                ScanProgressEvent(
                    stage = SmbScanStage.SAVING,
                    scannedCount = scannedCount
                )
            )

            // 残りのバッチをフラッシュ
            batchMutex.withLock {
                if (pendingBatch.isNotEmpty()) {
                    songDao.insertSongs(pendingBatch)
                    totalSaved += pendingBatch.size
                    pendingBatch.clear()
                }
            }
            
            // クイックスキャン時：存在しなくなったファイルを削除
            if (quickScan && existingSyncInfos != null) {
                val deletedPaths = existingSyncInfos.keys - seenPaths
                if (deletedPaths.isNotEmpty()) {
                    deletedPaths.chunked(900).forEach { chunk ->
                        songDao.deleteSongsBySmbPaths(MusicSource.SMB.name, config.id, chunk)
                    }
                }
            }

            val message = buildString {
                append("${scannedCount}件の曲を解析しました")
            }

            RefreshResult(
                success = true,
                scannedCount = scannedCount,
                failedCount = 0,
                message = message
            )
        } catch (e: Exception) {
            Log.e(TAG, "refreshLibrary failed", e)
            RefreshResult(
                success = false,
                scannedCount = 0,
                failedCount = 0,
                message = e.message ?: "SMB ライブラリの更新に失敗しました"
            )
        }
    }

    /** Song → SongEntity 変換（MusicRepository の private メソッドと同等） */
    private fun Song.toEntity() = com.example.aero_stream_for_android.data.local.db.entity.SongEntity(
        id = id,
        title = title,
        artist = artist,
        albumArtist = albumArtist,
        album = album,
        duration = duration,
        albumArtUri = albumArtUri?.toString(),
        source = source.name,
        smbPath = smbPath,
        smbConfigId = smbConfigId,
        smbLibraryBucket = smbLibraryBucket,
        localPath = localPath,
        contentUri = contentUri?.toString(),
        trackNumber = trackNumber,
        fileSize = fileSize,
        mimeType = mimeType,
        smbLastWriteTime = smbLastWriteTime,
        isCached = isCached,
        cachedAt = cachedAt,
        cacheLastPlayedAt = cacheLastPlayedAt,
        lastPlayedAt = lastPlayedAt,
        playCount = playCount,
        sourceUpdatedAt = sourceUpdatedAt
    )
}
