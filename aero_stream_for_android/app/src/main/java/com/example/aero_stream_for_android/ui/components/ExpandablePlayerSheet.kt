package com.example.aero_stream_for_android.ui.components

import androidx.compose.animation.core.Spring
import androidx.compose.animation.core.animateDpAsState
import androidx.compose.animation.core.exponentialDecay
import androidx.compose.animation.core.spring
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.AnchoredDraggableState
import androidx.compose.foundation.gestures.DraggableAnchors
import androidx.compose.foundation.gestures.Orientation
import androidx.compose.foundation.gestures.animateTo
import androidx.compose.foundation.gestures.anchoredDraggable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.aspectRatio
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.wrapContentHeight
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.QueueMusic
import androidx.compose.material.icons.filled.Album
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material.icons.filled.MusicNote
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.Repeat
import androidx.compose.material.icons.filled.RepeatOne
import androidx.compose.material.icons.filled.Shuffle
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material.icons.filled.SkipPrevious
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.snapshotFlow
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.lerp
import coil.compose.AsyncImage
import com.example.aero_stream_for_android.domain.model.PlayerState
import com.example.aero_stream_for_android.domain.model.RepeatMode
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens
import kotlinx.coroutines.flow.distinctUntilChanged
import kotlinx.coroutines.flow.map

private const val PlayerSheetMiniTransitionEnd = 0.25f
private const val PlayerSheetFullTransitionStart = 0.75f
private val PlayerSheetProgressBarHeight = 2.dp

