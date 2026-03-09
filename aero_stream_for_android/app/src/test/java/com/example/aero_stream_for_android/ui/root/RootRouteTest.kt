package com.example.aero_stream_for_android.ui.root

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class RootRouteTest {

    @Test
    fun isPlayerSheetVisibleRoute_settingsRoute_isFalse() {
        assertFalse(SettingsRoute.isPlayerSheetVisibleRoute())
    }

    @Test
    fun isPlayerSheetVisibleRoute_nonSettingsRoutes_areTrue() {
        assertTrue(TopRoute.isPlayerSheetVisibleRoute())
        assertTrue(LibraryRoute.isPlayerSheetVisibleRoute())
        assertTrue(SearchRoute.isPlayerSheetVisibleRoute())
        assertTrue(SmbBrowserRoute.isPlayerSheetVisibleRoute())
        assertTrue((null as AppRoute?).isPlayerSheetVisibleRoute())
    }
}
