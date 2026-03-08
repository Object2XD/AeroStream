package com.example.aero_stream_for_android.data.smb

import android.content.Context
import android.util.Log
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.ForegroundInfo
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.work.WorkerParameters
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.data.repository.SmbLibraryRepository
import com.example.aero_stream_for_android.data.scan.ActiveLibraryScanState
import com.example.aero_stream_for_android.data.scan.LibraryScanEta
import com.example.aero_stream_for_android.data.scan.LibraryScanEtaEstimator
import com.example.aero_stream_for_android.data.scan.LibraryScanProgress
import com.example.aero_stream_for_android.data.scan.LibraryScanSupervisor
import com.example.aero_stream_for_android.data.scan.LibraryScanNotificationCoordinator
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.KEY_QUICK_SCAN
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.KEY_SOURCE_CONFIG_ID
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.buildProgressMessage
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.initialProgressData
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.progressData
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.terminalResultData
import com.example.aero_stream_for_android.domain.model.MusicSource
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject

@HiltWorker
class SmbLibraryScanWorker @AssistedInject constructor(
    @Assisted appContext: Context,
    @Assisted workerParams: WorkerParameters,
    private val settingsRepository: SettingsRepository,
    private val smbLibraryRepository: SmbLibraryRepository,
    private val scanSupervisor: LibraryScanSupervisor,
    private val notificationCoordinator: LibraryScanNotificationCoordinator
) : CoroutineWorker(appContext, workerParams) {
    companion object {
        private const val TAG = "SmbLibraryScanWorker"
    }

    override suspend fun doWork(): Result {
        val smbConfigId = inputData.getString(KEY_SOURCE_CONFIG_ID) ?: return Result.failure()
        val quickScan = inputData.getBoolean(KEY_QUICK_SCAN, true)
        val config = settingsRepository.getSmbConfigById(smbConfigId) ?: return Result.failure()
        val scanStartedAtMs = System.currentTimeMillis()
        Log.i(
            TAG,
            "Starting SMB scan: configId=$smbConfigId quickScan=$quickScan runAttemptCount=$runAttemptCount"
        )

        val initialProgress = LibraryScanProgress(
            isRunning = true,
            stage = SmbScanStage.CONNECTING,
            sourceConfigId = smbConfigId
        )
        setForeground(createForegroundInfo(config.displayName, smbConfigId, initialProgress))

        scanSupervisor.register(
            source = MusicSource.SMB,
            sourceConfigId = smbConfigId,
            displayName = config.displayName,
            progress = initialProgress
        )
        setProgress(initialProgressData(MusicSource.SMB, smbConfigId, SmbScanStage.CONNECTING))

        val result = try {
            smbLibraryRepository.refreshLibrary(
                config = config,
                quickScan = quickScan,
                isCancelled = { isStopped },
                onProgress = { event ->
                    if (isStopped) return@refreshLibrary
                    val eta = if (event.discoveryCompleted) {
                        LibraryScanEtaEstimator.estimate(
                            stage = event.stage,
                            processedCount = event.processedCount,
                            totalCount = event.totalCount,
                            elapsedMillis = System.currentTimeMillis() - scanStartedAtMs
                        )
                    } else {
                        LibraryScanEta(
                            progressPercent = null,
                            estimatedRemainingSec = null
                        )
                    }
                    val elapsedSec = ((System.currentTimeMillis() - scanStartedAtMs) / 1000L).coerceAtLeast(0L)
                    val message = buildProgressMessage(event)
                    val progress = LibraryScanProgress(
                        isRunning = true,
                        stage = event.stage,
                        elapsedSec = elapsedSec,
                        processedCount = event.processedCount,
                        scannedCount = event.scannedCount,
                        stagedCount = event.stagedCount,
                        failedCount = event.failedCount,
                        skippedDirectories = event.skippedDirectories,
                        totalCount = event.totalCount,
                        discoveryCompleted = event.discoveryCompleted,
                        progressPercent = eta.progressPercent,
                        estimatedRemainingSec = eta.estimatedRemainingSec,
                        message = message,
                        sourceConfigId = smbConfigId
                    )
                    setProgressAsync(
                        progressData(
                            source = MusicSource.SMB,
                            sourceConfigId = smbConfigId,
                            event = event,
                            elapsedSec = elapsedSec,
                            eta = eta,
                            message = message
                        )
                    )
                    setForegroundAsync(
                        createForegroundInfo(
                            displayName = config.displayName,
                            smbConfigId = smbConfigId,
                            progress = progress
                        )
                    )
                    scanSupervisor.update(
                        source = MusicSource.SMB,
                        sourceConfigId = smbConfigId,
                        displayName = config.displayName,
                        progress = progress
                    )
                }
            )
        } finally {
            scanSupervisor.complete(MusicSource.SMB, smbConfigId)
            Log.i(
                TAG,
                "Finished SMB scan: configId=$smbConfigId isStopped=$isStopped stopReason=${stopReasonLabel(stopReason)} runAttemptCount=$runAttemptCount"
            )
        }

        if (isStopped) {
            return Result.failure(
                terminalResultData(
                    source = MusicSource.SMB,
                    sourceConfigId = smbConfigId,
                    stage = SmbScanStage.CANCELLED,
                    elapsedSec = 0L,
                    processedCount = 0,
                    scannedCount = 0,
                    failedCount = 0,
                    skippedDirectories = 0,
                    stagedCount = 0,
                    discoveryCompleted = false,
                    progressPercent = null,
                    estimatedRemainingSec = null,
                    message = SmbScanStage.CANCELLED.label
                )
            )
        }

        val elapsedSec = ((System.currentTimeMillis() - scanStartedAtMs) / 1000L).coerceAtLeast(0L)
        return if (result.success) {
            Result.success(
                terminalResultData(
                    source = MusicSource.SMB,
                    sourceConfigId = smbConfigId,
                    stage = SmbScanStage.COMPLETED,
                    elapsedSec = elapsedSec,
                    processedCount = result.stagedCount,
                    scannedCount = result.scannedCount,
                    failedCount = result.failedCount,
                    skippedDirectories = result.skippedDirectories,
                    stagedCount = result.stagedCount,
                    discoveryCompleted = true,
                    progressPercent = 100,
                    estimatedRemainingSec = 0L,
                    message = result.message
                )
            )
        } else {
            Result.failure(
                terminalResultData(
                    source = MusicSource.SMB,
                    sourceConfigId = smbConfigId,
                    stage = SmbScanStage.FAILED,
                    elapsedSec = elapsedSec,
                    processedCount = result.stagedCount,
                    scannedCount = result.scannedCount,
                    failedCount = result.failedCount,
                    skippedDirectories = result.skippedDirectories,
                    stagedCount = result.stagedCount,
                    discoveryCompleted = true,
                    progressPercent = null,
                    estimatedRemainingSec = null,
                    message = result.message
                )
            )
        }
    }

    override suspend fun getForegroundInfo(): ForegroundInfo {
        val smbConfigId = inputData.getString(KEY_SOURCE_CONFIG_ID).orEmpty()
        val displayName = settingsRepository.getSmbConfigById(smbConfigId)?.displayName ?: smbConfigId
        return createForegroundInfo(
            displayName = displayName,
            smbConfigId = smbConfigId,
            progress = LibraryScanProgress(
                isRunning = true,
                stage = SmbScanStage.CONNECTING,
                sourceConfigId = smbConfigId
            )
        )
    }

    private fun createForegroundInfo(
        displayName: String,
        smbConfigId: String,
        progress: LibraryScanProgress
    ): ForegroundInfo {
        val cancelIntent = WorkManager.getInstance(applicationContext).createCancelPendingIntent(id)
        return notificationCoordinator.buildForegroundInfo(
            context = applicationContext,
            activeState = ActiveLibraryScanState(
                source = MusicSource.SMB,
                sourceConfigId = smbConfigId,
                displayName = displayName,
                progress = progress
            ),
            cancelIntent = cancelIntent
        )
    }

    private fun stopReasonLabel(reason: Int): String = when (reason) {
        WorkInfo.STOP_REASON_APP_STANDBY -> "app_standby"
        WorkInfo.STOP_REASON_BACKGROUND_RESTRICTION -> "background_restriction"
        WorkInfo.STOP_REASON_CANCELLED_BY_APP -> "cancelled_by_app"
        WorkInfo.STOP_REASON_CONSTRAINT_BATTERY_NOT_LOW -> "constraint_battery_not_low"
        WorkInfo.STOP_REASON_CONSTRAINT_CHARGING -> "constraint_charging"
        WorkInfo.STOP_REASON_CONSTRAINT_CONNECTIVITY -> "constraint_connectivity"
        WorkInfo.STOP_REASON_CONSTRAINT_DEVICE_IDLE -> "constraint_device_idle"
        WorkInfo.STOP_REASON_CONSTRAINT_STORAGE_NOT_LOW -> "constraint_storage_not_low"
        WorkInfo.STOP_REASON_DEVICE_STATE -> "device_state"
        WorkInfo.STOP_REASON_ESTIMATED_APP_LAUNCH_TIME_CHANGED -> "estimated_app_launch_time_changed"
        WorkInfo.STOP_REASON_PREEMPT -> "preempt"
        WorkInfo.STOP_REASON_QUOTA -> "quota"
        WorkInfo.STOP_REASON_SYSTEM_PROCESSING -> "system_processing"
        WorkInfo.STOP_REASON_TIMEOUT -> "timeout"
        WorkInfo.STOP_REASON_UNKNOWN -> "unknown"
        else -> "reason_$reason"
    }
}
