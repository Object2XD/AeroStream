package com.example.aero_stream_for_android.ui.search

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.download.DownloadStartResult
import com.example.aero_stream_for_android.data.repository.DownloadRepository
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.isCacheDownloadEligible
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SearchUiState(
    val query: String = "",
    val recentSearches: List<String> = emptyList(),
    val results: List<Song> = emptyList(),
    val isSearching: Boolean = false,
    val toastMessage: String? = null
)

@OptIn(FlowPreview::class)
@HiltViewModel
class SearchViewModel @Inject constructor(
    private val musicRepository: MusicRepository,
    private val settingsRepository: SettingsRepository,
    private val downloadRepository: DownloadRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SearchUiState())
    val uiState: StateFlow<SearchUiState> = _uiState.asStateFlow()

    private val _searchQuery = MutableStateFlow("")

    init {
        viewModelScope.launch {
            settingsRepository.recentSearches.collect { recentSearches ->
                _uiState.update { it.copy(recentSearches = recentSearches) }
            }
        }

        viewModelScope.launch {
            _searchQuery
                .debounce(300)
                .distinctUntilChanged()
                .collectLatest { query ->
                    if (query.isBlank()) {
                        _uiState.update { it.copy(results = emptyList(), isSearching = false) }
                    } else {
                        _uiState.update { it.copy(isSearching = true) }
                        settingsRepository.saveRecentSearch(query)
                        musicRepository.searchSongs(query).collect { results ->
                            _uiState.update { it.copy(results = results, isSearching = false) }
                        }
                    }
                }
        }
    }

    fun onQueryChanged(query: String) {
        _uiState.update { it.copy(query = query) }
        _searchQuery.value = query
    }

    fun clearSearch() {
        _uiState.update { it.copy(query = "", results = emptyList()) }
        _searchQuery.value = ""
    }

    fun onRecentSearchSelected(query: String) {
        val normalizedQuery = query.trim()
        if (normalizedQuery.isBlank()) return
        _uiState.update { it.copy(query = normalizedQuery) }
        _searchQuery.value = normalizedQuery
    }

    fun clearRecentSearches() {
        viewModelScope.launch {
            settingsRepository.clearRecentSearches()
        }
    }

    fun addSongToCache(song: Song) {
        viewModelScope.launch {
            if (!song.isCacheDownloadEligible) return@launch
            val smbPath = song.smbPath ?: return@launch
            val message = when (val result = downloadRepository.startDownload(song.id, smbPath, song.smbConfigId)) {
                is DownloadStartResult.Started -> if (result.retriedFromFailure) {
                    "前回失敗したダウンロードを再試行しています"
                } else {
                    null
                }
                is DownloadStartResult.SkippedActive -> "この曲はすでにダウンロード中です"
                is DownloadStartResult.AlreadyCompleted -> "この曲はすでにキャッシュ済みです"
                is DownloadStartResult.ConfigResolutionFailed -> result.reason
            }
            if (message != null) {
                _uiState.update { it.copy(toastMessage = message) }
            }
        }
    }

    fun removeSongFromCache(song: Song) {
        viewModelScope.launch {
            val smbPath = song.smbPath ?: return@launch
            downloadRepository.deleteBySmbPath(smbPath, song.smbConfigId)
        }
    }

    fun consumeToastMessage() {
        _uiState.update { it.copy(toastMessage = null) }
    }
}
