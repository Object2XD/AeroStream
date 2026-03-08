package com.example.aero_stream_for_android.data.scan

import androidx.work.Data
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkInfo
import com.example.aero_stream_for_android.domain.model.MusicSource
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class LibraryScanManagerTest {
    @Test
    fun hasActiveWork_returnsTrue_whenAnyWorkIsEnqueuedOrRunning() {
        val infos = listOf(
            workInfo(state = WorkInfo.State.SUCCEEDED),
            workInfo(state = WorkInfo.State.RUNNING)
        )

        assertTrue(LibraryScanManager.hasActiveWork(infos))
    }

    @Test
    fun hasActiveWork_returnsFalse_whenAllWorkIsTerminal() {
        val infos = listOf(
            workInfo(state = WorkInfo.State.SUCCEEDED),
            workInfo(state = WorkInfo.State.FAILED),
            workInfo(state = WorkInfo.State.CANCELLED)
        )

        assertFalse(LibraryScanManager.hasActiveWork(infos))
    }

    @Test
    fun shouldKeepExistingScan_isEnabledForSmbOnly() {
        assertTrue(LibraryScanManager.shouldKeepExistingScan(MusicSource.SMB))
        assertFalse(LibraryScanManager.shouldKeepExistingScan(MusicSource.LOCAL))
    }

    private fun workInfo(state: WorkInfo.State): WorkInfo =
        WorkInfo(
            id = OneTimeWorkRequestBuilder<LocalLibraryScanWorker>().build().id,
            state = state,
            outputData = Data.EMPTY,
            tags = emptySet(),
            progress = Data.EMPTY,
            runAttemptCount = 0
        )
}
