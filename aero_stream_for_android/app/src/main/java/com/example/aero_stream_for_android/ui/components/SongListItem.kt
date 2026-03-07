package com.example.aero_stream_for_android.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.theme.*

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
        // アルバムアート
        Box(
            modifier = Modifier
                .size(AeroCompactUiTokens.miniPlayerArtworkSize)
                .clip(RoundedCornerShape(6.dp))
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
                        Icons.Default.MusicNote,
                        contentDescription = null,
                        modifier = Modifier.size(20.dp),
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
                        Icons.Default.Equalizer,
                        contentDescription = "Playing",
                        modifier = Modifier.size(18.dp),
                        tint = AccentRed
                    )
                }
            }
        }

        // 曲情報
        Column(
            modifier = Modifier
                .weight(1f)
                .padding(horizontal = AeroCompactUiTokens.miniPlayerTextPaddingHorizontal)
        ) {
            Text(
                text = song.title,
                style = AeroCompactUiTokens.rowTitleTextStyle(),
                color = if (isPlaying) AccentRed else MaterialTheme.colorScheme.onSurface,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Row(verticalAlignment = Alignment.CenterVertically) {
                // ソースバッジ
                when {
                    song.isCached -> {
                        Icon(
                            Icons.Default.CheckCircle,
                            contentDescription = "Downloaded",
                            modifier = Modifier.size(10.dp),
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                    }
                    song.source == MusicSource.SMB -> {
                        Icon(
                            Icons.Default.Cloud,
                            contentDescription = "SMB",
                            modifier = Modifier.size(10.dp),
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                        Spacer(modifier = Modifier.width(4.dp))
                    }
                }
                Text(
                    text = "${song.artist} · ${formatDuration(song.duration)}",
                    style = AeroCompactUiTokens.rowSubtitleTextStyle(),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        // ダウンロードアイコン（SMBソースの場合）
        if (showDownloadIcon && song.source == MusicSource.SMB && !song.isCached) {
            IconButton(onClick = { /* ダウンロード処理 */ }) {
                Icon(
                    Icons.Default.Download,
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
                    Icons.Default.MoreVert,
                    contentDescription = "More options",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(AeroCompactUiTokens.listOverflowIconSize)
                )
            }
        }
    }
}
