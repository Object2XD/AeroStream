package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.combinedClickable
import androidx.compose.foundation.ExperimentalFoundationApi
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Album
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Cloud
import androidx.compose.material.icons.filled.Download
import androidx.compose.material.icons.filled.Equalizer
import androidx.compose.material.icons.filled.MoreVert
import androidx.compose.material.icons.filled.MusicNote
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.SongCacheStatus
import com.example.aero_stream_for_android.domain.model.cacheStatus
import com.example.aero_stream_for_android.domain.model.isCacheDownloadEligible
import com.example.aero_stream_for_android.ui.components.AeroCard
import com.example.aero_stream_for_android.ui.components.AeroModalSheet
import com.example.aero_stream_for_android.ui.components.AeroSheetScaffold
import com.example.aero_stream_for_android.ui.theme.AccentRed
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens
import com.example.aero_stream_for_android.ui.theme.Black

internal data class LibraryRowMenuItem(
    val id: String,
    val label: String,
    val onClick: () -> Unit,
    val enabled: Boolean = true,
    val isDestructive: Boolean = false,
    val leadingIcon: ImageVector? = null
)

enum class LibrarySongRowStyle {
    WithStatusBadge,
    CompactNoBadge
}

@Composable
@OptIn(ExperimentalFoundationApi::class)
internal fun LibraryAlbumRow(
    albumName: String,
    subtitle: String,
    albumArtUri: Any?,
    onClick: () -> Unit,
    menuItems: List<LibraryRowMenuItem> = emptyList(),
    showStatusBadge: Boolean = false,
    isFullyCached: Boolean = false
) {
    var menuExpanded by remember { mutableStateOf(false) }
    val hasMenu = menuItems.hasMenuItems()
    val rowModifier = Modifier.libraryRowClickable(
        hasMenu = hasMenu,
        onClick = onClick,
        onOpenMenu = { menuExpanded = true }
    )

    Row(
        modifier = rowModifier
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        MediaArtwork(imageModel = albumArtUri, placeholder = Icons.Default.Album)
        Column(
            modifier = Modifier
                .weight(1f)
                .padding(start = 12.dp)
        ) {
            Text(text = albumName, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Row(verticalAlignment = Alignment.CenterVertically) {
                if (showStatusBadge) {
                    AlbumCacheBadge(isFullyCached = isFullyCached)
                    Spacer(modifier = Modifier.width(6.dp))
                }
                Text(
                    text = subtitle,
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
        if (hasMenu) {
            LibraryRowOverflowMenu(
                menuItems = menuItems,
                title = albumName,
                expanded = menuExpanded,
                onExpandedChange = { menuExpanded = it }
            )
        }
    }
}

@Composable
@OptIn(ExperimentalFoundationApi::class)
internal fun LibrarySongRow(
    song: Song,
    onClick: () -> Unit,
    menuItems: List<LibraryRowMenuItem> = emptyList(),
    isPlaying: Boolean = false,
    showDownloadIcon: Boolean = false,
    style: LibrarySongRowStyle = LibrarySongRowStyle.WithStatusBadge,
    modifier: Modifier = Modifier
) {
    var menuExpanded by remember { mutableStateOf(false) }
    val hasMenu = menuItems.hasMenuItems()
    val rowModifier = modifier.libraryRowClickable(
        hasMenu = hasMenu,
        onClick = onClick,
        onOpenMenu = { menuExpanded = true }
    )

    Row(
        modifier = rowModifier.padding(
            horizontal = AeroCompactUiTokens.screenHorizontalPadding,
            vertical = AeroCompactUiTokens.listRowVerticalPadding
        ),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Box(
            modifier = Modifier
                .size(AeroCompactUiTokens.listArtworkSize)
                .clip(RoundedCornerShape(10.dp))
        ) {
            if (song.albumArtUri != null) {
                AsyncImage(
                    model = song.albumArtUri,
                    contentDescription = "Album art",
                    modifier = Modifier.fillMaxWidth().height(AeroCompactUiTokens.listArtworkSize),
                    contentScale = ContentScale.Crop
                )
            } else {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(AeroCompactUiTokens.listArtworkSize)
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

            if (isPlaying) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(AeroCompactUiTokens.listArtworkSize)
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
                if (style == LibrarySongRowStyle.WithStatusBadge) {
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
                    text = "${song.artist} · ${formatSongDuration(song.duration)}",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }

        if (showDownloadIcon && song.isCacheDownloadEligible) {
            IconButton(onClick = { /* Download action */ }) {
                Icon(
                    imageVector = Icons.Default.Download,
                    contentDescription = "Download",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(AeroCompactUiTokens.listOverflowIconSize)
                )
            }
        }

        if (hasMenu) {
            LibraryRowOverflowMenu(
                menuItems = menuItems,
                title = song.title,
                expanded = menuExpanded,
                onExpandedChange = { menuExpanded = it }
            )
        }
    }
}

@Composable
@OptIn(ExperimentalFoundationApi::class)
internal fun LibraryArtistRow(
    artistName: String,
    songCount: Int,
    onClick: (() -> Unit)? = null,
    menuItems: List<LibraryRowMenuItem> = emptyList()
) {
    var menuExpanded by remember { mutableStateOf(false) }
    val hasMenu = menuItems.hasMenuItems()
    val rowModifier = if (onClick != null) {
        Modifier.libraryRowClickable(
            hasMenu = hasMenu,
            onClick = onClick,
            onOpenMenu = { menuExpanded = true }
        )
    } else {
        Modifier.fillMaxWidth()
    }

    Row(
        modifier = rowModifier
            .padding(horizontal = 16.dp, vertical = 8.dp),
        verticalAlignment = Alignment.CenterVertically
    ) {
        Surface(
            modifier = Modifier.size(AeroCompactUiTokens.listArtworkSize),
            shape = androidx.compose.foundation.shape.CircleShape,
            color = MaterialTheme.colorScheme.surfaceVariant
        ) {
            Box(contentAlignment = Alignment.Center) {
                Icon(Icons.Default.Person, contentDescription = null)
            }
        }
        Column(
            modifier = Modifier
                .weight(1f)
                .padding(start = 12.dp)
        ) {
            Text(text = artistName, maxLines = 1, overflow = TextOverflow.Ellipsis)
            Text(
                text = "アーティスト・${songCount}曲",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        if (hasMenu) {
            LibraryRowOverflowMenu(
                menuItems = menuItems,
                title = "メニュー",
                expanded = menuExpanded,
                onExpandedChange = { menuExpanded = it }
            )
        }
    }
}

@Composable
internal fun LibraryEmptyState(title: String) {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .height(260.dp),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = title,
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}

@Composable
private fun LibraryRowOverflowMenu(
    menuItems: List<LibraryRowMenuItem>,
    title: String,
    expanded: Boolean,
    onExpandedChange: (Boolean) -> Unit
) {
    Box {
        IconButton(onClick = { onExpandedChange(true) }) {
            Icon(
                imageVector = Icons.Default.MoreVert,
                contentDescription = "More options"
            )
        }
        if (expanded) {
            AeroModalSheet(onDismissRequest = { onExpandedChange(false) }) {
                AeroSheetScaffold(
                    title = title,
                    onDismiss = { onExpandedChange(false) }
                ) {
                    menuItems.forEach { item ->
                        AeroCard(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(horizontal = 20.dp, vertical = 6.dp),
                            onClick = if (item.enabled) {
                                {
                                    onExpandedChange(false)
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
    }
}

@OptIn(ExperimentalFoundationApi::class)
private fun Modifier.libraryRowClickable(
    hasMenu: Boolean,
    onClick: () -> Unit,
    onOpenMenu: () -> Unit
): Modifier = fillMaxWidth().combinedClickable(
    onClick = onClick,
    onLongClick = if (hasMenu) onOpenMenu else null
)

private fun List<LibraryRowMenuItem>.hasMenuItems(): Boolean = isNotEmpty()

private fun formatSongDuration(durationMs: Long): String {
    val totalSeconds = (durationMs / 1000).coerceAtLeast(0)
    val minutes = totalSeconds / 60
    val seconds = totalSeconds % 60
    return "%d:%02d".format(minutes, seconds)
}
