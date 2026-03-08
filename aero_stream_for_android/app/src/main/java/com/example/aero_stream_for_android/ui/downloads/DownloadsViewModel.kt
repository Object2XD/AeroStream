package com.example.aero_stream_for_android.ui.downloads

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.local.db.entity.DownloadEntity
import com.example.aero_stream_for_android.data.local.db.entity.DownloadState
import com.example.aero_stream_for_android.data.repository.DownloadRepository
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.Song
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class DownloadsUiState(
    val downloadedSongs: List<Song> = emptyList(),
    val activeDownloads: List<DownloadEntity> = emptyList(),
    val isLoading: Boolean = false
)

@HiltViewModel
class DownloadsViewModel @Inject constructor(
    private val musicRepository: MusicRepository,
    private val downloadRepository: DownloadRepository,
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(DownloadsUiState(isLoading = true))
    val uiState: StateFlow<DownloadsUiState> = _uiState.asStateFlow()

    init {
        loadDownloads()
    }

    private fun loadDownloads() {
        // ダウンロード済み楽曲の監視
        viewModelScope.launch {
            musicRepository.getCachedSmbSongs().collect { songs ->
                _uiState.update { it.copy(downloadedSongs = songs, isLoading = false) }
            }
        }
        // アクティブなダウンロードの監視
        viewModelScope.launch {
            downloadRepository.getAllDownloads().collect { downloads ->
                _uiState.update {
                    it.copy(activeDownloads = downloads.filter { d ->
                        d.state != DownloadState.COMPLETED
                    })
                }
            }
        }
    }

    fun deleteDownload(downloadId: Long) {
        viewModelScope.launch {
            downloadRepository.deleteDownload(downloadId)
        }
    }

    fun retryDownload(download: DownloadEntity) {
        viewModelScope.launch {
            val selectedConfig = settingsRepository.getSelectedSmbConfig() ?: return@launch
            downloadRepository.startDownload(download.songId, download.smbPath, selectedConfig.id)
        }
    }

    fun removeSongFromCache(song: Song) {
        viewModelScope.launch {
            val smbPath = song.smbPath ?: return@launch
            downloadRepository.deleteBySmbPath(smbPath)
        }
    }
}
