package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.QueueMusic
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Album
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.Artist
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Playlist
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.components.SongListItem
import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.library.LibraryFeatureState
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.LibraryViewModel
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun LocalLibraryContent(
    featureState: LibraryFeatureState,
    onNavigateToPlayer: () -> Unit = {},
    onNavigateToAlbumDetail: (Album, MusicSource?, String?) -> Unit = { _, _, _ -> },
    libraryViewModel: LibraryViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by libraryViewModel.uiState.collectAsStateWithLifecycle()
    val playerState by playerViewModel.playerState.collectAsStateWithLifecycle()
    var showCreatePlaylistDialog by remember { mutableStateOf(false) }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = 96.dp)
    ) {
        when (featureState.category) {
            LibraryCategory.Songs -> {
                val songs = uiState.songs
                    .sortedWith(songComparator(featureState.sort.key, featureState.sort.order))
                if (songs.isEmpty()) {
                    item { EmptyState("曲はまだありません") }
                } else {
                    items(songs) { song ->
                        SongListItem(
                            song = song,
                            onClick = {
                                playerViewModel.playQueue(songs, songs.indexOf(song))
                                onNavigateToPlayer()
                            },
                            isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying,
                            showDownloadIcon = true
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
                        AlbumRow(
                            album = album,
                            onClick = { onNavigateToAlbumDetail(album, null, null) }
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
                        ArtistRow(artist)
                    }
                }
            }

            LibraryCategory.Playlists -> {
                val playlists = uiState.playlists
                    .sortedWith(playlistComparator(featureState.sort.key, featureState.sort.order))
                item {
                    Button(
                        onClick = { showCreatePlaylistDialog = true },
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
                    ) {
                        Icon(Icons.Default.Add, contentDescription = null)
                        Spacer(modifier = Modifier.size(8.dp))
                        Text("新規プレイリスト")
                    }
                }
                if (playlists.isEmpty()) {
                    item { EmptyState("プレイリストはまだありません") }
                } else {
                    items(playlists) { playlist ->
                        PlaylistRow(
                            playlist = playlist,
                            onDelete = { libraryViewModel.deletePlaylist(playlist.id) }
                        )
                    }
                }
            }

            else -> {
                item {
                    EmptyState("このカテゴリはまだ利用できません")
                }
            }
        }
    }

    if (showCreatePlaylistDialog) {
        var playlistName by remember { mutableStateOf("") }
        AlertDialog(
            onDismissRequest = { showCreatePlaylistDialog = false },
            title = { Text("プレイリストを作成") },
            text = {
                OutlinedTextField(
                    value = playlistName,
                    onValueChange = { playlistName = it },
                    label = { Text("プレイリスト名") },
                    singleLine = true
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        if (playlistName.isNotBlank()) {
                            libraryViewModel.createPlaylist(playlistName)
                            showCreatePlaylistDialog = false
                        }
                    }
                ) {
                    Text("作成")
                }
            },
            dismissButton = {
                TextButton(onClick = { showCreatePlaylistDialog = false }) {
                    Text("キャンセル")
                }
            }
        )
    }
}

@Composable
internal fun AlbumRow(album: Album, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        MediaArtwork(album.albumArtUri, Icons.Default.Album)
        Column(
            modifier = Modifier
                .weight(1f)
                .padding(start = 12.dp)
        ) {
            Text(text = album.name, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(
                text = listOfNotNull("アルバム", album.artist, album.year?.toString()).joinToString("・"),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
private fun ArtistRow(artist: Artist) {
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
                Icon(Icons.Default.Person, contentDescription = null)
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

@Composable
private fun PlaylistRow(playlist: Playlist, onDelete: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        MediaArtwork(playlist.songs.firstOrNull()?.albumArtUri, Icons.AutoMirrored.Filled.QueueMusic)
        Column(
            modifier = Modifier
                .weight(1f)
                .padding(start = 12.dp)
        ) {
            Text(text = playlist.name, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(
                text = "プレイリスト・${playlist.songCount}曲",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        IconButton(onClick = onDelete) {
            Icon(Icons.Default.Delete, contentDescription = "Delete")
        }
    }
}

@Composable
internal fun EmptyState(title: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(260.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

internal fun songComparator(key: LibrarySortKey, order: SortOrder): Comparator<Song> =
    compareBy<Song> {
        when (key) {
            LibrarySortKey.Artist -> it.artist.lowercase()
            LibrarySortKey.Album -> it.album.lowercase()
            LibrarySortKey.AddedDate -> (it.sourceUpdatedAt ?: 0L).toString()
            LibrarySortKey.LastPlayed -> (it.lastPlayedAt ?: 0L).toString()
            else -> it.title.lowercase()
        }
    }.direction(order)

internal fun albumComparator(key: LibrarySortKey, order: SortOrder): Comparator<Album> =
    compareBy<Album> {
        when (key) {
            LibrarySortKey.Artist -> it.artist.lowercase()
            LibrarySortKey.Year -> it.year ?: Int.MIN_VALUE
            else -> it.name.lowercase()
        }
    }.direction(order)

internal fun artistComparator(key: LibrarySortKey, order: SortOrder): Comparator<Artist> =
    compareBy<Artist> {
        when (key) {
            LibrarySortKey.SongCount -> it.songCount
            else -> it.name.lowercase()
        }
    }.direction(order)

internal fun playlistComparator(key: LibrarySortKey, order: SortOrder): Comparator<Playlist> =
    compareBy<Playlist> {
        when (key) {
            LibrarySortKey.CreatedAt -> it.createdAt
            else -> it.name.lowercase()
        }
    }.direction(order)

internal fun <T> Comparator<T>.direction(order: SortOrder): Comparator<T> = when (order) {
    SortOrder.Asc -> this
    SortOrder.Desc -> reversed()
}
