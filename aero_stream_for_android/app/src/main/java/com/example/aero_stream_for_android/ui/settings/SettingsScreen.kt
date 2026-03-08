package com.example.aero_stream_for_android.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.WindowInsets
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.Bolt
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.DeleteSweep
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.GraphicEq
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.aero_stream_for_android.domain.model.AudioEngine
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.ui.components.AeroModalSheet
import com.example.aero_stream_for_android.ui.components.AeroSheetScaffold
import com.example.aero_stream_for_android.ui.components.AeroSheetSectionTitle
import com.example.aero_stream_for_android.ui.components.AeroSingleChoiceOptionRow
import com.example.aero_stream_for_android.ui.components.AeroTopBar
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens
import java.util.UUID

private data class SettingsOptionItem(
    val label: String,
    val selected: Boolean,
    val onClick: () -> Unit
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    onNavigateBack: () -> Unit = {},
    onNavigateToSmbBrowser: (String) -> Unit = {},
    viewModel: SettingsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var showAudioSheet by remember { mutableStateOf(false) }
    var showThemeSheet by remember { mutableStateOf(false) }
    var editorConfig by remember { mutableStateOf<SmbConfig?>(null) }
    var deleteTarget by remember { mutableStateOf<SmbConfig?>(null) }
    var refreshTargetConfigId by remember { mutableStateOf<String?>(null) }
    var showClearLoadedMusicConfirm by remember { mutableStateOf(false) }

    Scaffold(
        containerColor = MaterialTheme.colorScheme.background,
        contentWindowInsets = WindowInsets(0, 0, 0, 0),
        topBar = {
            AeroTopBar(
                title = "設定",
                onNavigateBack = onNavigateBack,
                modifier = Modifier.background(MaterialTheme.colorScheme.background)
            )
        }
    ) { paddingValues ->
        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues),
            contentPadding = PaddingValues(bottom = 80.dp)
        ) {
            item {
                SettingsSectionHeader("オーディオエンジン")
            }
            item {
                SettingsSelectionListItem(
                    title = "再生エンジン",
                    subtitle = when (uiState.audioEngine) {
                        AudioEngine.MEDIA3 -> "Media3 (ExoPlayer) - 推奨"
                        AudioEngine.MEDIA_PLAYER -> "MediaPlayer (標準API)"
                    },
                    leadingIcon = {
                        Icon(Icons.Default.GraphicEq, contentDescription = null)
                    },
                    onClick = { showAudioSheet = true }
                )
            }

            item {
                SettingsSectionHeader("テーマ")
            }
            item {
                SettingsSelectionListItem(
                    title = "テーマモード",
                    subtitle = when (uiState.themeMode) {
                        "dark" -> "ダーク"
                        "light" -> "ライト"
                        else -> "システム設定に従う"
                    },
                    leadingIcon = {
                        Icon(Icons.Default.DarkMode, contentDescription = null)
                    },
                    onClick = { showThemeSheet = true }
                )
            }

            item {
                SettingsSectionHeader("SMBサーバー")
            }
            item {
                SmbServersSection(
                    smbConfigs = uiState.smbConfigs,
                    selectedSmbConfigId = uiState.selectedSmbConfigId,
                    onSelect = viewModel::selectSmbConfig,
                    onAdd = {
                        viewModel.clearConnectionTestResult()
                        editorConfig = SmbConfig(
                            id = UUID.randomUUID().toString()
                        )
                    },
                    onEdit = { config ->
                        viewModel.clearConnectionTestResult()
                        editorConfig = config
                    },
                    onDelete = { deleteTarget = it },
                    onRefresh = { configId -> refreshTargetConfigId = configId },
                    onBrowse = onNavigateToSmbBrowser
                )
            }

            item {
                SettingsSectionHeader("データ管理")
            }
            item {
                ClearLoadedMusicDatabaseItem(
                    isClearing = uiState.isClearingLoadedMusicDatabase,
                    onClick = { showClearLoadedMusicConfirm = true }
                )
            }

            item {
                SettingsSectionHeader("情報")
            }
            item {
                ListItem(
                    headlineContent = { Text("バージョン") },
                    supportingContent = { Text("1.0") },
                    leadingContent = {
                        Icon(Icons.Default.Info, contentDescription = null)
                    }
                )
            }
        }
    }

    if (showAudioSheet) {
        SettingsOptionsSheet(
            title = "再生エンジン",
            options = listOf(
                SettingsOptionItem(
                    label = "Media3 (ExoPlayer)",
                    selected = uiState.audioEngine == AudioEngine.MEDIA3,
                    onClick = {
                        viewModel.setAudioEngine(AudioEngine.MEDIA3)
                        showAudioSheet = false
                    }
                ),
                SettingsOptionItem(
                    label = "MediaPlayer (標準API)",
                    selected = uiState.audioEngine == AudioEngine.MEDIA_PLAYER,
                    onClick = {
                        viewModel.setAudioEngine(AudioEngine.MEDIA_PLAYER)
                        showAudioSheet = false
                    }
                )
            ),
            onDismiss = { showAudioSheet = false }
        )
    }

    if (showThemeSheet) {
        SettingsOptionsSheet(
            title = "テーマモード",
            options = listOf(
                SettingsOptionItem(
                    label = "システム設定に従う",
                    selected = uiState.themeMode == "system",
                    onClick = {
                        viewModel.setThemeMode("system")
                        showThemeSheet = false
                    }
                ),
                SettingsOptionItem(
                    label = "ダーク",
                    selected = uiState.themeMode == "dark",
                    onClick = {
                        viewModel.setThemeMode("dark")
                        showThemeSheet = false
                    }
                ),
                SettingsOptionItem(
                    label = "ライト",
                    selected = uiState.themeMode == "light",
                    onClick = {
                        viewModel.setThemeMode("light")
                        showThemeSheet = false
                    }
                )
            ),
            onDismiss = { showThemeSheet = false }
        )
    }

    refreshTargetConfigId?.let { configId ->
        val config = uiState.smbConfigs.firstOrNull { it.id == configId }
        if (config != null) {
            SmbRefreshOptionsSheet(
                config = config,
                onDismiss = { refreshTargetConfigId = null },
                onQuickScan = {
                    viewModel.refreshSmbLibrary(config.id, quickScan = true)
                    refreshTargetConfigId = null
                },
                onFullScan = {
                    viewModel.refreshSmbLibrary(config.id, quickScan = false)
                    refreshTargetConfigId = null
                }
            )
        } else {
            refreshTargetConfigId = null
        }
    }

    editorConfig?.let { config ->
        SmbConfigEditorSheet(
            initialConfig = config,
            isTestingConnection = uiState.isTestingConnection,
            connectionTestResult = uiState.connectionTestResult,
            onDismiss = {
                viewModel.clearConnectionTestResult()
                editorConfig = null
            },
            onSave = { updated ->
                if (uiState.smbConfigs.any { it.id == updated.id }) {
                    viewModel.updateSmbConfig(updated)
                } else {
                    viewModel.addSmbConfig(updated)
                }
                editorConfig = null
                viewModel.clearConnectionTestResult()
            },
            onTestConnection = { updated ->
                viewModel.testSmbConnection(updated)
            },
            validateHostTarget = viewModel::validateHostTarget
        )
    }

    deleteTarget?.let { config ->
        AlertDialog(
            onDismissRequest = { deleteTarget = null },
            title = { Text("SMB設定を削除") },
            text = { Text("「${config.displayName}」を削除しますか？") },
            confirmButton = {
                TextButton(
                    onClick = {
                        viewModel.deleteSmbConfig(config.id)
                        deleteTarget = null
                    }
                ) {
                    Text("削除")
                }
            },
            dismissButton = {
                TextButton(onClick = { deleteTarget = null }) {
                    Text("キャンセル")
                }
            }
        )
    }

    if (showClearLoadedMusicConfirm) {
        ClearLoadedMusicDatabaseDialog(
            isClearing = uiState.isClearingLoadedMusicDatabase,
            onConfirm = {
                viewModel.clearLoadedMusicDatabase()
                showClearLoadedMusicConfirm = false
            },
            onDismiss = { showClearLoadedMusicConfirm = false }
        )
    }
}

