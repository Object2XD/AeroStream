package com.example.aero_stream_for_android.ui.search

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.Song
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.FlowPreview
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SearchUiState(
    val query: String = "",
    val recentSearches: List<String> = emptyList(),
    val results: List<Song> = emptyList(),
    val isSearching: Boolean = false
)

@OptIn(FlowPreview::class)
@HiltViewModel
class SearchViewModel @Inject constructor(
    private val musicRepository: MusicRepository,
    private val settingsRepository: SettingsRepository
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
}
