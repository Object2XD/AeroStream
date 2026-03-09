package com.example.aero_stream_for_android.ui.root

import com.example.aero_stream_for_android.ui.components.ExpandablePlayerSheetValue
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNull
import org.junit.Test

class RootShellPlayerSheetStateTest {

    @Test
    fun resolvePlayerSheetForRouteVisibility_expandedToSettingsAndBack_restoresExpanded() {
        val hiddenOnSettings = resolvePlayerSheetForRouteVisibility(
            currentValue = ExpandablePlayerSheetValue.Expanded,
            stashedValue = null,
            hasCurrentSong = true,
            isPlayerSheetVisibleRoute = false
        )
        assertEquals(ExpandablePlayerSheetValue.Hidden, hiddenOnSettings.sheetValue)
        assertEquals(ExpandablePlayerSheetValue.Expanded, hiddenOnSettings.stashedValue)

        val restored = resolvePlayerSheetForRouteVisibility(
            currentValue = hiddenOnSettings.sheetValue,
            stashedValue = hiddenOnSettings.stashedValue,
            hasCurrentSong = true,
            isPlayerSheetVisibleRoute = true
        )
        assertEquals(ExpandablePlayerSheetValue.Expanded, restored.sheetValue)
        assertNull(restored.stashedValue)
    }

    @Test
    fun resolvePlayerSheetForRouteVisibility_collapsedToSettingsAndBack_restoresCollapsed() {
        val hiddenOnSettings = resolvePlayerSheetForRouteVisibility(
            currentValue = ExpandablePlayerSheetValue.Collapsed,
            stashedValue = null,
            hasCurrentSong = true,
            isPlayerSheetVisibleRoute = false
        )
        assertEquals(ExpandablePlayerSheetValue.Hidden, hiddenOnSettings.sheetValue)
        assertEquals(ExpandablePlayerSheetValue.Collapsed, hiddenOnSettings.stashedValue)

        val restored = resolvePlayerSheetForRouteVisibility(
            currentValue = hiddenOnSettings.sheetValue,
            stashedValue = hiddenOnSettings.stashedValue,
            hasCurrentSong = true,
            isPlayerSheetVisibleRoute = true
        )
        assertEquals(ExpandablePlayerSheetValue.Collapsed, restored.sheetValue)
        assertNull(restored.stashedValue)
    }

    @Test
    fun resolvePlayerSheetForRouteVisibility_songRemovedOnSettings_doesNotRestore() {
        val hiddenOnSettings = resolvePlayerSheetForRouteVisibility(
            currentValue = ExpandablePlayerSheetValue.Expanded,
            stashedValue = null,
            hasCurrentSong = true,
            isPlayerSheetVisibleRoute = false
        )
        assertEquals(ExpandablePlayerSheetValue.Expanded, hiddenOnSettings.stashedValue)

        val whileNoSong = resolvePlayerSheetForRouteVisibility(
            currentValue = hiddenOnSettings.sheetValue,
            stashedValue = hiddenOnSettings.stashedValue,
            hasCurrentSong = false,
            isPlayerSheetVisibleRoute = false
        )
        assertEquals(ExpandablePlayerSheetValue.Hidden, whileNoSong.sheetValue)
        assertNull(whileNoSong.stashedValue)

        val backToVisible = resolvePlayerSheetForRouteVisibility(
            currentValue = whileNoSong.sheetValue,
            stashedValue = whileNoSong.stashedValue,
            hasCurrentSong = false,
            isPlayerSheetVisibleRoute = true
        )
        assertEquals(ExpandablePlayerSheetValue.Hidden, backToVisible.sheetValue)
        assertNull(backToVisible.stashedValue)
    }
}
