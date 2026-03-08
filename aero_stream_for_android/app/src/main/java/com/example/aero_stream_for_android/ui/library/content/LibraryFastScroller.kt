package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.sizeIn
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.gestures.detectVerticalDragGestures
import androidx.compose.foundation.gestures.detectTapGestures
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.platform.LocalDensity
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

internal fun shouldShowFastScroller(visible: Boolean): Boolean = visible
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
    onSeekRequested: (progress: Float, animated: Boolean) -> Unit,
    modifier: Modifier = Modifier
) {
    if (!shouldShowFastScroller(visible)) return

    val density = LocalDensity.current

    BoxWithConstraints(
        modifier = modifier
            .fillMaxHeight()
            .width(AeroCompactUiTokens.fastScrollerTouchWidth)
            .pointerInput(Unit) {
                detectTapGestures { offset ->
                    val (seekProgress, animated) = tapSeekRequest(
                        yPx = offset.y,
                        containerHeightPx = size.height.toFloat()
                    )
                    onSeekRequested(seekProgress, animated)
                }
            }
            .pointerInput(Unit) {
                detectVerticalDragGestures(
                    onDragStart = { offset ->
                        val (seekProgress, animated) = dragSeekRequest(
                            yPx = offset.y,
                            containerHeightPx = size.height.toFloat()
                        )
                        onSeekRequested(seekProgress, animated)
                    },
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
    }
}
