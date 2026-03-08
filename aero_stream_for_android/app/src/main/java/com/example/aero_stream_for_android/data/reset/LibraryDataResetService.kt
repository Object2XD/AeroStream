package com.example.aero_stream_for_android.data.reset

import android.content.Context
import com.example.aero_stream_for_android.data.download.DownloadManager
import com.example.aero_stream_for_android.data.local.db.AeroDatabase
import com.example.aero_stream_for_android.data.local.db.dao.DownloadDao
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStagingDao
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStatusDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.scan.LibraryScanManager
import dagger.hilt.android.qualifiers.ApplicationContext
import java.io.File
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@Singleton
class LibraryDataResetService @Inject constructor(
    @ApplicationContext private val context: Context,
    private val database: AeroDatabase,
    private val songDao: SongDao,
    private val downloadDao: DownloadDao,
    private val libraryScanStatusDao: LibraryScanStatusDao,
    private val libraryScanStagingDao: LibraryScanStagingDao,
    private val libraryScanManager: LibraryScanManager,
    private val downloadManager: DownloadManager
) {
    suspend fun clearLoadedMusicDatabase() {
        withContext(Dispatchers.IO) {
            libraryScanManager.cancelAllScans()
            downloadManager.cancelAllDownloads()

            database.runInTransaction {
                libraryScanStagingDao.clearAll()
                libraryScanStatusDao.clearAll()
                downloadDao.clearAllDownloads()
                songDao.clearAllSongs()
            }

            clearCachedDownloadFiles()
        }
    }

    private suspend fun clearCachedDownloadFiles() = withContext(Dispatchers.IO) {
        val downloadsDir = File(context.filesDir, "downloads")
        if (!downloadsDir.exists()) return@withContext
        downloadsDir.listFiles()?.forEach { file ->
            file.deleteRecursively()
        }
    }
}
