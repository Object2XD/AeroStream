package com.example.aero_stream_for_android.ui.home

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Download
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SongCacheStatus
import com.example.aero_stream_for_android.domain.model.cacheStatus
import com.example.aero_stream_for_android.ui.library.content.LibraryRowMenuItem
import com.example.aero_stream_for_android.ui.library.content.LibrarySongRow
import com.example.aero_stream_for_android.ui.library.content.LibrarySongRowStyle
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun HomeScreen(
    onNavigateToPlayer: () -> Unit = {},
    onNavigateToSettings: () -> Unit = {},
    homeViewModel: HomeViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by homeViewModel.uiState.collectAsStateWithLifecycle()
    val playerState by playerViewModel.playerState.collectAsStateWithLifecycle()

    if (uiState.isLoading) {
        Box(
            modifier = Modifier.fillMaxSize(),
            contentAlignment = Alignment.Center
        ) {
            CircularProgressIndicator()
        }
        return
    }

    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(bottom = 96.dp)
    ) {
        if (uiState.recentlyPlayed.isNotEmpty()) {
            item {
                SectionTitle("最近再生した曲")
            }
            items(uiState.recentlyPlayed) { song ->
                LibrarySongRow(
                    song = song,
                    onClick = {
                        playerViewModel.playSong(song)
                        onNavigateToPlayer()
                    },
                    menuItems = if (song.source == MusicSource.SMB) {
                        when (song.cacheStatus) {
                            SongCacheStatus.SMB_NOT_CACHED -> listOf(
                                LibraryRowMenuItem(
                                    id = "cache_add_${song.id}",
                                    label = "キャッシュにダウンロード追加",
                                    leadingIcon = Icons.Default.Download,
                                    onClick = { homeViewModel.addSongToCache(song) }
                                )
                            )

                            SongCacheStatus.CACHED -> listOf(
                                LibraryRowMenuItem(
                                    id = "cache_remove_${song.id}",
                                    label = "キャッシュから削除",
                                    isDestructive = true,
                                    leadingIcon = Icons.Default.Delete,
                                    onClick = { homeViewModel.removeSongFromCache(song) }
                                )
                            )

                            SongCacheStatus.NONE -> emptyList()
                        }
                    } else {
                        emptyList()
                    },
                    isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying,
                    showDownloadIcon = true,
                    style = LibrarySongRowStyle.WithStatusBadge
                )
            }
        }

        if (uiState.mostPlayed.isNotEmpty()) {
            item {
                Spacer(modifier = Modifier.height(16.dp))
                SectionTitle("よく再生する曲")
            }
            items(uiState.mostPlayed) { song ->
                LibrarySongRow(
                    song = song,
                    onClick = {
                        playerViewModel.playSong(song)
                        onNavigateToPlayer()
                    },
                    menuItems = if (song.source == MusicSource.SMB) {
                        when (song.cacheStatus) {
                            SongCacheStatus.SMB_NOT_CACHED -> listOf(
                                LibraryRowMenuItem(
                                    id = "cache_add_${song.id}",
                                    label = "キャッシュにダウンロード追加",
                                    leadingIcon = Icons.Default.Download,
                                    onClick = { homeViewModel.addSongToCache(song) }
                                )
                            )

                            SongCacheStatus.CACHED -> listOf(
                                LibraryRowMenuItem(
                                    id = "cache_remove_${song.id}",
                                    label = "キャッシュから削除",
                                    isDestructive = true,
                                    leadingIcon = Icons.Default.Delete,
                                    onClick = { homeViewModel.removeSongFromCache(song) }
                                )
                            )

                            SongCacheStatus.NONE -> emptyList()
                        }
                    } else {
                        emptyList()
                    },
                    isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying,
                    showDownloadIcon = true,
                    style = LibrarySongRowStyle.WithStatusBadge
                )
            }
        }

        if (uiState.recentlyPlayed.isEmpty() && uiState.mostPlayed.isEmpty()) {
            item {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(300.dp),
                    contentAlignment = Alignment.Center
                ) {
                    androidx.compose.foundation.layout.Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Text(
                            text = "楽曲が見つかりません",
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "ヘッダーの更新ボタンでローカル楽曲をスキャンしてください",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun SectionTitle(text: String) {
    Text(
        text = text,
        style = AeroCompactUiTokens.sectionHeaderTextStyle(),
        modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)
    )
}
