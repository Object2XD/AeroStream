package com.example.aero_stream_for_android.data.scan

import com.example.aero_stream_for_android.data.local.db.entity.SongEntity
import com.example.aero_stream_for_android.data.local.mediastore.LocalMediaDataSource
import com.example.aero_stream_for_android.data.local.mediastore.LocalMediaItem
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.SongMetadataState
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class LocalScanSourceAdapter @Inject constructor(
    private val localMediaDataSource: LocalMediaDataSource
) : LibraryScanSourceAdapter<Unit, LocalMediaItem> {
    companion object {
        const val STATUS_CONFIG_ID = "__LOCAL__"
    }

    override fun target(config: Unit): LibraryScanTarget =
        LibraryScanTarget(
            source = MusicSource.LOCAL,
            publishedConfigId = null,
            statusConfigId = STATUS_CONFIG_ID
        )

    override fun rootDescription(config: Unit): String = "MediaStore"

    override suspend fun enumerateItems(
        config: Unit,
        onItem: suspend (LocalMediaItem) -> Unit,
        onDirectorySkipped: () -> Unit
    ) {
        for (item in localMediaDataSource.queryAudioItems()) {
            onItem(item)
        }
    }

    override fun buildFingerprint(item: LocalMediaItem): ScanItemFingerprint =
        ScanItemFingerprint(
            lookupKey = item.lookupKey,
            fileSize = item.fileSize,
            modifiedAt = item.modifiedAt
        )

    override fun buildFingerprint(entity: SongEntity): ScanItemFingerprint? {
        val lookupKey = entity.localPath ?: entity.contentUri ?: return null
        return ScanItemFingerprint(
            lookupKey = lookupKey,
            fileSize = entity.fileSize,
            modifiedAt = entity.sourceUpdatedAt ?: 0L
        )
    }

    override fun currentPath(item: LocalMediaItem): String = item.lookupKey

    override suspend fun extractMetadata(config: Unit, item: LocalMediaItem): ScanMetadataResult =
        ScanMetadataResult.Success(item.toSong())

    override fun toFallbackRecord(config: Unit, item: LocalMediaItem): Song =
        item.toSong().copy(metadataState = SongMetadataState.FALLBACK)

    override fun mergeWithExisting(
        extractedSong: Song,
        existingEntity: SongEntity?,
        config: Unit,
        item: LocalMediaItem
    ): SongEntity {
        val sourceUpdatedAt = extractedSong.sourceUpdatedAt ?: item.modifiedAt
        return SongEntity(
            id = existingEntity?.id ?: extractedSong.id,
            title = extractedSong.title,
            artist = extractedSong.artist,
            albumArtist = extractedSong.albumArtist,
            album = extractedSong.album,
            duration = extractedSong.duration,
            albumArtUri = extractedSong.albumArtUri?.toString(),
            source = extractedSong.source.name,
            smbPath = null,
            smbConfigId = null,
            smbLibraryBucket = null,
            localPath = extractedSong.localPath,
            contentUri = extractedSong.contentUri?.toString(),
            trackNumber = extractedSong.trackNumber,
            fileSize = extractedSong.fileSize,
            mimeType = extractedSong.mimeType,
            smbLastWriteTime = 0L,
            isCached = false,
            cachedAt = null,
            cacheLastPlayedAt = null,
            metadataState = extractedSong.metadataState.name,
            lastPlayedAt = existingEntity?.lastPlayedAt ?: extractedSong.lastPlayedAt,
            playCount = existingEntity?.playCount ?: extractedSong.playCount,
            sourceUpdatedAt = sourceUpdatedAt,
            addedAt = existingEntity?.addedAt ?: System.currentTimeMillis()
        )
    }
}
