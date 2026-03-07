package com.example.aero_stream_for_android.ui.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.defaultMinSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.KeyboardArrowDown
import androidx.compose.material3.AssistChip
import androidx.compose.material3.AssistChipDefaults
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonColors
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.FilledIconButton
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonColors
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun AeroCard(
    modifier: Modifier = Modifier,
    onClick: (() -> Unit)? = null,
    contentPadding: PaddingValues = PaddingValues(
        horizontal = AeroCompactUiTokens.cardContentHorizontalPadding,
        vertical = AeroCompactUiTokens.cardContentVerticalPadding
    ),
    content: @Composable ColumnScope.() -> Unit
) {
    val clickableModifier = if (onClick == null) {
        modifier
    } else {
        modifier.clickable(onClick = onClick)
    }

    Surface(
        modifier = clickableModifier,
        shape = RoundedCornerShape(AeroCompactUiTokens.cardCornerRadius),
        color = AeroCompactUiTokens.cardContainerColor()
    ) {
        Column(
            modifier = Modifier.padding(contentPadding),
            content = content
        )
    }
}

@Composable
fun AeroActionChip(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    contentDescription: String? = null,
    containerColor: Color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.52f),
    labelColor: Color = MaterialTheme.colorScheme.onSurface,
    leadingIconColor: Color = MaterialTheme.colorScheme.onSurface,
    trailingIconColor: Color = MaterialTheme.colorScheme.onSurface,
    leadingIcon: (@Composable () -> Unit)? = null,
    trailingIcon: (@Composable () -> Unit)? = null
) {
    val semanticsModifier = if (contentDescription == null) {
        modifier
    } else {
        modifier.semantics { this.contentDescription = contentDescription }
    }

    AssistChip(
        modifier = semanticsModifier.heightIn(min = AeroCompactUiTokens.chipActionMinHeight),
        onClick = onClick,
        enabled = enabled,
        label = {
            Text(
                text = label,
                style = MaterialTheme.typography.labelLarge
            )
        },
        leadingIcon = leadingIcon,
        trailingIcon = trailingIcon,
        shape = RoundedCornerShape(AeroCompactUiTokens.chipCornerRadius),
        colors = AssistChipDefaults.assistChipColors(
            containerColor = containerColor,
            labelColor = labelColor,
            leadingIconContentColor = leadingIconColor,
            trailingIconContentColor = trailingIconColor
        )
    )
}

@Composable
fun AeroIconOutlinedButton(
    onClick: () -> Unit,
    icon: @Composable () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    contentDescription: String? = null
) {
    val semanticsModifier = if (contentDescription == null) {
        modifier
    } else {
        modifier.semantics { this.contentDescription = contentDescription }
    }

    OutlinedButton(
        modifier = semanticsModifier.heightIn(min = AeroCompactUiTokens.chipActionMinHeight),
        onClick = onClick,
        enabled = enabled,
        shape = RoundedCornerShape(AeroCompactUiTokens.chipCornerRadius),
        border = ButtonDefaults.outlinedButtonBorder(enabled = enabled)
    ) {
        icon()
    }
}

@Composable
fun AeroFilterChip(
    label: String,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    FilterChip(
        selected = selected,
        onClick = onClick,
        label = {
            Text(
                text = label,
                style = AeroCompactUiTokens.chipLabelTextStyle()
            )
        },
        shape = RoundedCornerShape(AeroCompactUiTokens.chipCornerRadius),
        modifier = modifier.heightIn(min = AeroCompactUiTokens.chipMinHeight),
        colors = FilterChipDefaults.filterChipColors(
            selectedContainerColor = AeroCompactUiTokens.chipSelectedContainerColor(),
            selectedLabelColor = AeroCompactUiTokens.chipSelectedLabelColor()
        )
    )
}

