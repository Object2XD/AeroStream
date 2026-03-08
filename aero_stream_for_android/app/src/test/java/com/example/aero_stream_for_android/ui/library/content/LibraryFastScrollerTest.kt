package com.example.aero_stream_for_android.ui.library.content

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class LibraryFastScrollerTest {

    @Test
    fun normalizeProgress_clampsRange() {
        assertEquals(0f, normalizeProgress(currentScrollablePx = -100, totalScrollablePx = 1000), 0.0001f)
        assertEquals(0.5f, normalizeProgress(currentScrollablePx = 500, totalScrollablePx = 1000), 0.0001f)
        assertEquals(1f, normalizeProgress(currentScrollablePx = 5000, totalScrollablePx = 1000), 0.0001f)
        assertEquals(0f, normalizeProgress(currentScrollablePx = 100, totalScrollablePx = 0), 0.0001f)
    }

    @Test
    fun calculateMetrics_appliesEdgeCorrections() {
        val measured = mapOf(0 to 100, 1 to 100, 2 to 100, 3 to 100)

        val topMetrics = calculateMetrics(
            measuredHeightsPx = measured,
            totalItemsCount = 4,
            firstVisibleItemIndex = 0,
            firstVisibleItemScrollOffset = 0,
            viewportHeightPx = 150,
            canScrollBackward = false,
            canScrollForward = true,
            fallbackAverageHeightPx = 100
        )
        assertEquals(0f, topMetrics.normalizedProgress, 0.0001f)

        val bottomMetrics = calculateMetrics(
            measuredHeightsPx = measured,
            totalItemsCount = 4,
            firstVisibleItemIndex = 2,
            firstVisibleItemScrollOffset = 20,
            viewportHeightPx = 150,
            canScrollBackward = true,
            canScrollForward = false,
            fallbackAverageHeightPx = 100
        )
        assertEquals(1f, bottomMetrics.normalizedProgress, 0.0001f)
    }

    @Test
    fun calculateMetrics_monotonicForIrregularHeights() {
        val measured = mapOf(0 to 120, 1 to 320, 2 to 80, 3 to 260, 4 to 140)

        val a = calculateMetrics(
            measuredHeightsPx = measured,
            totalItemsCount = 5,
            firstVisibleItemIndex = 0,
            firstVisibleItemScrollOffset = 30,
            viewportHeightPx = 300,
            canScrollBackward = true,
            canScrollForward = true,
            fallbackAverageHeightPx = 100
        )
        val b = calculateMetrics(
            measuredHeightsPx = measured,
            totalItemsCount = 5,
            firstVisibleItemIndex = 1,
            firstVisibleItemScrollOffset = 10,
            viewportHeightPx = 300,
            canScrollBackward = true,
            canScrollForward = true,
            fallbackAverageHeightPx = 100
        )

        assertTrue(b.normalizedProgress >= a.normalizedProgress)
    }

    @Test
    fun progressToTarget_roundTripIsClose() {
        val measured = mapOf(0 to 100, 1 to 220, 2 to 80, 3 to 140, 4 to 160)
        val metrics = calculateMetrics(
            measuredHeightsPx = measured,
            totalItemsCount = 5,
            firstVisibleItemIndex = 2,
            firstVisibleItemScrollOffset = 40,
            viewportHeightPx = 250,
            canScrollBackward = true,
            canScrollForward = true,
            fallbackAverageHeightPx = 100
        )

        val originalProgress = 0.6f
        val target = progressToTarget(
            progress = originalProgress,
            measuredHeightsPx = measured,
            totalItemsCount = 5,
            totalScrollablePx = metrics.totalScrollablePx,
            averageItemHeightPx = metrics.averageItemHeightPx
        )

        val reconstructedPx = estimatePrefixContentPx(
            endExclusiveIndex = target.index,
            measuredHeightsPx = measured,
            averageItemHeightPx = metrics.averageItemHeightPx
        ) + target.offset
        val reconstructedProgress = normalizeProgress(reconstructedPx, metrics.totalScrollablePx)

        assertEquals(originalProgress, reconstructedProgress, 0.12f)
    }

    @Test
    fun shouldShowFastScroller_requiresVisibleFlag() {
        assertTrue(shouldShowFastScroller(visible = true))
        assertFalse(shouldShowFastScroller(visible = false))
    }

    @Test
    fun calculateThumbTop_staysWithinTrackRange() {
        val containerHeightPx = 1000f
        val thumbHeightPx = 20f
        val travel = 980f

        assertEquals(0f, calculateThumbTop(0f, containerHeightPx, thumbHeightPx), 0.0001f)
        assertEquals(travel / 2f, calculateThumbTop(0.5f, containerHeightPx, thumbHeightPx), 0.0001f)
        assertEquals(travel, calculateThumbTop(1f, containerHeightPx, thumbHeightPx), 0.0001f)
    }

    @Test
    fun alignedTrackAndThumbX_shareSameCenter() {
        val containerWidthPx = 28f
        val trackWidthPx = 3f
        val thumbWidthPx = 8f

        val (trackX, thumbX) = alignedTrackAndThumbX(
            containerWidthPx = containerWidthPx,
            trackWidthPx = trackWidthPx,
            thumbWidthPx = thumbWidthPx
        )
        val trackCenter = trackX + (trackWidthPx / 2f)
        val thumbCenter = thumbX + (thumbWidthPx / 2f)

        assertEquals(trackCenter, thumbCenter, 0.0001f)
    }
}
