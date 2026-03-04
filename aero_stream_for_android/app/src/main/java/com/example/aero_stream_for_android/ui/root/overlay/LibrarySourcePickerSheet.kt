package com.example.aero_stream_for_android.ui.root.overlay

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
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
import com.example.aero_stream_for_android.ui.library.LibrarySource
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun LibrarySourcePickerSheet(
    selectedSource: LibrarySource,
    onDismiss: () -> Unit,
    onSelect: (LibrarySource) -> Unit
) {
    val options = listOf(
        LibrarySource.LocalFiles to "Local files",
        LibrarySource.SMB to "SMB",
        LibrarySource.Cache to "Cache"
    )

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
            Text(text = "Library source", style = MaterialTheme.typography.titleLarge)
            IconButton(onClick = onDismiss) {
                Icon(Icons.Default.Close, contentDescription = "Close")
            }
        }

        HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.28f))
        Spacer(modifier = Modifier.padding(top = 10.dp))

        options.forEach { (source, label) ->
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { onSelect(source) }
                    .padding(horizontal = 20.dp, vertical = 16.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                Box(
                    modifier = Modifier.width(28.dp),
                    contentAlignment = Alignment.CenterStart
                ) {
                    if (source == selectedSource) {
                        Icon(Icons.Default.Check, contentDescription = null)
                    }
                }
                Text(
                    text = label,
                    style = AeroCompactUiTokens.sortLabelTextStyle()
                )
            }
        }
    }
}
