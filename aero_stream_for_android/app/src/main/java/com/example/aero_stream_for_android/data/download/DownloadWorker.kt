package com.example.aero_stream_for_android.data.download

import android.content.Context
import androidx.hilt.work.HiltWorker
import androidx.work.*
import com.example.aero_stream_for_android.data.local.db.dao.DownloadDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.local.db.entity.DownloadState
import com.example.aero_stream_for_android.data.local.preferences.UserPreferencesDataStore
import com.example.aero_stream_for_android.data.remote.smb.SmbConnectionManager
import dagger.assisted.Assisted
import dagger.assisted.AssistedInject
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import com.hierynomus.msdtyp.AccessMask
import com.hierynomus.mssmb2.SMB2CreateDisposition
import com.hierynomus.mssmb2.SMB2ShareAccess
import java.io.File
import java.io.FileOutputStream
import java.util.EnumSet

/**
 * SMBファイルをバックグラウンドでダウンロードするWorker。
 */
@HiltWorker
class DownloadWorker @AssistedInject constructor(
    @Assisted appContext: Context,
    @Assisted workerParams: WorkerParameters,
    private val downloadDao: DownloadDao,
    private val songDao: SongDao,
    private val notificationCoordinator: DownloadNotificationCoordinator,
    private val smbConnectionManager: SmbConnectionManager,
    private val preferencesDataStore: UserPreferencesDataStore
) : CoroutineWorker(appContext, workerParams) {

    companion object {
        const val KEY_DOWNLOAD_ID = "download_id"
        const val KEY_SMB_PATH = "smb_path"
        const val KEY_SONG_ID = "song_id"
        const val KEY_SMB_CONFIG_ID = "smb_config_id"
        const val BUFFER_SIZE = 8192
    }

    override suspend fun doWork(): Result = withContext(Dispatchers.IO) {
        val downloadId = inputData.getLong(KEY_DOWNLOAD_ID, -1)
        val smbPath = inputData.getString(KEY_SMB_PATH) ?: return@withContext Result.failure()
        val songId = inputData.getLong(KEY_SONG_ID, -1)
        val smbConfigId = inputData.getString(KEY_SMB_CONFIG_ID) ?: return@withContext Result.failure()

        if (downloadId == -1L) return@withContext Result.failure()

        try {
            // ダウンロード状態を更新
            downloadDao.updateProgress(downloadId, DownloadState.DOWNLOADING, 0, 0)

            // SMB設定を取得
            preferencesDataStore.migrateLegacySmbConfigIfNeeded()
            val config = preferencesDataStore.getSmbConfigById(smbConfigId)
                ?: return@withContext Result.failure()
            if (!config.isConfigured) return@withContext Result.failure()

            val share = smbConnectionManager.getShare(config)

            // ダウンロード先ディレクトリを作成
            val downloadDir = File(applicationContext.filesDir, "downloads")
            if (!downloadDir.exists()) downloadDir.mkdirs()

            // ファイル名を生成（SMBパスから）
            val fileName = smbPath.substringAfterLast('\\')
            val localFile = File(downloadDir, fileName)

            // SMBファイルを開く
            val smbFile = share.openFile(
                smbPath,
                EnumSet.of(AccessMask.GENERIC_READ),
                null,
                EnumSet.of(SMB2ShareAccess.FILE_SHARE_READ),
                SMB2CreateDisposition.FILE_OPEN,
                null
            )

            val fileSize = smbFile.fileInformation.standardInformation.endOfFile
            downloadDao.updateProgress(downloadId, DownloadState.DOWNLOADING, 0, fileSize)
            updateForegroundNotification(
                downloadId = downloadId,
                smbPath = smbPath,
                downloadedBytes = 0L,
                fileSize = fileSize
            )
            var downloadedBytes = 0L

            // ファイルをダウンロード
            smbFile.inputStream.use { inputStream ->
                FileOutputStream(localFile).use { outputStream ->
                    val buffer = ByteArray(BUFFER_SIZE)
                    var bytesRead: Int
                    while (inputStream.read(buffer).also { bytesRead = it } != -1) {
                        outputStream.write(buffer, 0, bytesRead)
                        downloadedBytes += bytesRead

                        // 進捗を更新
                        downloadDao.updateProgress(downloadId, DownloadState.DOWNLOADING, downloadedBytes, fileSize)

                        // WorkManagerの進捗をセット
                        setProgress(
                            workDataOf(
                                "progress" to progressPercent(downloadedBytes, fileSize)
                            )
                        )
                        updateForegroundNotification(
                            downloadId = downloadId,
                            smbPath = smbPath,
                            downloadedBytes = downloadedBytes,
                            fileSize = fileSize
                        )
                    }
                }
            }

            smbFile.close()

            // ダウンロード完了を記録
            downloadDao.markCompleted(
                id = downloadId,
                localPath = localFile.absolutePath
            )

            // Song エンティティをキャッシュ済みとして更新（sourceは維持）
            val cachedAt = System.currentTimeMillis()
            var updated = 0
            if (songId != -1L) {
                updated = songDao.markSongCachedById(
                    songId = songId,
                    localPath = localFile.absolutePath,
                    timestamp = cachedAt
                )
            }
            if (updated == 0) {
                songDao.markSongCachedBySmbPath(
                    smbPath = smbPath,
                    localPath = localFile.absolutePath,
                    timestamp = cachedAt
                )
            }

            Result.success()
        } catch (e: Exception) {
            downloadDao.markFailed(downloadId, error = e.message)
            if (runAttemptCount < 3) {
                Result.retry()
            } else {
                Result.failure()
            }
        }
    }

    override suspend fun getForegroundInfo(): ForegroundInfo {
        val downloadId = inputData.getLong(KEY_DOWNLOAD_ID, -1)
        val smbPath = inputData.getString(KEY_SMB_PATH).orEmpty()
        return notificationCoordinator.buildForegroundInfo(
            context = applicationContext,
            downloadId = downloadId,
            fileName = smbPath.substringAfterLast('\\', missingDelimiterValue = smbPath.ifBlank { "unknown" }),
            downloadedBytes = 0L,
            fileSize = 0L
        )
    }

    private suspend fun updateForegroundNotification(
        downloadId: Long,
        smbPath: String,
        downloadedBytes: Long,
        fileSize: Long
    ) {
        val foregroundInfo = notificationCoordinator.buildForegroundInfo(
            context = applicationContext,
            downloadId = downloadId,
            fileName = smbPath.substringAfterLast('\\', missingDelimiterValue = smbPath),
            downloadedBytes = downloadedBytes,
            fileSize = fileSize
        )
        runCatching { setForeground(foregroundInfo) }
    }

    private fun progressPercent(downloadedBytes: Long, fileSize: Long): Int {
        if (fileSize <= 0L) return 0
        return ((downloadedBytes.coerceAtLeast(0L) * 100L) / fileSize)
            .coerceIn(0L, 100L)
            .toInt()
    }
}
