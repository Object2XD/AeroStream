package com.example.aero_stream_for_android.ui.library

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.itemsIndexed
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.automirrored.filled.QueueMusic
import androidx.compose.material.icons.filled.Album
import androidx.compose.material.icons.filled.Bookmark
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.derivedStateOf
import androidx.compose.runtime.getValue
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import android.widget.Toast
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.PlayerState
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens
import kotlinx.coroutines.flow.collectLatest

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
                            downloadVisualState = if (song.source == MusicSource.SMB) {
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

@Composable
private fun AlbumDetailTopOverlay(
    title: String,
    artist: String,
    subtitle: String,
    collapsedProgress: Float,
    topInset: androidx.compose.ui.unit.Dp,
    onNavigateBack: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = topInset)
            .background(MaterialTheme.colorScheme.background.copy(alpha = collapsedProgress * 0.94f))
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    start = AeroCompactUiTokens.albumDetailHorizontalPadding,
                    end = AeroCompactUiTokens.albumDetailHorizontalPadding,
                    top = AeroCompactUiTokens.albumDetailTopOverlayPaddingTop,
                    bottom = 8.dp
                ),
            verticalAlignment = Alignment.CenterVertically
        ) {
            IconButton(onClick = onNavigateBack) {
                Icon(
                    Icons.AutoMirrored.Filled.ArrowBack,
                    contentDescription = "Back",
                    modifier = Modifier.size(AeroCompactUiTokens.headerActionIconSize)
                )
            }

            Box(
                modifier = Modifier.weight(1f),
                contentAlignment = Alignment.Center
            ) {
                Column(
                    modifier = Modifier.alpha(1f - collapsedProgress),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    if (artist.isNotBlank()) {
                        Text(
                            text = artist,
                            style = AeroCompactUiTokens.headerSecondaryTextStyle(),
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                    if (subtitle.isNotBlank()) {
                        Text(
                            text = subtitle,
                            style = AeroCompactUiTokens.headerTertiaryTextStyle(),
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            maxLines = 1,
                            overflow = TextOverflow.Ellipsis
                        )
                    }
                }
                Text(
                    text = title,
                    modifier = Modifier.alpha(collapsedProgress),
                    style = AeroCompactUiTokens.albumDetailCollapsedTitleTextStyle(),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            IconButton(onClick = { }) {
                Icon(
                    Icons.AutoMirrored.Filled.QueueMusic,
                    contentDescription = "Queue",
                    modifier = Modifier.size(AeroCompactUiTokens.headerActionIconSize)
                )
            }
        }

        HorizontalDivider(
            modifier = Modifier.alpha(collapsedProgress),
            color = MaterialTheme.colorScheme.outline.copy(alpha = 0.36f)
        )
    }
}

@Composable
private fun AlbumDetailHeroSection(
    title: String,
    artwork: Any?,
    onPlay: () -> Unit,
    onDownload: () -> Unit,
    downloadEnabled: Boolean,
    isAlbumCached: Boolean
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = AeroCompactUiTokens.albumDetailHeroTopSpacing),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = AeroCompactUiTokens.albumDetailHorizontalPadding),
            contentAlignment = Alignment.Center
        ) {
            BoxWithConstraints {
                val artworkSize = if (maxWidth < AeroCompactUiTokens.albumDetailArtworkMaxWidth) {
                    maxWidth
                } else {
                    AeroCompactUiTokens.albumDetailArtworkMaxWidth
                }

                if (artwork != null) {
                    AsyncImage(
                        model = artwork,
                        contentDescription = "Album art",
                        modifier = Modifier
                            .size(artworkSize)
                            .aspectRatio(1f)
                            .clip(RoundedCornerShape(AeroCompactUiTokens.albumDetailArtworkCornerRadius)),
                        contentScale = ContentScale.Crop
                    )
                } else {
                    Box(
                        modifier = Modifier
                            .size(artworkSize)
                            .aspectRatio(1f)
                            .clip(RoundedCornerShape(AeroCompactUiTokens.albumDetailArtworkCornerRadius))
                            .background(MaterialTheme.colorScheme.surfaceVariant),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            Icons.Default.Album,
                            contentDescription = null,
                            modifier = Modifier.size(72.dp),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
                }
            }
        }

        Spacer(modifier = Modifier.height(20.dp))

        Text(
            text = title,
            modifier = Modifier.padding(horizontal = AeroCompactUiTokens.albumDetailHorizontalPadding),
            style = AeroCompactUiTokens.albumDetailTitleTextStyle(),
            textAlign = TextAlign.Center,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis
        )

        Spacer(modifier = Modifier.height(20.dp))

        AlbumActionRow(
            onPlay = onPlay,
            onDownload = onDownload,
            downloadEnabled = downloadEnabled,
            isAlbumCached = isAlbumCached
        )

        Spacer(modifier = Modifier.height(12.dp))
    }
}

