package com.example.aero_stream_for_android.data.reset

import android.content.Context
import com.example.aero_stream_for_android.data.download.DownloadManager
import com.example.aero_stream_for_android.data.local.db.AeroDatabase
import com.example.aero_stream_for_android.data.local.db.dao.DownloadDao
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStagingDao
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStatusDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.scan.LibraryScanManager
import io.mockk.coEvery
import io.mockk.coVerifyOrder
import io.mockk.every
import io.mockk.mockk
import io.mockk.verifyOrder
import java.io.File
import java.nio.file.Files
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertFalse
import org.junit.Test

class LibraryDataResetServiceTest {

    private val context: Context = mockk()
    private val database: AeroDatabase = mockk()
    private val songDao: SongDao = mockk(relaxed = true)
    private val downloadDao: DownloadDao = mockk(relaxed = true)
    private val libraryScanStatusDao: LibraryScanStatusDao = mockk(relaxed = true)
    private val libraryScanStagingDao: LibraryScanStagingDao = mockk(relaxed = true)
    private val libraryScanManager: LibraryScanManager = mockk()
    private val downloadManager: DownloadManager = mockk()

    @Test
    fun clearLoadedMusicDatabase_cancelsJobs_thenClearsDb_thenDeletesFiles() = runTest {
        val appFilesDir = Files.createTempDirectory("aero_reset_test").toFile()
        val downloadsDir = File(appFilesDir, "downloads").apply { mkdirs() }
        val cachedFile = File(downloadsDir, "song.mp3").apply { writeText("dummy") }
        every { context.filesDir } returns appFilesDir

        coEvery { libraryScanManager.cancelAllScans() } returns Unit
        coEvery { downloadManager.cancelAllDownloads() } returns Unit
        every { database.runInTransaction(any<Runnable>()) } answers {
            firstArg<Runnable>().run()
        }

        val service = LibraryDataResetService(
            context = context,
            database = database,
            songDao = songDao,
            downloadDao = downloadDao,
            libraryScanStatusDao = libraryScanStatusDao,
            libraryScanStagingDao = libraryScanStagingDao,
            libraryScanManager = libraryScanManager,
            downloadManager = downloadManager
        )

        service.clearLoadedMusicDatabase()

        coVerifyOrder {
            libraryScanManager.cancelAllScans()
            downloadManager.cancelAllDownloads()
        }
        verifyOrder {
            database.runInTransaction(any<Runnable>())
            libraryScanStagingDao.clearAll()
            libraryScanStatusDao.clearAll()
            downloadDao.clearAllDownloads()
            songDao.clearAllSongs()
        }
        assertFalse(cachedFile.exists())
    }
}
