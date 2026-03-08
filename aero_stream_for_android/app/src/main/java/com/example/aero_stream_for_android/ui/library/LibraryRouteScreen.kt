package com.example.aero_stream_for_android.ui.library

import androidx.compose.runtime.Composable
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.ui.library.content.CacheLibraryContent
import com.example.aero_stream_for_android.ui.library.content.LocalLibraryContent
import com.example.aero_stream_for_android.ui.library.content.SmbLibraryContent

@Composable
fun LibraryRouteScreen(
    featureState: LibraryFeatureState,
    smbScanSheetRequestToken: Int = 0,
    smbScanCancelRequestToken: Int = 0,
    onNavigateToAlbumDetail: (Album, MusicSource?, String?) -> Unit = { _, _, _ -> },
    onNavigateToArtistDetail: (String, MusicSource?, String?) -> Unit = { _, _, _ -> }
) {
    when (featureState.source) {
        LibrarySource.LocalFiles -> {
            LocalLibraryContent(
                featureState = featureState,
                onNavigateToAlbumDetail = onNavigateToAlbumDetail,
                onNavigateToArtistDetail = onNavigateToArtistDetail
            )
        }

        LibrarySource.SMB -> {
            SmbLibraryContent(
                featureState = featureState,
                openScanOptionsRequestToken = smbScanSheetRequestToken,
                cancelScanRequestToken = smbScanCancelRequestToken,
                onNavigateToAlbumDetail = onNavigateToAlbumDetail,
                onNavigateToArtistDetail = onNavigateToArtistDetail
            )
        }

        LibrarySource.Cache -> {
            CacheLibraryContent(featureState = featureState)
        }
    }
}
