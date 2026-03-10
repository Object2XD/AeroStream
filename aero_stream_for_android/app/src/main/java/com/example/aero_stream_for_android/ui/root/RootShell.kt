package com.example.aero_stream_for_android.ui.root

import androidx.activity.compose.BackHandler
import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBars
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalDensity
import androidx.compose.ui.unit.IntOffset
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.navigation.NavBackStackEntry
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.ui.components.ExpandablePlayerSheet
import com.example.aero_stream_for_android.ui.components.ExpandablePlayerSheetValue
import com.example.aero_stream_for_android.ui.components.collapsePlayerSheet
import com.example.aero_stream_for_android.ui.components.reconcilePlayerSheetValue
import com.example.aero_stream_for_android.ui.navigation.AeroNavGraph
import com.example.aero_stream_for_android.ui.navigation.Screen
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens
import kotlin.math.roundToInt

@Composable
fun RootShell(
    rootViewModel: RootViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val navController = rememberNavController()
    val rootState by rootViewModel.uiState.collectAsStateWithLifecycle()
    val playerState by playerViewModel.playerState.collectAsStateWithLifecycle()
    val navBackStackEntry by navController.currentBackStackEntryAsState()
    val currentRoute = navBackStackEntry?.toActualRoute()
    val appRoute = routeToAppRoute(currentRoute)
    val isPlayerSheetVisibleRoute = appRoute.isPlayerSheetVisibleRoute()
    var playerSheetValue by rememberSaveable { mutableStateOf(ExpandablePlayerSheetValue.Hidden) }
    var stashedPlayerSheetValue by rememberSaveable { mutableStateOf<ExpandablePlayerSheetValue?>(null) }
    var smbScanSheetRequestToken by rememberSaveable { mutableIntStateOf(0) }
    var smbScanCancelRequestToken by rememberSaveable { mutableIntStateOf(0) }
    val density = LocalDensity.current
    val bottomNavItems = remember {
        listOf(Screen.Home, Screen.Library)
    }

    val nestedScrollConnection = rememberQuickReturnNestedScrollConnection(
        enabled = rootState.headerSpec.enabled && rootState.activeOverlay == NoOverlay
    ) { deltaY ->
        rootViewModel.applyHeaderDelta(deltaY)
    }

    LaunchedEffect(currentRoute) {
        rootViewModel.onRouteChanged(currentRoute)
    }

    LaunchedEffect(playerState.currentSong?.id, isPlayerSheetVisibleRoute) {
        val resolution = resolvePlayerSheetForRouteVisibility(
            currentValue = playerSheetValue,
            stashedValue = stashedPlayerSheetValue,
            hasCurrentSong = playerState.currentSong != null,
            isPlayerSheetVisibleRoute = isPlayerSheetVisibleRoute
        )
        playerSheetValue = resolution.sheetValue
        stashedPlayerSheetValue = resolution.stashedValue
    }

    fun navigateToTopLevel(route: String) {
        navController.navigate(route) {
            popUpTo(navController.graph.findStartDestination().id) {
                saveState = true
            }
            launchSingleTop = true
            restoreState = true
        }
    }

    fun handleHeaderAction(action: HeaderAction) {
        when (action) {
            HeaderAction.Search -> navController.navigate(Screen.Search.route)
            HeaderAction.SmbScan -> smbScanSheetRequestToken += 1
            HeaderAction.CancelSmbScan -> smbScanCancelRequestToken += 1
            HeaderAction.Settings -> navController.navigate(Screen.Settings.route)
        }
    }

    BackHandler(
        enabled = isPlayerSheetVisibleRoute &&
            playerSheetValue == ExpandablePlayerSheetValue.Expanded
    ) {
        playerSheetValue = collapsePlayerSheet(playerSheetValue)
    }

    InsetsHost {
        val playerBottomClearance = if (playerState.currentSong != null) {
            AeroCompactUiTokens.playerSheetPeekHeight + AeroCompactUiTokens.playerSheetContentBottomSpacing
        } else {
            0.dp
        }
        val bottomNavHeight = if (rootState.bottomNavSpec.visible) {
            AeroCompactUiTokens.bottomNavHeight
        } else {
            0.dp
        }
        val edgeBackdropSpec = resolveEdgeBackdropSpec(
            appRoute = appRoute,
            colorScheme = MaterialTheme.colorScheme
        )

        CompositionLocalProvider(LocalPlayerSheetBottomClearance provides playerBottomClearance) {
            Box(modifier = Modifier.fillMaxSize()) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(edgeBackdropSpec.baseTone)
                )
                EdgeBackdropLayer(
                    spec = edgeBackdropSpec,
                    modifier = Modifier.fillMaxSize()
                )

                RootScaffold(
                    modifier = Modifier.quickReturnNestedScroll(
                        enabled = rootState.headerSpec.enabled && rootState.activeOverlay == NoOverlay,
                        connection = nestedScrollConnection
                    ),
                    bottomBar = {
                        if (rootState.bottomNavSpec.visible) {
                            NavigationBar(
                                modifier = Modifier.height(AeroCompactUiTokens.bottomNavHeight),
                                containerColor = edgeBackdropSpec.bottomTone,
                                windowInsets = WindowInsets(0, 0, 0, 0)
                            ) {
                                bottomNavItems.forEach { screen ->
                                    val isSelected = when (screen.route) {
                                        Screen.Home.route -> rootState.bottomNavSpec.selected == RootPrimaryRoute.Top
                                        Screen.Library.route -> rootState.bottomNavSpec.selected == RootPrimaryRoute.Library
                                        else -> false
                                    }
                                    NavigationBarItem(
                                        selected = isSelected,
                                        onClick = {
                                            if (screen.route == Screen.Library.route &&
                                                rootState.bottomNavSpec.selected == RootPrimaryRoute.Library
                                            ) {
                                                rootViewModel.openOverlay(LibrarySourcePickerOverlay)
                                            } else {
                                                navigateToTopLevel(screen.route)
                                                rootViewModel.closeOverlay()
                                                rootViewModel.resetHeaderOffset()
                                            }
                                        },
                                        icon = {
                                            val icon =
                                                if (isSelected) screen.selectedIcon else screen.unselectedIcon
                                            if (icon != null) {
                                                Icon(icon, contentDescription = screen.title)
                                            }
                                        },
                                        label = {
                                            Text(
                                                text = screen.title,
                                                style = AeroCompactUiTokens.bottomNavLabelTextStyle()
                                            )
                                        }
                                    )
                                }
                            }
                        }
                    }
                ) { innerPadding ->
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(innerPadding)
                    ) {
                        val visibleHeaderHeightDp = with(density) {
                            rootState.quickReturnHeaderState.visibleHeaderHeightPx.toDp()
                        }

                        Box(
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(top = visibleHeaderHeightDp)
                        ) {
                            AeroNavGraph(
                                navController = navController,
                                modifier = Modifier.fillMaxSize(),
                                libraryFeatureState = rootState.libraryFeatureState,
                                onNavigateToSettings = { navController.navigate(Screen.Settings.route) },
                                onNavigateBackFromSearch = { navController.popBackStack() },
                                smbScanSheetRequestToken = smbScanSheetRequestToken,
                                smbScanCancelRequestToken = smbScanCancelRequestToken
                            )
                        }

                        if (rootState.headerSpec.enabled) {
                            QuickReturnHeaderContainer(
                                spec = rootState.headerSpec,
                                onHeaderHeightChanged = rootViewModel::updateHeaderHeight,
                                onActionClick = ::handleHeaderAction,
                                onCategorySelected = rootViewModel::setLibraryCategory,
                                onOpenSortPicker = { rootViewModel.openOverlay(LibrarySortPickerOverlay) },
                                modifier = Modifier.offset {
                                    IntOffset(
                                        0,
                                        rootState.quickReturnHeaderState.headerOffsetPx.roundToInt()
                                    )
                                }
                            )
                        }
                    }
                }

                AnimatedVisibility(
                    visible = playerState.currentSong != null && isPlayerSheetVisibleRoute,
                    enter = slideInVertically(initialOffsetY = { it }),
                    exit = slideOutVertically(targetOffsetY = { it })
                ) {
                    ExpandablePlayerSheet(
                        playerState = playerState,
                        sheetValue = playerSheetValue,
                        onSheetValueChange = { playerSheetValue = it },
                        onPlayPause = playerViewModel::togglePlayPause,
                        onSkipNext = playerViewModel::skipToNext,
                        onSkipPrevious = playerViewModel::skipToPrevious,
                        onSeek = playerViewModel::seekTo,
                        onRepeatModeChange = playerViewModel::toggleRepeatMode,
                        onShuffleToggle = playerViewModel::toggleShuffle,
                        bottomBarHeight = bottomNavHeight
                    )
                }

                OverlayHost(
                    activeOverlay = rootState.activeOverlay,
                    selectedSource = rootState.libraryFeatureState.source,
                    selectedSort = rootState.libraryFeatureState.sort,
                    availableSortKeys = rootViewModel.availableSortKeys(),
                    onDismiss = rootViewModel::closeOverlay,
                    onSelectSource = rootViewModel::setLibrarySource,
                    onConfirmSort = rootViewModel::setLibrarySort
                )
            }
        }
    }
}