@Composable
internal fun ClearLoadedMusicDatabaseItem(
    isClearing: Boolean,
    onClick: () -> Unit
) {
    ListItem(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(
                enabled = !isClearing,
                onClick = onClick
            ),
        headlineContent = { Text("読み込み済み曲DBをクリア") },
        supportingContent = {
            Text(
                if (isClearing) {
                    "クリア中..."
                } else {
                    "曲DB・ダウンロード履歴・キャッシュファイルを削除します"
                }
            )
        },
        leadingContent = {
            Icon(Icons.Default.DeleteSweep, contentDescription = null)
        }
    )
}

@Composable
internal fun ClearLoadedMusicDatabaseDialog(
    isClearing: Boolean,
    onConfirm: () -> Unit,
    onDismiss: () -> Unit
) {
    AlertDialog(
        onDismissRequest = {
            if (!isClearing) {
                onDismiss()
            }
        },
        title = { Text("読み込み済み曲DBをクリア") },
        text = { Text("曲DB・ダウンロード履歴・キャッシュファイルを削除します。よろしいですか？") },
        confirmButton = {
            TextButton(
                onClick = onConfirm,
                enabled = !isClearing
            ) {
                Text("クリア")
            }
        },
        dismissButton = {
            TextButton(
                onClick = onDismiss,
                enabled = !isClearing
            ) {
                Text("キャンセル")
            }
        }
    )
}