@OptIn(ExperimentalFoundationApi::class)
@Composable
fun ExpandablePlayerSheet(
    playerState: PlayerState,
    sheetValue: ExpandablePlayerSheetValue,
    onSheetValueChange: (ExpandablePlayerSheetValue) -> Unit,
    onPlayPause: () -> Unit,
    onSkipNext: () -> Unit,
    onSkipPrevious: () -> Unit,
    onSeek: (Long) -> Unit,
    onRepeatModeChange: () -> Unit,
    onShuffleToggle: () -> Unit,
    bottomBarHeight: Dp,
    modifier: Modifier = Modifier
) {
    val song = playerState.currentSong ?: return

    BoxWithConstraints(
        modifier = modifier.fillMaxSize()
    ) {
        val density = androidx.compose.ui.platform.LocalDensity.current
        val decayAnimationSpec = remember { exponentialDecay<Float>() }
        val snapAnimationSpec = remember {
            spring<Float>(
                dampingRatio = Spring.DampingRatioNoBouncy,
                stiffness = Spring.StiffnessMediumLow
            )
        }
        val fullHeightPx = with(density) { maxHeight.toPx() }
        val peekHeightPx = with(density) { AeroCompactUiTokens.playerSheetPeekHeight.toPx() }
        val bottomBarHeightPx = with(density) { bottomBarHeight.toPx() }
        val collapsedAnchor = (fullHeightPx - peekHeightPx - bottomBarHeightPx).coerceAtLeast(0f)
        val anchors = remember(collapsedAnchor) {
            DraggableAnchors {
                ExpandablePlayerSheetAnchor.Expanded at 0f
                ExpandablePlayerSheetAnchor.Collapsed at collapsedAnchor
            }
        }
        val initialAnchor = if (sheetValue == ExpandablePlayerSheetValue.Expanded) {
            ExpandablePlayerSheetAnchor.Expanded
        } else {
            ExpandablePlayerSheetAnchor.Collapsed
        }
        val draggableState = remember {
            AnchoredDraggableState(
                initialValue = initialAnchor,
                positionalThreshold = { distance -> distance * 0.35f },
                velocityThreshold = { with(density) { 125.dp.toPx() } },
                snapAnimationSpec = snapAnimationSpec,
                decayAnimationSpec = decayAnimationSpec
            )
        }

        SideEffect {
            draggableState.updateAnchors(anchors)
        }

        val targetAnchor = if (sheetValue == ExpandablePlayerSheetValue.Expanded) {
            ExpandablePlayerSheetAnchor.Expanded
        } else {
            ExpandablePlayerSheetAnchor.Collapsed
        }

        LaunchedEffect(targetAnchor) {
            if (draggableState.targetValue != targetAnchor) {
                draggableState.animateTo(targetAnchor)
            }
        }

        LaunchedEffect(draggableState) {
            snapshotFlow { draggableState.currentValue }
                .map { it.toSheetValue() }
                .distinctUntilChanged()
                .collect(onSheetValueChange)
        }

        val offsetPx = draggableState.offset.takeIf { !it.isNaN() } ?: collapsedAnchor
        val expansionProgress = if (collapsedAnchor <= 0f) {
            1f
        } else {
            1f - (offsetPx / collapsedAnchor).coerceIn(0f, 1f)
        }
        val collapsedContentProgress = 1f - remapProgress(
            progress = expansionProgress,
            start = 0f,
            end = PlayerSheetMiniTransitionEnd
        )
        val expandedContentProgress = remapProgress(
            progress = expansionProgress,
            start = PlayerSheetFullTransitionStart,
            end = 1f
        )
        val dynamicBottomInsetPx = bottomBarHeightPx * (1f - expansionProgress)
        val sheetHeightPx = (fullHeightPx - offsetPx - dynamicBottomInsetPx).coerceAtLeast(peekHeightPx)
        val sheetHeight = with(density) { sheetHeightPx.toDp() }
        val horizontalPadding = lerp(
            AeroCompactUiTokens.playerSheetCollapsedHorizontalPadding,
            AeroCompactUiTokens.playerSheetExpandedHorizontalPadding,
            expansionProgress
        )
        val cornerRadius = lerp(
            AeroCompactUiTokens.playerSheetCollapsedCornerRadius,
            0.dp,
            expansionProgress
        )
        val progressFraction = if (playerState.duration > 0L) {
            playerState.currentPosition.toFloat() / playerState.duration.toFloat()
        } else {
            0f
        }.coerceIn(0f, 1f)
        val scrimAlpha = AeroCompactUiTokens.playerSheetScrimMaxAlpha * expansionProgress
        val expandedArtworkSize = minOf(
            AeroCompactUiTokens.playerSheetExpandedArtworkMaxSize,
            (maxWidth - (AeroCompactUiTokens.playerSheetExpandedHorizontalPadding * 2)).coerceAtLeast(
                AeroCompactUiTokens.playerSheetCollapsedArtworkSize
            )
        )
        val collapsedArtworkX = AeroCompactUiTokens.playerSheetCollapsedHorizontalPadding
        val collapsedArtworkY =
            PlayerSheetProgressBarHeight +
                AeroCompactUiTokens.playerSheetCollapsedVerticalPadding +
                ((AeroCompactUiTokens.playerSheetPeekHeight -
                    PlayerSheetProgressBarHeight -
                    (AeroCompactUiTokens.playerSheetCollapsedVerticalPadding * 2) -
                    AeroCompactUiTokens.playerSheetCollapsedArtworkSize) / 2)
        val expandedArtworkX = ((maxWidth - expandedArtworkSize) / 2).coerceAtLeast(0.dp)
        val expandedArtworkY =
            PlayerSheetProgressBarHeight +
                (AeroCompactUiTokens.playerSheetPeekHeight - PlayerSheetProgressBarHeight) +
                4.dp
        val sharedArtworkX = lerp(collapsedArtworkX, expandedArtworkX, expansionProgress)
        val sharedArtworkY = lerp(collapsedArtworkY, expandedArtworkY, expansionProgress)
        val sharedArtworkSize = lerp(
            AeroCompactUiTokens.playerSheetCollapsedArtworkSize,
            expandedArtworkSize,
            expansionProgress
        )
        val sharedArtworkCornerRadius = lerp(
            12.dp,
            AeroCompactUiTokens.playerSheetExpandedArtworkCornerRadius,
            expansionProgress
        )
        if (scrimAlpha > 0.01f) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(MaterialTheme.colorScheme.scrim.copy(alpha = scrimAlpha))
                    .clickable { onSheetValueChange(collapsePlayerSheet(sheetValue)) }
            )
        }

        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .height(sheetHeight)
                .offset(y = with(density) { offsetPx.toDp() })
                .anchoredDraggable(
                    state = draggableState,
                    orientation = Orientation.Vertical
                )
                .then(
                    if (sheetValue == ExpandablePlayerSheetValue.Expanded) {
                        Modifier.testTag("expanded_player")
                    } else {
                        Modifier
                    }
                ),
            color = MaterialTheme.colorScheme.surface,
            contentColor = MaterialTheme.colorScheme.onSurface,
            shape = RoundedCornerShape(topStart = cornerRadius, topEnd = cornerRadius)
        ) {
            Box(modifier = Modifier.fillMaxSize()) {
                Column(
                    modifier = Modifier.fillMaxSize()
                ) {
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(PlayerSheetProgressBarHeight)
                    ) {
                        if (collapsedContentProgress > 0.01f) {
                            LinearProgressIndicator(
                                progress = { progressFraction },
                                modifier = Modifier
                                    .fillMaxSize()
                                    .graphicsLayer {
                                        alpha = collapsedContentProgress.coerceIn(0f, 1f)
                                    }
                                    .testTag("collapsed_progress"),
                                color = MaterialTheme.colorScheme.primary,
                                trackColor = MaterialTheme.colorScheme.surfaceVariant
                            )
                        }
                    }

                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(AeroCompactUiTokens.playerSheetPeekHeight - PlayerSheetProgressBarHeight)
                    ) {
                        if (collapsedContentProgress > 0.01f) {
                            CollapsedPlayerHeader(
                                songTitle = song.title,
                                songArtist = song.artist,
                                isPlaying = playerState.isPlaying,
                                onExpand = { onSheetValueChange(expandPlayerSheet(sheetValue)) },
                                onPlayPause = onPlayPause,
                                onSkipNext = onSkipNext,
                                alpha = collapsedContentProgress.coerceIn(0f, 1f),
                                artworkSpacerWidth = AeroCompactUiTokens.playerSheetCollapsedArtworkSize,
                                modifier = Modifier
                                    .fillMaxSize()
                                    .then(
                                        if (sheetValue != ExpandablePlayerSheetValue.Expanded) {
                                            Modifier.testTag("collapsed_player")
                                        } else {
                                            Modifier
                                        }
                                    )
                            )
                        }

                        if (expandedContentProgress > 0.01f) {
                            ExpandedPlayerTopBar(
                                onCollapse = { onSheetValueChange(collapsePlayerSheet(sheetValue)) },
                                alpha = expandedContentProgress.coerceIn(0f, 1f),
                                modifier = Modifier.fillMaxSize()
                            )
                        }
                    }

                }

                if (expandedContentProgress > 0.01f) {
                    ExpandedPlayerBottomControls(
                        playerState = playerState,
                        progress = expandedContentProgress,
                        horizontalPadding = horizontalPadding,
                        onPlayPause = onPlayPause,
                        onSkipNext = onSkipNext,
                        onSkipPrevious = onSkipPrevious,
                        onSeek = onSeek,
                        onRepeatModeChange = onRepeatModeChange,
                        onShuffleToggle = onShuffleToggle,
                        modifier = Modifier
                            .align(Alignment.BottomCenter)
                            .fillMaxWidth()
                    )
                }

                SharedPlayerArtwork(
                    artwork = song.albumArtUri,
                    size = sharedArtworkSize,
                    cornerRadius = sharedArtworkCornerRadius,
                    offsetX = sharedArtworkX,
                    offsetY = sharedArtworkY,
                    modifier = Modifier.fillMaxSize()
                )
            }
        }
    }
}

