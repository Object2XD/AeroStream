package com.example.aero_stream_for_android.data.scan

import com.example.aero_stream_for_android.data.local.db.entity.SongEntity
import com.example.aero_stream_for_android.data.remote.smb.SmbFileInfo
import com.example.aero_stream_for_android.data.remote.smb.SmbMediaDataSource
import com.example.aero_stream_for_android.data.remote.smb.deriveSmbLibraryBucket
import com.example.aero_stream_for_android.data.remote.smb.normalizeSmbRootPath
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.SongMetadataState
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SmbScanSourceAdapter @Inject constructor(
    private val smbMediaDataSource: SmbMediaDataSource
) : LibraryScanSourceAdapter<SmbConfig, SmbFileInfo> {
    override fun target(config: SmbConfig): LibraryScanTarget =
        LibraryScanTarget(
            source = MusicSource.SMB,
            publishedConfigId = config.id,
            statusConfigId = config.id
        )

    override fun rootDescription(config: SmbConfig): String = normalizeSmbRootPath(config.rootPath)

    override suspend fun enumerateItems(
        config: SmbConfig,
        onItem: suspend (SmbFileInfo) -> Unit,
        onDirectorySkipped: () -> Unit
    ) {
        val rootPath = normalizeSmbRootPath(config.rootPath)
        val pendingDirectories = ArrayDeque<String>()
        pendingDirectories.add(rootPath)

        while (pendingDirectories.isNotEmpty()) {
            val currentPath = pendingDirectories.removeFirst()
            val listing = try {
                smbMediaDataSource.listDirectoryWithRetry(config, currentPath)
            } catch (e: Exception) {
                if (currentPath == rootPath) throw e
                onDirectorySkipped()
                continue
            }

            listing.directories.forEach { directory ->
                pendingDirectories.addLast(directory.path)
            }
            listing.audioFiles.forEach { fileInfo ->
                onItem(fileInfo)
            }
        }
    }

    override fun buildFingerprint(item: SmbFileInfo): ScanItemFingerprint =
        ScanItemFingerprint(
            lookupKey = item.path,
            fileSize = item.size,
            modifiedAt = item.lastWriteTime
        )

    override fun buildFingerprint(entity: SongEntity): ScanItemFingerprint? {
        val path = entity.smbPath ?: return null
        return ScanItemFingerprint(
            lookupKey = path,
            fileSize = entity.fileSize,
            modifiedAt = entity.smbLastWriteTime
        )
    }

    override fun currentPath(item: SmbFileInfo): String = item.path

    override suspend fun extractMetadata(config: SmbConfig, item: SmbFileInfo): ScanMetadataResult {
        return when (val result = smbMediaDataSource.extractSongMetadata(config, item)) {
            is ScanMetadataResult.Success -> result
            is ScanMetadataResult.Fallback -> result
            ScanMetadataResult.Error -> ScanMetadataResult.Error
        }
    }

    override fun toFallbackRecord(config: SmbConfig, item: SmbFileInfo): Song {
        val rootPath = normalizeSmbRootPath(config.rootPath)
        return smbMediaDataSource.toSong(item).copy(
            smbConfigId = config.id,
            smbLibraryBucket = deriveSmbLibraryBucket(rootPath, item.path),
            sourceUpdatedAt = System.currentTimeMillis(),
            metadataState = SongMetadataState.FALLBACK
        )
    }

    override fun mergeWithExisting(
        extractedSong: Song,
        existingEntity: SongEntity?,
        config: SmbConfig,
        item: SmbFileInfo
    ): SongEntity {
        val rootPath = normalizeSmbRootPath(config.rootPath)
        val sourceUpdatedAt = extractedSong.sourceUpdatedAt ?: System.currentTimeMillis()
        return SongEntity(
            id = existingEntity?.id ?: extractedSong.id,
            title = extractedSong.title,
            artist = extractedSong.artist,
            albumArtist = extractedSong.albumArtist,
            album = extractedSong.album,
            duration = extractedSong.duration,
            albumArtUri = extractedSong.albumArtUri?.toString(),
            source = extractedSong.source.name,
            smbPath = extractedSong.smbPath,
            smbConfigId = config.id,
            smbLibraryBucket = deriveSmbLibraryBucket(rootPath, item.path),
            localPath = existingEntity?.localPath,
            contentUri = extractedSong.contentUri?.toString(),
            trackNumber = extractedSong.trackNumber,
            fileSize = extractedSong.fileSize,
            mimeType = extractedSong.mimeType,
            smbLastWriteTime = extractedSong.smbLastWriteTime,
            isCached = existingEntity?.isCached ?: extractedSong.isCached,
            cachedAt = existingEntity?.cachedAt ?: extractedSong.cachedAt,
            cacheLastPlayedAt = existingEntity?.cacheLastPlayedAt ?: extractedSong.cacheLastPlayedAt,
            metadataState = extractedSong.metadataState.name,
            lastPlayedAt = existingEntity?.lastPlayedAt ?: extractedSong.lastPlayedAt,
            playCount = existingEntity?.playCount ?: extractedSong.playCount,
            sourceUpdatedAt = sourceUpdatedAt,
            addedAt = existingEntity?.addedAt ?: System.currentTimeMillis()
        )
    }
}
