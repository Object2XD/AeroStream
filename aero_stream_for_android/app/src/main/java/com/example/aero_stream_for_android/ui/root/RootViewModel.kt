package com.example.aero_stream_for_android.ui.root

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.data.repository.SmbLibraryRepository
import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.library.LibraryFeatureState
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.LibrarySource
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.navigation.Screen
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.Job
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class RootUiState(
    val currentRoute: String? = Screen.Home.route,
    val bottomNavSpec: BottomNavSpec = BottomNavSpec(visible = true, selected = RootPrimaryRoute.Top),
    val libraryFeatureState: LibraryFeatureState = LibraryFeatureState(),
    val activeOverlay: ActiveOverlay = NoOverlay,
    val headerSpec: HeaderSpec = HeaderSpec(
        enabled = true,
        title = "Top",
        actions = listOf(HeaderAction.Search, HeaderAction.Settings)
    ),
    val quickReturnHeaderState: QuickReturnHeaderState = QuickReturnHeaderState(),
    val selectedSmbConfigId: String? = null,
    val isSmbScanRunning: Boolean = false
)

@HiltViewModel
class RootViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository,
    private val smbLibraryRepository: SmbLibraryRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(RootUiState())
    val uiState: StateFlow<RootUiState> = _uiState.asStateFlow()
    private var smbScanProgressJob: Job? = null

    init {
        viewModelScope.launch {
            settingsRepository.selectedSmbConfig.collectLatest { config ->
                smbScanProgressJob?.cancel()
                _uiState.update { state ->
                    state.copy(
                        selectedSmbConfigId = config?.id,
                        isSmbScanRunning = false,
                        headerSpec = buildHeaderSpec(
                            route = state.currentRoute,
                            featureState = state.libraryFeatureState,
                            isSmbScanRunning = false
                        )
                    )
                }

                val configId = config?.id ?: return@collectLatest
                smbScanProgressJob = launch {
                    smbLibraryRepository.observeScanProgress(configId).collect { progress ->
                        _uiState.update { state ->
                            state.copy(
                                isSmbScanRunning = progress.isRunning,
                                headerSpec = buildHeaderSpec(
                                    route = state.currentRoute,
                                    featureState = state.libraryFeatureState,
                                    isSmbScanRunning = progress.isRunning
                                )
                            )
                        }
                    }
                }
            }
        }
    }

    fun onRouteChanged(route: String?) {
        _uiState.update { state ->
            val appRoute = routeToAppRoute(route)
            state.copy(
                currentRoute = route,
                bottomNavSpec = BottomNavSpec(
                    visible = appRoute.isBottomNavVisible(),
                    selected = appRoute.toBottomNavSelectedPrimaryRoute()
                ),
                headerSpec = buildHeaderSpec(route, state.libraryFeatureState, state.isSmbScanRunning),
                quickReturnHeaderState = if (route == Screen.Home.route || route == Screen.Library.route) {
                    state.quickReturnHeaderState.clampOffset()
                } else {
                    QuickReturnHeaderState()
                }
            )
        }
    }

    fun openOverlay(overlay: ActiveOverlay) {
        _uiState.update { state ->
            if (state.activeOverlay == overlay) state else state.copy(activeOverlay = overlay)
        }
    }

    fun closeOverlay() {
        _uiState.update { it.copy(activeOverlay = NoOverlay) }
    }

    fun setLibrarySource(source: LibrarySource) {
        _uiState.update { state ->
            val categories = categoriesForSource(source)
            val nextCategory = state.libraryFeatureState.category.takeIf { it in categories } ?: categories.first()
            val nextSort = state.libraryFeatureState.sort.takeIf {
                it.key in availableSortKeys(source, nextCategory)
            } ?: defaultSortForCategory(nextCategory)
            val nextFeatureState = state.libraryFeatureState.copy(
                source = source,
                category = nextCategory,
                sort = nextSort
            )
            state.copy(
                libraryFeatureState = nextFeatureState,
                activeOverlay = NoOverlay,
                headerSpec = buildHeaderSpec(state.currentRoute, nextFeatureState, state.isSmbScanRunning)
            )
        }
    }

    fun setLibraryCategory(category: LibraryCategory) {
        _uiState.update { state ->
            val nextSort = state.libraryFeatureState.sort.takeIf {
                it.key in availableSortKeys(state.libraryFeatureState.source, category)
            } ?: defaultSortForCategory(category)
            val nextFeatureState = state.libraryFeatureState.copy(category = category, sort = nextSort)
            state.copy(
                libraryFeatureState = nextFeatureState,
                headerSpec = buildHeaderSpec(state.currentRoute, nextFeatureState, state.isSmbScanRunning)
            )
        }
    }

    fun setLibrarySort(sort: LibrarySort) {
        _uiState.update { state ->
            val nextFeatureState = state.libraryFeatureState.copy(sort = sort)
            state.copy(
                libraryFeatureState = nextFeatureState,
                activeOverlay = NoOverlay,
                headerSpec = buildHeaderSpec(state.currentRoute, nextFeatureState, state.isSmbScanRunning)
            )
        }
    }

    fun updateHeaderHeight(heightPx: Int) {
        _uiState.update { state ->
            state.copy(
                quickReturnHeaderState = state.quickReturnHeaderState.updateHeaderHeight(heightPx)
            )
        }
    }

    fun applyHeaderDelta(deltaY: Float): Float {
        var consumedY = 0f
        _uiState.update { state ->
            val result = state.quickReturnHeaderState.applyScrollDeltaWithConsumption(deltaY)
            consumedY = result.consumedY
            state.copy(
                quickReturnHeaderState = result.state
            )
        }
        return consumedY
    }

    fun resetHeaderOffset() {
        _uiState.update { state ->
            state.copy(
                quickReturnHeaderState = state.quickReturnHeaderState.resetOffset()
            )
        }
    }

    fun availableSortKeys(): List<LibrarySortKey> {
        val featureState = _uiState.value.libraryFeatureState
        return availableSortKeys(featureState.source, featureState.category)
    }

    private fun buildHeaderSpec(
        route: String?,
        featureState: LibraryFeatureState,
        isSmbScanRunning: Boolean
    ): HeaderSpec {
        return when (route) {
            Screen.Home.route -> HeaderSpec(
                enabled = true,
                title = "Top",
                actions = listOf(HeaderAction.Search, HeaderAction.Settings)
            )

            Screen.Library.route -> HeaderSpec(
                enabled = true,
                title = "Library",
                actions = buildList {
                    add(HeaderAction.Search)
                    if (featureState.source == LibrarySource.SMB) {
                        add(if (isSmbScanRunning) HeaderAction.CancelSmbScan else HeaderAction.SmbScan)
                    }
                    add(HeaderAction.Settings)
                },
                accessory = LibraryAccessorySpec(
                    categories = categoriesForSource(featureState.source),
                    selectedCategory = featureState.category,
                    sort = featureState.sort,
                    featureState = featureState
                )
            )

            else -> HeaderSpec(enabled = false, title = "")
        }
    }

    private fun categoriesForSource(source: LibrarySource): List<LibraryCategory> = when (source) {
        LibrarySource.LocalFiles -> listOf(
            LibraryCategory.Songs,
            LibraryCategory.Albums,
            LibraryCategory.Artists,
            LibraryCategory.Playlists
        )

        LibrarySource.SMB -> listOf(
            LibraryCategory.Songs,
            LibraryCategory.Albums,
            LibraryCategory.Artists
        )

        LibrarySource.Cache -> listOf(LibraryCategory.Songs)
    }

    private fun availableSortKeys(source: LibrarySource, category: LibraryCategory): List<LibrarySortKey> =
        when (source to category) {
            LibrarySource.LocalFiles to LibraryCategory.Songs,
            LibrarySource.SMB to LibraryCategory.Songs,
            LibrarySource.Cache to LibraryCategory.Songs -> listOf(
                LibrarySortKey.Name,
                LibrarySortKey.Artist,
                LibrarySortKey.Album,
                LibrarySortKey.AddedDate,
                LibrarySortKey.LastPlayed
            )

            LibrarySource.LocalFiles to LibraryCategory.Albums,
            LibrarySource.SMB to LibraryCategory.Albums -> listOf(
                LibrarySortKey.Name,
                LibrarySortKey.Artist,
                LibrarySortKey.Year
            )

            LibrarySource.LocalFiles to LibraryCategory.Artists,
            LibrarySource.SMB to LibraryCategory.Artists -> listOf(
                LibrarySortKey.Name,
                LibrarySortKey.SongCount
            )

            LibrarySource.LocalFiles to LibraryCategory.Playlists -> listOf(
                LibrarySortKey.Name,
                LibrarySortKey.CreatedAt
            )

            else -> listOf(LibrarySortKey.Name)
        }

    private fun defaultSortForCategory(category: LibraryCategory): LibrarySort = when (category) {
        LibraryCategory.Playlists -> LibrarySort(LibrarySortKey.CreatedAt, SortOrder.Desc)
        else -> LibrarySort(LibrarySortKey.Name, SortOrder.Asc)
    }
}
