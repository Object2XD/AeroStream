package com.example.aero_stream_for_android.data.scan

import android.content.Context
import androidx.hilt.work.HiltWorker
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import androidx.work.workDataOf
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
class LocalLibraryScanWorker @AssistedInject constructor(
    @Assisted appContext: Context,
    @Assisted workerParams: WorkerParameters,
    private val orchestrator: LibraryScanOrchestrator,
    private val localScanSourceAdapter: LocalScanSourceAdapter,
    private val scanSupervisor: LibraryScanSupervisor
) : CoroutineWorker(appContext, workerParams) {
    override suspend fun doWork(): Result {
        val sourceConfigId = inputData.getString(KEY_SOURCE_CONFIG_ID)
            ?: LocalScanSourceAdapter.STATUS_CONFIG_ID
        val scanStartedAtMs = System.currentTimeMillis()

        scanSupervisor.register(
            source = MusicSource.LOCAL,
            sourceConfigId = sourceConfigId,
            displayName = "このデバイス",
            progress = LibraryScanProgress(
                isRunning = true,
                stage = LibraryScanStage.CONNECTING,
                sourceConfigId = sourceConfigId
            )
        )
        setProgress(initialProgressData(MusicSource.LOCAL, sourceConfigId, LibraryScanStage.CONNECTING))

        val result = try {
            orchestrator.refresh(
                config = Unit,
                adapter = localScanSourceAdapter,
                quickScan = inputData.getBoolean(KEY_QUICK_SCAN, false),
                isCancelled = { isStopped },
                onProgress = { event ->
                    if (isStopped) return@refresh
                    val eta = if (event.discoveryCompleted) {
                        LibraryScanEtaEstimator.estimate(
                            stage = event.stage,
                            processedCount = event.processedCount,
                            totalCount = event.totalCount,
                            elapsedMillis = System.currentTimeMillis() - scanStartedAtMs
                        )
                    } else {
                        LibraryScanEta(progressPercent = null, estimatedRemainingSec = null)
                    }
                    val elapsedSec = ((System.currentTimeMillis() - scanStartedAtMs) / 1000L).coerceAtLeast(0L)
                    val message = buildProgressMessage(event)
                    setProgressAsync(
                        progressData(
                            source = MusicSource.LOCAL,
                            sourceConfigId = sourceConfigId,
                            event = event,
                            elapsedSec = elapsedSec,
                            eta = eta,
                            message = message
                        )
                    )
                    scanSupervisor.update(
                        source = MusicSource.LOCAL,
                        sourceConfigId = sourceConfigId,
                        displayName = "このデバイス",
                        progress = LibraryScanProgress(
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
                            sourceConfigId = sourceConfigId
                        )
                    )
                }
            )
        } finally {
            scanSupervisor.complete(MusicSource.LOCAL, sourceConfigId)
        }

        if (isStopped) {
            return Result.failure(
                terminalResultData(
                    source = MusicSource.LOCAL,
                    sourceConfigId = sourceConfigId,
                    stage = LibraryScanStage.CANCELLED,
                    elapsedSec = 0L,
                    processedCount = 0,
                    scannedCount = 0,
                    failedCount = 0,
                    skippedDirectories = 0,
                    stagedCount = 0,
                    discoveryCompleted = false,
                    progressPercent = null,
                    estimatedRemainingSec = null,
                    message = LibraryScanStage.CANCELLED.label
                )
            )
        }

        val elapsedSec = ((System.currentTimeMillis() - scanStartedAtMs) / 1000L).coerceAtLeast(0L)
        return if (result.success) {
            Result.success(
                terminalResultData(
                    source = MusicSource.LOCAL,
                    sourceConfigId = sourceConfigId,
                    stage = LibraryScanStage.COMPLETED,
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
                    source = MusicSource.LOCAL,
                    sourceConfigId = sourceConfigId,
                    stage = LibraryScanStage.FAILED,
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
}
