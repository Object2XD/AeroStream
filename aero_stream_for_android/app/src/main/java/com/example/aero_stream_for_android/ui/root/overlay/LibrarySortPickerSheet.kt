package com.example.aero_stream_for_android.ui.root.overlay

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.root.chrome.label

@Composable
fun LibrarySortPickerSheet(
    selectedSort: LibrarySort,
    availableKeys: List<LibrarySortKey>,
    onDismiss: () -> Unit,
    onConfirm: (LibrarySort) -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(top = 8.dp, bottom = 24.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 12.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(text = "Sort options", style = MaterialTheme.typography.titleLarge)
            IconButton(onClick = onDismiss) {
                Icon(Icons.Default.Close, contentDescription = "Close")
            }
        }
        HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.28f))

        Text(
            text = "Sort",
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 12.dp),
            style = MaterialTheme.typography.titleMedium
        )
        availableKeys.forEach { key ->
            SortOptionRow(
                label = key.label(),
                selected = key == selectedSort.key,
                onClick = { onConfirm(selectedSort.copy(key = key)) }
            )
        }

        Text(
            text = "Order",
            modifier = Modifier.padding(horizontal = 20.dp, vertical = 12.dp),
            style = MaterialTheme.typography.titleMedium
        )
        SortOrder.entries.forEach { order ->
            SortOptionRow(
                label = order.label(),
                selected = order == selectedSort.order,
                onClick = { onConfirm(selectedSort.copy(order = order)) }
            )
        }
    }
}

@Composable
private fun SortOptionRow(
    label: String,
    selected: Boolean,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 20.dp, vertical = 16.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(modifier = Modifier.width(28.dp), contentAlignment = Alignment.CenterStart) {
            if (selected) {
                Icon(Icons.Default.Check, contentDescription = null)
            }
        }
        Text(text = label)
    }
}
