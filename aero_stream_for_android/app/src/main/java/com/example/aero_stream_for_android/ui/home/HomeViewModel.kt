package com.example.aero_stream_for_android.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.repository.DownloadRepository
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.isCacheDownloadEligible
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import javax.inject.Inject

data class HomeUiState(
    val recentlyPlayed: List<Song> = emptyList(),
    val mostPlayed: List<Song> = emptyList(),
    val isLoading: Boolean = false,
    val error: String? = null
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val musicRepository: MusicRepository,
    private val settingsRepository: SettingsRepository,
    private val downloadRepository: DownloadRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState(isLoading = true))
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()
    private var homeDataLoaded = false
    private var localScanRunning = false

    init {
        loadHomeData()
        observeLocalScanProgress()
    }

    private fun loadHomeData() {
        viewModelScope.launch {
            musicRepository.getRecentlyPlayed(20).collect { recent ->
                _uiState.update { it.copy(recentlyPlayed = recent) }
            }
        }
        viewModelScope.launch {
            musicRepository.getMostPlayed(20).collect { most ->
                homeDataLoaded = true
                _uiState.update {
                    it.copy(
                        mostPlayed = most,
                        isLoading = !homeDataLoaded || localScanRunning
                    )
                }
            }
        }
    }

    private fun observeLocalScanProgress() {
        viewModelScope.launch {
            musicRepository.observeLocalScanProgress().collect { progress ->
                localScanRunning = progress.isRunning
                _uiState.update {
                    it.copy(
                        isLoading = !homeDataLoaded || localScanRunning,
                        error = if (progress.stage == com.example.aero_stream_for_android.data.scan.LibraryScanStage.FAILED) {
                            progress.message.ifBlank { it.error }
                        } else {
                            it.error
                        }
                    )
                }
            }
        }
    }

    fun refreshLocalMusic() {
        viewModelScope.launch {
            try {
                musicRepository.refreshLocalMusic()
            } catch (e: Exception) {
                _uiState.update { it.copy(error = e.message) }
            }
        }
    }

    fun addSongToCache(song: Song) {
        viewModelScope.launch {
            if (!song.isCacheDownloadEligible) return@launch
            val smbPath = song.smbPath ?: return@launch
            val configId = settingsRepository.getSelectedSmbConfig()?.id ?: return@launch
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
}
