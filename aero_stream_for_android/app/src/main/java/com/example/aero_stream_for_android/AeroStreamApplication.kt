package com.example.aero_stream_for_android

import android.app.Application
import android.content.pm.ApplicationInfo
import androidx.work.Configuration
import com.example.aero_stream_for_android.data.cache.CacheCleanupManager
import com.example.aero_stream_for_android.data.debug.DebugSmbSeedManager
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

    @Inject
    lateinit var debugSmbSeedManager: DebugSmbSeedManager

    private val appScope = CoroutineScope(SupervisorJob() + Dispatchers.IO)

    override val workManagerConfiguration: Configuration
        get() = Configuration.Builder()
            .setWorkerFactory(workerFactory)
            .build()

    override fun onCreate() {
        super.onCreate()
        appScope.launch {
            val isDebuggable = (applicationInfo.flags and ApplicationInfo.FLAG_DEBUGGABLE) != 0
            debugSmbSeedManager.seedIfDebug(isDebuggable)
            cacheCleanupManager.cleanupExpiredCache()
            smbScanFailureNotifier.notifyIfLatestFailedForSelectedConfig()
        }
    }
}
