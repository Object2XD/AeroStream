package com.example.aero_stream_for_android

import android.app.Application
import androidx.work.Configuration
import com.example.aero_stream_for_android.data.cache.CacheCleanupManager
import com.example.aero_stream_for_android.data.smb.SmbScanFailureNotifier
import androidx.hilt.work.HiltWorkerFactory
import dagger.hilt.android.HiltAndroidApp
import javax.inject.Inject
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.launch

@HiltAndroidApp
class AeroStreamApplication : Application(), Configuration.Provider {

    @Inject
    lateinit var workerFactory: HiltWorkerFactory

    @Inject
    lateinit var cacheCleanupManager: CacheCleanupManager

    @Inject
    lateinit var smbScanFailureNotifier: SmbScanFailureNotifier

    private val appScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override val workManagerConfiguration: Configuration
        get() = Configuration.Builder()
            .setWorkerFactory(workerFactory)
            .build()

    override fun onCreate() {
        super.onCreate()
        appScope.launch {
            cacheCleanupManager.cleanupExpiredCache()
            smbScanFailureNotifier.notifyIfLatestFailedForSelectedConfig()
        }
    }
}
