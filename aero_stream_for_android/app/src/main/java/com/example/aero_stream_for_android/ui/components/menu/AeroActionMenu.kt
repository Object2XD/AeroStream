package com.example.aero_stream_for_android.ui.components.menu

import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.dp
import com.example.aero_stream_for_android.ui.components.AeroCard
import com.example.aero_stream_for_android.ui.components.AeroModalSheet
import com.example.aero_stream_for_android.ui.components.AeroSheetScaffold

data class AeroMenuItem(
    val id: String,
    val label: String,
    val onClick: () -> Unit,
    val enabled: Boolean = true,
    val isDestructive: Boolean = false,
    val leadingIcon: ImageVector? = null
)

@Composable
fun AeroOverflowMenuTrigger(
    onOpenMenu: () -> Unit,
    contentDescription: String = "More options"
) {
    IconButton(onClick = onOpenMenu) {
        Icon(
            imageVector = Icons.Default.MoreVert,
            contentDescription = contentDescription
        )
    }
}

@Composable
fun AeroActionMenuSheet(
    items: List<AeroMenuItem>,
    title: String,
    expanded: Boolean,
    onDismiss: () -> Unit
) {
    if (!expanded) return
    AeroModalSheet(onDismissRequest = onDismiss) {
        AeroSheetScaffold(
            title = title,
            onDismiss = onDismiss
        ) {
            items.forEach { item ->
                AeroCard(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp, vertical = 6.dp),
                    onClick = if (item.enabled) {
                        {
                            onDismiss()
                            item.onClick()
                        }
                    } else {
                        null
                    }
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        if (item.leadingIcon != null) {
                            Icon(
                                imageVector = item.leadingIcon,
                                contentDescription = null,
                                tint = if (item.isDestructive) {
                                    MaterialTheme.colorScheme.error
                                } else {
                                    MaterialTheme.colorScheme.onSurfaceVariant
                                }
                            )
                            Spacer(modifier = Modifier.width(10.dp))
                        }
                        Text(
                            text = item.label,
                            color = if (item.isDestructive) {
                                MaterialTheme.colorScheme.error
                            } else {
                                MaterialTheme.colorScheme.onSurface
                            }
                        )
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalFoundationApi::class)
fun Modifier.aeroMenuClickable(
    hasMenu: Boolean,
    onClick: () -> Unit,
    onOpenMenu: () -> Unit
): Modifier = fillMaxWidth().combinedClickable(
    onClick = onClick,
    onLongClick = if (hasMenu) onOpenMenu else null
)
