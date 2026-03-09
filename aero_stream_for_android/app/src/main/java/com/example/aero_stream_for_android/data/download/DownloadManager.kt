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
import javax.inject.Inject
import javax.inject.Singleton

/**
 * ダウンロードを開始・管理するマネージャークラス。
 */
@Singleton
class DownloadManager @Inject constructor(
    @ApplicationContext private val context: Context,
    private val downloadDao: DownloadDao,
    private val songDao: SongDao,
    private val smbConfigResolver: SmbConfigResolver,
    private val workManager: WorkManager = WorkManager.getInstance(context)
) {
    companion object {
        private const val DOWNLOAD_WORK_TAG_PREFIX = "download_"
        private const val UNIQUE_WORK_PREFIX = "download_work_"
    }

    /**
     * SMBファイルのダウンロードを開始する。
     */
    suspend fun startDownload(songId: Long, smbPath: String, smbConfigId: String?): DownloadStartResult {
        val resolved = when (val resolution = smbConfigResolver.resolveForDownloadStart(songId, smbConfigId)) {
            is SmbConfigResolutionResult.Resolved -> resolution.config
            is SmbConfigResolutionResult.Failed -> {
                return DownloadStartResult.ConfigResolutionFailed(resolution.reason)
            }
        }

        // 同一SMB構成内の既存ダウンロードをチェック
        var existing = downloadDao.getDownloadBySmbPathAndConfigId(smbPath, resolved.id)
        if (existing == null) {
            val legacy = downloadDao.getLegacyDownloadBySmbPath(smbPath)
            if (legacy != null) {
                val upgraded = legacy.copy(songId = songId, smbConfigId = resolved.id)
                downloadDao.updateDownload(upgraded)
                existing = upgraded
            }
        }
        if (existing != null) {
            when (existing.state) {
                DownloadState.COMPLETED -> return DownloadStartResult.AlreadyCompleted(existing.id)
                DownloadState.PENDING, DownloadState.DOWNLOADING -> {
                    return DownloadStartResult.SkippedActive(existing.id)
                }
                DownloadState.FAILED, DownloadState.PAUSED -> {
                    workManager.cancelAllWorkByTag("$DOWNLOAD_WORK_TAG_PREFIX${existing.id}")
                    existing.localCachePath?.let { path -> File(path).delete() }
                    downloadDao.deleteDownload(existing)
                }
            }
        }

        // ダウンロードエントリを作成
        val download = DownloadEntity(
            songId = songId,
            smbPath = smbPath,
            smbConfigId = resolved.id,
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
                    DownloadWorker.KEY_SMB_CONFIG_ID to resolved.id
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
            uniqueWorkName(smbPath = smbPath, smbConfigId = resolved.id),
            ExistingWorkPolicy.KEEP,
            workRequest
        )

        return DownloadStartResult.Started(
            downloadId = downloadId,
            retriedFromFailure = existing?.state == DownloadState.FAILED || existing?.state == DownloadState.PAUSED
        )
    }

    /**
     * ダウンロードをキャンセルする。
     */
    suspend fun cancelDownload(downloadId: Long) {
        workManager.cancelAllWorkByTag("$DOWNLOAD_WORK_TAG_PREFIX$downloadId")
        downloadDao.getDownloadById(downloadId)?.let { download ->
            downloadDao.updateDownload(download.copy(state = DownloadState.PAUSED))
        }
    }

    /**
     * 追跡中の全ダウンロードジョブを停止する。
     */
    suspend fun cancelAllDownloads() {
        downloadDao.getAllDownloadIds().forEach { id ->
            workManager.cancelAllWorkByTag("$DOWNLOAD_WORK_TAG_PREFIX$id")
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
            val smbConfigId = download.smbConfigId
            if (!smbConfigId.isNullOrBlank()) {
                songDao.clearCacheBySmbPathAndConfigId(download.smbPath, smbConfigId)
            } else {
                songDao.clearCacheBySmbPath(download.smbPath)
            }
            downloadDao.deleteDownload(download)
        }
    }

    /**
     * SMBパスをキーにキャッシュを削除する。
     * ダウンロード履歴が無い場合も songs テーブルのキャッシュ状態を直接クリアする。
     */
    suspend fun deleteDownloadBySmbPath(smbPath: String) {
        deleteDownloadBySmbPath(smbPath, smbConfigId = null)
    }

    /**
     * SMBパスとSMB設定IDをキーにキャッシュを削除する。
     * smbConfigId が null の場合はレガシー互換で SMB パスのみを使用する。
     */
    suspend fun deleteDownloadBySmbPath(smbPath: String, smbConfigId: String?) {
        val existing = if (!smbConfigId.isNullOrBlank()) {
            downloadDao.getDownloadBySmbPathAndConfigId(smbPath, smbConfigId)
                ?: downloadDao.getLegacyDownloadBySmbPath(smbPath)
        } else {
            downloadDao.getDownloadBySmbPath(smbPath)
        }
        if (existing != null) {
            deleteDownload(existing.id)
            return
        }

        if (!smbConfigId.isNullOrBlank()) {
            songDao.getSongBySmbPathAndConfigId(smbPath, smbConfigId)?.localPath?.let { path ->
                File(path).delete()
            }
            songDao.clearCacheBySmbPathAndConfigId(smbPath, smbConfigId)
            downloadDao.deleteBySmbPathAndConfigId(smbPath, smbConfigId)
        } else {
            songDao.getSongBySmbPath(smbPath)?.localPath?.let { path ->
                File(path).delete()
            }
            songDao.clearCacheBySmbPath(smbPath)
            downloadDao.deleteBySmbPath(smbPath)
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

    private fun uniqueWorkName(smbPath: String, smbConfigId: String): String {
        return UNIQUE_WORK_PREFIX + smbConfigId + "_" + smbPath.hashCode()
    }
}
