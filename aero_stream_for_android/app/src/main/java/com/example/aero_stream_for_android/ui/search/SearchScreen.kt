package com.example.aero_stream_for_android.ui.search

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.History
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.focus.FocusRequester
import androidx.compose.ui.focus.focusRequester
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SongCacheStatus
import com.example.aero_stream_for_android.domain.model.cacheStatus
import com.example.aero_stream_for_android.ui.components.AeroActionChip
import com.example.aero_stream_for_android.ui.components.AeroIconActionButton
import com.example.aero_stream_for_android.ui.components.AeroTopBarSearch
import com.example.aero_stream_for_android.ui.library.content.LibraryRowMenuItem
import com.example.aero_stream_for_android.ui.library.content.LibrarySongRow
import com.example.aero_stream_for_android.ui.library.content.LibrarySongRowStyle
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.root.LocalPlayerSheetBottomClearance

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SearchScreen(
    onNavigateBack: () -> Unit = {},
    searchViewModel: SearchViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by searchViewModel.uiState.collectAsState()
    val playerState by playerViewModel.playerState.collectAsState()
    val focusRequester = remember { FocusRequester() }
    val playerSheetBottomClearance = LocalPlayerSheetBottomClearance.current

    LaunchedEffect(Unit) {
        focusRequester.requestFocus()
    }

    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        contentWindowInsets = WindowInsets(0, 0, 0, 0),
        topBar = {
            AeroTopBarSearch(
                value = uiState.query,
                onValueChange = searchViewModel::onQueryChanged,
                placeholderText = "曲名、アーティスト、アルバムを検索",
                onNavigateBack = onNavigateBack,
                trailingIcon = {
                    if (uiState.query.isNotEmpty()) {
                        AeroIconActionButton(
                            onClick = searchViewModel::clearSearch,
                            contentDescription = "検索文字列をクリア",
                            icon = { Icon(Icons.Default.Clear, contentDescription = null) }
                        )
                    }
                },
                modifier = Modifier
                    .background(MaterialTheme.colorScheme.background)
                    .focusRequester(focusRequester)
            )
        }
    ) { paddingValues ->
        when {
            uiState.isSearching -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }

            uiState.query.isBlank() -> {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentPadding = PaddingValues(bottom = playerSheetBottomClearance + 8.dp)
                ) {
                    item {
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 16.dp, vertical = 8.dp),
                            horizontalArrangement = Arrangement.SpaceBetween,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Text(
                                text = "最近の検索",
                                style = MaterialTheme.typography.titleMedium
                            )
                            if (uiState.recentSearches.isNotEmpty()) {
                                AeroActionChip(
                                    label = "履歴を消去",
                                    onClick = searchViewModel::clearRecentSearches
                                )
                            }
                        }
                    }

                    if (uiState.recentSearches.isEmpty()) {
                        item {
                            Text(
                                text = "最近の検索はありません",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                modifier = Modifier.padding(horizontal = 16.dp, vertical = 12.dp)
                            )
                        }
                    } else {
                        items(uiState.recentSearches) { query ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(
                                        horizontal = 16.dp,
                                        vertical = 12.dp
                                    )
                                    .clickable { searchViewModel.onRecentSearchSelected(query) },
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.History,
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                                Spacer(modifier = Modifier.width(12.dp))
                                Text(
                                    text = query,
                                    style = MaterialTheme.typography.bodyLarge,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                            }
                            HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.22f))
                        }
                    }
                }
            }

            uiState.results.isEmpty() -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues)
                        .padding(32.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "\"${uiState.query}\" に一致する結果はありません",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            else -> {
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentPadding = PaddingValues(bottom = playerSheetBottomClearance + 8.dp)
                ) {
                    items(uiState.results) { song ->
                        LibrarySongRow(
                            song = song,
                            onClick = {
                                playerViewModel.playQueue(uiState.results, uiState.results.indexOf(song))
                            },
                            menuItems = if (song.source == MusicSource.SMB) {
                                when (song.cacheStatus) {
                                    SongCacheStatus.SMB_NOT_CACHED -> listOf(
                                        LibraryRowMenuItem(
                                            id = "cache_add_${song.id}",
                                            label = "キャッシュにダウンロード追加",
                                            leadingIcon = Icons.Default.Download,
                                            onClick = { searchViewModel.addSongToCache(song) }
                                        )
                                    )

                                    SongCacheStatus.CACHED -> listOf(
                                        LibraryRowMenuItem(
                                            id = "cache_remove_${song.id}",
                                            label = "キャッシュから削除",
                                            isDestructive = true,
                                            leadingIcon = Icons.Default.Delete,
                                            onClick = { searchViewModel.removeSongFromCache(song) }
                                        )
                                    )

                                    SongCacheStatus.NONE -> emptyList()
                                }
                            } else {
                                emptyList()
                            },
                            isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying,
                            style = LibrarySongRowStyle.WithStatusBadge
                        )
                    }
                }
            }
        }
    }
}
