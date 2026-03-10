package com.example.aero_stream_for_android.ui.root

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

class RootRouteTest {

    @Test
    fun isPlayerSheetVisibleRoute_settingsRoute_isFalse() {
        assertFalse(SettingsRoute.isPlayerSheetVisibleRoute())
    }

    @Test
    fun isPlayerSheetVisibleRoute_nonSettingsRoutes_areTrue() {
        assertTrue(TopRoute.isPlayerSheetVisibleRoute())
        assertTrue(LibraryRoute.isPlayerSheetVisibleRoute())
        assertTrue(SearchRoute.isPlayerSheetVisibleRoute())
        assertTrue(SmbBrowserRoute.isPlayerSheetVisibleRoute())
        assertTrue((null as AppRoute?).isPlayerSheetVisibleRoute())
    }

    @Test
    fun routeToAppRoute_albumDetailWithArgs_returnsAlbumDetailRouteWithParsedValues() {
        val route = "album_detail?albumName=Album&albumArtist=Artist&source=SMB&smbConfigId=cfg&year=2024"
        val result = routeToAppRoute(route)
        assertTrue(result is AlbumDetailRoute)
        val albumRoute = result as AlbumDetailRoute
        assertEquals("Album", albumRoute.albumName)
        assertEquals("Artist", albumRoute.albumArtist)
        assertEquals("SMB", albumRoute.source)
        assertEquals("cfg", albumRoute.smbConfigId)
        assertEquals("2024", albumRoute.year)
    }

    @Test
    fun routeToAppRoute_albumDetailWithUrlEncodedArgs_decodesCorrectly() {
        val route = "album_detail?albumName=My%20Album&albumArtist=My%20Artist&source=LOCAL&smbConfigId=&year="
        val result = routeToAppRoute(route)
        assertTrue(result is AlbumDetailRoute)
        val albumRoute = result as AlbumDetailRoute
        assertEquals("My Album", albumRoute.albumName)
        assertEquals("My Artist", albumRoute.albumArtist)
        assertEquals("LOCAL", albumRoute.source)
        assertEquals("", albumRoute.smbConfigId)
        assertEquals("", albumRoute.year)
    }

    @Test
    fun routeToAppRoute_albumDetailWithoutArgs_returnsNull() {
        assertNull(routeToAppRoute("album_detail"))
    }

    @Test
    fun routeToAppRoute_albumDetailMissingRequiredArg_returnsNull() {
        val route = "album_detail?albumName=Album&source=LOCAL"
        assertNull(routeToAppRoute(route))
    }

    @Test
    fun routeToAppRoute_artistDetailWithArgs_returnsArtistDetailRouteWithParsedValues() {
        val route = "artist_detail?artistName=Artist&source=LOCAL&smbConfigId="
        val result = routeToAppRoute(route)
        assertTrue(result is ArtistDetailRoute)
        val artistRoute = result as ArtistDetailRoute
        assertEquals("Artist", artistRoute.artistName)
        assertEquals("LOCAL", artistRoute.source)
        assertEquals("", artistRoute.smbConfigId)
    }

    @Test
    fun routeToAppRoute_artistDetailWithUrlEncodedArgs_decodesCorrectly() {
        val route = "artist_detail?artistName=My%20Artist&source=SMB&smbConfigId=config%2F1"
        val result = routeToAppRoute(route)
        assertTrue(result is ArtistDetailRoute)
        val artistRoute = result as ArtistDetailRoute
        assertEquals("My Artist", artistRoute.artistName)
        assertEquals("SMB", artistRoute.source)
        assertEquals("config/1", artistRoute.smbConfigId)
    }

    @Test
    fun routeToAppRoute_artistDetailWithoutArgs_returnsNull() {
        assertNull(routeToAppRoute("artist_detail"))
    }

    @Test
    fun routeToAppRoute_artistDetailMissingArtistName_returnsNull() {
        val route = "artist_detail?source=LOCAL&smbConfigId="
        assertNull(routeToAppRoute(route))
    }

    @Test
    fun routeToAppRoute_artistDetailMissingSource_returnsNull() {
        val route = "artist_detail?artistName=Artist&smbConfigId="
        assertNull(routeToAppRoute(route))
    }

    @Test
    fun routeToAppRoute_albumDetail_isBottomNavVisibleAndSelectsLibrary() {
        val route = "album_detail?albumName=Album&albumArtist=Artist&source=LOCAL&smbConfigId=&year="
        val appRoute = routeToAppRoute(route)
        assertTrue(appRoute.isBottomNavVisible())
        assertEquals(RootPrimaryRoute.Library, appRoute.toBottomNavSelectedPrimaryRoute())
    }

    @Test
    fun routeToAppRoute_artistDetail_isBottomNavVisibleAndSelectsLibrary() {
        val route = "artist_detail?artistName=Artist&source=LOCAL&smbConfigId="
        val appRoute = routeToAppRoute(route)
        assertTrue(appRoute.isBottomNavVisible())
        assertEquals(RootPrimaryRoute.Library, appRoute.toBottomNavSelectedPrimaryRoute())
    }
}