@Composable
private fun CollapsedPlayerHeader(
    songTitle: String,
    songArtist: String,
    isPlaying: Boolean,
    onExpand: () -> Unit,
    onPlayPause: () -> Unit,
    onSkipNext: () -> Unit,
    alpha: Float,
    artworkSpacerWidth: Dp,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .graphicsLayer { this.alpha = alpha }
            .padding(
                horizontal = AeroCompactUiTokens.playerSheetCollapsedHorizontalPadding,
                vertical = AeroCompactUiTokens.playerSheetCollapsedVerticalPadding
            ),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Row(
            modifier = Modifier
                .weight(1f)
                .fillMaxHeight()
                .clip(RoundedCornerShape(18.dp))
                .clickable(onClick = onExpand)
                .testTag("expand_player"),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Spacer(modifier = Modifier.width(artworkSpacerWidth))
            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(start = 12.dp, end = 8.dp)
            ) {
                Text(
                    text = songTitle,
                    style = AeroCompactUiTokens.rowTitleTextStyle(),
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = songArtist,
                    style = AeroCompactUiTokens.rowSubtitleTextStyle(),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        AeroIconActionButton(
            onClick = onPlayPause,
            contentDescription = if (isPlaying) "Pause" else "Play",
            icon = {
                Icon(
                    imageVector = if (isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = null
                )
            }
        )
        AeroIconActionButton(
            onClick = onSkipNext,
            contentDescription = "Next",
            icon = {
                Icon(
                    imageVector = Icons.Default.SkipNext,
                    contentDescription = null
                )
            }
        )
    }
}

@Composable
private fun ExpandedPlayerTopBar(
    onCollapse: () -> Unit,
    alpha: Float,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .graphicsLayer { this.alpha = alpha }
            .padding(
                horizontal = AeroCompactUiTokens.playerSheetExpandedHorizontalPadding,
                vertical = AeroCompactUiTokens.playerSheetTopBarVerticalPadding
            )
    ) {
        Box(
            modifier = Modifier.fillMaxWidth(),
            contentAlignment = Alignment.Center
        ) {
            Box(
                modifier = Modifier
                    .size(
                        width = AeroCompactUiTokens.playerSheetDragHandleWidth,
                        height = AeroCompactUiTokens.playerSheetDragHandleHeight
                    )
                    .clip(RoundedCornerShape(999.dp))
                    .background(MaterialTheme.colorScheme.onSurface.copy(alpha = 0.18f))
            )
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = AeroCompactUiTokens.playerSheetDragHandleGap),
            verticalAlignment = Alignment.CenterVertically
        ) {
            AeroIconActionButton(
                onClick = onCollapse,
                contentDescription = "collapse_player",
                modifier = Modifier.testTag("collapse_player"),
                icon = {
                    Icon(
                        imageVector = Icons.Default.KeyboardArrowDown,
                        contentDescription = null
                    )
                }
            )

            Spacer(modifier = Modifier.weight(1f))
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun ExpandedPlayerBottomControls(
    playerState: PlayerState,
    progress: Float,
    horizontalPadding: Dp,
    onPlayPause: () -> Unit,
    onSkipNext: () -> Unit,
    onSkipPrevious: () -> Unit,
    onSeek: (Long) -> Unit,
    onRepeatModeChange: () -> Unit,
    onShuffleToggle: () -> Unit,
    modifier: Modifier = Modifier
) {
    val song = playerState.currentSong ?: return
    var sliderPosition by remember(playerState.currentPosition) {
        mutableFloatStateOf(playerState.currentPosition.toFloat())
    }
    var isDragging by remember { mutableStateOf(false) }
    val seekBarHeight by animateDpAsState(
        targetValue = if (isDragging) {
            AeroCompactUiTokens.playerSheetSeekBarDraggingHeight
        } else {
            AeroCompactUiTokens.playerSheetSeekBarIdleHeight
        },
        label = "player_seek_bar_height"
    )

    Column(
        modifier = modifier
            .graphicsLayer {
                alpha = progress
                translationY = (1f - progress) * 20f
            }
            .padding(
                start = horizontalPadding,
                end = horizontalPadding,
                bottom = AeroCompactUiTokens.playerSheetExpandedControlsBottomPadding
            )
            .wrapContentHeight(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = song.title,
            modifier = Modifier.fillMaxWidth(),
            style = MaterialTheme.typography.headlineMedium,
            textAlign = TextAlign.Start,
            maxLines = 2,
            overflow = TextOverflow.Ellipsis
        )
        Text(
            text = song.artist,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 6.dp),
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis
        )

        Slider(
            value = if (isDragging) sliderPosition else playerState.currentPosition.toFloat(),
            onValueChange = {
                isDragging = true
                sliderPosition = it
            },
            onValueChangeFinished = {
                isDragging = false
                onSeek(sliderPosition.toLong())
            },
            valueRange = 0f..playerState.duration.toFloat().coerceAtLeast(1f),
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = AeroCompactUiTokens.playerSheetExpandedControlsTopGap),
            thumb = {},
            track = { sliderState ->
                SimplePlayerSliderTrack(
                    fraction = normalizedSliderFraction(
                        value = sliderState.value,
                        valueRangeStart = sliderState.valueRange.start,
                        valueRangeEnd = sliderState.valueRange.endInclusive
                    ),
                    height = seekBarHeight
                )
            },
            colors = SliderDefaults.colors(
                thumbColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0f),
                activeTrackColor = MaterialTheme.colorScheme.onSurface.copy(alpha = 0f),
                inactiveTrackColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0f)
            )
        )

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = formatPlayerTime(
                    if (isDragging) sliderPosition.toLong() else playerState.currentPosition
                ),
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = formatPlayerTime(playerState.duration),
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }

        PlayerPrimaryControls(
            playerState = playerState,
            onPlayPause = onPlayPause,
            onSkipNext = onSkipNext,
            onSkipPrevious = onSkipPrevious,
            onRepeatModeChange = onRepeatModeChange,
            onShuffleToggle = onShuffleToggle,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 20.dp)
        )

        PlayerQueueSummary(
            playerState = playerState,
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = AeroCompactUiTokens.playerSheetExpandedQueueSummaryTopPadding)
        )
    }
}

