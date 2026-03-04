package com.example.aero_stream_for_android.ui.root

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.onSizeChanged
import androidx.compose.ui.zIndex
import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.root.chrome.LibraryCategoryChipsRow
import com.example.aero_stream_for_android.ui.root.chrome.LibrarySortRow

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun QuickReturnHeaderContainer(
    spec: HeaderSpec,
    onHeaderHeightChanged: (Int) -> Unit,
    onActionClick: (HeaderAction) -> Unit,
    onCategorySelected: (LibraryCategory) -> Unit,
    onOpenSortPicker: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .zIndex(1f)
            .background(MaterialTheme.colorScheme.background)
            .onSizeChanged { onHeaderHeightChanged(it.height) }
    ) {
        TopAppBar(
            title = { Text(spec.title) },
            windowInsets = WindowInsets(0, 0, 0, 0),
            colors = TopAppBarDefaults.topAppBarColors(
                containerColor = MaterialTheme.colorScheme.background
            ),
            actions = {
                spec.actions.forEach { action ->
                    when (action) {
                        HeaderAction.Settings -> {
                            IconButton(onClick = { onActionClick(action) }) {
                                Icon(Icons.Default.Settings, contentDescription = "Settings")
                            }
                        }

                        HeaderAction.RefreshTop,
                        HeaderAction.RefreshLibrary -> {
                            IconButton(onClick = { onActionClick(action) }) {
                                Icon(Icons.Default.Refresh, contentDescription = "Refresh")
                            }
                        }
                    }
                }
            }
        )

        when (val accessory = spec.accessory) {
            is LibraryAccessorySpec -> {
                LibraryCategoryChipsRow(
                    categories = accessory.categories,
                    selectedCategory = accessory.selectedCategory,
                    onSelect = onCategorySelected
                )
                LibrarySortRow(
                    sort = accessory.sort,
                    onOpenSortPicker = onOpenSortPicker
                )
            }

            NoAccessory -> Unit
        }
    }
}
