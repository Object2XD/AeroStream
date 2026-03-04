package com.example.aero_stream_for_android.ui.root.chrome

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.example.aero_stream_for_android.ui.library.LibraryCategory
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
            FilterChip(
                selected = category == selectedCategory,
                onClick = { onSelect(category) },
                label = {
                    Text(
                        text = category.label(),
                        style = AeroCompactUiTokens.chipLabelTextStyle()
                    )
                },
                shape = RoundedCornerShape(AeroCompactUiTokens.chipCornerRadius),
                modifier = Modifier.heightIn(min = AeroCompactUiTokens.chipMinHeight),
                colors = FilterChipDefaults.filterChipColors(
                    selectedContainerColor = AeroCompactUiTokens.chipSelectedContainerColor(),
                    selectedLabelColor = AeroCompactUiTokens.chipSelectedLabelColor()
                )
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
