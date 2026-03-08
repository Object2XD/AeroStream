package com.example.aero_stream_for_android.ui.components

import org.junit.Assert.assertEquals
import org.junit.Test

class ExpandablePlayerSheetStateTest {

    @Test
    fun reconcilePlayerSheetValue_collapsesWhenPlaybackStartsFromHidden() {
        val result = reconcilePlayerSheetValue(
            currentValue = ExpandablePlayerSheetValue.Hidden,
            hasCurrentSong = true
        )

        assertEquals(ExpandablePlayerSheetValue.Collapsed, result)
    }

    @Test
    fun reconcilePlayerSheetValue_keepsExpandedWhileSongChanges() {
        val result = reconcilePlayerSheetValue(
            currentValue = ExpandablePlayerSheetValue.Expanded,
            hasCurrentSong = true
        )

        assertEquals(ExpandablePlayerSheetValue.Expanded, result)
    }

    @Test
    fun reconcilePlayerSheetValue_hidesWhenPlaybackStops() {
        val result = reconcilePlayerSheetValue(
            currentValue = ExpandablePlayerSheetValue.Expanded,
            hasCurrentSong = false
        )

        assertEquals(ExpandablePlayerSheetValue.Hidden, result)
    }

    @Test
    fun collapseAndExpand_ignoreHiddenState() {
        assertEquals(
            ExpandablePlayerSheetValue.Hidden,
            expandPlayerSheet(ExpandablePlayerSheetValue.Hidden)
        )
        assertEquals(
            ExpandablePlayerSheetValue.Hidden,
            collapsePlayerSheet(ExpandablePlayerSheetValue.Hidden)
        )
    }
}
