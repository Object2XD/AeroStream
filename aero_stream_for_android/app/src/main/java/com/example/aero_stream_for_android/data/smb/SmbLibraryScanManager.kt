package com.example.aero_stream_for_android.data.smb

import com.example.aero_stream_for_android.data.scan.LibraryScanManager
import com.example.aero_stream_for_android.domain.model.MusicSource
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.Flow

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
}
