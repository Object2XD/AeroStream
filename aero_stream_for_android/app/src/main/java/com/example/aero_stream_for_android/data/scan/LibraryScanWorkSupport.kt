package com.example.aero_stream_for_android.data.scan

import androidx.work.Data
import androidx.work.WorkInfo
import androidx.work.workDataOf
import com.example.aero_stream_for_android.domain.model.MusicSource

object LibraryScanWorkSupport {
    const val TAG_ALL = "library_scan"
    const val KEY_SOURCE = "library_scan_source"
    const val KEY_SOURCE_CONFIG_ID = "library_scan_source_config_id"
    const val KEY_SCANNED_COUNT = "scanned_count"
    const val KEY_FAILED_COUNT = "failed_count"
    const val KEY_SKIPPED_DIRECTORIES = "skipped_directories"
    const val KEY_TOTAL_COUNT = "total_count"
    const val KEY_PROCESSED_COUNT = "processed_count"
    const val KEY_STAGED_COUNT = "staged_count"
    const val KEY_DISCOVERY_COMPLETED = "discovery_completed"
    const val KEY_PROGRESS_PERCENT = "progress_percent"
    const val KEY_ESTIMATED_REMAINING_SEC = "estimated_remaining_sec"
    const val KEY_ELAPSED_SEC = "elapsed_sec"
    const val KEY_RESULT_MESSAGE = "result_message"
    const val KEY_LAST_STAGE = "last_stage"
    const val KEY_QUICK_SCAN = "quick_scan"

    fun uniqueWorkName(source: MusicSource, sourceConfigId: String): String =
        "library_scan_${source.name}_$sourceConfigId"

    fun scanTag(source: MusicSource, sourceConfigId: String): String =
        "library_scan_${source.name}_$sourceConfigId"

    fun initialProgressData(
        source: MusicSource,
        sourceConfigId: String,
        stage: LibraryScanStage
    ): Data = workDataOf(
        KEY_SOURCE to source.name,
        KEY_SOURCE_CONFIG_ID to sourceConfigId,
        KEY_LAST_STAGE to stage.name,
        KEY_ELAPSED_SEC to 0L,
        KEY_PROCESSED_COUNT to 0,
        KEY_SCANNED_COUNT to 0,
        KEY_FAILED_COUNT to 0,
        KEY_TOTAL_COUNT to 0,
        KEY_STAGED_COUNT to 0,
        KEY_DISCOVERY_COMPLETED to false,
        KEY_PROGRESS_PERCENT to -1,
        KEY_ESTIMATED_REMAINING_SEC to -1L,
        KEY_RESULT_MESSAGE to stage.label
    )

    fun progressData(
        source: MusicSource,
        sourceConfigId: String,
        event: ScanProgressEvent,
        elapsedSec: Long,
        eta: LibraryScanEta,
        message: String
    ): Data = workDataOf(
        KEY_SOURCE to source.name,
        KEY_SOURCE_CONFIG_ID to sourceConfigId,
        KEY_LAST_STAGE to event.stage.name,
        KEY_ELAPSED_SEC to elapsedSec,
        KEY_PROCESSED_COUNT to event.processedCount,
        KEY_SCANNED_COUNT to event.scannedCount,
        KEY_FAILED_COUNT to event.failedCount,
        KEY_SKIPPED_DIRECTORIES to event.skippedDirectories,
        KEY_TOTAL_COUNT to event.totalCount,
        KEY_STAGED_COUNT to event.stagedCount,
        KEY_DISCOVERY_COMPLETED to event.discoveryCompleted,
        KEY_PROGRESS_PERCENT to (eta.progressPercent ?: -1),
        KEY_ESTIMATED_REMAINING_SEC to (eta.estimatedRemainingSec ?: -1L),
        KEY_RESULT_MESSAGE to message
    )

    fun terminalResultData(
        source: MusicSource,
        sourceConfigId: String,
        stage: LibraryScanStage,
        elapsedSec: Long,
        processedCount: Int,
        scannedCount: Int,
        failedCount: Int,
        skippedDirectories: Int,
        stagedCount: Int,
        discoveryCompleted: Boolean,
        progressPercent: Int?,
        estimatedRemainingSec: Long?,
        message: String
    ): Data = workDataOf(
        KEY_SOURCE to source.name,
        KEY_SOURCE_CONFIG_ID to sourceConfigId,
        KEY_LAST_STAGE to stage.name,
        KEY_ELAPSED_SEC to elapsedSec,
        KEY_PROCESSED_COUNT to processedCount,
        KEY_SCANNED_COUNT to scannedCount,
        KEY_FAILED_COUNT to failedCount,
        KEY_SKIPPED_DIRECTORIES to skippedDirectories,
        KEY_STAGED_COUNT to stagedCount,
        KEY_TOTAL_COUNT to if (discoveryCompleted) scannedCount.coerceAtLeast(processedCount) else 0,
        KEY_DISCOVERY_COMPLETED to discoveryCompleted,
        KEY_PROGRESS_PERCENT to (progressPercent ?: -1),
        KEY_ESTIMATED_REMAINING_SEC to (estimatedRemainingSec ?: -1L),
        KEY_RESULT_MESSAGE to message
    )

