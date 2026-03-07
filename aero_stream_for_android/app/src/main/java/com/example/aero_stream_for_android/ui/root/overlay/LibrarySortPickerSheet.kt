package com.example.aero_stream_for_android.ui.root.overlay

import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import com.example.aero_stream_for_android.ui.components.AeroSheetScaffold
import com.example.aero_stream_for_android.ui.components.AeroSheetSectionTitle
import com.example.aero_stream_for_android.ui.components.AeroSingleChoiceOptionRow
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun LibrarySortPickerSheet(
    selectedSort: LibrarySort,
    availableKeys: List<LibrarySortKey>,
    onDismiss: () -> Unit,
    onConfirm: (LibrarySort) -> Unit
) {
    AeroSheetScaffold(
        title = "並び替えオプション",
        onDismiss = onDismiss
    ) {
        AeroSheetSectionTitle(text = "キー")
        availableKeys.forEach { key ->
            AeroSingleChoiceOptionRow(
                label = key.bottomCardLabel(),
                selected = key == selectedSort.key,
                onClick = { onConfirm(selectedSort.copy(key = key)) },
                contentDescription = "キー: ${key.bottomCardLabel()}"
            )
        }

        Spacer(modifier = Modifier.height(AeroCompactUiTokens.bottomCardSectionGap))
        AeroSheetSectionTitle(text = "順序")
        SortOrder.entries.forEach { order ->
            AeroSingleChoiceOptionRow(
                label = order.bottomCardLabel(),
                selected = order == selectedSort.order,
                onClick = { onConfirm(selectedSort.copy(order = order)) },
                contentDescription = "順序: ${order.bottomCardLabel()}"
            )
        }
    }
}

private fun LibrarySortKey.bottomCardLabel(): String = when (this) {
    LibrarySortKey.Name -> "名前"
    LibrarySortKey.AddedDate -> "追加日"
    LibrarySortKey.LastPlayed -> "最終再生"
    LibrarySortKey.Year -> "年"
    LibrarySortKey.Artist -> "アーティスト"
    LibrarySortKey.Album -> "アルバム"
    LibrarySortKey.SongCount -> "曲数"
    LibrarySortKey.CreatedAt -> "作成日"
}

private fun SortOrder.bottomCardLabel(): String = when (this) {
    SortOrder.Asc -> "昇順"
    SortOrder.Desc -> "降順"
}
