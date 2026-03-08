package com.example.aero_stream_for_android.data.smb

import android.content.Context
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.work.workDataOf
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

@Singleton
class SmbLibraryScanManager @Inject constructor(
    @ApplicationContext context: Context
) {
    private val workManager = WorkManager.getInstance(context)

    fun observeScanProgress(smbConfigId: String): Flow<SmbScanProgress> =
        workManager.getWorkInfosForUniqueWorkFlow(uniqueWorkName(smbConfigId)).map { infos ->
            val info = infos.firstOrNull() ?: return@map SmbScanProgress(sourceConfigId = smbConfigId)
            info.toScanProgress(smbConfigId)
        }

    suspend fun enqueueScan(smbConfigId: String, quickScan: Boolean = true) {
        val request = OneTimeWorkRequestBuilder<SmbLibraryScanWorker>()
            .setInputData(
                workDataOf(
                    SmbLibraryScanWorker.KEY_SMB_CONFIG_ID to smbConfigId,
                    SmbLibraryScanWorker.KEY_QUICK_SCAN to quickScan
                )
            )
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .addTag(scanTag(smbConfigId))
            .build()

        workManager.enqueueUniqueWork(
            uniqueWorkName(smbConfigId),
            ExistingWorkPolicy.REPLACE,
            request
        )
    }

    suspend fun cancelScan(smbConfigId: String) {
        workManager.cancelUniqueWork(uniqueWorkName(smbConfigId))
    }

    private fun uniqueWorkName(smbConfigId: String) = "smb_scan_$smbConfigId"

    private fun scanTag(smbConfigId: String) = "smb_scan_$smbConfigId"

    private fun WorkInfo.toScanProgress(smbConfigId: String): SmbScanProgress {
        val data = if (state == WorkInfo.State.SUCCEEDED || state == WorkInfo.State.FAILED) {
            outputData
        } else {
            progress
        }
        val stageFromData = data.getString(SmbLibraryScanWorker.KEY_LAST_STAGE)
            ?.let { runCatching { SmbScanStage.valueOf(it) }.getOrNull() }
        val stage = when (state) {
            WorkInfo.State.SUCCEEDED -> SmbScanStage.COMPLETED
            WorkInfo.State.FAILED -> if (stageFromData == SmbScanStage.CANCELLED) {
                SmbScanStage.CANCELLED
            } else {
                SmbScanStage.FAILED
            }
            WorkInfo.State.CANCELLED -> SmbScanStage.CANCELLED
            else -> stageFromData ?: SmbScanStage.IDLE
        }

        return SmbScanProgress(
            isRunning = state == WorkInfo.State.RUNNING || state == WorkInfo.State.ENQUEUED,
            stage = stage,
            elapsedSec = data.getLong(SmbLibraryScanWorker.KEY_ELAPSED_SEC, 0L).coerceAtLeast(0L),
            processedCount = data.getInt(SmbLibraryScanWorker.KEY_PROCESSED_COUNT, 0),
            scannedCount = data.getInt(SmbLibraryScanWorker.KEY_SCANNED_COUNT, 0),
            stagedCount = data.getInt(SmbLibraryScanWorker.KEY_STAGED_COUNT, 0),
            failedCount = data.getInt(SmbLibraryScanWorker.KEY_FAILED_COUNT, 0),
            skippedDirectories = data.getInt(SmbLibraryScanWorker.KEY_SKIPPED_DIRECTORIES, 0),
            totalCount = data.getInt(SmbLibraryScanWorker.KEY_TOTAL_COUNT, 0),
            discoveryCompleted = data.getBoolean(SmbLibraryScanWorker.KEY_DISCOVERY_COMPLETED, false),
            progressPercent = data.getInt(SmbLibraryScanWorker.KEY_PROGRESS_PERCENT, -1)
                .takeIf { it >= 0 },
            estimatedRemainingSec = data.getLong(SmbLibraryScanWorker.KEY_ESTIMATED_REMAINING_SEC, -1L)
                .takeIf { it >= 0L },
            message = data.getString(SmbLibraryScanWorker.KEY_RESULT_MESSAGE).orEmpty(),
            sourceConfigId = smbConfigId
        )
    }
}
