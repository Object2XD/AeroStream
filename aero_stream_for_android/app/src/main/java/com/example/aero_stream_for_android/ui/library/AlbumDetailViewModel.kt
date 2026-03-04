package com.example.aero_stream_for_android.ui.library

import android.net.Uri
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.navigation.Screen
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class AlbumDetailUiState(
    val album: Album? = null,
    val songs: List<Song> = emptyList(),
    val isLoading: Boolean = true,
    val error: String? = null,
    val source: MusicSource? = null,
    val smbConfigId: String? = null,
    val totalDurationMs: Long = 0L
) {
    val displayArtist: String
        get() = album?.albumArtist?.ifBlank { album.artist }.orEmpty()

    val displayYear: String?
        get() = album?.year?.let { "${it}年" }

    val headerSubtitle: String
        get() = buildList {
            add("アルバム")
            displayYear?.let { add(it) }
        }.joinToString("・")

    val footerSummary: String
        get() {
            val totalMinutes = if (totalDurationMs <= 0L) {
                0L
            } else {
                (totalDurationMs + 59_999L) / 60_000L
            }
            return "${songs.size}曲・${totalMinutes}分"
        }
}

@HiltViewModel
class AlbumDetailViewModel @Inject constructor(
    private val musicRepository: MusicRepository,
    savedStateHandle: SavedStateHandle
) : ViewModel() {

    private val albumName = savedStateHandle.get<String>(Screen.AlbumDetail.albumNameArg).orEmpty()
    private val albumArtist = savedStateHandle.get<String>(Screen.AlbumDetail.albumArtistArg).orEmpty()
    private val source = savedStateHandle.get<String>(Screen.AlbumDetail.sourceArg)
        ?.takeIf { it.isNotBlank() }
        ?.let { MusicSource.valueOf(it) }
    private val smbConfigId = savedStateHandle.get<String>(Screen.AlbumDetail.smbConfigIdArg).orEmpty()
        .ifBlank { null }
    private val year = savedStateHandle.get<String>(Screen.AlbumDetail.yearArg)?.toIntOrNull()

    private val _uiState = MutableStateFlow(
        AlbumDetailUiState(
            album = buildAlbum(albumArtUri = null, songCount = 0),
            source = source,
            smbConfigId = smbConfigId
        )
    )
    val uiState: StateFlow<AlbumDetailUiState> = _uiState.asStateFlow()

    init {
        loadAlbum()
    }

    private fun loadAlbum() {
        if (albumName.isBlank()) {
            _uiState.update {
                it.copy(
                    isLoading = false,
                    error = "アルバム情報が見つかりませんでした"
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
                MusicSource.SMB -> musicRepository.getSongsByAlbumSourceAndSmbConfig(
                    album = albumName,
                    albumArtist = albumArtist,
                    source = MusicSource.SMB,
                    smbConfigId = smbConfigId.orEmpty()
                )

                MusicSource.LOCAL -> musicRepository.getSongsByAlbumAndSource(
                    album = albumName,
                    albumArtist = albumArtist,
                    source = MusicSource.LOCAL
                )

                MusicSource.DOWNLOAD -> musicRepository.getSongsByAlbumAndSource(
                    album = albumName,
                    albumArtist = albumArtist,
                    source = MusicSource.DOWNLOAD
                )

                null -> musicRepository.getSongsByAlbum(
                    album = albumName,
                    albumArtist = albumArtist
                )
            }

            songsFlow.collect { songs ->
                val albumArtUri = songs.firstOrNull()?.albumArtUri
                val displayArtist = songs.firstOrNull()?.albumArtist
                    ?.ifBlank { songs.firstOrNull()?.artist.orEmpty() }
                    .orEmpty()
                    .ifBlank { albumArtist }
                _uiState.update {
                    it.copy(
                        album = buildAlbum(
                            albumArtUri = albumArtUri,
                            songCount = songs.size,
                            resolvedArtist = displayArtist
                        ),
                        songs = songs,
                        isLoading = false,
                        error = null,
                        totalDurationMs = songs.sumOf { song -> song.duration }
                    )
                }
            }
        }
    }

    private fun buildAlbum(
        albumArtUri: Uri?,
        songCount: Int,
        resolvedArtist: String = albumArtist
    ): Album {
        return Album(
            id = 0L,
            name = albumName,
            artist = resolvedArtist,
            albumArtist = resolvedArtist,
            albumArtUri = albumArtUri,
            songCount = songCount,
            year = year
        )
    }
}