@Composable
private fun PlayerPrimaryControls(
    playerState: PlayerState,
    onPlayPause: () -> Unit,
    onSkipNext: () -> Unit,
    onSkipPrevious: () -> Unit,
    onRepeatModeChange: () -> Unit,
    onShuffleToggle: () -> Unit,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier,
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        AeroIconActionButton(
            onClick = onShuffleToggle,
            contentDescription = "Shuffle",
            icon = {
                Icon(
                    imageVector = Icons.Default.Shuffle,
                    contentDescription = null,
                    tint = if (playerState.isShuffleEnabled) {
                        MaterialTheme.colorScheme.onSurface
                    } else {
                        MaterialTheme.colorScheme.onSurfaceVariant
                    }
                )
            }
        )
        AeroIconActionButton(
            onClick = onSkipPrevious,
            contentDescription = "Previous",
            modifier = Modifier.size(56.dp),
            icon = {
                Icon(
                    imageVector = Icons.Default.SkipPrevious,
                    contentDescription = null,
                    modifier = Modifier.size(40.dp)
                )
            }
        )
        AeroIconActionButton(
            onClick = onPlayPause,
            modifier = Modifier.size(76.dp),
            style = AeroIconActionStyle.Filled,
            filledColors = IconButtonDefaults.filledIconButtonColors(
                containerColor = MaterialTheme.colorScheme.onSurface,
                contentColor = MaterialTheme.colorScheme.surface
            ),
            contentDescription = if (playerState.isPlaying) "Pause" else "Play",
            icon = {
                Icon(
                    imageVector = if (playerState.isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = null,
                    modifier = Modifier.size(40.dp)
                )
            }
        )
        AeroIconActionButton(
            onClick = onSkipNext,
            contentDescription = "Next",
            modifier = Modifier.size(56.dp),
            icon = {
                Icon(
                    imageVector = Icons.Default.SkipNext,
                    contentDescription = null,
                    modifier = Modifier.size(40.dp)
                )
            }
        )
        AeroIconActionButton(
            onClick = onRepeatModeChange,
            contentDescription = "Repeat",
            icon = {
                Icon(
                    imageVector = when (playerState.repeatMode) {
                        RepeatMode.ONE -> Icons.Default.RepeatOne
                        else -> Icons.Default.Repeat
                    },
                    contentDescription = null,
                    tint = if (playerState.repeatMode == RepeatMode.OFF) {
                        MaterialTheme.colorScheme.onSurfaceVariant
                    } else {
                        MaterialTheme.colorScheme.onSurface
                    }
                )
            }
        )
    }
}

