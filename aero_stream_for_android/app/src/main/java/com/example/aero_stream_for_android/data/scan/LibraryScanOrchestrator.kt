package com.example.aero_stream_for_android.data.scan

import android.util.Log
import androidx.room.withTransaction
import com.example.aero_stream_for_android.data.local.db.AeroDatabase
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStagingDao
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStatusDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.local.db.entity.LibraryScanStagingSongEntity
import com.example.aero_stream_for_android.data.local.db.entity.LibraryScanStatusEntity
import com.example.aero_stream_for_android.data.local.db.entity.SongEntity
import com.example.aero_stream_for_android.domain.model.Song
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.CancellationException
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.joinAll
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

data class RefreshResult(
    val success: Boolean,
    val scannedCount: Int,
    val failedCount: Int,
    val stagedCount: Int,
    val skippedDirectories: Int = 0,
    val message: String
)

private data class MetaTask<TItem>(
    val item: TItem,
    val existingEntity: SongEntity?
)

private data class DbWriterResult(
    val stagedCount: Int
)

private sealed interface ScanWriteCommand {
    data class StageExisting(
        val entity: SongEntity,
        val currentPath: String?
    ) : ScanWriteCommand

    data class StageExtracted(
        val entity: SongEntity,
        val currentPath: String?,
        val result: ScanMetadataResult
    ) : ScanWriteCommand

    data class MetadataFailed(
        val currentPath: String?,
        val result: ScanMetadataResult
    ) : ScanWriteCommand

    data object FinalizeCommit : ScanWriteCommand
}