@Composable
private fun AlbumActionRow(
    onPlay: () -> Unit,
    onDownload: () -> Unit,
    downloadEnabled: Boolean,
    isAlbumCached: Boolean
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = AeroCompactUiTokens.albumDetailHorizontalPadding),
        horizontalArrangement = Arrangement.SpaceEvenly,
        verticalAlignment = Alignment.CenterVertically
    ) {
        AlbumSecondaryActionButton(
            icon = if (isAlbumCached) Icons.Default.CheckCircle else Icons.Default.Download,
            label = if (isAlbumCached) "Cached" else "Download",
            onClick = onDownload,
            enabled = downloadEnabled
        )
        AlbumSecondaryActionButton(icon = Icons.Default.Bookmark, label = "Bookmark")

        FilledIconButton(
            onClick = onPlay,
            modifier = Modifier.size(AeroCompactUiTokens.albumDetailPrimaryPlayButtonSize),
            shape = CircleShape,
            colors = IconButtonDefaults.filledIconButtonColors(
                containerColor = MaterialTheme.colorScheme.onSurface,
                contentColor = MaterialTheme.colorScheme.surface
            )
        ) {
            Icon(
                Icons.Default.PlayArrow,
                contentDescription = "Play",
                modifier = Modifier.size(34.dp)
            )
        }

        AlbumSecondaryActionButton(icon = Icons.Default.Share, label = "Share")
        AlbumSecondaryActionButton(icon = Icons.Default.MoreVert, label = "More")
    }
}

@Composable
private fun AlbumSecondaryActionButton(
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    label: String,
    onClick: () -> Unit = {},
    enabled: Boolean = true
) {
    Surface(
        modifier = Modifier.size(AeroCompactUiTokens.albumDetailSecondaryActionButtonSize),
        shape = CircleShape,
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.28f)
    ) {
        IconButton(onClick = onClick, enabled = enabled) {
            Icon(icon, contentDescription = label)
        }
    }
}

