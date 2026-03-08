package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CloudDownload
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Downloading
import androidx.compose.material.icons.filled.Error
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.aero_stream_for_android.data.local.db.entity.DownloadState
import com.example.aero_stream_for_android.domain.model.SongCacheStatus
import com.example.aero_stream_for_android.domain.model.cacheStatus
import com.example.aero_stream_for_android.ui.downloads.DownloadsViewModel
import com.example.aero_stream_for_android.ui.library.LibraryFeatureState
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun CacheLibraryContent(
    featureState: LibraryFeatureState,
    onNavigateToPlayer: () -> Unit = {},
    downloadsViewModel: DownloadsViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by downloadsViewModel.uiState.collectAsStateWithLifecycle()
    val playerState by playerViewModel.playerState.collectAsStateWithLifecycle()
    val listState = rememberLazyListState()
    val scrollController = rememberLibraryScrollController(listState)
    val activeDownloads = uiState.activeDownloads
    val downloadedSongs = uiState.downloadedSongs

    if (uiState.isLoading) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator()
        }
        return
    }

    Box(modifier = Modifier.fillMaxSize()) {
        LazyColumn(
            state = listState,
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(bottom = 96.dp)
        ) {
            if (activeDownloads.isNotEmpty()) {
                item {
                    Text(
                        text = "ダウンロード中",
                        style = AeroCompactUiTokens.sectionHeaderTextStyle(),
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                items(activeDownloads) { download ->
                    androidx.compose.foundation.layout.Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(horizontal = 16.dp, vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            when (download.state) {
                                DownloadState.DOWNLOADING -> Icons.Default.Downloading
                                DownloadState.FAILED -> Icons.Default.Error
                                DownloadState.PAUSED -> Icons.Default.Pause
                                else -> Icons.Default.CloudDownload
                            },
                            contentDescription = null
                        )
                        androidx.compose.foundation.layout.Column(
                            modifier = Modifier
                                .weight(1f)
                                .padding(horizontal = 12.dp)
                        ) {
                            Text(text = download.smbPath.substringAfterLast('\\'), maxLines = 1)
                            if (download.fileSize > 0) {
                                LinearProgressIndicator(
                                    progress = {
                                        download.downloadedBytes.toFloat() / download.fileSize.toFloat()
                                    },
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(top = 4.dp)
                                )
                            }
                        }
                        if (download.state == DownloadState.FAILED) {
                            IconButton(onClick = { downloadsViewModel.retryDownload(download) }) {
                                Icon(Icons.Default.Refresh, contentDescription = "Retry")
                            }
                        }
                    }
                }
                item {
                    HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))
                }
            }

            if (downloadedSongs.isNotEmpty()) {
                item {
                    Text(
                        text = "ダウンロード済み（${downloadedSongs.size}曲）",
                        style = AeroCompactUiTokens.sectionHeaderTextStyle(),
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                items(downloadedSongs) { song ->
                    LibrarySongRow(
                        song = song,
                        onClick = {
                            playerViewModel.playQueue(downloadedSongs, downloadedSongs.indexOf(song))
                            onNavigateToPlayer()
                        },
                        menuItems = if (song.cacheStatus == SongCacheStatus.CACHED) {
                            listOf(
                                LibraryRowMenuItem(
                                    id = "cache_remove_${song.id}",
                                    label = "キャッシュから削除",
                                    isDestructive = true,
                                    leadingIcon = Icons.Default.Delete,
                                    onClick = { downloadsViewModel.removeSongFromCache(song) }
                                )
                            )
                        } else {
                            emptyList()
                        },
                        isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying,
                        style = LibrarySongRowStyle.WithStatusBadge
                    )
                }
            }

            if (downloadedSongs.isEmpty() && activeDownloads.isEmpty()) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(300.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        androidx.compose.foundation.layout.Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Icon(
                                Icons.Default.CloudDownload,
                                contentDescription = null,
                                modifier = Modifier.padding(bottom = 16.dp)
                            )
                            Text(
                                text = "ダウンロード済みの楽曲はありません",
                                style = MaterialTheme.typography.titleMedium
                            )
                        }
                    }
                }
            }
        }

        LibraryFastScroller(
            progress = scrollController.progress.value,
            visible = scrollController.canScroll.value && downloadedSongs.isNotEmpty(),
            modifier = Modifier.align(Alignment.CenterEnd)
        )
    }
}
