package com.example.aero_stream_for_android.ui.navigation

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
    onNavigateToSmbBrowser: () -> Unit = {}
) {
    NavHost(
        navController = navController,
        startDestination = Screen.Home.route,
        modifier = modifier
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
                onNavigateToSmbBrowser = onNavigateToSmbBrowser,
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
                onNavigateToPlayer = onNavigateToPlayer
            )
        }

        composable(Screen.SmbBrowser.route) {
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
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}
