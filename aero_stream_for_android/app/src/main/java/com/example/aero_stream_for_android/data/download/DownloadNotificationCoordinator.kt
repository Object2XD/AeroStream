package com.example.aero_stream_for_android.data.download

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.work.ForegroundInfo
import com.example.aero_stream_for_android.R
import javax.inject.Inject
import javax.inject.Singleton

internal data class DownloadNotificationProgress(
    val max: Int,
    val current: Int,
    val indeterminate: Boolean
)

@Singleton
class DownloadNotificationCoordinator @Inject constructor() {

    companion object {
        const val CHANNEL_ID = "download_progress"
        private const val CHANNEL_NAME = "ダウンロード進行"
        private const val NOTIFICATION_ID_BASE = 4100
    }

    fun buildForegroundInfo(
        context: Context,
        downloadId: Long,
        fileName: String,
        downloadedBytes: Long,
        fileSize: Long
    ): ForegroundInfo = ForegroundInfo(
        notificationIdForDownload(downloadId),
        buildProgressNotification(
            context = context,
            fileName = fileName,
            downloadedBytes = downloadedBytes,
            fileSize = fileSize
        )
    )

    internal fun notificationIdForDownload(downloadId: Long): Int {
        val offset = (downloadId.coerceAtLeast(0L) % 1_000_000L).toInt()
        return NOTIFICATION_ID_BASE + offset
    }

    internal fun computeProgress(downloadedBytes: Long, fileSize: Long): DownloadNotificationProgress {
        if (fileSize <= 0L) {
            return DownloadNotificationProgress(max = 0, current = 0, indeterminate = true)
        }
        val max = 100
        val current = ((downloadedBytes.coerceAtLeast(0L) * max) / fileSize)
            .coerceIn(0L, max.toLong())
            .toInt()
        return DownloadNotificationProgress(max = max, current = current, indeterminate = false)
    }

    fun ensureChannel(context: Context) {
        val channel = NotificationChannel(
            CHANNEL_ID,
            CHANNEL_NAME,
            NotificationManager.IMPORTANCE_LOW
        )
        notificationManager(context).createNotificationChannel(channel)
    }

    private fun buildProgressNotification(
        context: Context,
        fileName: String,
        downloadedBytes: Long,
        fileSize: Long
    ): Notification {
        ensureChannel(context)
        val progress = computeProgress(downloadedBytes = downloadedBytes, fileSize = fileSize)
        return NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("キャッシュへダウンロード中")
            .setContentText(fileName)
            .setOnlyAlertOnce(true)
            .setOngoing(true)
            .setProgress(progress.max, progress.current, progress.indeterminate)
            .setContentIntent(buildLaunchIntent(context))
            .build()
    }

    private fun buildLaunchIntent(context: Context): PendingIntent? {
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
            ?: Intent(Intent.ACTION_MAIN).apply {
                addCategory(Intent.CATEGORY_LAUNCHER)
                setPackage(context.packageName)
            }
        return PendingIntent.getActivity(
            context,
            0,
            launchIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
    }

    private fun notificationManager(context: Context): NotificationManager =
        context.getSystemService(Service.NOTIFICATION_SERVICE) as NotificationManager
}
