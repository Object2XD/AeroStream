package com.example.aero_stream_for_android.ui.smb

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.repository.DownloadRepository
import com.example.aero_stream_for_android.data.smb.SmbScanProgress
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.data.repository.SmbLibraryRepository
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

data class SmbLibraryUiState(
    val selectedTab: Int = 0,
    val songs: List<Song> = emptyList(),
    val albums: List<Album> = emptyList(),
    val artists: List<Artist> = emptyList(),
    val isLoading: Boolean = true,
    val isRefreshing: Boolean = false,
    val error: String? = null,
    val selectedSmbConfig: SmbConfig? = null,
    val selectedSourceLabel: String = "",
    val selectedSourcePathLabel: String = "",
    val lastRefreshTime: Long? = null,
    val hasCachedContent: Boolean = false,
    val scanProgress: SmbScanProgress = SmbScanProgress(),
    val showScanOptionsSheet: Boolean = false
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
            settingsRepository.selectedSmbConfig.collect { config ->
                _uiState.update {
                    it.copy(
                        selectedSmbConfig = config,
                        selectedSourceLabel = config?.displayName.orEmpty(),
                        selectedSourcePathLabel = config?.let(::buildSourcePathLabel).orEmpty(),
                        isLoading = false,
                        error = if (config == null) "SMBサーバーが設定されていません" else null
                    )
                }
                bindConfig(config)
            }
        }
    }

    fun selectTab(index: Int) {
        _uiState.update { it.copy(selectedTab = index) }
    }

    fun refreshLibrary(quickScan: Boolean = true) {
        val config = _uiState.value.selectedSmbConfig ?: return
        viewModelScope.launch {
            smbLibraryRepository.enqueueScan(config.id, quickScan)
        }
    }

    fun showScanSheet() {
        if (_uiState.value.isRefreshing || _uiState.value.selectedSmbConfig == null) return
        _uiState.update { it.copy(showScanOptionsSheet = true) }
    }

    fun dismissScanSheet() {
        _uiState.update { it.copy(showScanOptionsSheet = false) }
    }

    fun requestQuickScan() {
        dismissScanSheet()
        refreshLibrary(quickScan = true)
    }

    fun requestFullScan() {
        dismissScanSheet()
        refreshLibrary(quickScan = false)
    }

    fun cancelScan() {
        val config = _uiState.value.selectedSmbConfig ?: return
        viewModelScope.launch {
            smbLibraryRepository.cancelScan(config.id)
        }
    }

    fun clearError() {
        _uiState.update { it.copy(error = null) }
    }

    fun addSongToCache(song: Song) {
        viewModelScope.launch {
            if (!song.isCacheDownloadEligible) return@launch
            val smbPath = song.smbPath ?: return@launch
            val configId = _uiState.value.selectedSmbConfig?.id ?: return@launch
            if (downloadRepository.hasDownloadEntry(smbPath)) return@launch
            downloadRepository.startDownload(song.id, smbPath, configId)
        }
    }

    fun removeSongFromCache(song: Song) {
        viewModelScope.launch {
            val smbPath = song.smbPath ?: return@launch
            downloadRepository.deleteBySmbPath(smbPath)
        }
    }

    fun addAlbumToCache(album: Album) {
        viewModelScope.launch {
            val configId = _uiState.value.selectedSmbConfig?.id ?: return@launch
            val albumArtist = album.albumArtist.ifBlank { album.artist }
            val targets = _uiState.value.songs.filter { song ->
                song.album == album.name &&
                    song.albumArtist.ifBlank { song.artist } == albumArtist &&
                    song.isCacheDownloadEligible
            }
            targets.forEach { song ->
                val smbPath = song.smbPath ?: return@forEach
                if (!downloadRepository.hasDownloadEntry(smbPath)) {
                    downloadRepository.startDownload(song.id, smbPath, configId)
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
                downloadRepository.deleteBySmbPath(smbPath)
            }
        }
    }

    private fun bindConfig(config: SmbConfig?) {
        songsJob?.cancel()
        albumsJob?.cancel()
        artistsJob?.cancel()
        refreshTimeJob?.cancel()
        scanProgressJob?.cancel()

        if (config == null || config.id.isBlank()) {
            _uiState.update {
                it.copy(
                    songs = emptyList(),
                    albums = emptyList(),
                    artists = emptyList(),
                    selectedSourceLabel = "",
                    selectedSourcePathLabel = "",
                    lastRefreshTime = null,
                    hasCachedContent = false,
                    scanProgress = SmbScanProgress(),
                    showScanOptionsSheet = false
                )
            }
            return
        }

        bindLibraryContent(config)

        refreshTimeJob = viewModelScope.launch {
            smbLibraryRepository.getLastRefreshTime(config.id).collect { timestamp ->
                _uiState.update { it.copy(lastRefreshTime = timestamp) }
            }
        }
        scanProgressJob = viewModelScope.launch {
            smbLibraryRepository.observeScanProgress(config.id).collect { progress ->
                _uiState.update {
                    it.copy(
                        isRefreshing = progress.isRunning,
                        scanProgress = progress,
                        showScanOptionsSheet = if (progress.isRunning) false else it.showScanOptionsSheet
                    )
                }
            }
        }
    }

    private fun bindLibraryContent(config: SmbConfig) {
        songsJob?.cancel()
        albumsJob?.cancel()
        artistsJob?.cancel()

        songsJob = viewModelScope.launch {
            smbLibraryRepository.getSongs(config.id).collect { songs ->
                _uiState.update { state ->
                    state.copy(
                        songs = songs,
                        hasCachedContent = songs.isNotEmpty() || state.albums.isNotEmpty() || state.artists.isNotEmpty()
                    )
                }
            }
        }
        albumsJob = viewModelScope.launch {
            smbLibraryRepository.getAlbums(config.id).collect { albums ->
                _uiState.update { state ->
                    state.copy(
                        albums = albums,
                        hasCachedContent = state.songs.isNotEmpty() || albums.isNotEmpty() || state.artists.isNotEmpty()
                    )
                }
            }
        }
        artistsJob = viewModelScope.launch {
            smbLibraryRepository.getArtists(config.id).collect { artists ->
                _uiState.update { state ->
                    state.copy(
                        artists = artists,
                        hasCachedContent = state.songs.isNotEmpty() || state.albums.isNotEmpty() || artists.isNotEmpty()
                    )
                }
            }
        }
    }

    private fun buildSourcePathLabel(config: SmbConfig): String {
        return buildString {
            append("${config.hostname}/${config.shareName}")
            if (config.rootPath.isNotBlank()) {
                append("/${config.rootPath}")
            }
        }
    }
}
