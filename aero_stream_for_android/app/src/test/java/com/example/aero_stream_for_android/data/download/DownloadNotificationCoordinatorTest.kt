package com.example.aero_stream_for_android.data.download

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class DownloadNotificationCoordinatorTest {
    private val coordinator = DownloadNotificationCoordinator()

    @Test
    fun notificationIdForDownload_generates_stable_and_distinct_ids() {
        val idA = coordinator.notificationIdForDownload(1L)
        val idB = coordinator.notificationIdForDownload(2L)
        val idA2 = coordinator.notificationIdForDownload(1L)

        assertEquals(idA, idA2)
        assertTrue(idA > 0)
        assertTrue(idB > 0)
        assertTrue(idA != idB)
    }

    @Test
    fun computeProgress_returns_indeterminate_when_size_unknown() {
        val progress = coordinator.computeProgress(downloadedBytes = 1024L, fileSize = 0L)

        assertTrue(progress.indeterminate)
        assertEquals(0, progress.max)
        assertEquals(0, progress.current)
    }

    @Test
    fun computeProgress_clamps_between_0_and_100() {
        val normal = coordinator.computeProgress(downloadedBytes = 50L, fileSize = 100L)
        val overflow = coordinator.computeProgress(downloadedBytes = 999L, fileSize = 100L)

        assertFalse(normal.indeterminate)
        assertEquals(100, normal.max)
        assertEquals(50, normal.current)
        assertEquals(100, overflow.current)
    }
}
