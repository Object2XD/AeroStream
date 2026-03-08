package com.example.aero_stream_for_android.ui.library

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.ui.components.AeroTopBar
import com.example.aero_stream_for_android.ui.library.content.LibraryFastScroller
import com.example.aero_stream_for_android.ui.library.content.LibrarySongRow
import com.example.aero_stream_for_android.ui.library.content.LibrarySongRowStyle
import com.example.aero_stream_for_android.ui.library.content.rememberLibraryScrollController
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.root.LocalPlayerSheetBottomClearance
import kotlinx.coroutines.launch

@Composable
fun ArtistDetailScreen(
    onNavigateBack: () -> Unit,
    viewModel: ArtistDetailViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()
    val playerState by playerViewModel.playerState.collectAsStateWithLifecycle()
    val listState = rememberLazyListState()
    val scrollController = rememberLibraryScrollController(listState)
    val coroutineScope = rememberCoroutineScope()
    val playerSheetBottomClearance = LocalPlayerSheetBottomClearance.current

    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        topBar = {
            AeroTopBar(
                title = uiState.artistName.ifBlank { "アーティスト詳細" },
                onNavigateBack = onNavigateBack
            )
        }
    ) { paddingValues ->
        when {
            uiState.isLoading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }

            uiState.error != null -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = uiState.error ?: "",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            uiState.songs.isEmpty() -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    Text(
                        text = "このアーティストの曲はありません",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            else -> {
                Box(modifier = Modifier.fillMaxSize()) {
                    LazyColumn(
                        state = listState,
                        modifier = Modifier.fillMaxSize(),
                        contentPadding = PaddingValues(
                            top = paddingValues.calculateTopPadding(),
                            bottom = playerSheetBottomClearance + 24.dp
                        )
                    ) {
                        itemsIndexed(uiState.songs) { index, song ->
                            LibrarySongRow(
                                song = song,
                                onClick = {
                                    playerViewModel.playQueue(uiState.songs, index)
                                },
                                isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying,
                                style = if (uiState.source == MusicSource.LOCAL) {
                                    LibrarySongRowStyle.CompactNoBadge
                                } else {
                                    LibrarySongRowStyle.WithStatusBadge
                                },
                                modifier = Modifier
                            )
                        }
                    }

                    LibraryFastScroller(
                        progress = scrollController.progress.value,
                        visible = scrollController.canScroll.value && uiState.songs.isNotEmpty(),
                        isNameSort = false,
                        bubbleLabel = null,
                        bottomClearance = playerSheetBottomClearance,
                        onSeekRequested = { seekProgress, animated ->
                            coroutineScope.launch {
                                scrollController.scrollToProgress(seekProgress, animated)
                            }
                        },
                        modifier = Modifier
                            .align(Alignment.CenterEnd)
                            .padding(top = paddingValues.calculateTopPadding())
                    )
                }
            }
        }
    }
}
