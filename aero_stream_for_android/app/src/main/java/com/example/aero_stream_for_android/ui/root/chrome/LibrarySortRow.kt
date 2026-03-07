package com.example.aero_stream_for_android.ui.root.chrome

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.components.AeroSortPill
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
        AeroSortPill(
            label = sort.label(),
            onClick = onOpenSortPicker,
            contentDescription = "並び替え: ${sort.label()}"
        )
    }
}

fun LibrarySort.label(): String = "${key.label()} / ${order.label()}"

fun LibrarySortKey.label(): String = when (this) {
    LibrarySortKey.Name -> "名前"
    LibrarySortKey.AddedDate -> "追加日"
    LibrarySortKey.LastPlayed -> "最終再生"
    LibrarySortKey.Year -> "年"
    LibrarySortKey.Artist -> "アーティスト"
    LibrarySortKey.Album -> "アルバム"
    LibrarySortKey.SongCount -> "曲数"
    LibrarySortKey.CreatedAt -> "作成日"
}

fun SortOrder.label(): String = when (this) {
    SortOrder.Asc -> "昇順"
    SortOrder.Desc -> "降順"
}
