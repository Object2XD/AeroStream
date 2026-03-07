package com.example.aero_stream_for_android.ui.root.overlay

import androidx.compose.runtime.Composable
import com.example.aero_stream_for_android.ui.components.AeroSheetScaffold
import com.example.aero_stream_for_android.ui.components.AeroSheetSectionTitle
import com.example.aero_stream_for_android.ui.components.AeroSingleChoiceOptionRow
import com.example.aero_stream_for_android.ui.library.LibrarySource

@Composable
fun LibrarySourcePickerSheet(
    selectedSource: LibrarySource,
    onDismiss: () -> Unit,
    onSelect: (LibrarySource) -> Unit
) {
    val options = listOf(
        LibrarySource.LocalFiles to "ローカルファイル",
        LibrarySource.SMB to "SMB",
        LibrarySource.Cache to "キャッシュ"
    )

    AeroSheetScaffold(
        title = "ライブラリソース",
        onDismiss = onDismiss
    ) {
        AeroSheetSectionTitle(text = "ソース")
        options.forEach { (source, label) ->
            AeroSingleChoiceOptionRow(
                label = label,
                selected = source == selectedSource,
                onClick = { onSelect(source) },
                contentDescription = "ライブラリソース: $label"
            )
        }
    }
}
