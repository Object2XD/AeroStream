package com.example.aero_stream_for_android.data.repository

import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStatusDao
import com.example.aero_stream_for_android.data.scan.LibraryScanOrchestrator
import com.example.aero_stream_for_android.data.scan.RefreshResult
import com.example.aero_stream_for_android.data.scan.ScanProgressEvent
import com.example.aero_stream_for_android.data.scan.SmbScanSourceAdapter
import com.example.aero_stream_for_android.data.smb.SmbLibraryScanManager
import com.example.aero_stream_for_android.data.smb.SmbScanProgress
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.Artist
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.domain.model.Song
import javax.inject.Inject
import javax.inject.Singleton
import kotlinx.coroutines.flow.Flow

@Singleton
class SmbLibraryRepository @Inject constructor(
    private val musicRepository: MusicRepository,
    private val statusDao: LibraryScanStatusDao,
    private val orchestrator: LibraryScanOrchestrator,
    private val smbScanSourceAdapter: SmbScanSourceAdapter,
    private val scanManager: SmbLibraryScanManager
) {
    fun getAllSongs(): Flow<List<Song>> =
        musicRepository.getSongsBySource(MusicSource.SMB)

    fun getAllAlbums(): Flow<List<Album>> =
        musicRepository.getAlbumsBySource(MusicSource.SMB)

    fun getAllArtists(): Flow<List<Artist>> =
        musicRepository.getArtistsBySource(MusicSource.SMB)

    fun getSongs(smbConfigId: String): Flow<List<Song>> =
        musicRepository.getSongsBySourceAndSmbConfig(MusicSource.SMB, smbConfigId)

    fun getAlbums(smbConfigId: String): Flow<List<Album>> =
        musicRepository.getAlbumsBySourceAndSmbConfig(MusicSource.SMB, smbConfigId)

    fun getArtists(smbConfigId: String): Flow<List<Artist>> =
        musicRepository.getArtistsBySourceAndSmbConfig(MusicSource.SMB, smbConfigId)

    fun getLastRefreshTime(smbConfigId: String): Flow<Long?> =
        statusDao.observeLastSuccessfulScanAt(MusicSource.SMB.name, smbConfigId)

    fun getLastRefreshTime(): Flow<Long?> =
        statusDao.observeLastSuccessfulScanAtForSource(MusicSource.SMB.name)

    fun observeScanProgress(smbConfigId: String): Flow<SmbScanProgress> =
        scanManager.observeScanProgress(smbConfigId)

    fun observeAllScanProgress(): Flow<Map<String, SmbScanProgress>> =
        scanManager.observeAllScanProgress()

    suspend fun enqueueScan(smbConfigId: String, quickScan: Boolean = true) {
        scanManager.enqueueScan(smbConfigId, quickScan)
    }

    suspend fun cancelScan(smbConfigId: String) {
        scanManager.cancelScan(smbConfigId)
    }

    suspend fun refreshLibrary(
        config: SmbConfig,
        quickScan: Boolean = true,
        isCancelled: () -> Boolean = { false },
        onProgress: (ScanProgressEvent) -> Unit = {}
    ): RefreshResult {
        return orchestrator.refresh(
            config = config,
            adapter = smbScanSourceAdapter,
            quickScan = quickScan,
            isCancelled = isCancelled,
            onProgress = onProgress
        )
    }
}