internal data class PlayerSheetRouteResolution(
    val sheetValue: ExpandablePlayerSheetValue,
    val stashedValue: ExpandablePlayerSheetValue?
)

internal fun resolvePlayerSheetForRouteVisibility(
    currentValue: ExpandablePlayerSheetValue,
    stashedValue: ExpandablePlayerSheetValue?,
    hasCurrentSong: Boolean,
    isPlayerSheetVisibleRoute: Boolean
): PlayerSheetRouteResolution {
    if (!isPlayerSheetVisibleRoute) {
        val nextStash = if (hasCurrentSong) {
            stashedValue ?: currentValue.takeIf { it != ExpandablePlayerSheetValue.Hidden }
        } else {
            null
        }
        return PlayerSheetRouteResolution(
            sheetValue = ExpandablePlayerSheetValue.Hidden,
            stashedValue = nextStash
        )
    }

    if (!hasCurrentSong) {
        return PlayerSheetRouteResolution(
            sheetValue = ExpandablePlayerSheetValue.Hidden,
            stashedValue = null
        )
    }

    val baseValue = stashedValue ?: currentValue
    return PlayerSheetRouteResolution(
        sheetValue = reconcilePlayerSheetValue(
            currentValue = baseValue,
            hasCurrentSong = true
        ),
        stashedValue = null
    )
}

