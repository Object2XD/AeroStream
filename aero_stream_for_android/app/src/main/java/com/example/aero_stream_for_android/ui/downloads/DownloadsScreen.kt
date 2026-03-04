package com.example.aero_stream_for_android.ui.downloads

import androidx.compose.runtime.Composable
import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.library.LibraryFeatureState
import com.example.aero_stream_for_android.ui.library.LibrarySource
import com.example.aero_stream_for_android.ui.library.content.CacheLibraryContent

@Composable
fun DownloadsScreen(
    onNavigateToPlayer: () -> Unit = {}
) {
    CacheLibraryContent(
        featureState = LibraryFeatureState(
            source = LibrarySource.Cache,
            category = LibraryCategory.Songs
        ),
        onNavigateToPlayer = onNavigateToPlayer
    )
}
