package com.example.aero_stream_for_android.data.scan

import com.example.aero_stream_for_android.data.local.db.entity.SongEntity
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song

data class LibraryScanTarget(
    val source: MusicSource,
    val publishedConfigId: String? = null,
    val statusConfigId: String
)

data class ScanItemFingerprint(
    val lookupKey: String,
    val fileSize: Long = 0L,
    val modifiedAt: Long = 0L
)

data class ExistingSongSnapshot(
    val entity: SongEntity,
    val fingerprint: ScanItemFingerprint
)

interface LibraryScanSourceAdapter<TConfig, TItem> {
    fun target(config: TConfig): LibraryScanTarget

    fun rootDescription(config: TConfig): String? = null

    suspend fun enumerateItems(
        config: TConfig,
        onItem: suspend (TItem) -> Unit,
        onDirectorySkipped: () -> Unit = {}
    )

    fun buildFingerprint(item: TItem): ScanItemFingerprint

    fun buildFingerprint(entity: SongEntity): ScanItemFingerprint?

    fun currentPath(item: TItem): String? = buildFingerprint(item).lookupKey

    suspend fun extractMetadata(config: TConfig, item: TItem): ScanMetadataResult

    fun toFallbackRecord(config: TConfig, item: TItem): Song

    fun mergeWithExisting(
        extractedSong: Song,
        existingEntity: SongEntity?,
        config: TConfig,
        item: TItem
    ): SongEntity
}
