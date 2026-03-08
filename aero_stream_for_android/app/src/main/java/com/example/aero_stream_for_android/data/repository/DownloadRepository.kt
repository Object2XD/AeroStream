package com.example.aero_stream_for_android.data.repository

import com.example.aero_stream_for_android.data.download.DownloadManager
import com.example.aero_stream_for_android.data.local.db.entity.DownloadEntity
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class DownloadRepository @Inject constructor(
    private val downloadManager: DownloadManager
) {
    fun getAllDownloads(): Flow<List<DownloadEntity>> = downloadManager.observeAllDownloads()

    fun getDownloadsByState(state: String): Flow<List<DownloadEntity>> =
        downloadManager.observeDownloadsByState(state)

    fun getCompletedCount(): Flow<Int> = downloadManager.observeCompletedCount()

    suspend fun startDownload(songId: Long, smbPath: String, smbConfigId: String): Long =
        downloadManager.startDownload(songId, smbPath, smbConfigId)

    suspend fun hasDownloadEntry(smbPath: String): Boolean =
        downloadManager.hasDownloadEntry(smbPath)

    suspend fun cancelDownload(downloadId: Long) = downloadManager.cancelDownload(downloadId)

    suspend fun deleteDownload(downloadId: Long) = downloadManager.deleteDownload(downloadId)

    suspend fun deleteBySmbPath(smbPath: String) = downloadManager.deleteDownloadBySmbPath(smbPath)
}
