package com.example.aero_stream_for_android.data.smb

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Context
import android.content.pm.ServiceInfo
import androidx.core.app.NotificationCompat
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import androidx.work.workDataOf
import com.example.aero_stream_for_android.R
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.data.repository.SmbLibraryRepository
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject

@HiltWorker
class SmbLibraryScanWorker @AssistedInject constructor(
    @Assisted appContext: Context,
    @Assisted workerParams: WorkerParameters,
    private val settingsRepository: SettingsRepository,
    private val smbLibraryRepository: SmbLibraryRepository
) : CoroutineWorker(appContext, workerParams) {

    companion object {
        const val KEY_SMB_CONFIG_ID = "smb_config_id"
        const val KEY_SCANNED_COUNT = "scanned_count"
        const val KEY_FAILED_COUNT = "failed_count"
        const val KEY_SKIPPED_DIRECTORIES = "skipped_directories"
        const val KEY_TOTAL_COUNT = "total_count"
        const val KEY_PROCESSED_COUNT = "processed_count"
        const val KEY_PROGRESS_PERCENT = "progress_percent"
        const val KEY_ESTIMATED_REMAINING_SEC = "estimated_remaining_sec"
        const val KEY_ELAPSED_SEC = "elapsed_sec"
        const val KEY_RESULT_MESSAGE = "result_message"
        const val KEY_LAST_STAGE = "last_stage"
        const val KEY_QUICK_SCAN = "quick_scan"

        const val CHANNEL_ID = "smb_library_scan"
        private const val NOTIFICATION_ID = 2002
    }

    override suspend fun doWork(): Result {
        val smbConfigId = inputData.getString(KEY_SMB_CONFIG_ID) ?: return Result.failure()
        val quickScan = inputData.getBoolean(KEY_QUICK_SCAN, true)
        val config = settingsRepository.getSmbConfigById(smbConfigId) ?: return Result.failure()
        val scanStartedAtMs = System.currentTimeMillis()

        ensureNotificationChannel()
        setForeground(
            createForegroundInfo(
                stage = SmbScanStage.CONNECTING,
                elapsedSec = 0L,
                processedCount = 0,
                failedCount = 0,
                totalCount = 0,
                progressPercent = null,
                estimatedRemainingSec = null
            )
        )
        setProgress(
            workDataOf(
                KEY_SMB_CONFIG_ID to smbConfigId,
                KEY_LAST_STAGE to SmbScanStage.CONNECTING.name,
                KEY_ELAPSED_SEC to 0L,
                KEY_PROCESSED_COUNT to 0,
                KEY_SCANNED_COUNT to 0,
                KEY_FAILED_COUNT to 0,
                KEY_TOTAL_COUNT to 0,
                KEY_PROGRESS_PERCENT to -1,
                KEY_ESTIMATED_REMAINING_SEC to -1L,
                KEY_RESULT_MESSAGE to SmbScanStage.CONNECTING.label
            )
        )

        val result = smbLibraryRepository.refreshLibrary(
            config = config,
            quickScan = quickScan,
            isCancelled = { isStopped },
            onProgress = { event ->
                if (isStopped) return@refreshLibrary
                val eta = SmbScanEtaEstimator.estimate(
                    stage = event.stage,
                    processedCount = event.processedCount,
                    totalCount = event.totalCount,
                    elapsedMillis = System.currentTimeMillis() - scanStartedAtMs
                )
                val elapsedSec = ((System.currentTimeMillis() - scanStartedAtMs) / 1000L).coerceAtLeast(0L)
                setProgressAsync(
                    workDataOf(
                        KEY_SMB_CONFIG_ID to smbConfigId,
                        KEY_LAST_STAGE to event.stage.name,
                        KEY_ELAPSED_SEC to elapsedSec,
                        KEY_PROCESSED_COUNT to event.processedCount,
                        KEY_SCANNED_COUNT to event.scannedCount,
                        KEY_FAILED_COUNT to event.failedCount,
                        KEY_SKIPPED_DIRECTORIES to event.skippedDirectories,
                        KEY_TOTAL_COUNT to event.totalCount,
                        KEY_PROGRESS_PERCENT to (eta.progressPercent ?: -1),
                        KEY_ESTIMATED_REMAINING_SEC to (eta.estimatedRemainingSec ?: -1L),
                        KEY_RESULT_MESSAGE to buildProgressMessage(event)
                    )
                )
                setForegroundAsync(
                    createForegroundInfo(
                        stage = event.stage,
                        elapsedSec = elapsedSec,
                        processedCount = event.processedCount,
                        failedCount = event.failedCount,
                        totalCount = event.totalCount,
                        progressPercent = eta.progressPercent,
                        estimatedRemainingSec = eta.estimatedRemainingSec
                    )
                )
            }
        )

        if (isStopped) {
            return Result.failure(
                workDataOf(
                    KEY_SMB_CONFIG_ID to smbConfigId,
                    KEY_LAST_STAGE to SmbScanStage.CANCELLED.name,
                    KEY_ELAPSED_SEC to 0L,
                    KEY_PROCESSED_COUNT to 0,
                    KEY_SCANNED_COUNT to 0,
                    KEY_FAILED_COUNT to 0,
                    KEY_SKIPPED_DIRECTORIES to 0,
                    KEY_PROGRESS_PERCENT to -1,
                    KEY_ESTIMATED_REMAINING_SEC to -1L,
                    KEY_RESULT_MESSAGE to SmbScanStage.CANCELLED.label
                )
            )
        }

        return if (result.success) {
            Result.success(
                workDataOf(
                    KEY_SMB_CONFIG_ID to smbConfigId,
                    KEY_LAST_STAGE to SmbScanStage.COMPLETED.name,
                    KEY_ELAPSED_SEC to ((System.currentTimeMillis() - scanStartedAtMs) / 1000L).coerceAtLeast(0L),
                    KEY_PROCESSED_COUNT to result.scannedCount + result.failedCount,
                    KEY_SCANNED_COUNT to result.scannedCount,
                    KEY_FAILED_COUNT to result.failedCount,
                    KEY_SKIPPED_DIRECTORIES to result.skippedDirectories,
                    KEY_PROGRESS_PERCENT to 100,
                    KEY_ESTIMATED_REMAINING_SEC to 0L,
                    KEY_RESULT_MESSAGE to result.message
                )
            )
        } else {
            Result.failure(
                workDataOf(
                    KEY_SMB_CONFIG_ID to smbConfigId,
                    KEY_LAST_STAGE to SmbScanStage.FAILED.name,
                    KEY_ELAPSED_SEC to ((System.currentTimeMillis() - scanStartedAtMs) / 1000L).coerceAtLeast(0L),
                    KEY_PROCESSED_COUNT to result.scannedCount + result.failedCount,
                    KEY_SCANNED_COUNT to result.scannedCount,
                    KEY_FAILED_COUNT to result.failedCount,
                    KEY_SKIPPED_DIRECTORIES to result.skippedDirectories,
                    KEY_PROGRESS_PERCENT to -1,
                    KEY_ESTIMATED_REMAINING_SEC to -1L,
                    KEY_RESULT_MESSAGE to result.message
                )
            )
        }
    }

    private fun buildProgressMessage(event: ScanProgressEvent): String {
        return buildString {
            append(event.stage.label)
            if (event.totalCount > 0) {
                append(" ${event.processedCount}/${event.totalCount}件")
                val percent = ((event.processedCount * 100.0) / event.totalCount)
                    .toInt()
                    .coerceIn(0, 100)
                append(" (${percent}%)")
            } else if (event.stage == SmbScanStage.ANALYZING || event.processedCount > 0) {
                append(" ${event.processedCount}件")
            }
            if (event.failedCount > 0) {
                append(" / 失敗 ${event.failedCount}件")
            }
            if (event.skippedDirectories > 0) {
                append(" / ${event.skippedDirectories}フォルダスキップ")
            }
        }
    }

    private fun ensureNotificationChannel() {
        val manager = applicationContext.getSystemService(Service.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            "SMBライブラリ更新",
            NotificationManager.IMPORTANCE_LOW
        )
        manager.createNotificationChannel(channel)
    }

    private fun createForegroundInfo(
        stage: SmbScanStage,
        elapsedSec: Long,
        processedCount: Int,
        failedCount: Int,
        totalCount: Int,
        progressPercent: Int?,
        estimatedRemainingSec: Long?
    ): ForegroundInfo {
        val cancelIntent = WorkManager.getInstance(applicationContext).createCancelPendingIntent(id)
        val (line1, line2) = buildNotificationLines(
            stage = stage,
            elapsedSec = elapsedSec,
            processedCount = processedCount,
            failedCount = failedCount,
            totalCount = totalCount,
            progressPercent = progressPercent,
            estimatedRemainingSec = estimatedRemainingSec
        )

        val boundedProcessed = processedCount.coerceAtLeast(0)
        val notification = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("SMBライブラリを更新中")
            .setContentText(line1)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setStyle(
                NotificationCompat.BigTextStyle().bigText(
                    buildString {
                        append(line1)
                        append('\n')
                        append(line2)
                    }
                )
            )
            .setProgress(
                if (totalCount > 0) totalCount else 0,
                if (totalCount > 0) boundedProcessed.coerceAtMost(totalCount) else 0,
                totalCount <= 0
            )
            .addAction(0, "キャンセル", cancelIntent)
            .build()

        return ForegroundInfo(
            NOTIFICATION_ID + id.hashCode(),
            notification,
            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
        )
    }

    private fun buildNotificationLines(
        stage: SmbScanStage,
        elapsedSec: Long,
        processedCount: Int,
        failedCount: Int,
        totalCount: Int,
        progressPercent: Int?,
        estimatedRemainingSec: Long?
    ): Pair<String, String> {
        val line1 = buildString {
            append(stage.label)
            if (totalCount > 0) {
                append(" ${processedCount.coerceAtMost(totalCount)}/${totalCount}件")
                progressPercent?.let { append(" (${it}%)") }
            } else if (stage == SmbScanStage.ANALYZING || processedCount > 0) {
                append(" ${processedCount}件")
            }
            if (failedCount > 0) {
                append(" / 失敗 ${failedCount}件")
            }
        }

        val line2 = buildString {
            append("経過 ${SmbScanEtaEstimator.formatElapsed(elapsedSec)}")
            if (stage == SmbScanStage.ANALYZING) {
                append(" ・ ")
                if (estimatedRemainingSec != null) {
                    append("残り約 ${SmbScanEtaEstimator.formatRemaining(estimatedRemainingSec)}")
                } else {
                    append("残り時間を計算中")
                }
            }
        }
        return line1 to line2
    }
}
