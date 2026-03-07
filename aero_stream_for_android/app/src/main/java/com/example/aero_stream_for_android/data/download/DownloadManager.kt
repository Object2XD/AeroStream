package com.example.aero_stream_for_android.data.download

import android.content.Context
import androidx.work.*
import com.example.aero_stream_for_android.data.local.db.dao.DownloadDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.local.db.entity.DownloadEntity
import com.example.aero_stream_for_android.data.local.db.entity.DownloadState
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import java.io.File
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

/**
 * ダウンロードを開始・管理するマネージャークラス。
 */
@Singleton
class DownloadManager @Inject constructor(
    @ApplicationContext private val context: Context,
    private val downloadDao: DownloadDao,
    private val songDao: SongDao
) {
    private val workManager = WorkManager.getInstance(context)

    /**
     * SMBファイルのダウンロードを開始する。
     */
    suspend fun startDownload(songId: Long, smbPath: String, smbConfigId: String): Long {
        // 既存のダウンロードをチェック
        val existing = downloadDao.getDownloadBySmbPath(smbPath)
        if (existing != null && existing.state == DownloadState.COMPLETED) {
            return existing.id
        }

        // ダウンロードエントリを作成
        val download = DownloadEntity(
            songId = songId,
            smbPath = smbPath,
            state = DownloadState.PENDING
        )
        val downloadId = downloadDao.insertDownload(download)

        // WorkManagerでバックグラウンドダウンロードを開始
        val workRequest = OneTimeWorkRequestBuilder<DownloadWorker>()
            .setInputData(
                workDataOf(
                    DownloadWorker.KEY_DOWNLOAD_ID to downloadId,
                    DownloadWorker.KEY_SMB_PATH to smbPath,
                    DownloadWorker.KEY_SONG_ID to songId,
                    DownloadWorker.KEY_SMB_CONFIG_ID to smbConfigId
                )
            )
            .setConstraints(
                Constraints.Builder()
                    .setRequiredNetworkType(NetworkType.CONNECTED)
                    .build()
            )
            .setBackoffCriteria(
                BackoffPolicy.EXPONENTIAL,
                WorkRequest.MIN_BACKOFF_MILLIS,
                java.util.concurrent.TimeUnit.MILLISECONDS
            )
            .addTag("download_$downloadId")
            .build()

        workManager.enqueueUniqueWork(
            "download_${smbPath}",
            ExistingWorkPolicy.KEEP,
            workRequest
        )

        return downloadId
    }

    /**
     * 指定SMBパスのダウンロード履歴が存在するか確認する。
     */
    suspend fun hasDownloadEntry(smbPath: String): Boolean {
        return downloadDao.getDownloadBySmbPath(smbPath) != null
    }

    /**
     * ダウンロードをキャンセルする。
     */
    suspend fun cancelDownload(downloadId: Long) {
        workManager.cancelAllWorkByTag("download_$downloadId")
        downloadDao.getDownloadById(downloadId)?.let { download ->
            downloadDao.updateDownload(download.copy(state = DownloadState.PAUSED))
        }
    }

    /**
     * ダウンロード済みファイルを削除する。
     */
    suspend fun deleteDownload(downloadId: Long) {
        downloadDao.getDownloadById(downloadId)?.let { download ->
            // ローカルファイルを削除
            download.localCachePath?.let { path ->
                File(path).delete()
            }
            songDao.clearCacheBySmbPath(download.smbPath)
            downloadDao.deleteDownload(download)
        }
    }

    /**
     * 全ダウンロードを監視する。
     */
    fun observeAllDownloads(): Flow<List<DownloadEntity>> = downloadDao.getAllDownloads()

    /**
     * 状態別のダウンロードを監視する。
     */
    fun observeDownloadsByState(state: String): Flow<List<DownloadEntity>> =
        downloadDao.getDownloadsByState(state)

    /**
     * 完了済みダウンロード数を監視する。
     */
    fun observeCompletedCount(): Flow<Int> = downloadDao.getCompletedCount()
}