@Singleton
class LibraryScanOrchestrator @Inject constructor(
    private val database: AeroDatabase,
    private val songDao: SongDao,
    private val stagingDao: LibraryScanStagingDao,
    private val statusDao: LibraryScanStatusDao
) {
    companion object {
        private const val TAG = "LibraryScanOrchestrator"
        private const val INCREMENTAL_BATCH_SIZE = 100
        private const val FILE_TO_META_QUEUE_CAPACITY = 128
        private const val META_TO_DB_QUEUE_CAPACITY = 128
        private const val META_WORKER_COUNT = 8
    }

    suspend fun <TConfig, TItem> refresh(
        config: TConfig,
        adapter: LibraryScanSourceAdapter<TConfig, TItem>,
        quickScan: Boolean = true,
        isCancelled: () -> Boolean = { false },
        onProgress: (ScanProgressEvent) -> Unit = {}
    ): RefreshResult = withContext(Dispatchers.IO) {
        val startedAt = System.currentTimeMillis()
        val scanSessionId = UUID.randomUUID().toString()
        val target = adapter.target(config)
        val previousStatus = statusDao.getStatus(target.source.name, target.statusConfigId)
        val progressTracker = LibraryScanProgressTracker(onProgress)

        suspend fun markRunning() {
            statusDao.upsert(
                LibraryScanStatusEntity(
                    sourceType = target.source.name,
                    sourceConfigId = target.statusConfigId,
                    lastStartedAt = startedAt,
                    lastSuccessfulScanAt = previousStatus?.lastSuccessfulScanAt,
                    lastCompletedAt = previousStatus?.lastCompletedAt,
                    lastResult = LibraryStoredScanResult.RUNNING.name,
                    lastMessage = LibraryScanStage.CONNECTING.label
                )
            )
        }

        suspend fun markTerminal(result: LibraryStoredScanResult, message: String) {
            statusDao.upsert(
                LibraryScanStatusEntity(
                    sourceType = target.source.name,
                    sourceConfigId = target.statusConfigId,
                    lastStartedAt = startedAt,
                    lastSuccessfulScanAt = previousStatus?.lastSuccessfulScanAt,
                    lastCompletedAt = System.currentTimeMillis(),
                    lastResult = result.name,
                    lastMessage = message
                )
            )
        }

        try {
            ensureNotCancelled(isCancelled)
            markRunning()
            stagingDao.deleteBySourceConfig(target.source.name, target.statusConfigId)
            onProgress(ScanProgressEvent(stage = LibraryScanStage.CONNECTING))

            val existingSongs = loadExistingSongs(target)
            val existingByKey = existingSongs.mapNotNull { entity ->
                adapter.buildFingerprint(entity)?.let { fingerprint ->
                    fingerprint.lookupKey to ExistingSongSnapshot(entity, fingerprint)
                }
            }.toMap()

            val metaQueue = Channel<MetaTask<TItem>>(capacity = FILE_TO_META_QUEUE_CAPACITY)
            val dbQueue = Channel<ScanWriteCommand>(capacity = META_TO_DB_QUEUE_CAPACITY)
            val dbResult = CompletableDeferred<DbWriterResult>()

            coroutineScope {
                val dbJob = launch {
                    try {
                        dbResult.complete(
                            runDbWriter(
                                scanSessionId = scanSessionId,
                                target = target,
                                startedAt = startedAt,
                                previousStatus = previousStatus,
                                progressTracker = progressTracker,
                                dbQueue = dbQueue,
                                publishIncrementally = quickScan
                            )
                        )
                    } catch (t: Throwable) {
                        if (!dbResult.isCompleted) {
                            dbResult.completeExceptionally(t)
                        }
                        throw t
                    }
                }

                val metaJobs = List(META_WORKER_COUNT) {
                    launch {
                        runMetaWorker(
                            config = config,
                            adapter = adapter,
                            metaQueue = metaQueue,
                            dbQueue = dbQueue,
                            isCancelled = isCancelled
                        )
                    }
                }

                try {
                    runFileScanWorker(
                        config = config,
                        adapter = adapter,
                        quickScan = quickScan,
                        existingByKey = existingByKey,
                        progressTracker = progressTracker,
                        metaQueue = metaQueue,
                        dbQueue = dbQueue,
                        isCancelled = isCancelled
                    )
                } finally {
                    metaQueue.close()
                }

                metaJobs.joinAll()
                ensureNotCancelled(isCancelled)
                dbQueue.send(ScanWriteCommand.FinalizeCommit)
                dbQueue.close()
                dbJob.join()
            }

            val writerResult = dbResult.await()
            val message = buildSummaryMessage(progressTracker)
            RefreshResult(
                success = true,
                scannedCount = progressTracker.scannedCount(),
                failedCount = progressTracker.failedCount(),
                stagedCount = writerResult.stagedCount,
                skippedDirectories = progressTracker.skippedDirectories(),
                message = message
            )
        } catch (e: CancellationException) {
            markTerminal(LibraryStoredScanResult.CANCELLED, LibraryScanStage.CANCELLED.label)
            RefreshResult(
                success = false,
                scannedCount = progressTracker.scannedCount(),
                failedCount = progressTracker.failedCount(),
                stagedCount = 0,
                skippedDirectories = progressTracker.skippedDirectories(),
                message = "スキャンがキャンセルされました"
            )
        } catch (e: Exception) {
            Log.e(TAG, "refresh failed", e)
            markTerminal(
                LibraryStoredScanResult.FAILED,
                e.message ?: "ライブラリの更新に失敗しました"
            )
            RefreshResult(
                success = false,
                scannedCount = progressTracker.scannedCount(),
                failedCount = progressTracker.failedCount(),
                stagedCount = 0,
                skippedDirectories = progressTracker.skippedDirectories(),
                message = e.message ?: "ライブラリの更新に失敗しました"
            )
        }
    }

    private suspend fun <TConfig, TItem> runFileScanWorker(
        config: TConfig,
        adapter: LibraryScanSourceAdapter<TConfig, TItem>,
        quickScan: Boolean,
        existingByKey: Map<String, ExistingSongSnapshot>,
        progressTracker: LibraryScanProgressTracker,
        metaQueue: Channel<MetaTask<TItem>>,
        dbQueue: Channel<ScanWriteCommand>,
        isCancelled: () -> Boolean
    ) {
        progressTracker.emitListing(adapter.rootDescription(config))
        adapter.enumerateItems(
            config = config,
            onItem = { item ->
                ensureNotCancelled(isCancelled)
                val fingerprint = adapter.buildFingerprint(item)
                val existing = existingByKey[fingerprint.lookupKey]
                progressTracker.onFileDiscovered(adapter.currentPath(item))
                if (quickScan && existing != null && existing.fingerprint == fingerprint && fingerprint.modifiedAt > 0L) {
                    dbQueue.send(
                        ScanWriteCommand.StageExisting(
                            entity = existing.entity,
                            currentPath = adapter.currentPath(item)
                        )
                    )
                } else {
                    metaQueue.send(MetaTask(item = item, existingEntity = existing?.entity))
                }
            },
            onDirectorySkipped = progressTracker::onDirectorySkipped
        )
        progressTracker.markDiscoveryCompleted(adapter.rootDescription(config))
    }

    private suspend fun <TConfig, TItem> runMetaWorker(
        config: TConfig,
        adapter: LibraryScanSourceAdapter<TConfig, TItem>,
        metaQueue: Channel<MetaTask<TItem>>,
        dbQueue: Channel<ScanWriteCommand>,
        isCancelled: () -> Boolean
    ) {
        for (task in metaQueue) {
            ensureNotCancelled(isCancelled)
            when (val extracted = adapter.extractMetadata(config, task.item)) {
                is ScanMetadataResult.Success -> {
                    val finalEntity = adapter.mergeWithExisting(
                        extractedSong = extracted.song,
                        existingEntity = task.existingEntity,
                        config = config,
                        item = task.item
                    )
                    dbQueue.send(
                        ScanWriteCommand.StageExtracted(
                            entity = finalEntity,
                            currentPath = adapter.currentPath(task.item),
                            result = extracted
                        )
                    )
                }

                is ScanMetadataResult.Fallback,
                ScanMetadataResult.Error -> {
                    dbQueue.send(
                        ScanWriteCommand.MetadataFailed(
                            currentPath = adapter.currentPath(task.item),
                            result = extracted
                        )
                    )
                }
            }
        }
    }

    private suspend fun runDbWriter(
        scanSessionId: String,
        target: LibraryScanTarget,
        startedAt: Long,
        previousStatus: LibraryScanStatusEntity?,
        progressTracker: LibraryScanProgressTracker,
        dbQueue: Channel<ScanWriteCommand>,
        publishIncrementally: Boolean
    ): DbWriterResult {
        val pendingBatch = mutableListOf<LibraryScanStagingSongEntity>()

        suspend fun flushPending(publish: Boolean) {
            if (pendingBatch.isEmpty()) return
            stagingDao.insertSongs(pendingBatch.toList())
            pendingBatch.clear()
            if (publish) {
                publishStagedSongs(scanSessionId, target)
            }
        }

        for (command in dbQueue) {
            when (command) {
                is ScanWriteCommand.StageExisting -> {
                    pendingBatch.add(command.entity.toStaging(scanSessionId, target))
                    progressTracker.onExistingRowStaged(command.currentPath)
                    if (publishIncrementally && pendingBatch.size >= INCREMENTAL_BATCH_SIZE) {
                        flushPending(publish = true)
                    }
                }

                is ScanWriteCommand.StageExtracted -> {
                    pendingBatch.add(command.entity.toStaging(scanSessionId, target))
                    progressTracker.onExtractedRowStaged(command.currentPath, command.result)
                    if (publishIncrementally && pendingBatch.size >= INCREMENTAL_BATCH_SIZE) {
                        flushPending(publish = true)
                    }
                }

                is ScanWriteCommand.MetadataFailed -> {
                    progressTracker.onMetadataResult(command.currentPath, command.result)
                }

                ScanWriteCommand.FinalizeCommit -> {
                    flushPending(publish = false)
                    progressTracker.emitCommitting()
                    val committedAt = System.currentTimeMillis()
                    var committedCount = 0
                    database.withTransaction {
                        val stagedSongs = stagingDao.getSongsBySession(scanSessionId)
                        replacePublishedSongs(target, stagedSongs.map { it.toSongEntity() })
                        committedCount = stagedSongs.size
                        statusDao.upsert(
                            LibraryScanStatusEntity(
                                sourceType = target.source.name,
                                sourceConfigId = target.statusConfigId,
                                lastStartedAt = startedAt,
                                lastSuccessfulScanAt = committedAt,
                                lastCompletedAt = committedAt,
                                lastResult = LibraryStoredScanResult.COMPLETED.name,
                                lastMessage = buildSummaryMessage(progressTracker)
                            )
                        )
                        stagingDao.deleteBySession(scanSessionId)
                    }
                    return DbWriterResult(stagedCount = committedCount)
                }
            }
        }

        statusDao.upsert(
            LibraryScanStatusEntity(
                sourceType = target.source.name,
                sourceConfigId = target.statusConfigId,
                lastStartedAt = startedAt,
                lastSuccessfulScanAt = previousStatus?.lastSuccessfulScanAt,
                lastCompletedAt = previousStatus?.lastCompletedAt,
                lastResult = LibraryStoredScanResult.FAILED.name,
                lastMessage = "DB writer closed without a finalize command"
            )
        )
        throw IllegalStateException("DB writer closed without a finalize command")
    }

    private suspend fun loadExistingSongs(target: LibraryScanTarget): List<SongEntity> {
        return if (target.publishedConfigId == null) {
            songDao.getSongsBySourceList(target.source.name)
        } else {
            songDao.getSongsBySourceAndSmbConfigList(target.source.name, target.publishedConfigId)
        }
    }

    private suspend fun replacePublishedSongs(
        target: LibraryScanTarget,
        songs: List<SongEntity>
    ) {
        if (target.publishedConfigId == null) {
            songDao.deleteAllBySource(target.source.name)
        } else {
            songDao.deleteAllBySourceAndSmbConfig(target.source.name, target.publishedConfigId)
        }
        songDao.insertSongs(songs)
    }

    private suspend fun publishStagedSongs(
        scanSessionId: String,
        target: LibraryScanTarget
    ) {
        val stagedSongs = stagingDao.getSongsBySession(scanSessionId)
        replacePublishedSongs(target, stagedSongs.map { it.toSongEntity() })
    }

    private fun buildSummaryMessage(progressTracker: LibraryScanProgressTracker): String {
        return buildString {
            append("${progressTracker.scannedCount()}件の曲を解析しました")
            if (progressTracker.failedCount() > 0) {
                append(" / 失敗 ${progressTracker.failedCount()}件")
            }
        }
    }

    private fun SongEntity.toStaging(
        scanSessionId: String,
        target: LibraryScanTarget
    ): LibraryScanStagingSongEntity = LibraryScanStagingSongEntity(
        scanSessionId = scanSessionId,
        scanSource = target.source.name,
        scanSourceConfigId = target.statusConfigId,
        songId = id,
        title = title,
        artist = artist,
        albumArtist = albumArtist,
        album = album,
        duration = duration,
        albumArtUri = albumArtUri,
        source = source,
        smbPath = smbPath,
        smbConfigId = smbConfigId,
        smbLibraryBucket = smbLibraryBucket,
        localPath = localPath,
        contentUri = contentUri,
        trackNumber = trackNumber,
        fileSize = fileSize,
        mimeType = mimeType,
        smbLastWriteTime = smbLastWriteTime,
        isCached = isCached,
        cachedAt = cachedAt,
        cacheLastPlayedAt = cacheLastPlayedAt,
        sourceUpdatedAt = sourceUpdatedAt,
        metadataState = metadataState,
        lastPlayedAt = lastPlayedAt,
        playCount = playCount,
        addedAt = addedAt
    )

    private fun LibraryScanStagingSongEntity.toSongEntity(): SongEntity = SongEntity(
        id = songId,
        title = title,
        artist = artist,
        albumArtist = albumArtist,
        album = album,
        duration = duration,
        albumArtUri = albumArtUri,
        source = source,
        smbPath = smbPath,
        smbConfigId = smbConfigId,
        smbLibraryBucket = smbLibraryBucket,
        localPath = localPath,
        contentUri = contentUri,
        trackNumber = trackNumber,
        fileSize = fileSize,
        mimeType = mimeType,
        smbLastWriteTime = smbLastWriteTime,
        isCached = isCached,
        cachedAt = cachedAt,
        cacheLastPlayedAt = cacheLastPlayedAt,
        metadataState = metadataState,
        lastPlayedAt = lastPlayedAt,
        playCount = playCount,
        sourceUpdatedAt = sourceUpdatedAt,
        addedAt = addedAt
    )

    private fun ensureNotCancelled(isCancelled: () -> Boolean) {
        if (isCancelled()) {
            throw CancellationException("Library scan cancelled")
        }
    }
}
