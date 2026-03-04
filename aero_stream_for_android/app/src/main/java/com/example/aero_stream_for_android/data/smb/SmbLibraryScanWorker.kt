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

        ensureNotificationChannel()
        setForeground(createForegroundInfo(SmbScanStage.CONNECTING, 0, 0))
        setProgress(
            workDataOf(
                KEY_SMB_CONFIG_ID to smbConfigId,
                KEY_LAST_STAGE to SmbScanStage.CONNECTING.name,
                KEY_SCANNED_COUNT to 0,
                KEY_FAILED_COUNT to 0,
                KEY_TOTAL_COUNT to 0,
                KEY_RESULT_MESSAGE to SmbScanStage.CONNECTING.label
            )
        )

        val result = smbLibraryRepository.refreshLibrary(
            config = config,
            quickScan = quickScan,
            isCancelled = { isStopped },
            onProgress = { event ->
                if (isStopped) return@refreshLibrary
                setProgressAsync(
                    workDataOf(
                        KEY_SMB_CONFIG_ID to smbConfigId,
                        KEY_LAST_STAGE to event.stage.name,
                        KEY_SCANNED_COUNT to event.scannedCount,
                        KEY_FAILED_COUNT to event.failedCount,
                        KEY_SKIPPED_DIRECTORIES to event.skippedDirectories,
                        KEY_TOTAL_COUNT to event.totalCount,
                        KEY_RESULT_MESSAGE to buildProgressMessage(event)
                    )
                )
                setForegroundAsync(
                    createForegroundInfo(
                        stage = event.stage,
                        scannedCount = event.scannedCount,
                        failedCount = event.failedCount
                    )
                )
            }
        )

        if (isStopped) {
            return Result.failure(
                workDataOf(
                    KEY_SMB_CONFIG_ID to smbConfigId,
                    KEY_LAST_STAGE to SmbScanStage.CANCELLED.name,
                    KEY_SCANNED_COUNT to 0,
                    KEY_FAILED_COUNT to 0,
                    KEY_SKIPPED_DIRECTORIES to 0,
                    KEY_RESULT_MESSAGE to SmbScanStage.CANCELLED.label
                )
            )
        }

        return if (result.success) {
            Result.success(
                workDataOf(
                    KEY_SMB_CONFIG_ID to smbConfigId,
                    KEY_LAST_STAGE to SmbScanStage.COMPLETED.name,
                    KEY_SCANNED_COUNT to result.scannedCount,
                    KEY_FAILED_COUNT to result.failedCount,
                    KEY_SKIPPED_DIRECTORIES to result.skippedDirectories,
                    KEY_RESULT_MESSAGE to result.message
                )
            )
        } else {
            Result.failure(
                workDataOf(
                    KEY_SMB_CONFIG_ID to smbConfigId,
                    KEY_LAST_STAGE to SmbScanStage.FAILED.name,
                    KEY_SCANNED_COUNT to result.scannedCount,
                    KEY_FAILED_COUNT to result.failedCount,
                    KEY_SKIPPED_DIRECTORIES to result.skippedDirectories,
                    KEY_RESULT_MESSAGE to result.message
                )
            )
        }
    }

    private fun buildProgressMessage(event: ScanProgressEvent): String {
        return buildString {
            append(event.stage.label)
            if (event.stage == SmbScanStage.ANALYZING || event.scannedCount > 0) {
                append(" ${event.scannedCount}件")
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
        scannedCount: Int,
        failedCount: Int
    ): ForegroundInfo {
        val cancelIntent = WorkManager.getInstance(applicationContext).createCancelPendingIntent(id)
        val text = buildString {
            append(stage.label)
            if (stage == SmbScanStage.ANALYZING || scannedCount > 0) {
                append(" ${scannedCount}件")
            }
            if (failedCount > 0) {
                append(" / 失敗 ${failedCount}件")
            }
        }

        val notification = NotificationCompat.Builder(applicationContext, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("SMBライブラリを更新中")
            .setContentText(text)
            .setOngoing(true)
            .setOnlyAlertOnce(true)
            .setProgress(0, 0, true)
            .addAction(0, "キャンセル", cancelIntent)
            .build()

        return ForegroundInfo(
            NOTIFICATION_ID + id.hashCode(),
            notification,
            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
        )
    }
}
