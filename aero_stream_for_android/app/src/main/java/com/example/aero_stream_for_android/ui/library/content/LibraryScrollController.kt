package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.foundation.lazy.LazyListState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.Stable
import androidx.compose.runtime.State
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableFloatStateOf
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.runtime.snapshotFlow
import androidx.compose.ui.util.fastForEach
import kotlinx.coroutines.flow.collectLatest
import kotlin.math.roundToInt

internal data class ScrollTarget(val index: Int, val offset: Int)

internal data class LibraryScrollMetrics(
    val normalizedProgress: Float,
    val canScroll: Boolean,
    val currentScrollablePx: Int,
    val totalScrollablePx: Int,
    val averageItemHeightPx: Int,
    val totalItemsCount: Int
)

internal fun clampProgress(progress: Float): Float = progress.coerceIn(0f, 1f)

internal fun normalizeProgress(currentScrollablePx: Int, totalScrollablePx: Int): Float {
    if (totalScrollablePx <= 0) return 0f
    return clampProgress(currentScrollablePx.toFloat() / totalScrollablePx.toFloat())
}

internal fun estimateTotalContentPx(
    totalItemsCount: Int,
    measuredHeightsPx: Map<Int, Int>,
    averageItemHeightPx: Int
): Int {
    if (totalItemsCount <= 0) return 0
    var sum = 0
    for (index in 0 until totalItemsCount) {
        sum += measuredHeightsPx[index] ?: averageItemHeightPx
    }
    return sum
}

internal fun estimatePrefixContentPx(
    endExclusiveIndex: Int,
    measuredHeightsPx: Map<Int, Int>,
    averageItemHeightPx: Int
): Int {
    if (endExclusiveIndex <= 0) return 0
    var sum = 0
    for (index in 0 until endExclusiveIndex) {
        sum += measuredHeightsPx[index] ?: averageItemHeightPx
    }
    return sum
}

internal fun calculateMetrics(
    measuredHeightsPx: Map<Int, Int>,
    totalItemsCount: Int,
    firstVisibleItemIndex: Int,
    firstVisibleItemScrollOffset: Int,
    viewportHeightPx: Int,
    canScrollBackward: Boolean,
    canScrollForward: Boolean,
    fallbackAverageHeightPx: Int
): LibraryScrollMetrics {
    val safeAverage = when {
        measuredHeightsPx.isNotEmpty() -> measuredHeightsPx.values.average().roundToInt().coerceAtLeast(1)
        fallbackAverageHeightPx > 0 -> fallbackAverageHeightPx
        else -> 1
    }

    val totalContentPx = estimateTotalContentPx(
        totalItemsCount = totalItemsCount,
        measuredHeightsPx = measuredHeightsPx,
        averageItemHeightPx = safeAverage
    )
    val totalScrollablePx = (totalContentPx - viewportHeightPx).coerceAtLeast(0)

    val prefixPx = estimatePrefixContentPx(
        endExclusiveIndex = firstVisibleItemIndex,
        measuredHeightsPx = measuredHeightsPx,
        averageItemHeightPx = safeAverage
    )
    val currentPx = (prefixPx + firstVisibleItemScrollOffset).coerceAtLeast(0)
    val normalized = when {
        !canScrollBackward -> 0f
        !canScrollForward -> 1f
        else -> normalizeProgress(currentScrollablePx = currentPx, totalScrollablePx = totalScrollablePx)
    }

    return LibraryScrollMetrics(
        normalizedProgress = normalized,
        canScroll = totalScrollablePx > 0 && (canScrollBackward || canScrollForward),
        currentScrollablePx = currentPx.coerceAtMost(totalScrollablePx),
        totalScrollablePx = totalScrollablePx,
        averageItemHeightPx = safeAverage,
        totalItemsCount = totalItemsCount
    )
}

