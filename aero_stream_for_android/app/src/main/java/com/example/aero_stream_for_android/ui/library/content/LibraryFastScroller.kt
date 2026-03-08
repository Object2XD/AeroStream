package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

internal fun shouldShowFastScroller(visible: Boolean): Boolean = visible
internal fun shouldShowIndexBubble(
    visible: Boolean,
    isDraggingScrollbar: Boolean,
    isNameSort: Boolean,
    bubbleLabel: String?
): Boolean = visible && isDraggingScrollbar && isNameSort && !bubbleLabel.isNullOrBlank()

internal fun normalizeAlphabetLabel(text: String?): String {
    val firstChar = text?.trim()?.firstOrNull() ?: return "#"
    return if (firstChar.isLetter() && firstChar.code < 128) {
        firstChar.uppercaseChar().toString()
    } else {
        "#"
    }
}

internal fun progressFromTouchY(yPx: Float, containerHeightPx: Float): Float {
    if (containerHeightPx <= 0f) return 0f
    return (yPx / containerHeightPx).coerceIn(0f, 1f)
}
internal fun tapSeekRequest(yPx: Float, containerHeightPx: Float): Pair<Float, Boolean> {
    return progressFromTouchY(yPx = yPx, containerHeightPx = containerHeightPx) to true
}
internal fun dragSeekRequest(yPx: Float, containerHeightPx: Float): Pair<Float, Boolean> {
    return progressFromTouchY(yPx = yPx, containerHeightPx = containerHeightPx) to false
}
internal fun calculateBubbleTop(
    thumbTopPx: Float,
    thumbHeightPx: Float,
    bubbleHeightPx: Float,
    containerHeightPx: Float
): Float {
    if (containerHeightPx <= 0f || bubbleHeightPx <= 0f) return 0f
    val desiredTop = thumbTopPx + (thumbHeightPx / 2f) - (bubbleHeightPx / 2f)
    val maxTop = (containerHeightPx - bubbleHeightPx).coerceAtLeast(0f)
    return desiredTop.coerceIn(0f, maxTop)
}

internal fun calculateThumbTop(progress: Float, containerHeightPx: Float, thumbHeightPx: Float): Float {
    if (containerHeightPx <= 0f || thumbHeightPx <= 0f) return 0f
    val travel = (containerHeightPx - thumbHeightPx).coerceAtLeast(0f)
    return (travel * progress.coerceIn(0f, 1f)).coerceIn(0f, travel)
}

internal fun alignedTrackAndThumbX(
    containerWidthPx: Float,
    trackWidthPx: Float,
    thumbWidthPx: Float
): Pair<Float, Float> {
    val centerXPx = containerWidthPx - (thumbWidthPx / 2f)
    val trackXPx = centerXPx - (trackWidthPx / 2f)
    val thumbXPx = centerXPx - (thumbWidthPx / 2f)
    return trackXPx to thumbXPx
}

