package com.example.aero_stream_for_android.ui.smb

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
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
import com.example.aero_stream_for_android.ui.components.formatDuration
import com.example.aero_stream_for_android.ui.theme.*

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SmbBrowserScreen(
    onNavigateToPlayer: () -> Unit = {},
    viewModel: SmbBrowserViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var isSearchMode by remember { mutableStateOf(false) }
    var searchQuery by remember { mutableStateOf("") }

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
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(MaterialTheme.colorScheme.background)
                    .padding(
                        start = AeroCompactUiTokens.screenHorizontalPadding,
                        end = AeroCompactUiTokens.screenHorizontalPadding,
                        top = AeroCompactUiTokens.headerTopPadding,
                        bottom = AeroCompactUiTokens.headerBottomPadding
                    ),
                verticalAlignment = Alignment.CenterVertically
            ) {
                if (uiState.pathHistory.size > 1) {
                    IconButton(onClick = { viewModel.navigateUp() }) {
                        Icon(Icons.Default.ArrowBack, contentDescription = "Back")
                    }
                    Spacer(modifier = Modifier.width(4.dp))
                }

                if (isSearchMode) {
                    OutlinedTextField(
                        value = searchQuery,
                        onValueChange = { searchQuery = it },
                        singleLine = true,
                        placeholder = { Text("現在のフォルダを検索") },
                        leadingIcon = {
                            Icon(Icons.Default.Search, contentDescription = null)
                        },
                        trailingIcon = {
                            if (searchQuery.isNotEmpty()) {
                                IconButton(onClick = { searchQuery = "" }) {
                                    Icon(Icons.Default.Clear, contentDescription = "Clear")
                                }
                            }
                        },
                        modifier = Modifier.weight(1f)
                    )
                } else {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("SMBブラウザ", style = AeroCompactUiTokens.topAppBarTitleTextStyle())
                        if (uiState.currentPath.isNotEmpty()) {
                            Text(
                                text = uiState.currentPath,
                                style = AeroCompactUiTokens.headerTertiaryTextStyle(),
                                color = MaterialTheme.colorScheme.onSurfaceVariant,
                                maxLines = 1,
                                overflow = TextOverflow.Ellipsis
                            )
                        }
                    }
                }

                Spacer(modifier = Modifier.width(8.dp))
                IconButton(onClick = {
                    if (isSearchMode) closeSearch() else isSearchMode = true
                }) {
                    Icon(
                        if (isSearchMode) Icons.Default.Close else Icons.Default.Search,
                        contentDescription = if (isSearchMode) "Close search" else "Search"
                    )
                }
                Icon(
                    imageVector = if (uiState.isConnected) Icons.Default.Cloud else Icons.Default.CloudOff,
                    contentDescription = "Connection status",
                    tint = if (uiState.isConnected) SmbSourceColor else MaterialTheme.colorScheme.error
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
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            Icons.Default.SettingsEthernet,
                            contentDescription = null,
                            modifier = Modifier.size(AeroCompactUiTokens.emptyStateIconSize),
                            tint = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = "SMBサーバーが設定されていません",
                            style = MaterialTheme.typography.titleMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "設定画面からSMBサーバーを設定してください",
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.onSurfaceVariant
                        )
                    }
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
                        Icon(
                            Icons.Default.ErrorOutline,
                            contentDescription = null,
                            modifier = Modifier.size(AeroCompactUiTokens.emptyStateIconSize),
                            tint = MaterialTheme.colorScheme.error
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Text(
                            text = uiState.error!!,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.error
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(onClick = { viewModel.browseTo(uiState.currentPath) }) {
                            Text("再試行")
                        }
                    }
                }
            }

            else -> {
                val listing = uiState.listing
                LazyColumn(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(paddingValues),
                    contentPadding = PaddingValues(bottom = 80.dp)
                ) {
                    // ディレクトリ
                    if (listing != null) {
                        items(filteredDirectories) { dir ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { viewModel.browseTo(dir.path) }
                                    .padding(horizontal = 16.dp, vertical = 12.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    Icons.Default.Folder,
                                    contentDescription = "Folder",
                                    tint = SmbSourceColor,
                                    modifier = Modifier.size(40.dp)
                                )
                                Text(
                                    text = dir.name,
                                    style = MaterialTheme.typography.bodyMedium,
                                    modifier = Modifier
                                        .weight(1f)
                                        .padding(horizontal = 12.dp),
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis
                                )
                                Icon(
                                    Icons.Default.ChevronRight,
                                    contentDescription = null,
                                    tint = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
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
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { viewModel.playSmbFile(file) }
                                    .padding(horizontal = 16.dp, vertical = 8.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    Icons.Default.MusicNote,
                                    contentDescription = "Music",
                                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                                    modifier = Modifier.size(40.dp)
                                )
                                Column(
                                    modifier = Modifier
                                        .weight(1f)
                                        .padding(horizontal = 12.dp)
                                ) {
                                    Text(
                                        text = file.name,
                                        style = MaterialTheme.typography.bodyMedium,
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                    Text(
                                        text = formatFileSize(file.size),
                                        style = MaterialTheme.typography.bodySmall,
                                        color = MaterialTheme.colorScheme.onSurfaceVariant
                                    )
                                }
                                IconButton(onClick = { viewModel.downloadFile(file) }) {
                                    Icon(
                                        Icons.Default.Download,
                                        contentDescription = "Download",
                                        tint = DownloadSourceColor
                                    )
                                }
                            }
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
