package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.Icon
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SongCacheStatus
import com.example.aero_stream_for_android.domain.model.cacheStatus
import com.example.aero_stream_for_android.ui.components.AeroModalSheet
import com.example.aero_stream_for_android.ui.components.AeroSheetScaffold
import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.library.LibraryFeatureState
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.smb.SmbLibraryViewModel

@Composable
fun SmbLibraryContent(
    featureState: LibraryFeatureState,
    onNavigateToPlayer: () -> Unit = {},
    onNavigateToAlbumDetail: (Album, MusicSource?, String?) -> Unit = { _, _, _ -> },
    onNavigateToArtistDetail: (String, MusicSource?, String?) -> Unit = { _, _, _ -> },
    openScanOptionsRequestToken: Int = 0,
    cancelScanRequestToken: Int = 0,
    viewModel: SmbLibraryViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val playerState by playerViewModel.playerState.collectAsStateWithLifecycle()

    LaunchedEffect(openScanOptionsRequestToken) {
        if (openScanOptionsRequestToken > 0) {
            viewModel.showScanSheet()
        }
    }

    LaunchedEffect(cancelScanRequestToken) {
        if (cancelScanRequestToken > 0) {
            viewModel.cancelScan()
        }
    }

    if (uiState.showScanOptionsSheet) {
        AeroModalSheet(onDismissRequest = viewModel::dismissScanSheet) {
            AeroSheetScaffold(
                title = "SMB ライブラリ更新",
                onDismiss = viewModel::dismissScanSheet
            ) {
                SmbScanOptionRow(
                    title = "クイックスキャン",
                    description = "変更された曲だけを優先して確認します。",
                    icon = Icons.Default.Bolt,
                    onClick = viewModel::requestQuickScan
                )
                SmbScanOptionRow(
                    title = "フルスキャン",
                    description = "ライブラリ全体を最初から再確認します。",
                    icon = Icons.Default.Refresh,
                    onClick = viewModel::requestFullScan
                )
            }
        }
    }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = 96.dp)
    ) {
        when {
            uiState.selectedSmbConfig == null -> {
                item { LibraryEmptyState("SMBサーバーが設定されていません") }
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
                item { LibraryEmptyState("まだ SMB ライブラリを読み込んでいません") }
            }

            else -> {
                when (featureState.category) {
                    LibraryCategory.Songs -> {
                        val songs = uiState.songs
                            .sortedWith(songComparator(featureState.sort.key, featureState.sort.order))
                        if (songs.isEmpty()) {
                            item { LibraryEmptyState("曲はまだありません") }
                        } else {
                            items(songs) { song ->
                                LibrarySongRow(
                                    song = song,
                                    onClick = {
                                        playerViewModel.playQueue(songs, songs.indexOf(song))
                                        onNavigateToPlayer()
                                    },
                                    menuItems = when (song.cacheStatus) {
                                        SongCacheStatus.SMB_NOT_CACHED -> listOf(
                                            LibraryRowMenuItem(
                                                id = "cache_add_${song.id}",
                                                label = "キャッシュにダウンロード追加",
                                                leadingIcon = Icons.Default.Download,
                                                onClick = { viewModel.addSongToCache(song) }
                                            )
                                        )

                                        SongCacheStatus.CACHED -> listOf(
                                            LibraryRowMenuItem(
                                                id = "cache_remove_${song.id}",
                                                label = "キャッシュから削除",
                                                isDestructive = true,
                                                leadingIcon = Icons.Default.Delete,
                                                onClick = { viewModel.removeSongFromCache(song) }
                                            )
                                        )

                                        SongCacheStatus.NONE -> emptyList()
                                    },
                                    isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying,
                                    style = LibrarySongRowStyle.WithStatusBadge
                                )
                            }
                        }
                    }

                    LibraryCategory.Albums -> {
                        val albums = uiState.albums
                            .sortedWith(albumComparator(featureState.sort.key, featureState.sort.order))
                        if (albums.isEmpty()) {
                            item { LibraryEmptyState("アルバムはまだありません") }
                        } else {
                            items(albums) { album ->
                                LibraryAlbumRow(
                                    albumName = album.name,
                                    subtitle = "アルバム・${album.artist}・${album.songCount}曲",
                                    albumArtUri = album.albumArtUri,
                                    showStatusBadge = true,
                                    isFullyCached = album.isFullyCached,
                                    menuItems = if (album.isFullyCached) {
                                        listOf(
                                            LibraryRowMenuItem(
                                                id = "album_cache_remove_${album.name}_${album.artist}",
                                                label = "キャッシュから削除",
                                                isDestructive = true,
                                                leadingIcon = Icons.Default.Delete,
                                                onClick = { viewModel.removeAlbumFromCache(album) }
                                            )
                                        )
                                    } else {
                                        listOf(
                                            LibraryRowMenuItem(
                                                id = "album_cache_add_${album.name}_${album.artist}",
                                                label = "キャッシュにダウンロード追加",
                                                leadingIcon = Icons.Default.Download,
                                                onClick = { viewModel.addAlbumToCache(album) }
                                            )
                                        )
                                    },
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
                            item { LibraryEmptyState("アーティストはまだありません") }
                        } else {
                            items(artists) { artist ->
                                LibraryArtistRow(
                                    artistName = artist.name,
                                    songCount = artist.songCount,
                                    onClick = {
                                        onNavigateToArtistDetail(
                                            artist.name,
                                            MusicSource.SMB,
                                            uiState.selectedSmbConfig?.id
                                        )
                                    }
                                )
                            }
                        }
                    }

                    else -> item { LibraryEmptyState("このカテゴリはまだ利用できません") }
                }
            }
        }
    }
}

@Composable
private fun SmbScanOptionRow(
    title: String,
    description: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    onClick: () -> Unit
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 6.dp)
            .clickable(onClick = onClick),
        shape = MaterialTheme.shapes.large,
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.45f)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 14.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurface
            )
            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(start = 14.dp)
            ) {
                Text(
                    text = title,
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    text = description,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
    }
}
