package com.example.aero_stream_for_android.ui.library

import android.net.Uri
import androidx.lifecycle.SavedStateHandle
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.download.DownloadManager
import com.example.aero_stream_for_android.data.local.db.entity.DownloadState
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.isCacheDownloadEligible
import com.example.aero_stream_for_android.ui.navigation.Screen
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.collect
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.MutableSharedFlow
import kotlinx.coroutines.flow.SharedFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.asSharedFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class AlbumDetailUiState(
    val album: Album? = null,
    val songs: List<Song> = emptyList(),
    val isLoading: Boolean = true,
    val error: String? = null,
    val source: MusicSource? = null,
    val smbConfigId: String? = null,
    val totalDurationMs: Long = 0L,
    val activeDownloadsBySmbPath: Map<String, TrackDownloadVisualState> = emptyMap()
) {
    val isSmbContext: Boolean
        get() = source == MusicSource.SMB || source == MusicSource.DOWNLOAD

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

    val pendingSmbSongs: List<Song>
        get() = songs.filter { song -> song.isCacheDownloadEligible }

    val isAlbumCached: Boolean
        get() = isSmbContext && pendingSmbSongs.isEmpty()

    val isDownloadActionEnabled: Boolean
        get() = isSmbContext && !isLoading && pendingSmbSongs.isNotEmpty()
}

data class TrackDownloadVisualState(
    val state: String,
    val progress: Float?
)

@HiltViewModel
class AlbumDetailViewModel @Inject constructor(
    private val musicRepository: MusicRepository,
    private val downloadManager: DownloadManager,
    private val settingsRepository: SettingsRepository,
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
    private val _toastMessages = MutableSharedFlow<String>(extraBufferCapacity = 1)
    val toastMessages: SharedFlow<String> = _toastMessages.asSharedFlow()

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

        viewModelScope.launch {
            val songsFlow = when (source) {
                MusicSource.SMB -> {
                    val configId = smbConfigId
                    if (!configId.isNullOrBlank()) {
                        musicRepository.getSongsByAlbumSourceAndSmbConfig(
                            album = albumName,
                            albumArtist = albumArtist,
                            source = MusicSource.SMB,
                            smbConfigId = configId
                        )
                    } else {
                        musicRepository.getSongsByAlbumAndSource(
                            album = albumName,
                            albumArtist = albumArtist,
                            source = MusicSource.SMB
                        )
                    }
                }

                MusicSource.LOCAL -> musicRepository.getSongsByAlbumAndSource(
                    album = albumName,
                    albumArtist = albumArtist,
                    source = MusicSource.LOCAL
                )

                MusicSource.DOWNLOAD -> {
                    val configId = smbConfigId
                    if (!configId.isNullOrBlank()) {
                        musicRepository.getSongsByAlbumSourceAndSmbConfig(
                            album = albumName,
                            albumArtist = albumArtist,
                            source = MusicSource.SMB,
                            smbConfigId = configId
                        )
                    } else {
                        musicRepository.getSongsByAlbumAndSource(
                            album = albumName,
                            albumArtist = albumArtist,
                            source = MusicSource.SMB
                        )
                    }
                }

                null -> musicRepository.getSongsByAlbum(
                    album = albumName,
                    albumArtist = albumArtist
                )
            }

            combine(songsFlow, downloadManager.observeAllDownloads()) { songs, downloads ->
                songs to downloads
            }.collect { (songs, downloads) ->
                val albumArtUri = songs.firstOrNull()?.albumArtUri
                val displayArtist = songs.firstOrNull()?.albumArtist
                    ?.ifBlank { songs.firstOrNull()?.artist.orEmpty() }
                    .orEmpty()
                    .ifBlank { albumArtist }
                val activeDownloads = downloads
                    .asSequence()
                    .filter { it.state == DownloadState.PENDING || it.state == DownloadState.DOWNLOADING }
                    .associate { download ->
                        val progress = if (download.fileSize > 0L) {
                            (download.downloadedBytes.toFloat() / download.fileSize.toFloat()).coerceIn(0f, 1f)
                        } else {
                            null
                        }
                        download.smbPath to TrackDownloadVisualState(
                            state = download.state,
                            progress = progress
                        )
                    }
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
                        totalDurationMs = songs.sumOf { song -> song.duration },
                        activeDownloadsBySmbPath = activeDownloads
                    )
                }
            }
        }
    }

    fun cacheAlbumTracks() {
        viewModelScope.launch {
            val state = _uiState.value
            if (!state.isSmbContext) {
                return@launch
            }

            val config = (state.smbConfigId?.let { settingsRepository.getSmbConfigById(it) }
                ?: settingsRepository.getSelectedSmbConfig())
                ?.takeIf { it.isConfigured && it.id.isNotBlank() }

            if (config == null) {
                _toastMessages.tryEmit("SMB設定が見つかりません")
                return@launch
            }

            val targets = state.pendingSmbSongs
            if (targets.isEmpty()) {
                _toastMessages.tryEmit("このアルバムはすべてキャッシュ済みです")
                return@launch
            }

            var started = 0
            var skipped = 0
            var failed = 0

            for (song in targets) {
                val smbPath = song.smbPath ?: continue
                try {
                    if (downloadManager.hasDownloadEntry(smbPath)) {
                        skipped++
                    } else {
                        downloadManager.startDownload(song.id, smbPath, config.id)
                        started++
                    }
                } catch (_: Exception) {
                    failed++
                }
            }

            _toastMessages.tryEmit("開始:${started} スキップ:${skipped} 失敗:${failed}")
        }
    }

    companion object {
        private val albumTrackComparator = compareBy<Song>(
            { if (it.trackNumber > 0) 0 else 1 },
            { if (it.trackNumber > 0) it.trackNumber else Int.MAX_VALUE },
            { it.title.lowercase() }
        )
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
