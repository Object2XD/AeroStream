package com.example.aero_stream_for_android.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.selection.selectable
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.RadioButtonUnchecked
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.Role
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.role
import androidx.compose.ui.semantics.selected
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.stateDescription
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun AeroModalSheet(
    onDismissRequest: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismissRequest,
        containerColor = MaterialTheme.colorScheme.surface,
        dragHandle = null,
        modifier = modifier,
        content = content
    )
}

@Composable
fun AeroSheetScaffold(
    title: String,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
    content: @Composable ColumnScope.() -> Unit
) {
    Column(
        modifier = modifier
            .fillMaxWidth()
            .padding(
                top = 8.dp,
                bottom = AeroCompactUiTokens.bottomCardBodyBottomPadding
            )
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    horizontal = AeroCompactUiTokens.bottomCardHeaderHorizontalPadding,
                    vertical = AeroCompactUiTokens.bottomCardHeaderVerticalPadding
                ),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = title,
                style = MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold),
                modifier = Modifier.weight(1f)
            )
            IconButton(onClick = onDismiss) {
                Icon(
                    imageVector = Icons.Default.Close,
                    contentDescription = "閉じる"
                )
            }
        }

        HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.28f))

        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = AeroCompactUiTokens.bottomCardBodyTopPadding),
            content = content
        )
    }
}

@Composable
fun AeroSheetSectionTitle(
    text: String,
    modifier: Modifier = Modifier
) {
    Text(
        text = text,
        style = MaterialTheme.typography.titleMedium.copy(fontWeight = FontWeight.SemiBold),
        modifier = modifier.padding(
            horizontal = AeroCompactUiTokens.bottomCardOptionHorizontalPadding,
            vertical = AeroCompactUiTokens.bottomCardSectionTitleBottomPadding
        )
    )
}

@Composable
fun AeroSingleChoiceOptionRow(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    contentDescription: String,
    modifier: Modifier = Modifier
) {
    val indicatorIcon: ImageVector =
        if (selected) Icons.Default.CheckCircle else Icons.Default.RadioButtonUnchecked
    val containerColor =
        if (selected) {
            MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.72f)
        } else {
            MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.28f)
        }
    val labelColor =
        if (selected) MaterialTheme.colorScheme.onSurface else MaterialTheme.colorScheme.onSurfaceVariant

    Surface(
        shape = RoundedCornerShape(AeroCompactUiTokens.bottomCardOptionCornerRadius),
        color = containerColor,
        tonalElevation = if (selected) 2.dp else 0.dp,
        modifier = modifier
            .fillMaxWidth()
            .padding(
                horizontal = AeroCompactUiTokens.bottomCardOptionHorizontalPadding,
                vertical = AeroCompactUiTokens.bottomCardOptionVerticalPadding
            )
            .defaultMinSize(minHeight = AeroCompactUiTokens.bottomCardOptionMinHeight)
            .selectable(
                selected = selected,
                onClick = onClick,
                role = Role.RadioButton
            )
            .semantics(mergeDescendants = true) {
                role = Role.RadioButton
                this.selected = selected
                stateDescription = if (selected) "選択中" else "未選択"
                this.contentDescription = contentDescription
            }
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    horizontal = AeroCompactUiTokens.bottomCardOptionInnerHorizontalPadding,
                    vertical = AeroCompactUiTokens.bottomCardOptionInnerVerticalPadding
                ),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Icon(
                imageVector = indicatorIcon,
                contentDescription = null,
                tint = MaterialTheme.colorScheme.onSurface,
                modifier = Modifier.size(20.dp)
            )
            Spacer(modifier = Modifier.size(12.dp))
            Text(
                text = label,
                style = AeroCompactUiTokens.sortLabelTextStyle(),
                color = labelColor,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
        }
    }
}

@Composable
fun AeroConfirmationSheet(
    title: String,
    message: String,
    confirmLabel: String,
    dismissLabel: String,
    onConfirm: () -> Unit,
    onDismiss: () -> Unit,
    modifier: Modifier = Modifier,
    destructiveConfirm: Boolean = false,
    confirmContentDescription: String? = null,
    dismissContentDescription: String? = null
) {
    AeroSheetScaffold(
        title = title,
        onDismiss = onDismiss,
        modifier = modifier
    ) {
        AeroCard(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = AeroCompactUiTokens.bottomCardOptionHorizontalPadding)
        ) {
            Text(
                text = message,
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onSurface
            )
        }

        Spacer(modifier = Modifier.size(AeroCompactUiTokens.bottomCardSectionGap))

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = AeroCompactUiTokens.bottomCardOptionHorizontalPadding),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            AeroActionChip(
                label = dismissLabel,
                onClick = onDismiss,
                modifier = Modifier.weight(1f),
                contentDescription = dismissContentDescription
            )
            AeroActionChip(
                label = confirmLabel,
                onClick = onConfirm,
                modifier = Modifier.weight(1f),
                contentDescription = confirmContentDescription,
                labelColor = if (destructiveConfirm) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface,
                leadingIconColor = if (destructiveConfirm) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface,
                trailingIconColor = if (destructiveConfirm) MaterialTheme.colorScheme.error else MaterialTheme.colorScheme.onSurface
            )
        }
    }
}
