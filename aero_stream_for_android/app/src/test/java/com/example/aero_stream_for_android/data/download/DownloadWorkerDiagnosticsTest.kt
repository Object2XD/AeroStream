package com.example.aero_stream_for_android.data.download

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class DownloadWorkerDiagnosticsTest {

    @Test
    fun buildFailureSummary_messageNull_isNotEmptyAndContainsStage() {
        val ex = IllegalStateException(null as String?)

        val summary = DownloadWorkerDiagnostics.buildFailureSummary(ex, "open-file")

        assertTrue(summary.isNotBlank())
        assertTrue(summary.startsWith("open-file:"))
    }

    @Test
    fun rootCauseOf_returnsDeepestCause() {
        val root = IllegalArgumentException("root")
        val wrapped = RuntimeException("mid", root)
        val top = IllegalStateException("top", wrapped)

        val resolved = DownloadWorkerDiagnostics.rootCauseOf(top)

        assertEquals(root, resolved)
    }

    @Test
    fun buildFailureSummary_isLengthCapped() {
        val longMessage = "x".repeat(500)
        val ex = RuntimeException(longMessage)

        val summary = DownloadWorkerDiagnostics.buildFailureSummary(ex, "stream-copy")

        assertTrue(summary.length <= 180)
    }

    @Test
    fun shouldEmitProgressLog_emitsOnFivePercentOrOneMib() {
        val byPercent = DownloadWorkerDiagnostics.shouldEmitProgressLog(
            downloadedBytes = 5L * 1024L * 1024L,
            fileSize = 100L * 1024L * 1024L,
            lastLoggedPercent = 0,
            lastLoggedMib = 4L
        )
        val byMib = DownloadWorkerDiagnostics.shouldEmitProgressLog(
            downloadedBytes = 6L * 1024L * 1024L,
            fileSize = 0L,
            lastLoggedPercent = 0,
            lastLoggedMib = 5L
        )
        val noEmit = DownloadWorkerDiagnostics.shouldEmitProgressLog(
            downloadedBytes = 4L * 1024L * 1024L,
            fileSize = 100L * 1024L * 1024L,
            lastLoggedPercent = 4,
            lastLoggedMib = 4L
        )

        assertTrue(byPercent)
        assertTrue(byMib)
        assertFalse(noEmit)
    }
}
