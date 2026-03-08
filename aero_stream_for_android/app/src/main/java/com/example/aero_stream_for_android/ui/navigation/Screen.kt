package com.example.aero_stream_for_android.ui.navigation

import android.net.Uri
import androidx.compose.material.icons.Icons
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
    }

    companion object {
        val bottomNavItems = listOf(Home, Library)
    }
}
