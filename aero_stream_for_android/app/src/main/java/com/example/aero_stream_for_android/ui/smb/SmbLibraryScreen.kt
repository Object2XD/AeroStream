package com.example.aero_stream_for_android.ui.smb

import androidx.compose.runtime.Composable
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.library.LibraryFeatureState
import com.example.aero_stream_for_android.ui.library.LibrarySource
import com.example.aero_stream_for_android.ui.library.content.SmbLibraryContent

@Composable
fun SmbLibraryScreen(
    onNavigateToPlayer: () -> Unit = {},
    onNavigateToAlbumDetail: (Album, MusicSource?, String?) -> Unit = { _, _, _ -> }
) {
    SmbLibraryContent(
        featureState = LibraryFeatureState(
            source = LibrarySource.SMB,
            category = LibraryCategory.Songs
        ),
        onNavigateToPlayer = onNavigateToPlayer,
        onNavigateToAlbumDetail = onNavigateToAlbumDetail
    )
}
