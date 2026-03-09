package com.example.aero_stream_for_android.data.download

import android.content.Context
import android.util.Log
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
        private const val TAG = "DownloadWorker"
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
        val safePathLabel = DownloadWorkerDiagnostics.safePathLabel(smbPath)

        if (downloadId == -1L) return@withContext Result.failure()
        val download = downloadDao.getDownloadById(downloadId)
        val resolvedSmbConfigId = inputData.getString(KEY_SMB_CONFIG_ID)
            ?.takeIf { it.isNotBlank() }
            ?: download?.smbConfigId?.takeIf { it.isNotBlank() }
        val smbConfigId = resolvedSmbConfigId.orEmpty()

        var stage = "init"
        var lastLoggedPercent = -1
        var lastLoggedMib = -1L

        Log.i(
            TAG,
            "start downloadId=$downloadId songId=$songId smbConfigId=${resolvedSmbConfigId ?: "<missing>"} " +
                "path=$safePathLabel runAttemptCount=$runAttemptCount"
        )

        try {
            // ダウンロード状態を更新
            stage = "config-load"
            downloadDao.updateProgress(downloadId, DownloadState.DOWNLOADING, 0, 0)
            updateForegroundNotification(
                downloadId = downloadId,
                smbPath = smbPath,
                downloadedBytes = 0L,
                fileSize = 0L
            )
            Log.d(TAG, "stage=$stage downloadId=$downloadId state=DOWNLOADING")
            if (smbConfigId.isBlank()) {
                val summary = "config-load: IllegalStateException - SMB設定IDを特定できません"
                Log.e(TAG, "failed stage=$stage downloadId=$downloadId path=$safePathLabel reason=config-id-missing")
                downloadDao.markFailed(downloadId, error = summary)
                return@withContext Result.failure()
            }
            if (download != null && download.smbConfigId.isNullOrBlank()) {
                downloadDao.updateDownload(download.copy(smbConfigId = smbConfigId))
            }

            // SMB設定を取得
            preferencesDataStore.migrateLegacySmbConfigIfNeeded()
            val config = preferencesDataStore.getSmbConfigById(smbConfigId)
            if (config == null) {
                val summary = "config-load: IllegalStateException - SMB設定が見つかりません"
                Log.e(TAG, "failed stage=$stage downloadId=$downloadId path=$safePathLabel reason=config-not-found")
                downloadDao.markFailed(downloadId, error = summary)
                return@withContext Result.failure()
            }
            if (!config.isConfigured) {
                val summary = "config-load: IllegalStateException - SMB設定が未構成です"
                Log.e(TAG, "failed stage=$stage downloadId=$downloadId path=$safePathLabel reason=config-not-configured")
                downloadDao.markFailed(downloadId, error = summary)
                return@withContext Result.failure()
            }

            stage = "share-connect"
            val share = smbConnectionManager.getShare(config)
            Log.d(TAG, "stage=$stage downloadId=$downloadId connected")

            // ダウンロード先ディレクトリを作成
            val downloadDir = File(applicationContext.filesDir, "downloads")
            if (!downloadDir.exists()) downloadDir.mkdirs()

            // ファイル名を生成（SMBパスから）
            val fileName = smbPath.substringAfterLast('\\')
            val localFile = File(downloadDir, fileName)

            // SMBファイルを開く
            stage = "open-file"
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
            Log.d(TAG, "stage=$stage downloadId=$downloadId fileSize=$fileSize")
            var downloadedBytes = 0L

            // ファイルをダウンロード
            stage = "stream-copy"
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
                        if (DownloadWorkerDiagnostics.shouldEmitProgressLog(
                                downloadedBytes = downloadedBytes,
                                fileSize = fileSize,
                                lastLoggedPercent = lastLoggedPercent,
                                lastLoggedMib = lastLoggedMib
                            )
                        ) {
                            val currentPercent = progressPercent(downloadedBytes, fileSize)
                            val currentMib = downloadedBytes / (1024L * 1024L)
                            lastLoggedPercent = currentPercent
                            lastLoggedMib = currentMib
                            Log.d(
                                TAG,
                                "stage=$stage downloadId=$downloadId progress=${currentPercent}% bytes=$downloadedBytes/$fileSize"
                            )
                        }
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
            stage = "db-complete"
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
                updated = songDao.markSongCachedBySmbPathAndConfigId(
                    smbPath = smbPath,
                    smbConfigId = smbConfigId,
                    localPath = localFile.absolutePath,
                    timestamp = cachedAt
                )
            }
            if (updated == 0) {
                songDao.markSongCachedBySmbPath(smbPath, localFile.absolutePath, cachedAt)
            }

            Log.i(TAG, "success downloadId=$downloadId path=$safePathLabel")
            Result.success()
        } catch (e: Exception) {
            val summary = DownloadWorkerDiagnostics.buildFailureSummary(e, stage)
            val rootCause = DownloadWorkerDiagnostics.rootCauseOf(e)
            Log.e(
                TAG,
                "failed stage=$stage downloadId=$downloadId path=$safePathLabel " +
                    "exceptionClass=${e::class.java.simpleName} message=${e.message ?: "<null>"} " +
                    "causeClass=${rootCause::class.java.simpleName} causeMessage=${rootCause.message ?: "<null>"}",
                e
            )
            downloadDao.markFailed(downloadId, error = summary)
            if (runAttemptCount < 3) {
                Log.w(TAG, "retrying downloadId=$downloadId runAttemptCount=$runAttemptCount")
                Result.retry()
            } else {
                Log.e(TAG, "terminal-failure downloadId=$downloadId runAttemptCount=$runAttemptCount")
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

internal object DownloadWorkerDiagnostics {
    private const val MAX_FAILURE_SUMMARY = 180

    fun buildFailureSummary(throwable: Throwable, stage: String): String {
        val root = rootCauseOf(throwable)
        val stagePart = "$stage: "
        val classPart = root::class.java.simpleName.ifBlank { "Exception" }
        val messagePart = root.message?.takeIf { it.isNotBlank() }
            ?: throwable.message?.takeIf { it.isNotBlank() }
            ?: "原因不明"
        return (stagePart + classPart + " - " + messagePart)
            .replace('\n', ' ')
            .replace(Regex("\\s+"), " ")
            .take(MAX_FAILURE_SUMMARY)
    }

    fun rootCauseOf(throwable: Throwable): Throwable {
        var current = throwable
        while (current.cause != null && current.cause !== current) {
            current = current.cause!!
        }
        return current
    }

    fun shouldEmitProgressLog(
        downloadedBytes: Long,
        fileSize: Long,
        lastLoggedPercent: Int,
        lastLoggedMib: Long
    ): Boolean {
        val currentPercent = if (fileSize > 0L) {
            ((downloadedBytes * 100L) / fileSize).coerceIn(0L, 100L).toInt()
        } else {
            0
        }
        val currentMib = downloadedBytes / (1024L * 1024L)
        val percentThresholdReached = currentPercent >= ((lastLoggedPercent / 5) + 1) * 5
        val mibThresholdReached = currentMib >= lastLoggedMib + 1
        return percentThresholdReached || mibThresholdReached
    }

    fun safePathLabel(path: String): String {
        val fileName = path.substringAfterLast('\\', path).substringAfterLast('/')
        return if (fileName.isBlank()) {
            "<unknown>"
        } else {
            fileName
        }
    }
}
