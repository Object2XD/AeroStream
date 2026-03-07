package com.example.aero_stream_for_android.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Slider
import androidx.compose.material3.SliderDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.example.aero_stream_for_android.domain.model.PlayerState
import com.example.aero_stream_for_android.domain.model.RepeatMode
import com.example.aero_stream_for_android.domain.model.isCacheDownloadEligible
import com.example.aero_stream_for_android.ui.theme.*

/**
 * フルスクリーンプレイヤー画面。
 * YouTube Music のフルスクリーンプレイヤーを模倣。
 */
@Composable
fun FullScreenPlayer(
    playerState: PlayerState,
    onPlayPause: () -> Unit,
    onSkipNext: () -> Unit,
    onSkipPrevious: () -> Unit,
    onSeek: (Long) -> Unit,
    onRepeatModeChange: () -> Unit,
    onShuffleToggle: () -> Unit,
    onDownload: (() -> Unit)? = null,
    onCollapse: () -> Unit,
    modifier: Modifier = Modifier
) {
    val song = playerState.currentSong ?: return

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(PlayerBackground)
            .padding(horizontal = 24.dp, vertical = 24.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // ヘッダーバー
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(vertical = 8.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            AeroIconActionButton(
                onClick = onCollapse,
                contentDescription = "Collapse",
                icon = {
                    Icon(
                        Icons.Default.KeyboardArrowDown,
                        contentDescription = null,
                        tint = White
                    )
                }
            )
            Spacer(modifier = Modifier.weight(1f))
            Text(
                text = "再生中",
                style = MaterialTheme.typography.titleSmall,
                color = LightGray
            )
            Spacer(modifier = Modifier.weight(1f))
            // SMBソースの場合、ダウンロードボタンを表示
            if (song.isCacheDownloadEligible && onDownload != null) {
                AeroIconActionButton(
                    onClick = onDownload,
                    contentDescription = "Download",
                    icon = {
                        Icon(
                            Icons.Default.Download,
                            contentDescription = null,
                            tint = White
                        )
                    }
                )
            } else {
                Spacer(modifier = Modifier.size(48.dp))
            }
        }

        Spacer(modifier = Modifier.weight(0.5f))

        // アルバムアート（大）
        if (song.albumArtUri != null) {
            AsyncImage(
                model = song.albumArtUri,
                contentDescription = "Album art",
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(1f)
                    .clip(RoundedCornerShape(8.dp)),
                contentScale = ContentScale.Crop
            )
        } else {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(1f)
                    .clip(RoundedCornerShape(8.dp))
                    .background(DarkSurface2),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    Icons.Default.MusicNote,
                    contentDescription = null,
                    modifier = Modifier.size(80.dp),
                    tint = MediumGray
                )
            }
        }

        Spacer(modifier = Modifier.height(24.dp))

        // 曲名とアーティスト
        Text(
            text = song.title,
            style = MaterialTheme.typography.titleLarge,
            color = White,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth()
        )
        Spacer(modifier = Modifier.height(4.dp))
        Text(
            text = song.artist,
            style = MaterialTheme.typography.bodyMedium,
            color = LightGray,
            maxLines = 1,
            overflow = TextOverflow.Ellipsis,
            textAlign = TextAlign.Center,
            modifier = Modifier.fillMaxWidth()
        )

        Spacer(modifier = Modifier.height(24.dp))

        // シークバー
        var sliderPosition by remember(playerState.currentPosition) {
            mutableFloatStateOf(playerState.currentPosition.toFloat())
        }
        var isDragging by remember { mutableStateOf(false) }

        Slider(
            value = if (isDragging) sliderPosition else playerState.currentPosition.toFloat(),
            onValueChange = {
                isDragging = true
                sliderPosition = it
            },
            onValueChangeFinished = {
                isDragging = false
                onSeek(sliderPosition.toLong())
            },
            valueRange = 0f..playerState.duration.toFloat().coerceAtLeast(1f),
            modifier = Modifier.fillMaxWidth(),
            colors = SliderDefaults.colors(
                thumbColor = White,
                activeTrackColor = White,
                inactiveTrackColor = SeekBarInactive
            )
        )

        // 時間表示
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(
                text = formatDuration(
                    if (isDragging) sliderPosition.toLong() else playerState.currentPosition
                ),
                style = MaterialTheme.typography.labelSmall,
                color = LightGray
            )
            Text(
                text = formatDuration(playerState.duration),
                style = MaterialTheme.typography.labelSmall,
                color = LightGray
            )
        }

        Spacer(modifier = Modifier.height(16.dp))

        // 再生コントロール
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceEvenly,
            verticalAlignment = Alignment.CenterVertically
        ) {
            // シャッフル
            AeroIconActionButton(
                onClick = onShuffleToggle,
                contentDescription = "Shuffle",
                icon = {
                    Icon(
                        Icons.Default.Shuffle,
                        contentDescription = null,
                        tint = if (playerState.isShuffleEnabled) AccentRed else LightGray,
                        modifier = Modifier.size(28.dp)
                    )
                }
            )

            // 前の曲
            AeroIconActionButton(
                onClick = onSkipPrevious,
                contentDescription = "Previous",
                modifier = Modifier.size(48.dp),
                icon = {
                    Icon(
                        Icons.Default.SkipPrevious,
                        contentDescription = null,
                        tint = White,
                        modifier = Modifier.size(36.dp)
                    )
                }
            )

            // 再生/一時停止
            AeroIconActionButton(
                onClick = onPlayPause,
                modifier = Modifier.size(64.dp),
                style = AeroIconActionStyle.Filled,
                filledColors = IconButtonDefaults.filledIconButtonColors(
                    containerColor = White,
                    contentColor = Black
                ),
                contentDescription = if (playerState.isPlaying) "Pause" else "Play",
                icon = {
                    Icon(
                        imageVector = if (playerState.isPlaying) Icons.Default.Pause else Icons.Default.PlayArrow,
                        contentDescription = null,
                        modifier = Modifier.size(36.dp)
                    )
                }
            )

            // 次の曲
            AeroIconActionButton(
                onClick = onSkipNext,
                contentDescription = "Next",
                modifier = Modifier.size(48.dp),
                icon = {
                    Icon(
                        Icons.Default.SkipNext,
                        contentDescription = null,
                        tint = White,
                        modifier = Modifier.size(36.dp)
                    )
                }
            )

            // リピート
            AeroIconActionButton(
                onClick = onRepeatModeChange,
                contentDescription = "Repeat",
                icon = {
                    Icon(
                        imageVector = when (playerState.repeatMode) {
                            RepeatMode.ONE -> Icons.Default.RepeatOne
                            else -> Icons.Default.Repeat
                        },
                        contentDescription = null,
                        tint = if (playerState.repeatMode != RepeatMode.OFF) AccentRed else LightGray,
                        modifier = Modifier.size(28.dp)
                    )
                }
            )
        }

        Spacer(modifier = Modifier.weight(1f))
    }
}

/**
 * ミリ秒を "mm:ss" 形式にフォーマットする。
 */
fun formatDuration(durationMs: Long): String {
    val totalSeconds = (durationMs / 1000).coerceAtLeast(0)
    val minutes = totalSeconds / 60
    val seconds = totalSeconds % 60
    return "%d:%02d".format(minutes, seconds)
}
