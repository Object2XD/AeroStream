package com.example.aero_stream_for_android.ui.smb

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.aero_stream_for_android.ui.components.AeroEmptyState
import com.example.aero_stream_for_android.ui.components.AeroIconActionButton
import com.example.aero_stream_for_android.ui.components.AeroListRow
import com.example.aero_stream_for_android.ui.components.AeroPrimaryActionButton
import com.example.aero_stream_for_android.ui.components.AeroTopBar
import com.example.aero_stream_for_android.ui.components.AeroTopBarSearch
import com.example.aero_stream_for_android.ui.root.LocalPlayerSheetBottomClearance
import com.example.aero_stream_for_android.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SmbBrowserScreen(
    viewModel: SmbBrowserViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var isSearchMode by remember { mutableStateOf(false) }
    var searchQuery by remember { mutableStateOf("") }
    val playerSheetBottomClearance = LocalPlayerSheetBottomClearance.current

    val filteredDirectories = uiState.listing?.directories?.filter { dir ->
        dir.name.contains(searchQuery, ignoreCase = true) ||
            dir.path.contains(searchQuery, ignoreCase = true)
    }.orEmpty()
    val filteredAudioFiles = uiState.listing?.audioFiles?.filter { file ->
        file.name.contains(searchQuery, ignoreCase = true) ||
            file.path.contains(searchQuery, ignoreCase = true)
    }.orEmpty()

    fun closeSearch() {
        isSearchMode = false
        searchQuery = ""
    }

    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        contentWindowInsets = WindowInsets(0, 0, 0, 0),
        topBar = {
            if (isSearchMode) {
                AeroTopBarSearch(
                    value = searchQuery,
                    onValueChange = { searchQuery = it },
                    placeholderText = "現在のフォルダを検索",
                    onNavigateBack = ::closeSearch,
                    modifier = Modifier.background(MaterialTheme.colorScheme.background),
                    trailingIcon = {
                        if (searchQuery.isNotEmpty()) {
                            AeroIconActionButton(
                                onClick = { searchQuery = "" },
                                contentDescription = "検索文字列をクリア",
                                icon = { Icon(Icons.Default.Clear, contentDescription = null) }
                            )
                        }
                    }
                )
            } else {
                AeroTopBar(
                    title = "SMBブラウザ",
                    subtitle = uiState.currentPath.takeIf { it.isNotBlank() },
                    onNavigateBack = if (uiState.pathHistory.size > 1) {
                        { viewModel.navigateUp() }
                    } else {
                        null
                    },
                    modifier = Modifier.background(MaterialTheme.colorScheme.background),
                    actions = {
                        AeroIconActionButton(
                            onClick = { isSearchMode = true },
                            contentDescription = "検索",
                            icon = { Icon(Icons.Default.Search, contentDescription = null) }
                        )
                        Icon(
                            imageVector = if (uiState.isConnected) Icons.Default.Cloud else Icons.Default.CloudOff,
                            contentDescription = "Connection status",
                            tint = if (uiState.isConnected) {
                                MaterialTheme.colorScheme.onSurface
                            } else {
                                MaterialTheme.colorScheme.error
                            }
                        )
                    }
                )
            }
        }
    ) { paddingValues ->
        when {
            !uiState.smbConfig.isConfigured -> {
                // SMB未設定
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    AeroEmptyState(
                        title = "SMBサーバーが設定されていません",
                        description = "設定画面からSMBサーバーを設定してください",
                        icon = Icons.Default.SettingsEthernet
                    )
                }
            }

            uiState.isLoading -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    CircularProgressIndicator()
                }
            }

            uiState.error != null -> {
                Box(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        AeroEmptyState(
                            title = uiState.error!!,
                            icon = Icons.Default.ErrorOutline,
                            iconTint = MaterialTheme.colorScheme.error
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        AeroPrimaryActionButton(
                            text = "再試行",
                            onClick = { viewModel.browseTo(uiState.currentPath) }
                        )
                    }
                }
            }

            else -> {
                val listing = uiState.listing
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentPadding = PaddingValues(bottom = playerSheetBottomClearance + 8.dp)
                ) {
                    // ディレクトリ
                    if (listing != null) {
                        items(filteredDirectories) { dir ->
                            AeroListRow(
                                title = dir.name,
                                onClick = { viewModel.browseTo(dir.path) },
                                leading = {
                                    Icon(
                                        Icons.Default.Folder,
                                        contentDescription = "Folder",
                                        tint = SmbSourceColor,
                                        modifier = Modifier.size(40.dp)
                                    )
                                },
                                trailing = {
                                    Icon(
                                        Icons.Default.ChevronRight,
                                        contentDescription = null,
                                        tint = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            )
                        }

                        // 音楽ファイル
                        if (filteredAudioFiles.isNotEmpty()) {
                            item {
                                if (filteredDirectories.isNotEmpty()) {
                                    HorizontalDivider(modifier = Modifier.padding(vertical = 4.dp))
                                }
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(horizontal = 16.dp, vertical = 8.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Text(
                                        text = "音楽ファイル (${filteredAudioFiles.size})",
                                        style = AeroCompactUiTokens.sectionHeaderTextStyle(),
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }
                        }

                        items(filteredAudioFiles) { file ->
                            AeroListRow(
                                title = file.name,
                                subtitle = formatFileSize(file.size),
                                onClick = { viewModel.playSmbFile(file) },
                                leading = {
                                    Icon(
                                        Icons.Default.MusicNote,
                                        contentDescription = "Music",
                                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                                        modifier = Modifier.size(40.dp)
                                    )
                                },
                                trailing = {
                                    AeroIconActionButton(
                                        onClick = { viewModel.downloadFile(file) },
                                        contentDescription = "ダウンロード",
                                        icon = {
                                            Icon(
                                                Icons.Default.Download,
                                                contentDescription = null,
                                                tint = DownloadSourceColor
                                            )
                                        }
                                    )
                                }
                            )
                        }

                        // 空のディレクトリ
                        if (filteredDirectories.isEmpty() && filteredAudioFiles.isEmpty()) {
                            item {
                                Box(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .height(200.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Text(
                                        text = if (searchQuery.isBlank()) {
                                            "このフォルダは空です"
                                        } else {
                                            "\"$searchQuery\" に一致する項目はありません"
                                        },
                                        style = MaterialTheme.typography.bodyMedium,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

private fun formatFileSize(bytes: Long): String {
    return when {
        bytes < 1024 -> "$bytes B"
        bytes < 1024 * 1024 -> "%.1f KB".format(bytes / 1024.0)
        bytes < 1024 * 1024 * 1024 -> "%.1f MB".format(bytes / (1024.0 * 1024.0))
        else -> "%.1f GB".format(bytes / (1024.0 * 1024.0 * 1024.0))
    }
}
