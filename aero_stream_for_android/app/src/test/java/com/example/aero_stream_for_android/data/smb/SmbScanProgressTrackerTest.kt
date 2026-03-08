package com.example.aero_stream_for_android.data.smb

import com.example.aero_stream_for_android.data.scan.ScanMetadataResult
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.SongMetadataState
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class SmbScanProgressTrackerTest {

    @Test
    fun tracker_updatesDiscoveryAndStagingCounters() {
        val events = mutableListOf<ScanProgressEvent>()
        val tracker = SmbScanProgressTracker(events::add)

        tracker.onFileDiscovered("share\\a.mp3")
        tracker.onFileDiscovered("share\\b.mp3")
        tracker.markDiscoveryCompleted("share")
        tracker.onExistingRowStaged("share\\a.mp3")
        tracker.onExtractedRowStaged(
            currentPath = "share\\b.mp3",
            result = ScanMetadataResult.Fallback(dummySong.copy(metadataState = SongMetadataState.FALLBACK))
        )

        val discoveryEvent = events.first { it.stage == SmbScanStage.EXTRACTING && it.discoveryCompleted }
        assertEquals(2, discoveryEvent.scannedCount)
        assertEquals(2, discoveryEvent.totalCount)
        assertEquals(0, discoveryEvent.processedCount)
        assertTrue(discoveryEvent.discoveryCompleted)

        val finalEvent = events.last()
        assertEquals(SmbScanStage.STAGING, finalEvent.stage)
        assertEquals(2, finalEvent.processedCount)
        assertEquals(2, finalEvent.stagedCount)
        assertEquals(1, finalEvent.failedCount)
        assertTrue(finalEvent.discoveryCompleted)
    }

    @Test
    fun tracker_marksSkippedDirectoriesWithoutFinishingDiscovery() {
        val events = mutableListOf<ScanProgressEvent>()
        val tracker = SmbScanProgressTracker(events::add)

        tracker.onDirectorySkipped()

        val event = events.last()
        assertEquals(SmbScanStage.LISTING, event.stage)
        assertEquals(1, event.skippedDirectories)
        assertFalse(event.discoveryCompleted)
    }

    private companion object {
        val dummySong = Song(
            id = 1L,
            title = "Track",
            artist = "Artist",
            album = "Album",
            duration = 0L,
            source = MusicSource.SMB,
            smbPath = "share\\b.mp3",
            metadataState = SongMetadataState.UNSCANNED
        )
    }
}