@Composable
internal fun LibraryFastScroller(
    progress: Float,
    visible: Boolean,
    isNameSort: Boolean,
    bubbleLabel: String?,
    onSeekRequested: (progress: Float, animated: Boolean) -> Unit,
    bottomClearance: Dp = 0.dp,
    modifier: Modifier = Modifier
) {
    if (!shouldShowFastScroller(visible)) return

    val density = LocalDensity.current
    var isDraggingScrollbar by remember { mutableStateOf(false) }

    BoxWithConstraints(
        modifier = modifier
            .padding(bottom = bottomClearance)
            .fillMaxHeight()
            .width(AeroCompactUiTokens.fastScrollerTouchWidth)
            .pointerInput(Unit) {
                detectTapGestures(
                    onTap = { offset ->
                        val (seekProgress, animated) = tapSeekRequest(
                            yPx = offset.y,
                            containerHeightPx = size.height.toFloat()
                        )
                        onSeekRequested(seekProgress, animated)
                    }
                )
            }
            .pointerInput(Unit) {
                detectVerticalDragGestures(
                    onDragStart = { offset ->
                        isDraggingScrollbar = true
                        val (seekProgress, animated) = dragSeekRequest(
                            yPx = offset.y,
                            containerHeightPx = size.height.toFloat()
                        )
                        onSeekRequested(seekProgress, animated)
                    },
                    onDragEnd = { isDraggingScrollbar = false },
                    onDragCancel = { isDraggingScrollbar = false },
                    onVerticalDrag = { change, _ ->
                        change.consume()
                        val (seekProgress, animated) = dragSeekRequest(
                            yPx = change.position.y,
                            containerHeightPx = size.height.toFloat()
                        )
                        onSeekRequested(seekProgress, animated)
                    }
                )
            },
        contentAlignment = Alignment.TopStart
    ) {
        val containerHeightPx = constraints.maxHeight.toFloat()
        val containerWidthPx = constraints.maxWidth.toFloat()
        val trackWidthPx = with(density) { AeroCompactUiTokens.fastScrollerTrackWidth.toPx() }
        val thumbWidthPx = with(density) { AeroCompactUiTokens.fastScrollerThumbWidth.toPx() }
        val thumbHeightPx = with(density) { AeroCompactUiTokens.fastScrollerThumbHeight.toPx() }
        val bubbleMinHeightPx = with(density) { AeroCompactUiTokens.fastScrollerBubbleMinHeight.toPx() }

        val (trackXPx, thumbXPx) = alignedTrackAndThumbX(
            containerWidthPx = containerWidthPx,
            trackWidthPx = trackWidthPx,
            thumbWidthPx = thumbWidthPx
        )
        val thumbTopPx = calculateThumbTop(
            progress = progress,
            containerHeightPx = containerHeightPx,
            thumbHeightPx = thumbHeightPx
        )
        val showBubble = shouldShowIndexBubble(
            visible = visible,
            isDraggingScrollbar = isDraggingScrollbar,
            isNameSort = isNameSort,
            bubbleLabel = bubbleLabel
        )
        val bubbleTopPx = calculateBubbleTop(
            thumbTopPx = thumbTopPx,
            thumbHeightPx = thumbHeightPx,
            bubbleHeightPx = bubbleMinHeightPx,
            containerHeightPx = containerHeightPx
        )

        Box(
            modifier = Modifier
                .offset(
                    x = with(density) { trackXPx.toDp() },
                    y = with(density) { 0f.toDp() }
                )
                .fillMaxHeight()
                .width(AeroCompactUiTokens.fastScrollerTrackWidth)
                .clip(MaterialTheme.shapes.extraLarge)
                .background(MaterialTheme.colorScheme.onSurface.copy(alpha = 0.16f))
        )

        Box(
            modifier = Modifier
                .offset(
                    x = with(density) { thumbXPx.toDp() },
                    y = with(density) { thumbTopPx.toDp() }
                )
                .sizeIn(
                    minWidth = AeroCompactUiTokens.fastScrollerThumbWidth,
                    maxWidth = AeroCompactUiTokens.fastScrollerThumbWidth,
                    minHeight = AeroCompactUiTokens.fastScrollerThumbHeight,
                    maxHeight = AeroCompactUiTokens.fastScrollerThumbHeight
                )
                .clip(MaterialTheme.shapes.extraLarge)
                .background(MaterialTheme.colorScheme.onSurface.copy(alpha = 0.86f))
        )

        if (showBubble) {
            Box(
                modifier = Modifier
                    .offset(
                        x = with(density) {
                            (thumbXPx - AeroCompactUiTokens.fastScrollerBubbleGap.toPx() - AeroCompactUiTokens.fastScrollerBubbleMinWidth.toPx()).toDp()
                        },
                        y = with(density) { bubbleTopPx.toDp() }
                    )
                    .sizeIn(
                        minWidth = AeroCompactUiTokens.fastScrollerBubbleMinWidth,
                        minHeight = AeroCompactUiTokens.fastScrollerBubbleMinHeight
                    )
                    .clip(MaterialTheme.shapes.large)
                    .background(MaterialTheme.colorScheme.surfaceVariant.copy(alpha = AeroCompactUiTokens.fastScrollerBubbleBackgroundAlpha)),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = bubbleLabel ?: "#",
                    style = MaterialTheme.typography.labelLarge.copy(fontWeight = FontWeight.SemiBold),
                    color = MaterialTheme.colorScheme.onSurface,
                    maxLines = 1
                )
            }
        }
    }
}
