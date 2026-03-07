package com.example.aero_stream_for_android.ui.root.chrome

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.components.AeroFilterChip
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun LibraryCategoryChipsRow(
    categories: List<LibraryCategory>,
    selectedCategory: LibraryCategory,
    onSelect: (LibraryCategory) -> Unit
) {
    LazyRow(
        modifier = Modifier.fillMaxWidth(),
        contentPadding = PaddingValues(horizontal = AeroCompactUiTokens.screenHorizontalPadding),
        horizontalArrangement = Arrangement.spacedBy(AeroCompactUiTokens.chipSpacing)
    ) {
        items(categories) { category ->
            AeroFilterChip(
                label = category.label(),
                selected = category == selectedCategory,
                onClick = { onSelect(category) }
            )
        }
    }
}

fun LibraryCategory.label(): String = when (this) {
    LibraryCategory.Songs -> "曲"
    LibraryCategory.Albums -> "アルバム"
    LibraryCategory.AlbumArtists -> "アルバムアーティスト"
    LibraryCategory.Artists -> "アーティスト"
    LibraryCategory.Genres -> "ジャンル"
    LibraryCategory.Years -> "年"
    LibraryCategory.Playlists -> "プレイリスト"
}
