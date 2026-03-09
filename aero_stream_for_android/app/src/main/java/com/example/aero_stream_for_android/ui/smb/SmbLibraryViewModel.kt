package com.example.aero_stream_for_android.ui.smb

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.download.DownloadStartResult
import com.example.aero_stream_for_android.data.repository.DownloadRepository
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.data.repository.SmbLibraryRepository
import com.example.aero_stream_for_android.data.smb.SmbScanProgress
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.Artist
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.isCacheDownloadEligible
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

enum class ScanTargetSheetMode {
    Refresh,
    Cancel
}

data class SmbLibraryUiState(
    val selectedTab: Int = 0,
    val songs: List<Song> = emptyList(),
    val albums: List<Album> = emptyList(),
    val artists: List<Artist> = emptyList(),
    val smbConfigs: List<SmbConfig> = emptyList(),
    val isLoading: Boolean = true,
    val isRefreshing: Boolean = false,
    val error: String? = null,
    val lastRefreshTime: Long? = null,
    val hasCachedContent: Boolean = false,
    val scanProgressByConfig: Map<String, SmbScanProgress> = emptyMap(),
    val showScanTargetSheet: Boolean = false,
    val scanTargetSheetMode: ScanTargetSheetMode? = null
)

@HiltViewModel
class SmbLibraryViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository,
    private val smbLibraryRepository: SmbLibraryRepository,
    private val downloadRepository: DownloadRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SmbLibraryUiState())
    val uiState: StateFlow<SmbLibraryUiState> = _uiState.asStateFlow()

    private var songsJob: Job? = null
    private var albumsJob: Job? = null
    private var artistsJob: Job? = null
    private var refreshTimeJob: Job? = null
    private var scanProgressJob: Job? = null

    init {
        viewModelScope.launch {
            settingsRepository.migrateLegacySmbConfigIfNeeded()
        }

        viewModelScope.launch {
            settingsRepository.smbConfigs.collect { configs ->
                _uiState.update { state ->
                    state.copy(
                        smbConfigs = configs,
                        isLoading = false,
                        error = if (configs.isEmpty()) "SMBサーバーが設定されていません" else null,
                        showScanTargetSheet = if (configs.isEmpty()) false else state.showScanTargetSheet,
                        scanTargetSheetMode = if (configs.isEmpty()) null else state.scanTargetSheetMode
                    )
                }
            }
        }

        bindLibraryContent()

        refreshTimeJob = viewModelScope.launch {
            smbLibraryRepository.getLastRefreshTime().collect { timestamp ->
                _uiState.update { it.copy(lastRefreshTime = timestamp) }
            }
        }
        scanProgressJob = viewModelScope.launch {
            smbLibraryRepository.observeAllScanProgress().collect { progressByConfig ->
                val isRunning = progressByConfig.values.any { progress -> progress.isRunning }
                _uiState.update { state ->
                    state.copy(
                        isRefreshing = isRunning,
                        scanProgressByConfig = progressByConfig,
                        showScanTargetSheet = if (isRunning && state.scanTargetSheetMode == ScanTargetSheetMode.Refresh) {
                            false
                        } else {
                            state.showScanTargetSheet
                        }
                    )
                }
            }
        }
    }

    fun selectTab(index: Int) {
        _uiState.update { it.copy(selectedTab = index) }
    }

    fun showRefreshTargetSheet() {
        val state = _uiState.value
        if (state.smbConfigs.isEmpty() || state.isRefreshing) return
        _uiState.update {
            it.copy(
                showScanTargetSheet = true,
                scanTargetSheetMode = ScanTargetSheetMode.Refresh
            )
        }
    }

    fun showCancelTargetSheet() {
        val runningConfigIds = runningConfigIds()
        if (runningConfigIds.isEmpty()) return
        _uiState.update {
            it.copy(
                showScanTargetSheet = true,
                scanTargetSheetMode = ScanTargetSheetMode.Cancel
            )
        }
    }

    fun dismissScanSheet() {
        _uiState.update {
            it.copy(
                showScanTargetSheet = false,
                scanTargetSheetMode = null
            )
        }
    }

    fun requestQuickScan(configId: String) {
        dismissScanSheet()
        refreshLibrary(configId, quickScan = true)
    }

    fun requestFullScan(configId: String) {
        dismissScanSheet()
        refreshLibrary(configId, quickScan = false)
    }

    fun cancelScan(configId: String) {
        dismissScanSheet()
        viewModelScope.launch {
            smbLibraryRepository.cancelScan(configId)
        }
    }

    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }

    fun addSongToCache(song: Song) {
        viewModelScope.launch {
            if (!song.isCacheDownloadEligible) return@launch
            val smbPath = song.smbPath ?: return@launch
            when (val result = downloadRepository.startDownload(song.id, smbPath, song.smbConfigId)) {
                is DownloadStartResult.Started -> Unit
                is DownloadStartResult.SkippedActive -> {
                    _uiState.update { it.copy(error = "この曲はすでにダウンロード中です") }
                }
                is DownloadStartResult.AlreadyCompleted -> {
                    _uiState.update { it.copy(error = "この曲はすでにキャッシュ済みです") }
                }
                is DownloadStartResult.ConfigResolutionFailed -> {
                    _uiState.update { it.copy(error = result.reason) }
                }
            }
        }
    }

    fun removeSongFromCache(song: Song) {
        viewModelScope.launch {
            val smbPath = song.smbPath ?: return@launch
            downloadRepository.deleteBySmbPath(smbPath, song.smbConfigId)
        }
    }

    fun addAlbumToCache(album: Album) {
        viewModelScope.launch {
            val albumArtist = album.albumArtist.ifBlank { album.artist }
            val targets = _uiState.value.songs.filter { song ->
                song.album == album.name &&
                    song.albumArtist.ifBlank { song.artist } == albumArtist &&
                    song.isCacheDownloadEligible
            }
            targets.forEach { song ->
                val smbPath = song.smbPath ?: return@forEach
                when (val result = downloadRepository.startDownload(song.id, smbPath, song.smbConfigId)) {
                    is DownloadStartResult.Started -> Unit
                    is DownloadStartResult.SkippedActive -> Unit
                    is DownloadStartResult.AlreadyCompleted -> Unit
                    is DownloadStartResult.ConfigResolutionFailed -> {
                        _uiState.update { it.copy(error = result.reason) }
                    }
                }
            }
        }
    }

    fun removeAlbumFromCache(album: Album) {
        viewModelScope.launch {
            val albumArtist = album.albumArtist.ifBlank { album.artist }
            val targets = _uiState.value.songs.filter { song ->
                song.album == album.name &&
                    song.albumArtist.ifBlank { song.artist } == albumArtist &&
                    song.isCached &&
                    !song.smbPath.isNullOrBlank()
            }
            targets.forEach { song ->
                val smbPath = song.smbPath ?: return@forEach
                downloadRepository.deleteBySmbPath(smbPath, song.smbConfigId)
            }
        }
    }

    private fun bindLibraryContent() {
        songsJob?.cancel()
        albumsJob?.cancel()
        artistsJob?.cancel()

        songsJob = viewModelScope.launch {
            smbLibraryRepository.getAllSongs().collect { songs ->
                _uiState.update { state ->
                    state.copy(
                        songs = songs,
                        hasCachedContent = songs.isNotEmpty() || state.albums.isNotEmpty() || state.artists.isNotEmpty()
                    )
                }
            }
        }
        albumsJob = viewModelScope.launch {
            smbLibraryRepository.getAllAlbums().collect { albums ->
                _uiState.update { state ->
                    state.copy(
                        albums = albums,
                        hasCachedContent = state.songs.isNotEmpty() || albums.isNotEmpty() || state.artists.isNotEmpty()
                    )
                }
            }
        }
        artistsJob = viewModelScope.launch {
            smbLibraryRepository.getAllArtists().collect { artists ->
                _uiState.update { state ->
                    state.copy(
                        artists = artists,
                        hasCachedContent = state.songs.isNotEmpty() || state.albums.isNotEmpty() || artists.isNotEmpty()
                    )
                }
            }
        }
    }

    private fun refreshLibrary(configId: String, quickScan: Boolean) {
        viewModelScope.launch {
            smbLibraryRepository.enqueueScan(configId, quickScan)
        }
    }

    private fun runningConfigIds(): Set<String> =
        _uiState.value.scanProgressByConfig
            .asSequence()
            .filter { (_, progress) -> progress.isRunning }
            .map { (configId, _) -> configId }
            .toSet()
}
