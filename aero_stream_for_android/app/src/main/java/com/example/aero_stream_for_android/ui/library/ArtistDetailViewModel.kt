package com.example.aero_stream_for_android.ui.library

import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.navigation.Screen
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class ArtistDetailUiState(
    val artistName: String = "",
    val songs: List<Song> = emptyList(),
    val isLoading: Boolean = true,
    val error: String? = null,
    val source: MusicSource? = null,
    val smbConfigId: String? = null
)

@HiltViewModel
class ArtistDetailViewModel @Inject constructor(
    private val musicRepository: MusicRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val artistName = savedStateHandle.get<String>(Screen.ArtistDetail.artistNameArg).orEmpty()
    private val source = savedStateHandle.get<String>(Screen.ArtistDetail.sourceArg)
        ?.takeIf { it.isNotBlank() }
        ?.let { MusicSource.valueOf(it) }
    private val smbConfigId = savedStateHandle.get<String>(Screen.ArtistDetail.smbConfigIdArg).orEmpty()
        .ifBlank { null }

    private val _uiState = MutableStateFlow(
        ArtistDetailUiState(
            artistName = artistName,
            source = source,
            smbConfigId = smbConfigId
        )
    )
    val uiState: StateFlow<ArtistDetailUiState> = _uiState.asStateFlow()

    init {
        loadSongs()
    }

    private fun loadSongs() {
        if (artistName.isBlank()) {
            _uiState.update {
                it.copy(
                    isLoading = false,
                    error = "アーティスト情報が見つかりませんでした"
                )
            }
            return
        }

        if (source == MusicSource.SMB && smbConfigId.isNullOrBlank()) {
            _uiState.update {
                it.copy(
                    isLoading = false,
                    error = "SMB設定が見つかりませんでした"
                )
            }
            return
        }

        viewModelScope.launch {
            val songsFlow = when (source) {
                MusicSource.SMB -> musicRepository.getSongsByArtistSourceAndSmbConfig(
                    artist = artistName,
                    source = MusicSource.SMB,
                    smbConfigId = smbConfigId.orEmpty()
                )

                MusicSource.LOCAL -> musicRepository.getSongsByArtistAndSource(
                    artist = artistName,
                    source = MusicSource.LOCAL
                )

                MusicSource.DOWNLOAD -> {
                    val configId = smbConfigId
                    if (!configId.isNullOrBlank()) {
                        musicRepository.getSongsByArtistSourceAndSmbConfig(
                            artist = artistName,
                            source = MusicSource.SMB,
                            smbConfigId = configId
                        )
                    } else {
                        musicRepository.getSongsByArtistAndSource(
                            artist = artistName,
                            source = MusicSource.SMB
                        )
                    }
                }

                null -> musicRepository.getSongsByArtistAndSource(
                    artist = artistName,
                    source = MusicSource.LOCAL
                )
            }

            songsFlow.collect { songs ->
                _uiState.update {
                    it.copy(
                        songs = songs,
                        isLoading = false,
                        error = null
                    )
                }
            }
        }
    }
}
