package com.example.aero_stream_for_android.ui.root

import com.example.aero_stream_for_android.ui.navigation.Screen
import org.junit.Assert.assertEquals
import org.junit.Test

class RootViewModelTest {

    @Test
    fun headerActions_areSearchAndSettings_onTopAndLibraryRoutes() {
        val viewModel = RootViewModel()

        viewModel.onRouteChanged(Screen.Home.route)
        assertEquals(
            listOf(HeaderAction.Search, HeaderAction.Settings),
            viewModel.uiState.value.headerSpec.actions
        )

        viewModel.onRouteChanged(Screen.Library.route)
        assertEquals(
            listOf(HeaderAction.Search, HeaderAction.Settings),
            viewModel.uiState.value.headerSpec.actions
        )
    }

    @Test
    fun openOverlay_reselectSameOverlay_keepsSourcePickerActive() {
        val viewModel = RootViewModel()

        viewModel.openOverlay(LibrarySourcePickerOverlay)
        assertEquals(LibrarySourcePickerOverlay, viewModel.uiState.value.activeOverlay)

        viewModel.openOverlay(LibrarySourcePickerOverlay)
        assertEquals(LibrarySourcePickerOverlay, viewModel.uiState.value.activeOverlay)
    }
}