@Composable
private fun SettingsSelectionListItem(
    title: String,
    subtitle: String,
    leadingIcon: @Composable () -> Unit,
    onClick: () -> Unit
) {
    ListItem(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        headlineContent = { Text(title) },
        supportingContent = { Text(subtitle) },
        leadingContent = leadingIcon,
        trailingContent = {
            Icon(Icons.Default.ArrowDropDown, contentDescription = "Select")
        }
    )
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun SettingsOptionsSheet(
    title: String,
    options: List<SettingsOptionItem>,
    onDismiss: () -> Unit
) {
    AeroModalSheet(onDismissRequest = onDismiss) {
        AeroSheetScaffold(
            title = title,
            onDismiss = onDismiss
        ) {
            AeroSheetSectionTitle(text = "選択")
            options.forEach { option ->
                AeroSingleChoiceOptionRow(
                    label = option.label,
                    selected = option.selected,
                    onClick = option.onClick,
                    contentDescription = "$title: ${option.label}"
                )
            }
        }
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun SmbRefreshOptionsSheet(
    config: SmbConfig,
    onDismiss: () -> Unit,
    onQuickScan: () -> Unit,
    onFullScan: () -> Unit
) {
    AeroModalSheet(onDismissRequest = onDismiss) {
        AeroSheetScaffold(
            title = "${config.displayName.ifBlank { "SMB" }} を更新",
            onDismiss = onDismiss
        ) {
            SettingsRefreshOptionRow(
                title = "クイックスキャン",
                description = "変更された曲を優先して確認します。",
                icon = Icons.Default.Bolt,
                onClick = onQuickScan
            )
            SettingsRefreshOptionRow(
                title = "フルスキャン",
                description = "ライブラリ全体を最初から再確認します。",
                icon = Icons.Default.Refresh,
                onClick = onFullScan
            )
        }
    }
}

@Composable
private fun SettingsRefreshOptionRow(
    title: String,
    description: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    onClick: () -> Unit
) {
    ListItem(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(horizontal = 8.dp),
        headlineContent = { Text(title) },
        supportingContent = { Text(description) },
        leadingContent = { Icon(icon, contentDescription = null) }
    )
}

@Composable
private fun SettingsSectionHeader(title: String) {
    Text(
        text = title,
        style = AeroCompactUiTokens.sectionHeaderTextStyle(),
        color = MaterialTheme.colorScheme.primary,
        modifier = Modifier.padding(start = 16.dp, top = 24.dp, bottom = 8.dp)
    )
}
