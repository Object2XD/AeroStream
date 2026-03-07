package com.example.aero_stream_for_android.data.smb

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import androidx.core.app.NotificationCompat
import androidx.work.WorkInfo
import androidx.work.WorkManager
import com.example.aero_stream_for_android.R
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

@Singleton
class SmbScanFailureNotifier @Inject constructor(
    @ApplicationContext private val context: Context,
    private val settingsRepository: SettingsRepository
) {
    companion object {
        private const val CHANNEL_ID = "smb_library_scan"
        private const val BASE_NOTIFICATION_ID = 3200
    }

    suspend fun notifyIfLatestFailedForSelectedConfig() = withContext(Dispatchers.IO) {
        settingsRepository.migrateLegacySmbConfigIfNeeded()
        val config = settingsRepository.getSelectedSmbConfig() ?: return@withContext
        val workInfos = WorkManager.getInstance(context)
            .getWorkInfosForUniqueWork("smb_scan_${config.id}")
            .get()
        val latest = workInfos.firstOrNull() ?: return@withContext
        if (latest.state != WorkInfo.State.FAILED) return@withContext

        val dedupeKey = "${config.id}:${latest.id}"
        if (settingsRepository.getLastNotifiedSmbScanFailureKey() == dedupeKey) return@withContext

        val message = latest.outputData.getString(SmbLibraryScanWorker.KEY_RESULT_MESSAGE)
            ?.takeIf { it.isNotBlank() }
            ?: "SMBライブラリ更新に失敗しました"

        val manager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val channel = NotificationChannel(
            CHANNEL_ID,
            "SMBライブラリ更新",
            NotificationManager.IMPORTANCE_LOW
        )
        manager.createNotificationChannel(channel)

        val notification = NotificationCompat.Builder(context, CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("SMBライブラリ更新に失敗")
            .setContentText(message)
            .setAutoCancel(true)
            .build()

        manager.notify(BASE_NOTIFICATION_ID + config.id.hashCode(), notification)
        settingsRepository.setLastNotifiedSmbScanFailureKey(dedupeKey)
    }
}
