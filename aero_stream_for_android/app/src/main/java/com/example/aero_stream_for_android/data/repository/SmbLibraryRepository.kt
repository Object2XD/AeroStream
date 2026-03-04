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
        private const val INCREMENTAL_BATCH_SIZE = 20
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

            // クイックスキャン: 既存曲をメモリにロードして変更検知に使用
            val existingSongsMap: Map<String, Song>? = if (quickScan) {
                val entities = songDao.getSongsBySourceAndSmbConfigList(MusicSource.SMB.name, config.id)
                if (entities.isEmpty()) {
                    null // DBが空ならフルスキャンと同じ
                } else {
                    entities.mapNotNull { entity ->
                        val smbPath = entity.smbPath ?: return@mapNotNull null
                        smbPath to Song(
                            id = entity.id,
                            title = entity.title,
                            artist = entity.artist,
                            albumArtist = entity.albumArtist,
                            album = entity.album,
                            duration = entity.duration,
                            albumArtUri = entity.albumArtUri?.let { Uri.parse(it) },
                            source = MusicSource.valueOf(entity.source),
                            smbPath = entity.smbPath,
                            smbConfigId = entity.smbConfigId,
                            smbLibraryBucket = entity.smbLibraryBucket,
                            localPath = entity.localPath,
                            contentUri = entity.contentUri?.let { Uri.parse(it) },
                            trackNumber = entity.trackNumber,
                            fileSize = entity.fileSize,
                            mimeType = entity.mimeType,
                            smbLastWriteTime = entity.smbLastWriteTime,
                            sourceUpdatedAt = entity.sourceUpdatedAt,
                            lastPlayedAt = entity.lastPlayedAt,
                            playCount = entity.playCount
                        )
                    }.toMap()
                }
            } else {
                null
            }

            // スキャン前に旧データを削除
            songDao.deleteAllBySourceAndSmbConfig(MusicSource.SMB.name, config.id)

            // インクリメンタル保存用バッファ
            val pendingBatch = mutableListOf<Song>()
            val batchMutex = Mutex()
            var totalSaved = 0

            val songs = smbMediaDataSource.scanAllMusicAsSongs(
                config = config,
                rootPath = rootPath,
                onProgress = onProgress,
                onSongExtracted = { song ->
                    val toInsert = batchMutex.withLock {
                        val timestamped = song.copy(
                            smbConfigId = config.id,
                            sourceUpdatedAt = System.currentTimeMillis()
                        )
                        pendingBatch.add(timestamped)
                        if (pendingBatch.size >= INCREMENTAL_BATCH_SIZE) {
                            val batch = pendingBatch.toList()
                            pendingBatch.clear()
                            batch
                        } else {
                            null
                        }
                    }
                    if (toInsert != null) {
                        songDao.insertSongs(toInsert.map { it.toEntity() })
                        totalSaved += toInsert.size
                    }
                },
                existingSongsMap = existingSongsMap
            )

            if (isCancelled()) {
                return RefreshResult(
                    success = false,
                    scannedCount = songs.size,
                    failedCount = 0,
                    message = "スキャンがキャンセルされました"
                )
            }

            onProgress(
                ScanProgressEvent(
                    stage = SmbScanStage.SAVING,
                    scannedCount = songs.size
                )
            )

            // 残りのバッチをフラッシュ
            batchMutex.withLock {
                if (pendingBatch.isNotEmpty()) {
                    songDao.insertSongs(pendingBatch.map { it.toEntity() })
                    totalSaved += pendingBatch.size
                    pendingBatch.clear()
                }
            }

            val message = buildString {
                append("${songs.size}件の曲を解析しました")
            }

            RefreshResult(
                success = true,
                scannedCount = songs.size,
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
        lastPlayedAt = lastPlayedAt,
        playCount = playCount,
        sourceUpdatedAt = sourceUpdatedAt
    )
}
