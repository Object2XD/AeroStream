package com.example.aero_stream_for_android.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Equalizer
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.MusicNote
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.SongCacheStatus
import com.example.aero_stream_for_android.domain.model.cacheStatus
import com.example.aero_stream_for_android.domain.model.isCacheDownloadEligible
import com.example.aero_stream_for_android.ui.theme.AccentRed
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens
import com.example.aero_stream_for_android.ui.theme.Black

enum class SongListItemStyle {
    WithStatusBadge,
    CompactNoBadge
}

/**
 * 楽曲リストのアイテムコンポーネント。
 */
@Composable
fun SongListItem(
    song: Song,
    onClick: () -> Unit,
    onMoreClick: (() -> Unit)? = null,
    isPlaying: Boolean = false,
    showDownloadIcon: Boolean = false,
    style: SongListItemStyle = SongListItemStyle.WithStatusBadge,
    modifier: Modifier = Modifier
) {
    Row(
        modifier = modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(
                horizontal = AeroCompactUiTokens.screenHorizontalPadding,
                vertical = AeroCompactUiTokens.listRowVerticalPadding
            ),
        verticalAlignment = Alignment.CenterVertically
    ) {
        // メディアアート（アルバム行と同じ密度）
        Box(
            modifier = Modifier
                .size(AeroCompactUiTokens.listArtworkSize)
                .clip(RoundedCornerShape(10.dp))
        ) {
            if (song.albumArtUri != null) {
                AsyncImage(
                    model = song.albumArtUri,
                    contentDescription = "Album art",
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
            } else {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(MaterialTheme.colorScheme.surfaceVariant),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.MusicNote,
                        contentDescription = null,
                        modifier = Modifier.size(AeroCompactUiTokens.listOverflowIconSize),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // 再生中インジケーター
            if (isPlaying) {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .background(Black.copy(alpha = 0.5f)),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Equalizer,
                        contentDescription = "Playing",
                        modifier = Modifier.size(AeroCompactUiTokens.listOverflowIconSize),
                        tint = AccentRed
                    )
                }
            }
        }

        Column(
            modifier = Modifier
                .weight(1f)
                .padding(
                    start = 12.dp,
                    end = AeroCompactUiTokens.listTextEndPadding
                )
        ) {
            Text(
                text = song.title,
                color = if (isPlaying) AccentRed else MaterialTheme.colorScheme.onSurface,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (style == SongListItemStyle.WithStatusBadge) {
                    when (song.cacheStatus) {
                        SongCacheStatus.CACHED -> {
                            Icon(
                                imageVector = Icons.Default.CheckCircle,
                                contentDescription = "Downloaded",
                                modifier = Modifier.size(AeroCompactUiTokens.statusBadgeIconSize),
                                tint = MaterialTheme.colorScheme.onSurface
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                        }

                        SongCacheStatus.SMB_NOT_CACHED -> {
                            Icon(
                                imageVector = Icons.Default.Cloud,
                                contentDescription = "SMB",
                                modifier = Modifier.size(AeroCompactUiTokens.statusBadgeIconSize),
                                tint = MaterialTheme.colorScheme.onSurface
                            )
                            Spacer(modifier = Modifier.width(6.dp))
                        }

                        SongCacheStatus.NONE -> Unit
                    }
                }
                Text(
                    text = "${song.artist} · ${formatDuration(song.duration)}",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        // ダウンロードアイコン（SMBソースの場合）
        if (showDownloadIcon && song.isCacheDownloadEligible) {
            IconButton(onClick = { /* ダウンロード処理 */ }) {
                Icon(
                    imageVector = Icons.Default.Download,
                    contentDescription = "Download",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(AeroCompactUiTokens.listOverflowIconSize)
                )
            }
        }

        // メニューボタン
        if (onMoreClick != null) {
            IconButton(onClick = onMoreClick) {
                Icon(
                    imageVector = Icons.Default.MoreVert,
                    contentDescription = "More options",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(AeroCompactUiTokens.listOverflowIconSize)
                )
            }
        }
    }
}
