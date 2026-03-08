package com.example.aero_stream_for_android.ui.root

import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.data.repository.SmbLibraryRepository
import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.LibrarySource
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.navigation.Screen
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.setMain
import org.junit.After
import kotlinx.coroutines.flow.emptyFlow
import kotlinx.coroutines.flow.flowOf
import org.junit.Before
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class RootViewModelTest {

    private val dispatcher = StandardTestDispatcher()

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    private fun createViewModel(): RootViewModel {
        val settingsRepository = mockk<SettingsRepository>()
        val smbLibraryRepository = mockk<SmbLibraryRepository>()
        every { settingsRepository.selectedSmbConfig } returns flowOf(null)
        every { smbLibraryRepository.observeScanProgress(any()) } returns emptyFlow()
        return RootViewModel(settingsRepository, smbLibraryRepository)
    }

    @Test
    fun onRouteChanged_home_updatesHeaderAndBottomNavForTop() {
        val viewModel = createViewModel()

        viewModel.onRouteChanged(Screen.Home.route)

        val state = viewModel.uiState.value
        assertEquals(Screen.Home.route, state.currentRoute)
        assertTrue(state.bottomNavSpec.visible)
        assertEquals(RootPrimaryRoute.Top, state.bottomNavSpec.selected)
        assertTrue(state.headerSpec.enabled)
        assertEquals("Top", state.headerSpec.title)
        assertEquals(
            listOf(HeaderAction.Search, HeaderAction.Settings),
            state.headerSpec.actions
        )
        assertTrue(state.headerSpec.accessory is NoAccessory)
    }

    @Test
    fun onRouteChanged_library_updatesHeaderAndAccessoryForLibrary() {
        val viewModel = createViewModel()

        viewModel.onRouteChanged(Screen.Library.route)

        val state = viewModel.uiState.value
        assertEquals(Screen.Library.route, state.currentRoute)
        assertTrue(state.bottomNavSpec.visible)
        assertEquals(RootPrimaryRoute.Library, state.bottomNavSpec.selected)
        assertTrue(state.headerSpec.enabled)
        assertEquals("Library", state.headerSpec.title)
        assertEquals(
            listOf(HeaderAction.Search, HeaderAction.Settings),
            state.headerSpec.actions
        )

        val accessory = state.headerSpec.accessory as LibraryAccessorySpec
        assertEquals(
            listOf(
                LibraryCategory.Songs,
                LibraryCategory.Albums,
                LibraryCategory.Artists,
                LibraryCategory.Playlists
            ),
            accessory.categories
        )
        assertEquals(LibraryCategory.Songs, accessory.selectedCategory)
        assertEquals(LibrarySort(), accessory.sort)
        assertEquals(state.libraryFeatureState, accessory.featureState)
    }

    @Test
    fun onRouteChanged_settings_disablesHeaderAndHidesBottomNav() {
        val viewModel = createViewModel()

        viewModel.onRouteChanged(Screen.Settings.route)

        val state = viewModel.uiState.value
        assertEquals(Screen.Settings.route, state.currentRoute)
        assertFalse(state.bottomNavSpec.visible)
        assertEquals(null, state.bottomNavSpec.selected)
        assertFalse(state.headerSpec.enabled)
        assertEquals("", state.headerSpec.title)
        assertTrue(state.headerSpec.actions.isEmpty())
    }

    @Test
    fun onRouteChanged_albumDetail_keepsLibraryBottomNavSelectionAndDisablesHeader() {
        val viewModel = createViewModel()

        viewModel.onRouteChanged("album_detail?albumName=Album&albumArtist=Artist&source=SMB&smbConfigId=cfg&year=2024")

        val state = viewModel.uiState.value
        assertTrue(state.bottomNavSpec.visible)
        assertEquals(RootPrimaryRoute.Library, state.bottomNavSpec.selected)
        assertFalse(state.headerSpec.enabled)
        assertEquals("", state.headerSpec.title)
    }

    @Test
    fun onRouteChanged_smbBrowser_keepsLibraryBottomNavSelectionAndDisablesHeader() {
        val viewModel = createViewModel()

        viewModel.onRouteChanged("smb_browser?configId=cfg")

        val state = viewModel.uiState.value
        assertTrue(state.bottomNavSpec.visible)
        assertEquals(RootPrimaryRoute.Library, state.bottomNavSpec.selected)
        assertFalse(state.headerSpec.enabled)
        assertEquals("", state.headerSpec.title)
    }

    @Test
    fun setLibrarySource_cache_correctsCategoryAndSortAndClosesOverlay() {
        val viewModel = createViewModel()
        viewModel.onRouteChanged(Screen.Library.route)
        viewModel.setLibraryCategory(LibraryCategory.Playlists)
        viewModel.openOverlay(LibrarySourcePickerOverlay)

        viewModel.setLibrarySource(LibrarySource.Cache)

        val state = viewModel.uiState.value
        assertEquals(LibrarySource.Cache, state.libraryFeatureState.source)
        assertEquals(LibraryCategory.Songs, state.libraryFeatureState.category)
        assertEquals(LibrarySort(LibrarySortKey.Name, SortOrder.Asc), state.libraryFeatureState.sort)
        assertEquals(NoOverlay, state.activeOverlay)

        val accessory = state.headerSpec.accessory as LibraryAccessorySpec
        assertEquals(listOf(LibraryCategory.Songs), accessory.categories)
        assertEquals(LibraryCategory.Songs, accessory.selectedCategory)
        assertEquals(LibrarySort(LibrarySortKey.Name, SortOrder.Asc), accessory.sort)
    }

    @Test
    fun setLibrarySource_smb_correctsPlaylistsCategoryToSongs() {
        val viewModel = createViewModel()
        viewModel.onRouteChanged(Screen.Library.route)
        viewModel.setLibraryCategory(LibraryCategory.Playlists)

        viewModel.setLibrarySource(LibrarySource.SMB)

        val state = viewModel.uiState.value
        assertEquals(LibrarySource.SMB, state.libraryFeatureState.source)
        assertEquals(LibraryCategory.Songs, state.libraryFeatureState.category)
        assertEquals(LibrarySort(LibrarySortKey.Name, SortOrder.Asc), state.libraryFeatureState.sort)
    }

    @Test
    fun setLibraryCategory_playlists_resetsSortToCreatedAtDesc() {
        val viewModel = createViewModel()
        viewModel.onRouteChanged(Screen.Library.route)
        viewModel.setLibrarySort(LibrarySort(LibrarySortKey.Artist, SortOrder.Asc))

        viewModel.setLibraryCategory(LibraryCategory.Playlists)

        val state = viewModel.uiState.value
        assertEquals(LibraryCategory.Playlists, state.libraryFeatureState.category)
        assertEquals(
            LibrarySort(LibrarySortKey.CreatedAt, SortOrder.Desc),
            state.libraryFeatureState.sort
        )
    }

    @Test
    fun setLibraryCategory_albums_resetsInvalidSortToNameAsc() {
        val viewModel = createViewModel()
        viewModel.onRouteChanged(Screen.Library.route)
        viewModel.setLibrarySort(LibrarySort(LibrarySortKey.AddedDate, SortOrder.Desc))

        viewModel.setLibraryCategory(LibraryCategory.Albums)

        val state = viewModel.uiState.value
        assertEquals(LibraryCategory.Albums, state.libraryFeatureState.category)
        assertEquals(LibrarySort(LibrarySortKey.Name, SortOrder.Asc), state.libraryFeatureState.sort)
    }

    @Test
    fun setLibrarySort_updatesSortAndClosesOverlay() {
        val viewModel = createViewModel()
        viewModel.onRouteChanged(Screen.Library.route)
        viewModel.openOverlay(LibrarySortPickerOverlay)

        viewModel.setLibrarySort(LibrarySort(LibrarySortKey.Artist, SortOrder.Desc))

        val state = viewModel.uiState.value
        assertEquals(
            LibrarySort(LibrarySortKey.Artist, SortOrder.Desc),
            state.libraryFeatureState.sort
        )
        assertEquals(NoOverlay, state.activeOverlay)

        val accessory = state.headerSpec.accessory as LibraryAccessorySpec
        assertEquals(LibrarySort(LibrarySortKey.Artist, SortOrder.Desc), accessory.sort)
    }

    @Test
    fun openOverlay_sameOverlayTwice_keepsExistingOverlay() {
        val viewModel = createViewModel()

        viewModel.openOverlay(LibrarySourcePickerOverlay)
        viewModel.openOverlay(LibrarySourcePickerOverlay)

        assertEquals(LibrarySourcePickerOverlay, viewModel.uiState.value.activeOverlay)
    }

    @Test
    fun closeOverlay_resetsToNoOverlay() {
        val viewModel = createViewModel()
        viewModel.openOverlay(LibrarySortPickerOverlay)

        viewModel.closeOverlay()

        assertEquals(NoOverlay, viewModel.uiState.value.activeOverlay)
    }

    @Test
    fun availableSortKeys_returnsSourceAndCategorySpecificValues() {
        val viewModel = createViewModel()

        assertEquals(
            listOf(
                LibrarySortKey.Name,
                LibrarySortKey.Artist,
                LibrarySortKey.Album,
                LibrarySortKey.AddedDate,
                LibrarySortKey.LastPlayed
            ),
            viewModel.availableSortKeys()
        )

        viewModel.setLibrarySource(LibrarySource.SMB)
        viewModel.setLibraryCategory(LibraryCategory.Artists)

        assertEquals(
            listOf(LibrarySortKey.Name, LibrarySortKey.SongCount),
            viewModel.availableSortKeys()
        )

        viewModel.setLibrarySource(LibrarySource.Cache)

        assertEquals(
            listOf(
                LibrarySortKey.Name,
                LibrarySortKey.Artist,
                LibrarySortKey.Album,
                LibrarySortKey.AddedDate,
                LibrarySortKey.LastPlayed
            ),
            viewModel.availableSortKeys()
        )
    }

    @Test
    fun headerStateMutators_updateQuickReturnHeaderState() {
        val viewModel = createViewModel()

        viewModel.updateHeaderHeight(100)
        viewModel.applyHeaderDelta(-30f)
        assertEquals(100, viewModel.uiState.value.quickReturnHeaderState.totalHeaderHeightPx)
        assertEquals(-30f, viewModel.uiState.value.quickReturnHeaderState.headerOffsetPx)

        viewModel.resetHeaderOffset()

        assertEquals(0f, viewModel.uiState.value.quickReturnHeaderState.headerOffsetPx)
    }

    @Test
    fun onRouteChanged_nonHomeOrLibrary_resetsQuickReturnHeaderState() {
        val viewModel = createViewModel()
        viewModel.updateHeaderHeight(120)
        viewModel.applyHeaderDelta(-40f)

        viewModel.onRouteChanged(Screen.Settings.route)

        assertEquals(0, viewModel.uiState.value.quickReturnHeaderState.totalHeaderHeightPx)
        assertEquals(0f, viewModel.uiState.value.quickReturnHeaderState.headerOffsetPx)
    }

    @Test
    fun onRouteChanged_betweenHomeAndLibrary_clampsAndKeepsQuickReturnHeaderState() {
        val viewModel = createViewModel()
        viewModel.updateHeaderHeight(100)
        viewModel.applyHeaderDelta(-150f)

        viewModel.onRouteChanged(Screen.Library.route)

        assertEquals(100, viewModel.uiState.value.quickReturnHeaderState.totalHeaderHeightPx)
        assertEquals(-100f, viewModel.uiState.value.quickReturnHeaderState.headerOffsetPx)

        viewModel.onRouteChanged(Screen.Home.route)

        assertEquals(100, viewModel.uiState.value.quickReturnHeaderState.totalHeaderHeightPx)
        assertEquals(-100f, viewModel.uiState.value.quickReturnHeaderState.headerOffsetPx)
    }
}
