package com.example.aero_stream_for_android.data.scan

import android.content.Context
import androidx.core.content.ContextCompat
import com.example.aero_stream_for_android.domain.model.MusicSource
import dagger.hilt.android.qualifiers.ApplicationContext
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

@Singleton
class LibraryScanSupervisor @Inject constructor(
    @ApplicationContext private val context: Context,
    private val scanManager: LibraryScanManager
) {
    companion object {
        const val LOCAL_SOURCE_CONFIG_ID = "__LOCAL__"
    }

    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.Default)
    private val manualScans = MutableStateFlow<Map<String, ActiveLibraryScanState>>(emptyMap())
    private val workManagerScans = MutableStateFlow<Map<String, ActiveLibraryScanState>>(emptyMap())
    val activeScans: StateFlow<Map<String, ActiveLibraryScanState>> = combine(
        manualScans,
        workManagerScans
    ) { manual, workManager ->
        workManager + manual.filterKeys { it !in workManager }
    }.stateIn(scope, SharingStarted.Eagerly, emptyMap())

    init {
        scope.launch {
            scanManager.observeAllActiveScans().collect { states ->
                workManagerScans.value = states
            }
        }
    }

    fun register(
        source: MusicSource,
        sourceConfigId: String,
        displayName: String,
        progress: LibraryScanProgress
    ) {
        manualScans.update { states ->
            states + (registryKey(source, sourceConfigId) to ActiveLibraryScanState(
                source = source,
                sourceConfigId = sourceConfigId,
                displayName = displayName,
                progress = progress
            ))
        }
        if (source == MusicSource.LOCAL) {
            ensureForegroundService()
        }
    }

    fun update(
        source: MusicSource,
        sourceConfigId: String,
        displayName: String,
        progress: LibraryScanProgress
    ) {
        register(source, sourceConfigId, displayName, progress)
    }

    fun complete(source: MusicSource, sourceConfigId: String) {
        manualScans.update { states ->
            states - registryKey(source, sourceConfigId)
        }
    }

    suspend fun cancelRepresentative() {
        val representative = cancellableRepresentative() ?: return
        when (representative.source) {
            MusicSource.SMB -> scanManager.cancelScan(MusicSource.SMB, representative.sourceConfigId)
            MusicSource.LOCAL, MusicSource.DOWNLOAD -> Unit
        }
    }

    fun representativeScan(): ActiveLibraryScanState? =
        activeScans.value.values.maxByOrNull { it.updatedAt }

    fun hasCancellableScan(): Boolean = cancellableRepresentative() != null

    private fun ensureForegroundService() {
        ContextCompat.startForegroundService(
            context,
            LibraryScanForegroundService.newIntent(context)
        )
    }

    private fun registryKey(source: MusicSource, sourceConfigId: String): String =
        "${source.name}:$sourceConfigId"

    private fun cancellableRepresentative(): ActiveLibraryScanState? =
        activeScans.value.values
            .filter { it.source == MusicSource.SMB }
            .maxByOrNull { it.updatedAt }
}
