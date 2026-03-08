package com.example.aero_stream_for_android.data.scan

import android.content.Context
import androidx.work.Constraints
import androidx.work.ExistingWorkPolicy
import androidx.work.NetworkType
import androidx.work.OneTimeWorkRequestBuilder
import androidx.work.WorkInfo
import androidx.work.WorkManager
import androidx.work.workDataOf
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.KEY_QUICK_SCAN
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.KEY_SOURCE
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.KEY_SOURCE_CONFIG_ID
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.TAG_ALL
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.scanTag
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.toActiveLibraryScanState
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.toLibraryScanProgress
import com.example.aero_stream_for_android.data.scan.LibraryScanWorkSupport.uniqueWorkName
import com.example.aero_stream_for_android.domain.model.MusicSource
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers

enum class EnqueueScanResult {
    STARTED,
    ALREADY_RUNNING
}

@Singleton
class LibraryScanManager @Inject constructor(
    @ApplicationContext context: Context
) {
    companion object {
        internal fun shouldKeepExistingScan(source: MusicSource): Boolean = source == MusicSource.SMB

        internal fun hasActiveWork(existingInfos: List<WorkInfo>): Boolean =
            existingInfos.any {
                it.state == WorkInfo.State.ENQUEUED ||
                    it.state == WorkInfo.State.RUNNING ||
                    it.state == WorkInfo.State.BLOCKED
            }
    }

    private val workManager = WorkManager.getInstance(context)

    fun observeScanProgress(
        source: MusicSource,
        sourceConfigId: String
    ): Flow<LibraryScanProgress> =
        workManager.getWorkInfosForUniqueWorkFlow(uniqueWorkName(source, sourceConfigId)).map { infos ->
            val info = infos.firstOrNull() ?: return@map LibraryScanProgress(sourceConfigId = sourceConfigId)
            with(LibraryScanWorkSupport) { info.toLibraryScanProgress(sourceConfigId) }
        }

    fun observeAllActiveScans(): Flow<Map<String, ActiveLibraryScanState>> =
        workManager.getWorkInfosByTagFlow(TAG_ALL).map { infos ->
            with(LibraryScanWorkSupport) {
                infos.mapNotNull { info ->
                    info.toActiveLibraryScanState()?.let { state ->
                        registryKey(state.source, state.sourceConfigId) to state
                    }
                }.toMap()
            }
        }

    suspend fun enqueueScan(
        source: MusicSource,
        sourceConfigId: String,
        quickScan: Boolean = true
    ): EnqueueScanResult {
        val uniqueWorkName = uniqueWorkName(source, sourceConfigId)
        if (shouldKeepExistingScan(source)) {
            val existingInfos = withContext(Dispatchers.IO) {
                workManager.getWorkInfosForUniqueWork(uniqueWorkName).get()
            }
            if (hasActiveWork(existingInfos)) {
                return EnqueueScanResult.ALREADY_RUNNING
            }
        }

        val builder = when (source) {
            MusicSource.SMB -> OneTimeWorkRequestBuilder<com.example.aero_stream_for_android.data.smb.SmbLibraryScanWorker>()
                .setConstraints(
                    Constraints.Builder()
                        .setRequiredNetworkType(NetworkType.CONNECTED)
                        .build()
                )
            MusicSource.LOCAL -> OneTimeWorkRequestBuilder<LocalLibraryScanWorker>()
            MusicSource.DOWNLOAD -> error("Download scans are not supported")
        }

        val request = builder
            .setInputData(
                workDataOf(
                    KEY_SOURCE to source.name,
                    KEY_SOURCE_CONFIG_ID to sourceConfigId,
                    KEY_QUICK_SCAN to quickScan
                )
            )
            .addTag(TAG_ALL)
            .addTag(scanTag(source, sourceConfigId))
            .build()

        workManager.enqueueUniqueWork(
            uniqueWorkName,
            if (shouldKeepExistingScan(source)) ExistingWorkPolicy.KEEP else ExistingWorkPolicy.REPLACE,
            request
        )
        return EnqueueScanResult.STARTED
    }

    suspend fun cancelScan(source: MusicSource, sourceConfigId: String) {
        workManager.cancelUniqueWork(uniqueWorkName(source, sourceConfigId))
    }

    suspend fun cancelAllScans() {
        workManager.cancelAllWorkByTag(TAG_ALL)
    }

    private fun registryKey(source: MusicSource, sourceConfigId: String): String =
        "${source.name}:$sourceConfigId"
}
