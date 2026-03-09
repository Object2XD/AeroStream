package com.example.aero_stream_for_android.data.download

import android.content.Context
import androidx.work.ExistingWorkPolicy
import androidx.work.Operation
import androidx.work.OneTimeWorkRequest
import com.example.aero_stream_for_android.data.local.db.dao.DownloadDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.local.db.entity.DownloadEntity
import com.example.aero_stream_for_android.data.local.db.entity.DownloadState
import com.example.aero_stream_for_android.domain.model.SmbConfig
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class DownloadManagerTest {
    private val context: Context = mockk(relaxed = true)
    private val downloadDao: DownloadDao = mockk(relaxed = true)
    private val songDao: SongDao = mockk(relaxed = true)
    private val smbConfigResolver: SmbConfigResolver = mockk()
    private val workManager: androidx.work.WorkManager = mockk(relaxed = true)
    private val resolvedConfig = SmbConfig(
        id = "cfg",
        hostname = "host",
        shareName = "share"
    )

    @Before
    fun setUp() {
        every {
            workManager.enqueueUniqueWork(any(), any(), any<OneTimeWorkRequest>())
        } returns mockk<Operation>(relaxed = true)
        every { workManager.cancelAllWorkByTag(any()) } returns mockk<Operation>(relaxed = true)
        coEvery {
            smbConfigResolver.resolveForDownloadStart(any(), any())
        } returns SmbConfigResolutionResult.Resolved(resolvedConfig)
    }

    @Test
    fun startDownload_failedEntry_deletesOldAndStartsNew() = kotlinx.coroutines.test.runTest {
        val existing = DownloadEntity(
            id = 1L,
            songId = 10L,
            smbPath = "dir\\song.mp3",
            smbConfigId = "cfg",
            state = DownloadState.FAILED
        )
        coEvery { downloadDao.getDownloadBySmbPathAndConfigId("dir\\song.mp3", "cfg") } returns existing
        coEvery { downloadDao.getLegacyDownloadBySmbPath(any()) } returns null
        coEvery { downloadDao.insertDownload(any()) } returns 2L

        val manager = DownloadManager(context, downloadDao, songDao, smbConfigResolver, workManager)
        val result = manager.startDownload(10L, "dir\\song.mp3", "cfg")

        assertTrue(result is DownloadStartResult.Started)
        assertEquals(true, (result as DownloadStartResult.Started).retriedFromFailure)
        coVerify(exactly = 1) { downloadDao.deleteDownload(existing) }
        verify(exactly = 1) { workManager.cancelAllWorkByTag("download_1") }
        verify(exactly = 1) {
            workManager.enqueueUniqueWork(
                match { it.startsWith("download_work_cfg_") },
                ExistingWorkPolicy.KEEP,
                any<OneTimeWorkRequest>()
            )
        }
    }

    @Test
    fun startDownload_pendingEntry_skipsAsActive() = kotlinx.coroutines.test.runTest {
        coEvery { downloadDao.getDownloadBySmbPathAndConfigId("dir\\song.mp3", "cfg") } returns DownloadEntity(
            id = 7L,
            songId = 10L,
            smbPath = "dir\\song.mp3",
            smbConfigId = "cfg",
            state = DownloadState.PENDING
        )
        coEvery { downloadDao.getLegacyDownloadBySmbPath(any()) } returns null

        val manager = DownloadManager(context, downloadDao, songDao, smbConfigResolver, workManager)
        val result = manager.startDownload(10L, "dir\\song.mp3", "cfg")

        assertEquals(DownloadStartResult.SkippedActive(existingDownloadId = 7L), result)
        coVerify(exactly = 0) { downloadDao.insertDownload(any()) }
        verify(exactly = 0) { workManager.enqueueUniqueWork(any(), any(), any<OneTimeWorkRequest>()) }
    }

    @Test
    fun startDownload_completedEntry_returnsAlreadyCompleted() = kotlinx.coroutines.test.runTest {
        coEvery { downloadDao.getDownloadBySmbPathAndConfigId("dir\\song.mp3", "cfg") } returns DownloadEntity(
            id = 9L,
            songId = 10L,
            smbPath = "dir\\song.mp3",
            smbConfigId = "cfg",
            state = DownloadState.COMPLETED
        )
        coEvery { downloadDao.getLegacyDownloadBySmbPath(any()) } returns null

        val manager = DownloadManager(context, downloadDao, songDao, smbConfigResolver, workManager)
        val result = manager.startDownload(10L, "dir\\song.mp3", "cfg")

        assertEquals(DownloadStartResult.AlreadyCompleted(existingDownloadId = 9L), result)
        coVerify(exactly = 0) { downloadDao.insertDownload(any()) }
        verify(exactly = 0) { workManager.enqueueUniqueWork(any(), any(), any<OneTimeWorkRequest>()) }
    }

    @Test
    fun startDownload_configResolutionFailed_doesNotEnqueue() = kotlinx.coroutines.test.runTest {
        coEvery {
            smbConfigResolver.resolveForDownloadStart(10L, null)
        } returns SmbConfigResolutionResult.Failed("SMB設定IDを特定できません")

        val manager = DownloadManager(context, downloadDao, songDao, smbConfigResolver, workManager)
        val result = manager.startDownload(10L, "dir\\song.mp3", null)

        assertEquals(
            DownloadStartResult.ConfigResolutionFailed("SMB設定IDを特定できません"),
            result
        )
        coVerify(exactly = 0) { downloadDao.insertDownload(any()) }
        verify(exactly = 0) { workManager.enqueueUniqueWork(any(), any(), any<OneTimeWorkRequest>()) }
    }
}