internal fun progressToTarget(
    progress: Float,
    measuredHeightsPx: Map<Int, Int>,
    totalItemsCount: Int,
    totalScrollablePx: Int,
    averageItemHeightPx: Int
): ScrollTarget {
    if (totalItemsCount <= 0) return ScrollTarget(index = 0, offset = 0)

    val clampedProgress = clampProgress(progress)
    if (clampedProgress <= 0f) return ScrollTarget(index = 0, offset = 0)

    val targetPx = (totalScrollablePx.toFloat() * clampedProgress).roundToInt().coerceAtLeast(0)
    val safeAverage = averageItemHeightPx.coerceAtLeast(1)
    val prefixPx = IntArray(totalItemsCount + 1)
    for (index in 0 until totalItemsCount) {
        prefixPx[index + 1] = prefixPx[index] + (measuredHeightsPx[index] ?: safeAverage)
    }

    val clampedTargetPx = targetPx.coerceIn(0, prefixPx.last().coerceAtLeast(0))
    var low = 0
    var high = prefixPx.size - 1
    while (low < high) {
        val mid = (low + high) ushr 1
        if (prefixPx[mid] <= clampedTargetPx) {
            low = mid + 1
        } else {
            high = mid
        }
    }

    val index = (low - 1).coerceIn(0, totalItemsCount - 1)
    val itemStartPx = prefixPx[index]
    val itemHeight = (prefixPx[index + 1] - itemStartPx).coerceAtLeast(1)
    val offset = (clampedTargetPx - itemStartPx).coerceIn(0, itemHeight - 1)
    return ScrollTarget(index = index, offset = offset)
}

@Stable
internal class LibraryScrollController internal constructor(
    private val listState: LazyListState
) {
    private val measuredHeightsPx: MutableMap<Int, Int> = mutableMapOf()
    private var averageHeightPx by mutableIntStateOf(1)
    private var totalItemsCount by mutableIntStateOf(0)
    private var totalScrollablePx by mutableIntStateOf(0)

    private val _progress = mutableFloatStateOf(0f)
    val progress: State<Float> = _progress

    private val _canScroll = mutableStateOf(false)
    val canScroll: State<Boolean> = _canScroll

    val currentScrollablePx: Int
        get() = (_progress.floatValue * totalScrollablePx).roundToInt()

    fun updateFromListState() {
        val layoutInfo = listState.layoutInfo
        val viewportHeightPx = (layoutInfo.viewportEndOffset - layoutInfo.viewportStartOffset).coerceAtLeast(0)
        if (layoutInfo.visibleItemsInfo.isNotEmpty()) {
            layoutInfo.visibleItemsInfo.fastForEach { item ->
                measuredHeightsPx[item.index] = item.size.coerceAtLeast(1)
            }
        }

        val metrics = calculateMetrics(
            measuredHeightsPx = measuredHeightsPx,
            totalItemsCount = layoutInfo.totalItemsCount,
            firstVisibleItemIndex = listState.firstVisibleItemIndex,
            firstVisibleItemScrollOffset = listState.firstVisibleItemScrollOffset,
            viewportHeightPx = viewportHeightPx,
            canScrollBackward = listState.canScrollBackward,
            canScrollForward = listState.canScrollForward,
            fallbackAverageHeightPx = if (viewportHeightPx > 0 && layoutInfo.totalItemsCount > 0) {
                (viewportHeightPx / layoutInfo.totalItemsCount.coerceAtLeast(1)).coerceAtLeast(1)
            } else {
                1
            }
        )

        averageHeightPx = metrics.averageItemHeightPx
        totalItemsCount = metrics.totalItemsCount
        totalScrollablePx = metrics.totalScrollablePx
        _progress.floatValue = metrics.normalizedProgress
        _canScroll.value = metrics.canScroll
    }

    fun progressToTarget(progress: Float): ScrollTarget {
        return progressToTarget(
            progress = progress,
            measuredHeightsPx = measuredHeightsPx,
            totalItemsCount = totalItemsCount,
            totalScrollablePx = totalScrollablePx,
            averageItemHeightPx = averageHeightPx
        )
    }

    suspend fun scrollToProgress(progress: Float, animated: Boolean) {
        val target = progressToTarget(progress)
        if (animated) {
            listState.animateScrollToItem(target.index, target.offset)
        } else {
            listState.scrollToItem(target.index, target.offset)
        }
    }
}

@Composable
internal fun rememberLibraryScrollController(listState: LazyListState): LibraryScrollController {
    val controller = remember(listState) { LibraryScrollController(listState) }

    androidx.compose.runtime.LaunchedEffect(controller) {
        controller.updateFromListState()
    }

    androidx.compose.runtime.LaunchedEffect(listState, controller) {
        snapshotFlow {
            listState.firstVisibleItemIndex to listState.firstVisibleItemScrollOffset
        }.collectLatest {
            controller.updateFromListState()
        }
    }

    androidx.compose.runtime.LaunchedEffect(listState, controller) {
        snapshotFlow {
            listState.layoutInfo.visibleItemsInfo.map { item -> Triple(item.index, item.size, item.offset) }
        }.collectLatest {
            controller.updateFromListState()
        }
    }

    return controller
}