@Composable
fun AeroSortPill(
    label: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    contentDescription: String? = null
) {
    Surface(
        shape = RoundedCornerShape(AeroCompactUiTokens.chipCornerRadius),
        color = AeroCompactUiTokens.chipSelectedContainerColor(),
        modifier = modifier
            .defaultMinSize(minHeight = AeroCompactUiTokens.chipMinHeight)
            .clickable(onClick = onClick)
            .semantics {
                if (contentDescription != null) {
                    this.contentDescription = contentDescription
                }
            }
    ) {
        Row(
            modifier = Modifier.padding(
                horizontal = AeroCompactUiTokens.chipHorizontalPadding,
                vertical = AeroCompactUiTokens.chipVerticalPadding
            ),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = label,
                style = AeroCompactUiTokens.chipLabelTextStyle(),
                color = AeroCompactUiTokens.chipSelectedLabelColor()
            )
            Spacer(modifier = Modifier.size(4.dp))
            Icon(
                imageVector = Icons.Default.KeyboardArrowDown,
                contentDescription = null,
                tint = AeroCompactUiTokens.chipSelectedLabelColor()
            )
        }
    }
}

@Composable
fun AeroPrimaryActionButton(
    text: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    colors: ButtonColors = ButtonDefaults.buttonColors()
) {
    Button(
        onClick = onClick,
        modifier = modifier.defaultMinSize(minHeight = AeroCompactUiTokens.chipActionMinHeight),
        enabled = enabled,
        shape = RoundedCornerShape(AeroCompactUiTokens.chipCornerRadius),
        colors = colors
    ) {
        Text(text = text, style = MaterialTheme.typography.labelLarge)
    }
}

enum class AeroIconActionStyle {
    Plain,
    Filled,
    Outlined
}

@Composable
fun AeroIconActionButton(
    onClick: () -> Unit,
    icon: @Composable () -> Unit,
    contentDescription: String,
    modifier: Modifier = Modifier,
    enabled: Boolean = true,
    style: AeroIconActionStyle = AeroIconActionStyle.Plain,
    filledColors: IconButtonColors = IconButtonDefaults.filledIconButtonColors()
) {
    val semanticsModifier = modifier.semantics { this.contentDescription = contentDescription }
    when (style) {
        AeroIconActionStyle.Plain -> {
            IconButton(
                onClick = onClick,
                enabled = enabled,
                modifier = semanticsModifier
            ) { icon() }
        }

        AeroIconActionStyle.Filled -> {
            FilledIconButton(
                onClick = onClick,
                enabled = enabled,
                modifier = semanticsModifier,
                colors = filledColors
            ) { icon() }
        }

        AeroIconActionStyle.Outlined -> {
            OutlinedButton(
                onClick = onClick,
                enabled = enabled,
                modifier = semanticsModifier,
                shape = RoundedCornerShape(AeroCompactUiTokens.chipCornerRadius),
                border = ButtonDefaults.outlinedButtonBorder(enabled = enabled),
                contentPadding = PaddingValues(0.dp)
            ) {
                icon()
            }
        }
    }
}

@Composable
fun AeroListRow(
    title: String,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    onClick: (() -> Unit)? = null,
    leading: @Composable (() -> Unit)? = null,
    trailing: @Composable (() -> Unit)? = null
) {
    val rowModifier = if (onClick != null) {
        modifier.clickable(onClick = onClick)
    } else {
        modifier
    }

    Row(
        modifier = rowModifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 10.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (leading != null) {
            leading()
            Spacer(modifier = Modifier.size(12.dp))
        }
        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = AeroCompactUiTokens.rowTitleTextStyle(),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            if (!subtitle.isNullOrBlank()) {
                Text(
                    text = subtitle,
                    style = AeroCompactUiTokens.rowSubtitleTextStyle(),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
        if (trailing != null) {
            Spacer(modifier = Modifier.size(8.dp))
            trailing()
        }
    }
}

@Composable
fun AeroEmptyState(
    title: String,
    modifier: Modifier = Modifier,
    description: String? = null,
    icon: ImageVector? = null,
    iconTint: Color = MaterialTheme.colorScheme.onSurfaceVariant
) {
    Column(
        modifier = modifier,
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        if (icon != null) {
            Icon(
                imageVector = icon,
                contentDescription = null,
                modifier = Modifier.size(AeroCompactUiTokens.emptyStateIconSize),
                tint = iconTint
            )
            Spacer(modifier = Modifier.size(14.dp))
        }
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
        if (!description.isNullOrBlank()) {
            Spacer(modifier = Modifier.size(8.dp))
            Text(
                text = description,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
