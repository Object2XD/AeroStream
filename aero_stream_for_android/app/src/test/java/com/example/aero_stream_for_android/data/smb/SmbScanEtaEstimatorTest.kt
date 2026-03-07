package com.example.aero_stream_for_android.data.smb

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class SmbScanEtaEstimatorTest {

    @Test
    fun estimate_returnsProgressAndEta_whenAnalyzingAndCountsAvailable() {
        val result = SmbScanEtaEstimator.estimate(
            stage = SmbScanStage.ANALYZING,
            processedCount = 50,
            totalCount = 100,
            elapsedMillis = 25_000L
        )

        assertEquals(50, result.progressPercent)
        assertEquals(25L, result.estimatedRemainingSec)
    }

    @Test
    fun estimate_returnsNulls_whenStageIsNotAnalyzing() {
        val result = SmbScanEtaEstimator.estimate(
            stage = SmbScanStage.LISTING,
            processedCount = 50,
            totalCount = 100,
            elapsedMillis = 25_000L
        )

        assertNull(result.progressPercent)
        assertNull(result.estimatedRemainingSec)
    }

    @Test
    fun estimate_returnsNulls_whenCountsNotReady() {
        val result = SmbScanEtaEstimator.estimate(
            stage = SmbScanStage.ANALYZING,
            processedCount = 0,
            totalCount = 0,
            elapsedMillis = 25_000L
        )

        assertNull(result.progressPercent)
        assertNull(result.estimatedRemainingSec)
    }

    @Test
    fun formatRemaining_formatsAsHhMmSs() {
        val formatted = SmbScanEtaEstimator.formatRemaining(493L)
        assertEquals("00:08:13", formatted)
    }

    @Test
    fun formatElapsed_formatsAsHhMmSs() {
        val formatted = SmbScanEtaEstimator.formatElapsed(200L)
        assertEquals("00:03:20", formatted)
    }
}