@Composable
private fun AlbumTrackRow(
    song: Song,
    index: Int,
    playerState: PlayerState,
    downloadVisualState: TrackDownloadVisualState?,
    onClick: () -> Unit
) {
    val isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying
    val isDownloaded = song.isCached
    val isSmbNotCached = song.source == MusicSource.SMB && !song.isCached

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(
                horizontal = AeroCompactUiTokens.albumDetailHorizontalPadding,
                vertical = AeroCompactUiTokens.albumDetailTrackRowVerticalPadding
            ),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier.width(34.dp),
            contentAlignment = Alignment.Center
        ) {
            if (downloadVisualState != null) {
                if (downloadVisualState.progress != null) {
                    CircularProgressIndicator(
                        progress = { downloadVisualState.progress },
                        modifier = Modifier.size(22.dp),
                        strokeWidth = 2.dp,
                        color = MaterialTheme.colorScheme.onSurface,
                        trackColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.2f)
                    )
                } else {
                    CircularProgressIndicator(
                        modifier = Modifier.size(22.dp),
                        strokeWidth = 2.dp,
                        color = MaterialTheme.colorScheme.onSurface,
                        trackColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.2f)
                    )
                }
                Icon(
                    imageVector = Icons.Default.Download,
                    contentDescription = "Downloading",
                    modifier = Modifier.size(12.dp),
                    tint = MaterialTheme.colorScheme.onSurface
                )
            } else {
                Text(
                    text = (index + 1).toString(),
                    style = AeroCompactUiTokens.albumDetailTrackNumberTextStyle(),
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }

        Column(
            modifier = Modifier
                .weight(1f)
                .padding(start = 18.dp, end = 8.dp)
        ) {
            Text(
                text = song.title,
                style = AeroCompactUiTokens.albumDetailTrackTitleTextStyle(),
                color = if (isPlaying) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.onSurface,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(3.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                when {
                    isDownloaded -> {
                        Icon(
                            Icons.Default.CheckCircle,
                            contentDescription = "Downloaded",
                            modifier = Modifier.size(18.dp),
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                    }

                    isPlaying -> {
                        Icon(
                            Icons.Default.CheckCircle,
                            contentDescription = null,
                            modifier = Modifier.size(18.dp),
                            tint = MaterialTheme.colorScheme.primary
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                    }

                    isSmbNotCached -> {
                        Icon(
                            Icons.Default.Cloud,
                            contentDescription = "SMB",
                            modifier = Modifier.size(18.dp),
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                    }
                }
                Text(
                    text = buildTrackSubtitle(song),
                    style = AeroCompactUiTokens.albumDetailTrackSubtitleTextStyle(),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        IconButton(onClick = { }) {
            Icon(Icons.Default.MoreVert, contentDescription = "More")
        }
    }
}

@Composable
private fun AlbumFooterSummary(summary: String) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 20.dp, bottom = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = summary,
            style = AeroCompactUiTokens.albumDetailFooterTextStyle(),
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun AlbumBottomPlayShortcut(
    visible: Boolean,
    onPlay: () -> Unit
) {
    if (!visible) return

    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(
                start = AeroCompactUiTokens.albumDetailHorizontalPadding,
                end = AeroCompactUiTokens.albumDetailHorizontalPadding,
                top = AeroCompactUiTokens.albumDetailBottomPlayTopPadding,
                bottom = AeroCompactUiTokens.albumDetailBottomPlayBottomClearance
            ),
        horizontalArrangement = Arrangement.End
    ) {
        FilledIconButton(
            onClick = onPlay,
            modifier = Modifier.size(AeroCompactUiTokens.albumDetailFloatingPlayButtonSize),
            shape = CircleShape,
            colors = IconButtonDefaults.filledIconButtonColors(
                containerColor = MaterialTheme.colorScheme.onSurface,
                contentColor = MaterialTheme.colorScheme.surface
            )
        ) {
            Icon(
                Icons.Default.PlayArrow,
                contentDescription = "Play album",
                modifier = Modifier.size(34.dp)
            )
        }
    }
}

@Composable
private fun AlbumDetailMessage(
    title: String,
    message: String
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = AeroCompactUiTokens.albumDetailHorizontalPadding, vertical = 48.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = title,
            style = AeroCompactUiTokens.albumDetailTitleTextStyle(),
            textAlign = TextAlign.Center,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis
        )
        Spacer(modifier = Modifier.height(20.dp))
        Text(
            text = message,
            style = AeroCompactUiTokens.albumDetailTrackSubtitleTextStyle(),
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            textAlign = TextAlign.Center
        )
    }
}

private fun buildTrackSubtitle(song: Song): String {
    val parts = buildList {
        if (song.artist.isNotBlank()) add(song.artist)
        if (song.album.isNotBlank()) add(song.album)
    }
    return parts.joinToString("、")
}
