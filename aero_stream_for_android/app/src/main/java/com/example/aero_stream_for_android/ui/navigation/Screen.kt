package com.example.aero_stream_for_android.ui.navigation

import android.net.Uri
import androidx.compose.material.icons.Icons
import java.net.URLDecoder
import androidx.compose.material.icons.filled.*
import androidx.compose.material.icons.outlined.*
import androidx.compose.ui.graphics.vector.ImageVector
import com.example.aero_stream_for_android.domain.model.MusicSource

/**
 * 画面を表すsealed class。
 */
sealed class Screen(
    val route: String,
    val title: String,
    val selectedIcon: ImageVector? = null,
    val unselectedIcon: ImageVector? = null
) {
    data object Home : Screen(
        route = "home",
        title = "Top",
        selectedIcon = Icons.Filled.Home,
        unselectedIcon = Icons.Outlined.Home
    )

    data object Library : Screen(
        route = "library",
        title = "Library",
        selectedIcon = Icons.Filled.LibraryMusic,
        unselectedIcon = Icons.Outlined.LibraryMusic
    )

    data object Search : Screen(
        route = "search",
        title = "検索",
        selectedIcon = Icons.Filled.Search,
        unselectedIcon = Icons.Outlined.Search
    )

    data object Downloads : Screen(
        route = "downloads",
        title = "ダウンロード",
        selectedIcon = Icons.Filled.Download,
        unselectedIcon = Icons.Outlined.Download
    )

    data object SmbBrowser : Screen(
        route = "smb_browser",
        title = "SMB",
        selectedIcon = Icons.Filled.Cloud,
        unselectedIcon = Icons.Outlined.Cloud
    ) {
        const val configIdArg = "configId"
        val routePattern = "$route?$configIdArg={$configIdArg}"

        fun createRoute(configId: String?): String {
            val encodedConfigId = Uri.encode(configId.orEmpty())
            return "$route?$configIdArg=$encodedConfigId"
        }
    }

    data object SmbLibrary : Screen(
        route = "smb_library",
        title = "SMBライブラリ",
        selectedIcon = Icons.Filled.Cloud,
        unselectedIcon = Icons.Outlined.Cloud
    )

    data object Settings : Screen(
        route = "settings",
        title = "設定"
    )

    data object AlbumDetail : Screen(
        route = "album_detail",
        title = "アルバム詳細"
    ) {
        const val albumNameArg = "albumName"
        const val albumArtistArg = "albumArtist"
        const val sourceArg = "source"
        const val smbConfigIdArg = "smbConfigId"
        const val yearArg = "year"

        val routePattern =
            "$route?$albumNameArg={$albumNameArg}&$albumArtistArg={$albumArtistArg}&$sourceArg={$sourceArg}&$smbConfigIdArg={$smbConfigIdArg}&$yearArg={$yearArg}"

        data class Args(
            val albumName: String,
            val albumArtist: String,
            val source: String,
            val smbConfigId: String,
            val year: String
        )

        fun createRoute(
            albumName: String,
            albumArtist: String,
            source: MusicSource?,
            smbConfigId: String? = null,
            year: Int? = null
        ): String {
            val encodedAlbumName = Uri.encode(albumName)
            val encodedAlbumArtist = Uri.encode(albumArtist)
            val encodedSmbConfigId = Uri.encode(smbConfigId.orEmpty())
            val encodedYear = year?.toString().orEmpty()
            val encodedSource = source?.name.orEmpty()
            return "$route?$albumNameArg=$encodedAlbumName&$albumArtistArg=$encodedAlbumArtist&$sourceArg=$encodedSource&$smbConfigIdArg=$encodedSmbConfigId&$yearArg=$encodedYear"
        }

        fun parseRouteArgs(routeString: String): Args? {
            val params = parseQueryParams(routeString) ?: return null
            val albumName = params[albumNameArg] ?: return null
            val albumArtist = params[albumArtistArg] ?: return null
            val source = params[sourceArg] ?: return null
            val smbConfigId = params[smbConfigIdArg] ?: ""
            val year = params[yearArg] ?: ""
            return Args(albumName, albumArtist, source, smbConfigId, year)
        }
    }

    data object ArtistDetail : Screen(
        route = "artist_detail",
        title = "アーティスト詳細"
    ) {
        const val artistNameArg = "artistName"
        const val sourceArg = "source"
        const val smbConfigIdArg = "smbConfigId"

        val routePattern =
            "$route?$artistNameArg={$artistNameArg}&$sourceArg={$sourceArg}&$smbConfigIdArg={$smbConfigIdArg}"

        data class Args(
            val artistName: String,
            val source: String,
            val smbConfigId: String
        )

        fun createRoute(
            artistName: String,
            source: MusicSource?,
            smbConfigId: String? = null
        ): String {
            val encodedArtistName = Uri.encode(artistName)
            val encodedSource = source?.name.orEmpty()
            val encodedSmbConfigId = Uri.encode(smbConfigId.orEmpty())
            return "$route?$artistNameArg=$encodedArtistName&$sourceArg=$encodedSource&$smbConfigIdArg=$encodedSmbConfigId"
        }

        fun parseRouteArgs(routeString: String): Args? {
            val params = parseQueryParams(routeString) ?: return null
            val artistName = params[artistNameArg] ?: return null
            val source = params[sourceArg] ?: return null
            val smbConfigId = params[smbConfigIdArg] ?: ""
            return Args(artistName, source, smbConfigId)
        }
    }

    companion object {
        val bottomNavItems = listOf(Home, Library)

        /**
         * Parses query parameters from a route string of the form
         * `base_route?key1=value1&key2=value2`.
         * Values are percent-decoded. Returns null if there are no query parameters.
         */
        fun parseQueryParams(routeString: String): Map<String, String>? {
            val query = routeString.substringAfter("?", "").takeIf { it.isNotEmpty() }
                ?: return null
            return query.split("&").mapNotNull { param ->
                val idx = param.indexOf('=')
                if (idx < 0) null
                else {
                    val key = param.substring(0, idx)
                    // URLDecoder.decode(String, Charset) requires API 26+; using the String
                    // overload here is safe because "UTF-8" is always supported and never throws.
                    @Suppress("DEPRECATION")
                    val value = URLDecoder.decode(param.substring(idx + 1), "UTF-8")
                    key to value
                }
            }.toMap()
        }
    }
}
