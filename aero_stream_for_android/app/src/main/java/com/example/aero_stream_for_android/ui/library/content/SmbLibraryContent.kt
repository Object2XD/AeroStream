package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Album
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.Artist
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.components.SongListItem
import com.example.aero_stream_for_android.ui.components.SongListItemStyle
import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.library.LibraryFeatureState
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.smb.SmbLibraryViewModel
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun SmbLibraryContent(
    featureState: LibraryFeatureState,
    onNavigateToPlayer: () -> Unit = {},
    onNavigateToAlbumDetail: (Album, MusicSource?, String?) -> Unit = { _, _, _ -> },
    viewModel: SmbLibraryViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val playerState by playerViewModel.playerState.collectAsStateWithLifecycle()

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = 96.dp)
    ) {
        when {
            uiState.selectedSmbConfig == null -> {
                item { EmptyState("SMBサーバーが設定されていません") }
            }

            uiState.isLoading -> {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(260.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator()
                    }
                }
            }

            !uiState.hasCachedContent -> {
                item { EmptyState("まだ SMB ライブラリを読み込んでいません") }
            }

            else -> {
                when (featureState.category) {
                    LibraryCategory.Songs -> {
                        val songs = uiState.songs
                            .sortedWith(songComparator(featureState.sort.key, featureState.sort.order))
                        if (songs.isEmpty()) {
                            item { EmptyState("曲はまだありません") }
                        } else {
                            items(songs) { song ->
                                if (song.duration == 0L || song.albumArtUri == null) {
                                    androidx.compose.runtime.LaunchedEffect(song.id, song.sourceUpdatedAt) {
                                        viewModel.requestMetadataExtraction(song)
                                    }
                                }
                                SongListItem(
                                    song = song,
                                    onClick = {
                                        playerViewModel.playQueue(songs, songs.indexOf(song))
                                        onNavigateToPlayer()
                                    },
                                    isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying,
                                    style = SongListItemStyle.WithStatusBadge
                                )
                            }
                        }
                    }

                    LibraryCategory.Albums -> {
                        val albums = uiState.albums
                            .sortedWith(albumComparator(featureState.sort.key, featureState.sort.order))
                        if (albums.isEmpty()) {
                            item { EmptyState("アルバムはまだありません") }
                        } else {
                            items(albums) { album ->
                                SmbAlbumRow(
                                    album = album,
                                    showStatusBadge = true,
                                    onClick = {
                                        onNavigateToAlbumDetail(album, MusicSource.SMB, uiState.selectedSmbConfig?.id)
                                    }
                                )
                            }
                        }
                    }

                    LibraryCategory.Artists -> {
                        val artists = uiState.artists
                            .sortedWith(artistComparator(featureState.sort.key, featureState.sort.order))
                        if (artists.isEmpty()) {
                            item { EmptyState("アーティストはまだありません") }
                        } else {
                            items(artists) { artist ->
                                SmbArtistRow(artist)
                            }
                        }
                    }

                    else -> item { EmptyState("このカテゴリはまだ利用できません") }
                }
            }
        }
    }
}

@Composable
private fun SmbAlbumRow(
    album: Album,
    showStatusBadge: Boolean,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        MediaArtwork(imageModel = album.albumArtUri, placeholder = Icons.Default.Album)
        Column(
            modifier = Modifier
                .weight(1f)
                .padding(start = 12.dp)
        ) {
            Text(text = album.name, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (showStatusBadge) {
                    AlbumCacheBadge(isFullyCached = album.isFullyCached)
                    Spacer(modifier = Modifier.width(6.dp))
                }
                Text(
                    text = "アルバム・${album.artist}・${album.songCount}曲",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}

@Composable
private fun SmbArtistRow(artist: Artist) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Surface(
            modifier = Modifier.size(AeroCompactUiTokens.listArtworkSize),
            shape = androidx.compose.foundation.shape.CircleShape,
            color = MaterialTheme.colorScheme.surfaceVariant
        ) {
            Box(contentAlignment = Alignment.Center) {
                androidx.compose.material3.Icon(Icons.Default.Person, contentDescription = null)
            }
        }
        Column(
            modifier = Modifier
                .weight(1f)
                .padding(start = 12.dp)
        ) {
            Text(text = artist.name, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(
                text = "アーティスト・${artist.songCount}曲",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
