package com.example.aero_stream_for_android.data.smb

import java.util.concurrent.atomic.AtomicInteger

/**
 * SMBスキャン進捗の集計とイベント発火を担当する。
 */
class SmbScanProgressTracker(
    private val onProgress: (ScanProgressEvent) -> Unit
) {
    private val processedCount = AtomicInteger(0)
    private val scannedCount = AtomicInteger(0)
    private val failedCount = AtomicInteger(0)
    private val skippedDirectories = AtomicInteger(0)
    private val totalCount = AtomicInteger(0)

    fun emitListing(currentPath: String?) {
        onProgress(
            ScanProgressEvent(
                stage = SmbScanStage.LISTING,
                processedCount = processedCount.get(),
                scannedCount = scannedCount.get(),
                failedCount = failedCount.get(),
                skippedDirectories = skippedDirectories.get(),
                totalCount = totalCount.get(),
                currentPath = currentPath
            )
        )
    }

    fun addDiscoveredFiles(count: Int) {
        if (count > 0) {
            totalCount.addAndGet(count)
        }
    }

    fun onDirectorySkipped() {
        skippedDirectories.incrementAndGet()
    }

    fun emitAnalyzing(currentPath: String?) {
        onProgress(
            ScanProgressEvent(
                stage = SmbScanStage.ANALYZING,
                processedCount = processedCount.get(),
                scannedCount = scannedCount.get(),
                failedCount = failedCount.get(),
                skippedDirectories = skippedDirectories.get(),
                totalCount = totalCount.get(),
                currentPath = currentPath
            )
        )
    }

    fun onQuickScanHit(currentPath: String?) {
        processedCount.incrementAndGet()
        scannedCount.incrementAndGet()
        emitAnalyzing(currentPath)
    }

    fun onMetadataResult(currentPath: String?, result: MetadataResult) {
        processedCount.incrementAndGet()
        when (result) {
            is MetadataResult.Success -> scannedCount.incrementAndGet()
            is MetadataResult.Fallback -> {
                scannedCount.incrementAndGet()
                failedCount.incrementAndGet()
            }
            MetadataResult.Error -> failedCount.incrementAndGet()
        }
        emitAnalyzing(currentPath)
    }

    fun onProcessingError(currentPath: String?) {
        processedCount.incrementAndGet()
        failedCount.incrementAndGet()
        emitAnalyzing(currentPath)
    }
}
