package com.example.aero_stream_for_android.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.domain.model.Song
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
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
    private val musicRepository: MusicRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState(isLoading = true))
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadHomeData()
    }

    private fun loadHomeData() {
        viewModelScope.launch {
            musicRepository.getRecentlyPlayed(20).collect { recent ->
                _uiState.update { it.copy(recentlyPlayed = recent) }
            }
        }
        viewModelScope.launch {
            musicRepository.getMostPlayed(20).collect { most ->
                _uiState.update { it.copy(mostPlayed = most, isLoading = false) }
            }
        }
    }

    fun refreshLocalMusic() {
        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true) }
            try {
                musicRepository.refreshLocalMusic()
            } catch (e: Exception) {
                _uiState.update { it.copy(error = e.message) }
            } finally {
                _uiState.update { it.copy(isLoading = false) }
            }
        }
    }
}
