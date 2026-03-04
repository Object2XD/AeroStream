package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CloudDownload
import androidx.compose.material.icons.filled.Downloading
import androidx.compose.material.icons.filled.Error
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.SearchOff
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.aero_stream_for_android.data.local.db.entity.DownloadState
import com.example.aero_stream_for_android.ui.components.SongListItem
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
    var searchQuery by rememberSaveable { androidx.compose.runtime.mutableStateOf("") }

    val filteredActiveDownloads = uiState.activeDownloads.filter { download ->
        val fileName = download.smbPath.substringAfterLast('\\')
        fileName.contains(searchQuery, ignoreCase = true) ||
            download.smbPath.contains(searchQuery, ignoreCase = true) ||
            (download.errorMessage?.contains(searchQuery, ignoreCase = true) == true)
    }
    val filteredDownloadedSongs = uiState.downloadedSongs.filter { song ->
        song.title.contains(searchQuery, ignoreCase = true) ||
            song.artist.contains(searchQuery, ignoreCase = true) ||
            song.album.contains(searchQuery, ignoreCase = true) ||
            (song.smbPath?.contains(searchQuery, ignoreCase = true) == true)
    }

    if (uiState.isLoading) {
        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
            CircularProgressIndicator()
        }
        return
    }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = 96.dp)
    ) {
        item {
            SearchRow(
                isSearchMode = true,
                query = searchQuery,
                placeholder = "ダウンロードを検索",
                onQueryChange = { searchQuery = it },
                onToggleSearch = {}
            )
        }

        if (filteredActiveDownloads.isNotEmpty()) {
            item {
                Text(
                    text = "ダウンロード中",
                    style = AeroCompactUiTokens.sectionHeaderTextStyle(),
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            items(filteredActiveDownloads) { download ->
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

        if (filteredDownloadedSongs.isNotEmpty()) {
            item {
                Text(
                    text = "ダウンロード済み（${filteredDownloadedSongs.size}曲）",
                    style = AeroCompactUiTokens.sectionHeaderTextStyle(),
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
            items(filteredDownloadedSongs) { song ->
                SongListItem(
                    song = song,
                    onClick = {
                        playerViewModel.playQueue(filteredDownloadedSongs, filteredDownloadedSongs.indexOf(song))
                        onNavigateToPlayer()
                    },
                    isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying
                )
            }
        }

        if (filteredDownloadedSongs.isEmpty() && filteredActiveDownloads.isEmpty()) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(300.dp),
                    contentAlignment = Alignment.Center
                ) {
                    androidx.compose.foundation.layout.Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            if (searchQuery.isBlank()) Icons.Default.CloudDownload else Icons.Default.SearchOff,
                            contentDescription = null,
                            modifier = Modifier.padding(bottom = 16.dp)
                        )
                        Text(
                            text = if (searchQuery.isBlank()) {
                                "ダウンロード済みの楽曲はありません"
                            } else {
                                "\"$searchQuery\" に一致する項目はありません"
                            },
                            style = MaterialTheme.typography.titleMedium
                        )
                    }
                }
            }
        }
    }
}
