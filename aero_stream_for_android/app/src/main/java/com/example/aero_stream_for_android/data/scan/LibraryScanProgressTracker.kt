package com.example.aero_stream_for_android.data.scan

import java.util.concurrent.atomic.AtomicInteger

class LibraryScanProgressTracker(
    private val onProgress: (ScanProgressEvent) -> Unit
) {
    private val scannedCount = AtomicInteger(0)
    private val stagedCount = AtomicInteger(0)
    private val failedCount = AtomicInteger(0)
    private val skippedDirectories = AtomicInteger(0)
    private val totalCount = AtomicInteger(0)

    @Volatile
    private var discoveryCompleted = false

    fun emit(stage: LibraryScanStage, currentPath: String?) {
        onProgress(
            ScanProgressEvent(
                stage = stage,
                processedCount = stagedCount.get(),
                scannedCount = scannedCount.get(),
                stagedCount = stagedCount.get(),
                failedCount = failedCount.get(),
                skippedDirectories = skippedDirectories.get(),
                totalCount = totalCount.get(),
                discoveryCompleted = discoveryCompleted,
                currentPath = currentPath
            )
        )
    }

    fun emitListing(currentPath: String?) = emit(LibraryScanStage.LISTING, currentPath)

    fun emitExtracting(currentPath: String?) = emit(LibraryScanStage.EXTRACTING, currentPath)

    fun emitStaging(currentPath: String?) = emit(LibraryScanStage.STAGING, currentPath)

    fun emitCommitting(currentPath: String? = null) = emit(LibraryScanStage.COMMITTING, currentPath)

    fun onFileDiscovered(currentPath: String?) {
        scannedCount.incrementAndGet()
        totalCount.incrementAndGet()
        emitListing(currentPath)
    }

    fun onDirectorySkipped() {
        skippedDirectories.incrementAndGet()
        emitListing(null)
    }

    fun markDiscoveryCompleted(currentPath: String? = null) {
        discoveryCompleted = true
        emit(LibraryScanStage.EXTRACTING, currentPath)
    }

    fun onExistingRowStaged(currentPath: String?) {
        stagedCount.incrementAndGet()
        emitStaging(currentPath)
    }

    fun onMetadataResult(currentPath: String?, result: ScanMetadataResult) {
        when (result) {
            is ScanMetadataResult.Success -> Unit
            is ScanMetadataResult.Fallback -> failedCount.incrementAndGet()
            ScanMetadataResult.Error -> failedCount.incrementAndGet()
        }
        emitExtracting(currentPath)
    }

    fun onExtractedRowStaged(currentPath: String?, result: ScanMetadataResult) {
        onMetadataResult(currentPath, result)
        stagedCount.incrementAndGet()
        emitStaging(currentPath)
    }

    fun scannedCount(): Int = scannedCount.get()

    fun stagedCount(): Int = stagedCount.get()

    fun failedCount(): Int = failedCount.get()

    fun skippedDirectories(): Int = skippedDirectories.get()
}
