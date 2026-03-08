package com.example.aero_stream_for_android.ui.library

import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.aero_stream_for_android.domain.model.isSmbSource
import com.example.aero_stream_for_android.ui.library.content.LibraryFastScroller
import com.example.aero_stream_for_android.ui.library.content.rememberLibraryScrollController
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.launch

@Composable
fun AlbumDetailScreen(
    onNavigateBack: () -> Unit,
    onNavigateToPlayer: () -> Unit,
    topInset: androidx.compose.ui.unit.Dp = 0.dp,
    viewModel: AlbumDetailViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val playerState by playerViewModel.playerState.collectAsState()
    val context = LocalContext.current
    val listState = rememberLazyListState()
    val scrollController = rememberLibraryScrollController(listState)
    val coroutineScope = rememberCoroutineScope()
    val density = LocalDensity.current
    val collapseThresholdPx = with(density) { 240.dp.toPx() }
    val collapsedProgress by remember(listState, collapseThresholdPx) {
        derivedStateOf {
            when {
                listState.firstVisibleItemIndex > 0 -> 1f
                collapseThresholdPx <= 0f -> 0f
                else -> (listState.firstVisibleItemScrollOffset / collapseThresholdPx).coerceIn(0f, 1f)
            }
        }
    }
    val isCollapsed by remember {
        derivedStateOf { collapsedProgress >= 0.92f }
    }

    fun playAlbum(startIndex: Int = 0) {
        if (uiState.songs.isEmpty()) return
        playerViewModel.playQueue(uiState.songs, startIndex)
        onNavigateToPlayer()
    }

    LaunchedEffect(viewModel) {
        viewModel.toastMessages.collectLatest { message ->
            Toast.makeText(context, message, Toast.LENGTH_SHORT).show()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
    ) {
        LazyColumn(
            state = listState,
            contentPadding = PaddingValues(bottom = AeroCompactUiTokens.albumDetailListBottomPadding),
            modifier = Modifier.fillMaxSize()
        ) {
            item {
                AlbumDetailHeroSection(
                    title = uiState.album?.name.orEmpty(),
                    artwork = uiState.album?.albumArtUri,
                    onPlay = { playAlbum() },
                    onDownload = viewModel::cacheAlbumTracks,
                    downloadEnabled = uiState.isDownloadActionEnabled,
                    isAlbumCached = uiState.isAlbumCached
                )
            }

            if (uiState.isLoading) {
                item {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(top = 48.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator()
                    }
                }
            } else if (uiState.error != null || uiState.songs.isEmpty()) {
                item {
                    AlbumDetailMessage(
                        title = uiState.album?.name.orEmpty(),
                        message = uiState.error ?: "このアルバムの曲を読み込めませんでした"
                    )
                }
            } else {
                itemsIndexed(uiState.songs) { index, song ->
                    AlbumTrackRow(
                        song = song,
                        index = index,
                        playerState = playerState,
                        downloadVisualState = if (song.isSmbSource) {
                            song.smbPath?.let(uiState.activeDownloadsBySmbPath::get)
                        } else {
                            null
                        },
                        onClick = { playAlbum(index) }
                    )
                }

                item {
                    AlbumFooterSummary(summary = uiState.footerSummary)
                }

                item {
                    AlbumBottomPlayShortcut(
                        visible = isCollapsed && uiState.songs.isNotEmpty(),
                        onPlay = { playAlbum() }
                    )
                }
            }
        }

        LibraryFastScroller(
            progress = scrollController.progress.value,
            visible = scrollController.canScroll.value &&
                uiState.songs.isNotEmpty() &&
                !uiState.isLoading &&
                uiState.error == null,
            isNameSort = false,
            bubbleLabel = null,
            onSeekRequested = { seekProgress, animated ->
                coroutineScope.launch {
                    scrollController.scrollToProgress(seekProgress, animated)
                }
            },
            modifier = Modifier.align(Alignment.CenterEnd)
        )

        AlbumDetailTopOverlay(
            title = uiState.album?.name.orEmpty(),
            artist = uiState.displayArtist,
            subtitle = uiState.headerSubtitle,
            collapsedProgress = collapsedProgress,
            topInset = topInset,
            onNavigateBack = onNavigateBack
        )
    }
}
