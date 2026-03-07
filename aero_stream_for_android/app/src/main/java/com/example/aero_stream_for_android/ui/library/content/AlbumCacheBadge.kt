package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.foundation.layout.size
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
internal fun AlbumCacheBadge(
    isFullyCached: Boolean,
    modifier: Modifier = Modifier
) {
    val (icon, description) = if (isFullyCached) {
        Icons.Default.CheckCircle to "アルバムはキャッシュ済み"
    } else {
        Icons.Default.Cloud to "アルバムに未キャッシュ曲あり"
    }
    Icon(
        imageVector = icon,
        contentDescription = description,
        tint = MaterialTheme.colorScheme.onSurface,
        modifier = modifier.size(AeroCompactUiTokens.statusBadgeIconSize)
    )
}