@Composable
private fun PlayerQueueSummary(
    playerState: PlayerState,
    modifier: Modifier = Modifier
) {
    val song = playerState.currentSong ?: return
    val queueSize = playerState.queue.size
    val queueIndex = (playerState.currentQueueIndex + 1).coerceAtLeast(1)
    val summary = if (queueSize > 0) {
        "$queueIndex / $queueSize"
    } else {
        "1 / 1"
    }
    val album = song.album.ifBlank { "シングル" }

    Surface(
        modifier = modifier
            .testTag("player_queue_summary")
            .semantics { contentDescription = "player_queue_summary" },
        shape = RoundedCornerShape(20.dp),
        color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.52f)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 18.dp, vertical = 16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = Icons.AutoMirrored.Filled.QueueMusic,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurface
            )
            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(start = 12.dp)
            ) {
                Text(
                    text = summary,
                    style = MaterialTheme.typography.titleSmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = album,
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}

@Composable
private fun SharedPlayerArtwork(
    artwork: Any?,
    size: Dp,
    cornerRadius: Dp,
    offsetX: Dp,
    offsetY: Dp,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .testTag("shared_player_artwork")
    ) {
        PlayerArtwork(
            artwork = artwork,
            size = size,
            cornerRadius = cornerRadius,
            modifier = Modifier.offset(x = offsetX, y = offsetY)
        )
    }
}

