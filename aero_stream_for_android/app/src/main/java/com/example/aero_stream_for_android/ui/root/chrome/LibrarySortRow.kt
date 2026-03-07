package com.example.aero_stream_for_android.ui.root.chrome

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.components.AeroActionChip
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun LibrarySortRow(
    sort: LibrarySort,
    onOpenSortPicker: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = AeroCompactUiTokens.screenHorizontalPadding)
            .padding(
                top = AeroCompactUiTokens.sortRowTopPadding,
                bottom = AeroCompactUiTokens.sortRowBottomPadding
            ),
        horizontalArrangement = Arrangement.Start,
        verticalAlignment = Alignment.CenterVertically
    ) {
        AeroActionChip(
            label = sort.label(),
            onClick = onOpenSortPicker,
            trailingIcon = { androidx.compose.material3.Icon(Icons.Default.KeyboardArrowDown, contentDescription = null) }
        )
    }
}

fun LibrarySort.label(): String = "${key.label()} / ${order.label()}"

fun LibrarySortKey.label(): String = when (this) {
    LibrarySortKey.Name -> "Name"
    LibrarySortKey.AddedDate -> "Added date"
    LibrarySortKey.LastPlayed -> "Last played"
    LibrarySortKey.Year -> "Year"
    LibrarySortKey.Artist -> "Artist"
    LibrarySortKey.Album -> "Album"
    LibrarySortKey.SongCount -> "Song count"
    LibrarySortKey.CreatedAt -> "Created"
}

fun SortOrder.label(): String = when (this) {
    SortOrder.Asc -> "Ascending"
    SortOrder.Desc -> "Descending"
}
