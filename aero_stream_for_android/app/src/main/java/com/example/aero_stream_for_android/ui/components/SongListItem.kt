package com.example.aero_stream_for_android.ui.components

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.library.content.LibraryRowMenuItem
import com.example.aero_stream_for_android.ui.library.content.LibrarySongRow
import com.example.aero_stream_for_android.ui.library.content.LibrarySongRowStyle

enum class SongListItemStyle {
    WithStatusBadge,
    CompactNoBadge
}

@Deprecated("Use LibrarySongRow in ui.library.content instead.")
@Composable
fun SongListItem(
    song: Song,
    onClick: () -> Unit,
    onMoreClick: (() -> Unit)? = null,
    isPlaying: Boolean = false,
    style: SongListItemStyle = SongListItemStyle.WithStatusBadge,
    modifier: Modifier = Modifier
) {
    val menuItems = if (onMoreClick == null) {
        emptyList()
    } else {
        listOf(
            LibraryRowMenuItem(
                id = "legacy_more",
                label = "More options",
                leadingIcon = Icons.Default.MoreVert,
                onClick = onMoreClick
            )
        )
    }

    LibrarySongRow(
        song = song,
        onClick = onClick,
        menuItems = menuItems,
        isPlaying = isPlaying,
        style = when (style) {
            SongListItemStyle.WithStatusBadge -> LibrarySongRowStyle.WithStatusBadge
            SongListItemStyle.CompactNoBadge -> LibrarySongRowStyle.CompactNoBadge
        },
        modifier = modifier
    )
}
