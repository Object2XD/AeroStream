package com.example.aero_stream_for_android.ui.root

import org.junit.Assert.assertEquals
import org.junit.Test

class QuickReturnHeaderStateTest {

    @Test
    fun updateHeaderHeight_withinOnePixel_returnsSameState() {
        val state = QuickReturnHeaderState(totalHeaderHeightPx = 100, headerOffsetPx = -20f)

        val updated = state.updateHeaderHeight(101)

        assertEquals(state, updated)
    }

    @Test
    fun updateHeaderHeight_negativeValue_clampsToZero() {
        val state = QuickReturnHeaderState(totalHeaderHeightPx = 5, headerOffsetPx = -40f)

        val updated = state.updateHeaderHeight(-10)

        assertEquals(0, updated.totalHeaderHeightPx)
        assertEquals(0f, updated.headerOffsetPx, 0f)
    }

    @Test
    fun updateHeaderHeight_clampsExistingOffsetIntoNewRange() {
        val state = QuickReturnHeaderState(totalHeaderHeightPx = 200, headerOffsetPx = -150f)

        val updated = state.updateHeaderHeight(80)

        assertEquals(80, updated.totalHeaderHeightPx)
        assertEquals(-80f, updated.headerOffsetPx)
    }

    @Test
    fun applyScrollDelta_withoutHeight_resetsOffsetToZero() {
        val state = QuickReturnHeaderState(totalHeaderHeightPx = 0, headerOffsetPx = -30f)

        val updated = state.applyScrollDelta(-10f)

        assertEquals(0, updated.totalHeaderHeightPx)
        assertEquals(0f, updated.headerOffsetPx, 0f)
    }

    @Test
    fun applyScrollDelta_clampsOffsetWithinHeightRange() {
        val state = QuickReturnHeaderState(totalHeaderHeightPx = 100, headerOffsetPx = -20f)

        val collapsed = state.applyScrollDelta(-200f)
        val expanded = collapsed.applyScrollDelta(300f)

        assertEquals(-100f, collapsed.headerOffsetPx, 0f)
        assertEquals(0f, expanded.headerOffsetPx, 0f)
    }

    @Test
    fun resetOffset_alwaysReturnsZeroOffset() {
        val state = QuickReturnHeaderState(totalHeaderHeightPx = 100, headerOffsetPx = -60f)

        val updated = state.resetOffset()

        assertEquals(0f, updated.headerOffsetPx, 0f)
    }

    @Test
    fun visibleHeaderHeight_isAlwaysClampedWithinBounds() {
        val overExpanded = QuickReturnHeaderState(totalHeaderHeightPx = 100, headerOffsetPx = 30f)
        val overCollapsed = QuickReturnHeaderState(totalHeaderHeightPx = 100, headerOffsetPx = -150f)

        assertEquals(100f, overExpanded.visibleHeaderHeightPx, 0f)
        assertEquals(0f, overCollapsed.visibleHeaderHeightPx, 0f)
    }
}
