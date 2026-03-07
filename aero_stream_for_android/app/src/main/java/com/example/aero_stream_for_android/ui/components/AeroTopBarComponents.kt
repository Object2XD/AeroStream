package com.example.aero_stream_for_android.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.RowScope
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun AeroTopBar(
    title: String,
    onNavigateBack: (() -> Unit)?,
    modifier: Modifier = Modifier,
    subtitle: String? = null,
    actions: @Composable RowScope.() -> Unit = {}
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(
                start = AeroCompactUiTokens.screenHorizontalPadding,
                end = AeroCompactUiTokens.screenHorizontalPadding,
                top = AeroCompactUiTokens.headerTopPadding,
                bottom = AeroCompactUiTokens.headerBottomPadding
            ),
        verticalAlignment = Alignment.CenterVertically
    ) {
        if (onNavigateBack != null) {
            AeroIconActionButton(
                onClick = onNavigateBack,
                contentDescription = "戻る",
                icon = { Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null) }
            )
            Spacer(modifier = Modifier.size(4.dp))
        }

        Column(modifier = Modifier.weight(1f)) {
            Text(
                text = title,
                style = AeroCompactUiTokens.topAppBarTitleTextStyle(),
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            if (!subtitle.isNullOrBlank()) {
                Text(
                    text = subtitle,
                    style = AeroCompactUiTokens.headerTertiaryTextStyle(),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        Row(
            horizontalArrangement = Arrangement.spacedBy(4.dp),
            verticalAlignment = Alignment.CenterVertically,
            content = actions
        )
    }
}

@Composable
fun AeroTopBarSearch(
    value: String,
    onValueChange: (String) -> Unit,
    placeholderText: String,
    onNavigateBack: () -> Unit,
    modifier: Modifier = Modifier,
    trailingIcon: @Composable (() -> Unit)? = null
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .padding(
                start = AeroCompactUiTokens.screenHorizontalPadding,
                end = AeroCompactUiTokens.screenHorizontalPadding,
                top = AeroCompactUiTokens.headerTopPadding,
                bottom = AeroCompactUiTokens.headerBottomPadding
            ),
        verticalAlignment = Alignment.CenterVertically
    ) {
        AeroIconActionButton(
            onClick = onNavigateBack,
            contentDescription = "戻る",
            icon = { Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = null) }
        )
        Spacer(modifier = Modifier.size(4.dp))
        AeroSearchField(
            value = value,
            onValueChange = onValueChange,
            placeholder = {
                Text(
                    text = placeholderText,
                    maxLines = 1,
                    softWrap = false,
                    overflow = TextOverflow.Ellipsis
                )
            },
            trailingIcon = trailingIcon,
            modifier = Modifier.weight(1f)
        )
    }
}
