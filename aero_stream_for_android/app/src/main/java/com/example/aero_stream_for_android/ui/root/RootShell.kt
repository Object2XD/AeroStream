package com.example.aero_stream_for_android.ui.root

import androidx.compose.animation.AnimatedVisibility
import androidx.compose.animation.slideInVertically
import androidx.compose.animation.slideOutVertically
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBars
import androidx.compose.foundation.layout.offset
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.statusBars
import androidx.compose.material3.Icon
import androidx.compose.material3.ColorScheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
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
import androidx.navigation.NavGraph.Companion.findStartDestination
import androidx.navigation.compose.currentBackStackEntryAsState
import androidx.navigation.compose.rememberNavController
import com.example.aero_stream_for_android.ui.components.FullScreenPlayer
import com.example.aero_stream_for_android.ui.components.MiniPlayer
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
    val currentRoute = navBackStackEntry?.destination?.route
    var showFullPlayer by rememberSaveable { androidx.compose.runtime.mutableStateOf(false) }
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
            HeaderAction.Settings -> navController.navigate(Screen.Settings.route)
        }
    }

    if (showFullPlayer && playerState.currentSong != null) {
        FullScreenPlayer(
            playerState = playerState,
            onPlayPause = playerViewModel::togglePlayPause,
            onSkipNext = playerViewModel::skipToNext,
            onSkipPrevious = playerViewModel::skipToPrevious,
            onSeek = playerViewModel::seekTo,
            onRepeatModeChange = playerViewModel::toggleRepeatMode,
            onShuffleToggle = playerViewModel::toggleShuffle,
            onDownload = playerViewModel::downloadCurrentSong,
            onCollapse = { showFullPlayer = false }
        )
        return
    }

    InsetsHost {
        val appRoute = routeToAppRoute(currentRoute)
        val edgeBackdropSpec = resolveEdgeBackdropSpec(
            appRoute = appRoute,
            colorScheme = MaterialTheme.colorScheme
        )

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
                Column {
                    AnimatedVisibility(
                        visible = playerState.currentSong != null,
                        enter = slideInVertically(initialOffsetY = { it }),
                        exit = slideOutVertically(targetOffsetY = { it })
                    ) {
                        MiniPlayer(
                            playerState = playerState,
                            onPlayPause = playerViewModel::togglePlayPause,
                            onSkipNext = playerViewModel::skipToNext,
                            onClick = { showFullPlayer = true }
                        )
                    }
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
                                        val icon = if (isSelected) screen.selectedIcon else screen.unselectedIcon
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
                        onNavigateToPlayer = { showFullPlayer = true },
                        onNavigateToSettings = { navController.navigate(Screen.Settings.route) },
                        onNavigateBackFromSearch = { navController.popBackStack() },
                        onNavigateToSmbBrowser = { navController.navigate(Screen.SmbBrowser.route) }
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
                            IntOffset(0, rootState.quickReturnHeaderState.headerOffsetPx.roundToInt())
                        }
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
}

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
