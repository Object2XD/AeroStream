package com.example.aero_stream_for_android.ui.root

import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.runtime.Composable
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.LibrarySource
import com.example.aero_stream_for_android.ui.root.overlay.LibrarySortPickerSheet
import com.example.aero_stream_for_android.ui.root.overlay.LibrarySourcePickerSheet

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun OverlayHost(
    activeOverlay: ActiveOverlay,
    selectedSource: LibrarySource,
    selectedSort: LibrarySort,
    availableSortKeys: List<LibrarySortKey>,
    onDismiss: () -> Unit,
    onSelectSource: (LibrarySource) -> Unit,
    onConfirmSort: (LibrarySort) -> Unit
) {
    when (activeOverlay) {
        LibrarySourcePickerOverlay -> {
            ModalBottomSheet(
                onDismissRequest = onDismiss,
                containerColor = MaterialTheme.colorScheme.surface,
                dragHandle = null
            ) {
                LibrarySourcePickerSheet(
                    selectedSource = selectedSource,
                    onDismiss = onDismiss,
                    onSelect = onSelectSource
                )
            }
        }

        LibrarySortPickerOverlay -> {
            ModalBottomSheet(
                onDismissRequest = onDismiss,
                containerColor = MaterialTheme.colorScheme.surface,
                dragHandle = null
            ) {
                LibrarySortPickerSheet(
                    selectedSort = selectedSort,
                    availableKeys = availableSortKeys,
                    onDismiss = onDismiss,
                    onConfirm = onConfirmSort
                )
            }
        }

        NoOverlay -> Unit
    }
}
