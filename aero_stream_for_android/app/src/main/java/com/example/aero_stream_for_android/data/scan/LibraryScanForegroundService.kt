package com.example.aero_stream_for_android.data.scan

import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.IBinder
import androidx.core.app.ServiceCompat
import dagger.hilt.android.AndroidEntryPoint
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@AndroidEntryPoint
class LibraryScanForegroundService : Service() {
    companion object {
        private const val ACTION_CANCEL_REPRESENTATIVE = "cancel_representative_scan"
        private const val REQUEST_CODE_CANCEL = 4101

        fun newIntent(context: Context): Intent =
            Intent(context, LibraryScanForegroundService::class.java)

        fun newCancelIntent(context: Context): PendingIntent =
            PendingIntent.getService(
                context,
                REQUEST_CODE_CANCEL,
                newIntent(context).setAction(ACTION_CANCEL_REPRESENTATIVE),
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
    }

    @Inject lateinit var supervisor: LibraryScanSupervisor
    @Inject lateinit var notificationCoordinator: LibraryScanNotificationCoordinator

    private val serviceScope = CoroutineScope(SupervisorJob() + Dispatchers.Main.immediate)
    private var startedForeground = false

    override fun onCreate() {
        super.onCreate()
        notificationCoordinator.ensureChannel(this)
        startForegroundIfNeeded(notificationCoordinator.buildPreparingNotification(this))
        serviceScope.launch {
            supervisor.activeScans.collectLatest { activeScans ->
                if (activeScans.isEmpty()) {
                    stopForegroundAndSelf()
                    return@collectLatest
                }
                val cancelIntent = if (supervisor.hasCancellableScan()) {
                    newCancelIntent(this@LibraryScanForegroundService)
                } else {
                    null
                }
                val notification = notificationCoordinator.buildProgressNotification(
                    context = this@LibraryScanForegroundService,
                    activeStates = activeScans.values.toList(),
                    cancelIntent = cancelIntent
                )
                startForegroundIfNeeded(notification)
                notificationCoordinator.notificationManager(this@LibraryScanForegroundService)
                    .notify(LibraryScanNotificationCoordinator.NOTIFICATION_ID, notification)
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_CANCEL_REPRESENTATIVE) {
            serviceScope.launch {
                supervisor.cancelRepresentative()
            }
        }
        return START_STICKY
    }

    override fun onDestroy() {
        serviceScope.cancel()
        super.onDestroy()
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun startForegroundIfNeeded(notification: android.app.Notification) {
        if (startedForeground) return
        ServiceCompat.startForeground(
            this,
            LibraryScanNotificationCoordinator.NOTIFICATION_ID,
            notification,
            ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC
        )
        startedForeground = true
    }

    private fun stopForegroundAndSelf() {
        ServiceCompat.stopForeground(this, ServiceCompat.STOP_FOREGROUND_REMOVE)
        stopSelf()
    }
}
