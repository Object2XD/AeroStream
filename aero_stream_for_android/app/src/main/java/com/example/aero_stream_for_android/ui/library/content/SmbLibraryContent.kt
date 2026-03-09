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
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.Icon
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
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
import com.example.aero_stream_for_android.ui.root.LocalPlayerSheetBottomClearance
import com.example.aero_stream_for_android.ui.smb.ScanTargetSheetMode
import com.example.aero_stream_for_android.ui.smb.SmbLibraryViewModel
import kotlinx.coroutines.launch

@Composable
fun SmbLibraryContent(
    featureState: LibraryFeatureState,
    onNavigateToAlbumDetail: (Album, MusicSource?, String?) -> Unit = { _, _, _ -> },
    onNavigateToArtistDetail: (String, MusicSource?, String?) -> Unit = { _, _, _ -> },
    openScanOptionsRequestToken: Int = 0,
    cancelScanRequestToken: Int = 0,
    viewModel: SmbLibraryViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val playerState by playerViewModel.playerState.collectAsStateWithLifecycle()
    val listState = rememberLazyListState()
    val scrollController = rememberLibraryScrollController(listState)
    val coroutineScope = rememberCoroutineScope()
    val playerSheetBottomClearance = LocalPlayerSheetBottomClearance.current
    val isNameSort = featureState.sort.key == LibrarySortKey.Name
    val bubbleLabel = if (isNameSort) {
        val targetIndex = scrollController.progressToTarget(scrollController.progress.value).index
        when (featureState.category) {
            LibraryCategory.Songs -> normalizeAlphabetLabel(
                uiState.songs
                    .sortedWith(songComparator(featureState.sort.key, featureState.sort.order))
                    .getOrNull(targetIndex)
                    ?.title
            )
            LibraryCategory.Albums -> normalizeAlphabetLabel(
                uiState.albums
                    .sortedWith(albumComparator(featureState.sort.key, featureState.sort.order))
                    .getOrNull(targetIndex)
                    ?.name
            )
            LibraryCategory.Artists -> normalizeAlphabetLabel(
                uiState.artists
                    .sortedWith(artistComparator(featureState.sort.key, featureState.sort.order))
                    .getOrNull(targetIndex)
                    ?.name
            )
            else -> null
        }
    } else {
        null
    }

    LaunchedEffect(openScanOptionsRequestToken) {
        if (openScanOptionsRequestToken > 0) {
            viewModel.showRefreshTargetSheet()
        }
    }

    LaunchedEffect(cancelScanRequestToken) {
        if (cancelScanRequestToken > 0) {
            viewModel.showCancelTargetSheet()
        }
    }

    if (uiState.showScanTargetSheet) {
        AeroModalSheet(onDismissRequest = viewModel::dismissScanSheet) {
            AeroSheetScaffold(
                title = if (uiState.scanTargetSheetMode == ScanTargetSheetMode.Cancel) {
                    "SMB ライブラリ更新をキャンセル"
                } else {
                    "SMB ライブラリ更新"
                },
                onDismiss = viewModel::dismissScanSheet
            ) {
                val targets = when (uiState.scanTargetSheetMode) {
                    ScanTargetSheetMode.Cancel -> uiState.smbConfigs.filter { config ->
                        uiState.scanProgressByConfig[config.id]?.isRunning == true
                    }

                    ScanTargetSheetMode.Refresh -> uiState.smbConfigs
                    null -> emptyList()
                }
                if (targets.isEmpty()) {
                    SmbScanOptionRow(
                        title = "対象がありません",
                        description = if (uiState.scanTargetSheetMode == ScanTargetSheetMode.Cancel) {
                            "実行中のSMB更新はありません。"
                        } else {
                            "SMBサーバーが設定されていません。"
                        },
                        icon = Icons.Default.Refresh,
                        onClick = {}
                    )
                } else {
                    targets.forEach { config ->
                        if (uiState.scanTargetSheetMode == ScanTargetSheetMode.Cancel) {
                            SmbSingleActionRow(
                                title = config.displayName.ifBlank { "SMB" },
                                description = "${config.hostname}/${config.shareName}",
                                icon = Icons.Default.Delete,
                                actionLabel = "キャンセル",
                                onClick = { viewModel.cancelScan(config.id) }
                            )
                        } else {
                            SmbRefreshActionRow(
                                title = config.displayName.ifBlank { "SMB" },
                                description = "${config.hostname}/${config.shareName}",
                                onQuickScan = { viewModel.requestQuickScan(config.id) },
                                onFullScan = { viewModel.requestFullScan(config.id) }
                            )
                        }
                    }
                }
            }
        }
    }

    Box(modifier = Modifier.fillMaxSize()) {
        LazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(bottom = playerSheetBottomClearance + 24.dp)
        ) {
            when {
                uiState.smbConfigs.isEmpty() -> {
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
                                            onNavigateToAlbumDetail(album, MusicSource.SMB, null)
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
                                                null
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

        LibraryFastScroller(
            progress = scrollController.progress.value,
            visible = scrollController.canScroll.value &&
                uiState.smbConfigs.isNotEmpty() &&
                !uiState.isLoading &&
                uiState.hasCachedContent,
            isNameSort = isNameSort,
            bubbleLabel = bubbleLabel,
            bottomClearance = playerSheetBottomClearance,
            onSeekRequested = { seekProgress, animated ->
                coroutineScope.launch {
                    scrollController.scrollToProgress(seekProgress, animated)
                }
            },
            modifier = Modifier.align(Alignment.CenterEnd)
        )
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

@Composable
private fun SmbRefreshActionRow(
    title: String,
    description: String,
    onQuickScan: () -> Unit,
    onFullScan: () -> Unit
) {
    Surface(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 6.dp),
        shape = MaterialTheme.shapes.large,
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.45f)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 16.dp, vertical = 12.dp)
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onSurface
            )
            Text(
                text = description,
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(top = 10.dp)
            ) {
                FilledTonalButton(
                    modifier = Modifier.weight(1f),
                    onClick = onQuickScan
                ) {
                    Icon(Icons.Default.Bolt, contentDescription = null)
                    Text(text = "クイック", modifier = Modifier.padding(start = 8.dp))
                }
                FilledTonalButton(
                    modifier = Modifier
                        .weight(1f)
                        .padding(start = 8.dp),
                    onClick = onFullScan
                ) {
                    Icon(Icons.Default.Refresh, contentDescription = null)
                    Text(text = "フル", modifier = Modifier.padding(start = 8.dp))
                }
            }
        }
    }
}

@Composable
private fun SmbSingleActionRow(
    title: String,
    description: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    actionLabel: String,
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
            Icon(imageVector = icon, contentDescription = null, tint = MaterialTheme.colorScheme.onSurface)
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
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            Text(
                text = actionLabel,
                style = MaterialTheme.typography.labelLarge,
                color = MaterialTheme.colorScheme.primary
            )
        }
    }
}
