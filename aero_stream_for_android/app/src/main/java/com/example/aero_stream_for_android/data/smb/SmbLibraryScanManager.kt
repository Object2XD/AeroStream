package com.example.aero_stream_for_android.data.smb

import com.example.aero_stream_for_android.data.scan.LibraryScanManager
import com.example.aero_stream_for_android.data.scan.LibraryScanProgress
import com.example.aero_stream_for_android.domain.model.MusicSource
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

@Singleton
class SmbLibraryScanManager @Inject constructor(
    private val libraryScanManager: LibraryScanManager
) {
    fun observeScanProgress(smbConfigId: String): Flow<SmbScanProgress> =
        libraryScanManager.observeScanProgress(MusicSource.SMB, smbConfigId)

    suspend fun enqueueScan(smbConfigId: String, quickScan: Boolean = true) {
        libraryScanManager.enqueueScan(MusicSource.SMB, smbConfigId, quickScan)
    }

    suspend fun cancelScan(smbConfigId: String) {
        libraryScanManager.cancelScan(MusicSource.SMB, smbConfigId)
    }

    fun observeAllScanProgress(): Flow<Map<String, LibraryScanProgress>> =
        libraryScanManager.observeAllActiveScans().map { states ->
            states.values
                .asSequence()
                .filter { it.source == MusicSource.SMB }
                .associate { state -> state.sourceConfigId to state.progress }
        }
}
