package com.example.aero_stream_for_android.ui.navigation

import androidx.compose.animation.EnterTransition
import androidx.compose.animation.ExitTransition
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.navigation.NavType
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.navArgument
import com.example.aero_stream_for_android.ui.home.HomeScreen
import com.example.aero_stream_for_android.ui.library.AlbumDetailScreen
import com.example.aero_stream_for_android.ui.library.LibraryFeatureState
import com.example.aero_stream_for_android.ui.library.LibraryRouteScreen
import com.example.aero_stream_for_android.ui.search.SearchScreen
import com.example.aero_stream_for_android.ui.settings.SettingsScreen
import com.example.aero_stream_for_android.ui.smb.SmbBrowserScreen

@Composable
fun AeroNavGraph(
    navController: NavHostController,
    modifier: Modifier = Modifier,
    libraryFeatureState: LibraryFeatureState,
    onNavigateToPlayer: () -> Unit = {},
    onNavigateToSettings: () -> Unit = {},
    onNavigateBackFromSearch: () -> Unit = {},
    smbScanSheetRequestToken: Int = 0,
    smbScanCancelRequestToken: Int = 0
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Home.route,
        modifier = modifier,
        enterTransition = { EnterTransition.None },
        exitTransition = { ExitTransition.None },
        popEnterTransition = { EnterTransition.None },
        popExitTransition = { ExitTransition.None }
    ) {
        composable(Screen.Home.route) {
            HomeScreen(
                onNavigateToPlayer = onNavigateToPlayer,
                onNavigateToSettings = onNavigateToSettings
            )
        }

        composable(Screen.Library.route) {
            LibraryRouteScreen(
                featureState = libraryFeatureState,
                onNavigateToPlayer = onNavigateToPlayer,
                smbScanSheetRequestToken = smbScanSheetRequestToken,
                smbScanCancelRequestToken = smbScanCancelRequestToken,
                onNavigateToAlbumDetail = { album, source, smbConfigId ->
                    navController.navigate(
                        Screen.AlbumDetail.createRoute(
                            albumName = album.name,
                            albumArtist = album.albumArtist,
                            source = source,
                            smbConfigId = smbConfigId,
                            year = album.year
                        )
                    )
                }
            )
        }

        composable(Screen.Search.route) {
            SearchScreen(
                onNavigateBack = onNavigateBackFromSearch,
                onNavigateToPlayer = onNavigateToPlayer
            )
        }

        composable(
            route = Screen.SmbBrowser.routePattern,
            arguments = listOf(
                navArgument(Screen.SmbBrowser.configIdArg) {
                    type = NavType.StringType
                    defaultValue = ""
                }
            )
        ) {
            SmbBrowserScreen(
                onNavigateToPlayer = onNavigateToPlayer
            )
        }

        composable(
            route = Screen.AlbumDetail.routePattern,
            arguments = listOf(
                navArgument(Screen.AlbumDetail.albumNameArg) { type = NavType.StringType },
                navArgument(Screen.AlbumDetail.albumArtistArg) { type = NavType.StringType },
                navArgument(Screen.AlbumDetail.sourceArg) { type = NavType.StringType },
                navArgument(Screen.AlbumDetail.smbConfigIdArg) {
                    type = NavType.StringType
                    defaultValue = ""
                },
                navArgument(Screen.AlbumDetail.yearArg) {
                    type = NavType.StringType
                    defaultValue = ""
                }
            )
        ) {
            AlbumDetailScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToPlayer = onNavigateToPlayer
            )
        }

        composable(Screen.Settings.route) {
            SettingsScreen(
                onNavigateBack = { navController.popBackStack() },
                onNavigateToSmbBrowser = { configId ->
                    navController.navigate(Screen.SmbBrowser.createRoute(configId))
                }
            )
        }
    }
}
