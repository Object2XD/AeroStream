package com.example.aero_stream_for_android.ui.library

import androidx.compose.runtime.Composable
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.ui.library.content.LocalLibraryContent

@Composable
fun LibraryScreen(
    onNavigateToAlbumDetail: (Album, MusicSource?, String?) -> Unit = { _, _, _ -> }
) {
    LocalLibraryContent(
        featureState = LibraryFeatureState(
            source = LibrarySource.LocalFiles,
            category = LibraryCategory.Songs
        ),
        onNavigateToAlbumDetail = onNavigateToAlbumDetail
    )
}
