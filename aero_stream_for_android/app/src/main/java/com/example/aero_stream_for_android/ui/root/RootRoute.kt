package com.example.aero_stream_for_android.ui.root

import com.example.aero_stream_for_android.ui.navigation.Screen

enum class RootPrimaryRoute {
    Top,
    Library
}

sealed interface AppRoute

data object TopRoute : AppRoute

data object LibraryRoute : AppRoute

data object SettingsRoute : AppRoute

data class AlbumDetailRoute(
    val albumName: String,
    val albumArtist: String,
    val source: String,
    val smbConfigId: String,
    val year: String
) : AppRoute

data object SmbBrowserRoute : AppRoute

fun routeToAppRoute(route: String?): AppRoute? = when {
    route == null -> null
    route == Screen.Home.route -> TopRoute
    route == Screen.Library.route -> LibraryRoute
    route == Screen.Settings.route -> SettingsRoute
    route == Screen.SmbBrowser.route -> SmbBrowserRoute
    route.startsWith(Screen.AlbumDetail.route) -> AlbumDetailRoute("", "", "", "", "")
    else -> null
}
