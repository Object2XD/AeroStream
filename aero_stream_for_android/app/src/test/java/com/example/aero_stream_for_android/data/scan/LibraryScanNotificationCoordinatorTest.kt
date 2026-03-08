package com.example.aero_stream_for_android.data.scan

import com.example.aero_stream_for_android.domain.model.MusicSource
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class LibraryScanNotificationCoordinatorTest {
    private val coordinator = LibraryScanNotificationCoordinator()

    @Test
    fun aggregate_sums_counts_across_active_scans() {
        val aggregated = coordinator.aggregate(
            listOf(
                activeState(
                    source = MusicSource.SMB,
                    displayName = "NAS A",
                    stage = LibraryScanStage.EXTRACTING,
                    processedCount = 40,
                    scannedCount = 50,
                    totalCount = 80,
                    failedCount = 1,
                    skippedDirectories = 2,
                    discoveryCompleted = true,
                    estimatedRemainingSec = 20L
                ),
                activeState(
                    source = MusicSource.LOCAL,
                    displayName = "Device",
                    stage = LibraryScanStage.LISTING,
                    processedCount = 10,
                    scannedCount = 30,
                    totalCount = 0,
                    failedCount = 0,
                    skippedDirectories = 0,
                    discoveryCompleted = false,
                    estimatedRemainingSec = null
                )
            )
        )!!

        assertEquals(2, aggregated.activeCount)
        assertEquals(80, aggregated.totalCountKnownSum)
        assertEquals(50, aggregated.processedCountTotal)
        assertEquals(80, aggregated.scannedCountTotal)
        assertEquals(1, aggregated.failedCountTotal)
        assertEquals(2, aggregated.skippedDirectoriesTotal)
        assertTrue(aggregated.hasUnknownTotal)
        assertNull(aggregated.estimatedRemainingSecMax)
    }

    @Test
    fun aggregate_keeps_determinate_only_when_all_totals_known() {
        val aggregated = coordinator.aggregate(
            listOf(
                activeState(
                    source = MusicSource.SMB,
                    displayName = "NAS A",
                    stage = LibraryScanStage.STAGING,
                    processedCount = 20,
                    scannedCount = 24,
                    totalCount = 30,
                    discoveryCompleted = true,
                    estimatedRemainingSec = 10L
                ),
                activeState(
                    source = MusicSource.SMB,
                    displayName = "NAS B",
                    stage = LibraryScanStage.COMMITTING,
                    processedCount = 5,
                    scannedCount = 5,
                    totalCount = 5,
                    discoveryCompleted = true,
                    estimatedRemainingSec = 1L
                )
            )
        )!!

        assertFalse(aggregated.hasUnknownTotal)
        assertEquals(35, aggregated.totalCountKnownSum)
        assertEquals(25, aggregated.processedCountTotal)
        assertEquals(10L, aggregated.estimatedRemainingSecMax)
        assertEquals(29, aggregated.scannedCountTotal)
    }

    private fun activeState(
        source: MusicSource,
        displayName: String,
        stage: LibraryScanStage,
        processedCount: Int,
        scannedCount: Int,
        totalCount: Int,
        failedCount: Int = 0,
        skippedDirectories: Int = 0,
        discoveryCompleted: Boolean,
        estimatedRemainingSec: Long?
    ) = ActiveLibraryScanState(
        source = source,
        sourceConfigId = "$source:$displayName",
        displayName = displayName,
        progress = LibraryScanProgress(
            isRunning = true,
            stage = stage,
            elapsedSec = 12L,
            processedCount = processedCount,
            scannedCount = scannedCount,
            failedCount = failedCount,
            skippedDirectories = skippedDirectories,
            totalCount = totalCount,
            discoveryCompleted = discoveryCompleted,
            estimatedRemainingSec = estimatedRemainingSec
        )
    )
}
