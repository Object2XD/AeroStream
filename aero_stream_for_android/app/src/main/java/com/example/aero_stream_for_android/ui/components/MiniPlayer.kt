package com.example.aero_stream_for_android.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.MusicNote
import androidx.compose.material.icons.filled.Pause
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.SkipNext
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.example.aero_stream_for_android.domain.model.PlayerState
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens
import com.example.aero_stream_for_android.ui.theme.MiniPlayerBackground

/**
 * 画面下部に表示されるミニプレイヤー。
 * YouTube Music のミニプレイヤーを模倣。
 */
@Composable
fun MiniPlayer(
    playerState: PlayerState,
    onPlayPause: () -> Unit,
    onSkipNext: () -> Unit,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    if (playerState.currentSong == null) return

    val song = playerState.currentSong
    val progress = if (playerState.duration > 0) {
        playerState.currentPosition.toFloat() / playerState.duration.toFloat()
    } else 0f

    Column(
        modifier = modifier
            .fillMaxWidth()
            .background(MiniPlayerBackground)
            .clickable(onClick = onClick)
    ) {
        // プログレスバー
        LinearProgressIndicator(
            progress = { progress },
            modifier = Modifier
                .fillMaxWidth()
                .height(2.dp),
            color = MaterialTheme.colorScheme.primary,
            trackColor = MaterialTheme.colorScheme.surfaceVariant
        )

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(
                    horizontal = AeroCompactUiTokens.miniPlayerRowPaddingHorizontal,
                    vertical = AeroCompactUiTokens.miniPlayerRowPaddingVertical
                ),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // アルバムアート
            if (song.albumArtUri != null) {
                AsyncImage(
                    model = song.albumArtUri,
                    contentDescription = "Album art",
                    modifier = Modifier
                        .size(AeroCompactUiTokens.miniPlayerArtworkSize)
                        .clip(RoundedCornerShape(6.dp)),
                    contentScale = ContentScale.Crop
                )
            } else {
                Box(
                    modifier = Modifier
                        .size(AeroCompactUiTokens.miniPlayerArtworkSize)
                        .clip(RoundedCornerShape(6.dp))
                        .background(MaterialTheme.colorScheme.surfaceVariant),
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        Icons.Default.MusicNote,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                    )
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
                    color = MaterialTheme.colorScheme.onSurface,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
                Text(
                    text = song.artist,
                    style = AeroCompactUiTokens.rowSubtitleTextStyle(),
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }

            // 再生/一時停止ボタン
            IconButton(onClick = onPlayPause) {
                Icon(
                    imageVector = if (playerState.isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                    contentDescription = if (playerState.isPlaying) "Pause" else "Play",
                    tint = MaterialTheme.colorScheme.onSurface
                )
            }

            // 次の曲ボタン
            IconButton(onClick = onSkipNext) {
                Icon(
                    Icons.Default.SkipNext,
                    contentDescription = "Next",
                    tint = MaterialTheme.colorScheme.onSurface
                )
            }
        }
    }
}