/**
 * Reconstructs the actual navigated route string with argument values from the back stack entry.
 * For detail screens, reads decoded argument values from [NavBackStackEntry.arguments] and
 * re-encodes them using [Screen.AlbumDetail.createRoute] / [Screen.ArtistDetail.createRoute],
 * so that [routeToAppRoute] can parse and restore the full [AppRoute] with its arguments.
 * For all other screens, returns the destination route pattern as-is.
 */
private fun NavBackStackEntry.toActualRoute(): String? {
    val pattern = destination.route ?: return null
    val args = arguments ?: return pattern
    return when {
        pattern.startsWith(Screen.AlbumDetail.route) -> {
            val albumName = args.getString(Screen.AlbumDetail.albumNameArg) ?: return null
            val albumArtist = args.getString(Screen.AlbumDetail.albumArtistArg) ?: return null
            val source = args.getString(Screen.AlbumDetail.sourceArg).toMusicSourceOrNull()
            val smbConfigId = args.getString(Screen.AlbumDetail.smbConfigIdArg).emptyToNull()
            val year = args.getString(Screen.AlbumDetail.yearArg)?.toIntOrNull()
            Screen.AlbumDetail.createRoute(albumName, albumArtist, source, smbConfigId, year)
        }
        pattern.startsWith(Screen.ArtistDetail.route) -> {
            val artistName = args.getString(Screen.ArtistDetail.artistNameArg) ?: return null
            val source = args.getString(Screen.ArtistDetail.sourceArg).toMusicSourceOrNull()
            val smbConfigId = args.getString(Screen.ArtistDetail.smbConfigIdArg).emptyToNull()
            Screen.ArtistDetail.createRoute(artistName, source, smbConfigId)
        }
        else -> pattern
    }
}

private fun String?.toMusicSourceOrNull(): MusicSource? =
    this?.let { src -> MusicSource.entries.firstOrNull { it.name == src } }

private fun String?.emptyToNull(): String? = this?.takeIf { it.isNotEmpty() }

private data class EdgeBackdropSpec(
    val baseTone: Color,
    val topTone: Color,
    val bottomTone: Color,
    val enabled: Boolean = true
)

private fun resolveEdgeBackdropSpec(
    appRoute: AppRoute?,
    colorScheme: ColorScheme
): EdgeBackdropSpec {
    val isSettings = appRoute == SettingsRoute
    val bottomTone = if (isSettings) colorScheme.background else colorScheme.surface
    return EdgeBackdropSpec(
        baseTone = colorScheme.background,
        topTone = colorScheme.background,
        bottomTone = bottomTone
    )
}

@Composable
private fun EdgeBackdropLayer(
    spec: EdgeBackdropSpec,
    modifier: Modifier = Modifier
) {
    if (!spec.enabled) return

    val density = LocalDensity.current
    val statusBarInset = with(density) { WindowInsets.statusBars.getTop(density).toDp() }
    val navigationBarInset = with(density) { WindowInsets.navigationBars.getBottom(density).toDp() }

    Box(modifier = modifier) {
        if (statusBarInset > 0.dp) {
            Box(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .offset(y = -statusBarInset)
                    .fillMaxWidth()
                    .height(statusBarInset)
                    .background(spec.topTone)
            )
        }

        if (navigationBarInset > 0.dp) {
            Box(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .offset(y = navigationBarInset)
                    .fillMaxWidth()
                    .height(navigationBarInset)
                    .background(spec.bottomTone)
            )
        }
    }
}