@Composable
private fun PlayerArtwork(
    artwork: Any?,
    size: Dp,
    cornerRadius: Dp = 12.dp,
    modifier: Modifier = Modifier
) {
    if (artwork != null) {
        AsyncImage(
            model = artwork,
            contentDescription = "Album art",
            modifier = modifier
                .size(size)
                .aspectRatio(1f)
                .clip(RoundedCornerShape(cornerRadius)),
            contentScale = ContentScale.Crop
        )
    } else {
        Box(
            modifier = modifier
                .size(size)
                .aspectRatio(1f)
                .clip(RoundedCornerShape(cornerRadius))
                .background(MaterialTheme.colorScheme.surfaceVariant),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = if (size > 96.dp) Icons.Default.Album else Icons.Default.MusicNote,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}

private fun formatPlayerTime(durationMs: Long): String {
    val totalSeconds = (durationMs / 1000).coerceAtLeast(0)
    val minutes = totalSeconds / 60
    val seconds = totalSeconds % 60
    return "%d:%02d".format(minutes, seconds)
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun SimplePlayerSliderTrack(
    fraction: Float,
    height: Dp
) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(height)
            .clip(RoundedCornerShape(999.dp))
            .background(MaterialTheme.colorScheme.onSurface.copy(alpha = 0.22f))
    ) {
        Box(
            modifier = Modifier
                .fillMaxWidth(fraction.coerceIn(0f, 1f))
                .fillMaxHeight()
                .background(MaterialTheme.colorScheme.onSurface)
        )
    }
}

private fun normalizedSliderFraction(
    value: Float,
    valueRangeStart: Float,
    valueRangeEnd: Float
): Float {
    val range = (valueRangeEnd - valueRangeStart).coerceAtLeast(1f)
    return ((value - valueRangeStart) / range).coerceIn(0f, 1f)
}

private fun remapProgress(
    progress: Float,
    start: Float,
    end: Float
): Float {
    return ((progress - start) / (end - start).coerceAtLeast(0.0001f))
        .coerceIn(0f, 1f)
}