    fun buildProgressMessage(event: ScanProgressEvent): String = buildString {
        append(event.stage.label)
        if (!event.discoveryCompleted) {
            append(" ${event.scannedCount}件")
        } else if (event.totalCount > 0) {
            append(" ${event.processedCount}/${event.totalCount}件")
            val percent = ((event.processedCount * 100.0) / event.totalCount)
                .toInt()
                .coerceIn(0, 100)
            append(" (${percent}%)")
        } else if (event.processedCount > 0) {
            append(" ${event.processedCount}件")
        }
        if (event.failedCount > 0) {
            append(" / 失敗 ${event.failedCount}件")
        }
        if (event.skippedDirectories > 0) {
            append(" / ${event.skippedDirectories}フォルダスキップ")
        }
    }

    fun WorkInfo.toLibraryScanProgress(defaultSourceConfigId: String? = null): LibraryScanProgress {
        val data = if (state == WorkInfo.State.SUCCEEDED || state == WorkInfo.State.FAILED) {
            outputData
        } else {
            progress
        }
        val stageFromData = data.getString(KEY_LAST_STAGE)
            ?.let { runCatching { LibraryScanStage.valueOf(it) }.getOrNull() }
        val stage = when (state) {
            WorkInfo.State.SUCCEEDED -> LibraryScanStage.COMPLETED
            WorkInfo.State.FAILED -> if (stageFromData == LibraryScanStage.CANCELLED) {
                LibraryScanStage.CANCELLED
            } else {
                LibraryScanStage.FAILED
            }
            WorkInfo.State.CANCELLED -> LibraryScanStage.CANCELLED
            else -> stageFromData ?: LibraryScanStage.IDLE
        }
        return LibraryScanProgress(
            isRunning = state == WorkInfo.State.RUNNING || state == WorkInfo.State.ENQUEUED,
            stage = stage,
            elapsedSec = data.getLong(KEY_ELAPSED_SEC, 0L).coerceAtLeast(0L),
            processedCount = data.getInt(KEY_PROCESSED_COUNT, 0),
            scannedCount = data.getInt(KEY_SCANNED_COUNT, 0),
            stagedCount = data.getInt(KEY_STAGED_COUNT, 0),
            failedCount = data.getInt(KEY_FAILED_COUNT, 0),
            skippedDirectories = data.getInt(KEY_SKIPPED_DIRECTORIES, 0),
            totalCount = data.getInt(KEY_TOTAL_COUNT, 0),
            discoveryCompleted = data.getBoolean(KEY_DISCOVERY_COMPLETED, false),
            progressPercent = data.getInt(KEY_PROGRESS_PERCENT, -1).takeIf { it >= 0 },
            estimatedRemainingSec = data.getLong(KEY_ESTIMATED_REMAINING_SEC, -1L).takeIf { it >= 0L },
            message = data.getString(KEY_RESULT_MESSAGE).orEmpty(),
            sourceConfigId = data.getString(KEY_SOURCE_CONFIG_ID) ?: defaultSourceConfigId
        )
    }

    fun WorkInfo.toActiveLibraryScanState(): ActiveLibraryScanState? {
        if (state != WorkInfo.State.RUNNING && state != WorkInfo.State.ENQUEUED) return null
        val (source, sourceConfigIdFromTag) = parseSourceFromTags(tags) ?: return null
        val sourceConfigId = progress.getString(KEY_SOURCE_CONFIG_ID)
            ?: progress.getString(KEY_SOURCE_CONFIG_ID)
            ?: outputData.getString(KEY_SOURCE_CONFIG_ID)
            ?: sourceConfigIdFromTag
        return ActiveLibraryScanState(
            source = source,
            sourceConfigId = sourceConfigId,
            displayName = displayNameFor(source, sourceConfigId),
            progress = toLibraryScanProgress(sourceConfigId)
        )
    }

    private fun parseSourceFromTags(tags: Set<String>): Pair<MusicSource, String>? {
        val scanTag = tags.firstOrNull { it.startsWith("library_scan_") && it != TAG_ALL } ?: return null
        val prefix = "library_scan_"
        val remainder = scanTag.removePrefix(prefix)
        val separatorIndex = remainder.indexOf('_')
        if (separatorIndex <= 0 || separatorIndex >= remainder.lastIndex) return null
        val sourceName = remainder.substring(0, separatorIndex)
        val sourceConfigId = remainder.substring(separatorIndex + 1)
        val source = runCatching { MusicSource.valueOf(sourceName) }.getOrNull() ?: return null
        return source to sourceConfigId
    }

    private fun displayNameFor(source: MusicSource, sourceConfigId: String): String =
        when (source) {
            MusicSource.LOCAL -> "このデバイス"
            MusicSource.SMB -> sourceConfigId
            MusicSource.DOWNLOAD -> sourceConfigId
        }
}
