package com.example.aero_stream_for_android.ui.settings

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.heightIn
import androidx.compose.foundation.layout.imePadding
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.ArrowDropDown
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.DarkMode
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.GraphicEq
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.ListItem
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.aero_stream_for_android.data.remote.smb.HostValidationResult
import com.example.aero_stream_for_android.data.remote.smb.SmbConnectionTestResult
import com.example.aero_stream_for_android.data.remote.smb.normalizeSmbRootPath
import com.example.aero_stream_for_android.data.remote.smb.validateSmbRootPathInput
import com.example.aero_stream_for_android.domain.model.AudioEngine
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens
import java.util.UUID
import kotlinx.coroutines.launch

private data class SettingsOptionItem(
    val label: String,
    val selected: Boolean,
    val onClick: () -> Unit
)

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(
    onNavigateBack: () -> Unit = {},
    viewModel: SettingsViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    var showAudioSheet by remember { mutableStateOf(false) }
    var showThemeSheet by remember { mutableStateOf(false) }
    var editorConfig by remember { mutableStateOf<SmbConfig?>(null) }
    var deleteTarget by remember { mutableStateOf<SmbConfig?>(null) }

    Scaffold(
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
                IconButton(onClick = onNavigateBack) {
                    Icon(Icons.AutoMirrored.Filled.ArrowBack, contentDescription = "Back")
                }
                Spacer(modifier = Modifier.width(4.dp))
                Text("設定", style = AeroCompactUiTokens.topAppBarTitleTextStyle())
            }
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
                    onDelete = { deleteTarget = it }
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
private fun SmbServersSection(
    smbConfigs: List<SmbConfig>,
    selectedSmbConfigId: String?,
    onSelect: (String) -> Unit,
    onAdd: () -> Unit,
    onEdit: (SmbConfig) -> Unit,
    onDelete: (SmbConfig) -> Unit
) {
    Column {
        if (smbConfigs.isEmpty()) {
            Text(
                text = "SMBサーバーはまだ登録されていません",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
            )
        } else {
            smbConfigs.forEach { config ->
                ListItem(
                    modifier = Modifier.clickable { onSelect(config.id) },
                    headlineContent = { Text(config.displayName) },
                    supportingContent = {
                        Text(
                            buildString {
                                append("${config.hostname}/${config.shareName}")
                                if (config.rootPath.isNotBlank()) {
                                    append("/${config.rootPath}")
                                }
                            }
                        )
                    },
                    leadingContent = {
                        if (selectedSmbConfigId == config.id) {
                            Icon(Icons.Default.Check, contentDescription = null)
                        } else {
                            Icon(Icons.Default.Storage, contentDescription = null)
                        }
                    },
                    trailingContent = {
                        Row {
                            IconButton(onClick = { onEdit(config) }) {
                                Icon(Icons.Default.Edit, contentDescription = "Edit")
                            }
                            IconButton(onClick = { onDelete(config) }) {
                                Icon(Icons.Default.Delete, contentDescription = "Delete")
                            }
                        }
                    }
                )
            }
        }

        TextButton(
            onClick = onAdd,
            modifier = Modifier.padding(horizontal = 8.dp, vertical = 4.dp)
        ) {
            Icon(Icons.Default.Add, contentDescription = null)
            Spacer(modifier = Modifier.width(8.dp))
            Text("SMBを追加")
        }
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun SettingsOptionsSheet(
    title: String,
    options: List<SettingsOptionItem>,
    onDismiss: () -> Unit
) {
    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface,
        dragHandle = null
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(top = 8.dp, bottom = 24.dp)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = title,
                    style = AeroCompactUiTokens.sortLabelTextStyle()
                )
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = "Close")
                }
            }

            HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.28f))
            Spacer(modifier = Modifier.height(10.dp))

            options.forEach { option ->
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .clickable(onClick = option.onClick)
                        .padding(horizontal = 20.dp, vertical = 16.dp),
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Box(
                        modifier = Modifier.width(28.dp),
                        contentAlignment = Alignment.CenterStart
                    ) {
                        if (option.selected) {
                            Icon(
                                Icons.Default.Check,
                                contentDescription = null,
                                tint = MaterialTheme.colorScheme.onSurface
                            )
                        }
                    }
                    Text(
                        text = option.label,
                        style = MaterialTheme.typography.headlineSmall,
                        color = if (option.selected) {
                            MaterialTheme.colorScheme.onSurface
                        } else {
                            MaterialTheme.colorScheme.onSurfaceVariant
                        }
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))
        }
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun SmbConfigEditorSheet(
    initialConfig: SmbConfig,
    isTestingConnection: Boolean,
    connectionTestResult: SmbConnectionTestResult?,
    onDismiss: () -> Unit,
    onSave: (SmbConfig) -> Unit,
    onTestConnection: (SmbConfig) -> Unit,
    validateHostTarget: suspend (String) -> HostValidationResult
) {
    val scope = rememberCoroutineScope()
    var displayName by rememberSaveable(initialConfig.id) { mutableStateOf(initialConfig.displayName) }
    var hostname by rememberSaveable(initialConfig.id) { mutableStateOf(initialConfig.hostname) }
    var port by rememberSaveable(initialConfig.id) { mutableStateOf(initialConfig.port.toString()) }
    var shareName by rememberSaveable(initialConfig.id) { mutableStateOf(initialConfig.shareName) }
    var rootPath by rememberSaveable(initialConfig.id) { mutableStateOf(initialConfig.rootPath) }
    var username by rememberSaveable(initialConfig.id) { mutableStateOf(initialConfig.username) }
    var password by rememberSaveable(initialConfig.id) { mutableStateOf(initialConfig.password) }
    var domain by rememberSaveable(initialConfig.id) { mutableStateOf(initialConfig.domain) }
    var showPassword by remember { mutableStateOf(false) }
    var pendingSaveConfig by remember { mutableStateOf<SmbConfig?>(null) }
    var saveWarningMessage by remember { mutableStateOf<String?>(null) }
    var isValidatingHost by remember { mutableStateOf(false) }
    var rootPathError by rememberSaveable(initialConfig.id) { mutableStateOf<String?>(null) }

    fun currentConfig(): SmbConfig {
        return initialConfig.copy(
            displayName = displayName.trim(),
            hostname = hostname.trim(),
            port = port.toIntOrNull() ?: 445,
            shareName = shareName.trim(),
            rootPath = normalizeSmbRootPath(rootPath),
            username = username.trim(),
            password = password,
            domain = domain.trim()
        )
    }

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        containerColor = MaterialTheme.colorScheme.surface,
        dragHandle = null
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(max = 720.dp)
                .navigationBarsPadding()
                .imePadding()
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 12.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = if (initialConfig.displayName.isBlank()) "SMBを追加" else "SMBを編集",
                    style = AeroCompactUiTokens.sortLabelTextStyle()
                )
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = "Close")
                }
            }

            HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.28f))

            LazyColumn(
                modifier = Modifier.fillMaxWidth(),
                contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 12.dp, bottom = 32.dp)
            ) {
                item {
                    OutlinedTextField(
                        value = displayName,
                        onValueChange = { displayName = it },
                        label = { Text("表示名") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = hostname,
                        onValueChange = { hostname = it },
                        label = { Text("ホスト名またはIPアドレス") },
                        singleLine = true,
                        placeholder = { Text("192.168.1.10 / nas.example.localdomain") },
                        supportingText = {
                            Column {
                                Text("DNS名/FQDN または IP アドレスを入力してください")
                                Text("ローカル機器名で解決できない場合は IP アドレスを使用してください")
                            }
                        },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = port,
                        onValueChange = { port = it },
                        label = { Text("ポート") },
                        singleLine = true,
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = shareName,
                        onValueChange = { shareName = it },
                        label = { Text("共有名") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = rootPath,
                        onValueChange = {
                            rootPath = it
                            rootPathError = null
                        },
                        label = { Text("開始フォルダ（任意）") },
                        singleLine = true,
                        isError = rootPathError != null,
                        placeholder = { Text("music/anime") },
                        supportingText = {
                            Column {
                                Text("共有名の下の相対フォルダを指定します")
                                Text("例: music/anime")
                                Text("未入力なら共有直下を使用します")
                                Text("共有名は含めず、その下のフォルダだけを入力してください")
                                rootPathError?.let {
                                    Text(it, color = MaterialTheme.colorScheme.error)
                                }
                            }
                        },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = username,
                        onValueChange = { username = it },
                        label = { Text("ユーザー名（任意）") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = password,
                        onValueChange = { password = it },
                        label = { Text("パスワード（任意）") },
                        singleLine = true,
                        visualTransformation = if (showPassword) VisualTransformation.None else PasswordVisualTransformation(),
                        trailingIcon = {
                            IconButton(onClick = { showPassword = !showPassword }) {
                                Icon(
                                    if (showPassword) Icons.Default.VisibilityOff else Icons.Default.Visibility,
                                    contentDescription = "Toggle password visibility"
                                )
                            }
                        },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    OutlinedTextField(
                        value = domain,
                        onValueChange = { domain = it },
                        label = { Text("ドメイン（任意）") },
                        singleLine = true,
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(16.dp))

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Button(
                            onClick = {
                                rootPathError = validateSmbRootPathInput(rootPath)
                                if (rootPathError == null) {
                                    onTestConnection(currentConfig())
                                }
                            },
                            enabled = !isTestingConnection && currentConfig().isConfigured
                        ) {
                            if (isTestingConnection) {
                                CircularProgressIndicator(
                                    modifier = Modifier.size(16.dp),
                                    strokeWidth = 2.dp
                                )
                                Spacer(modifier = Modifier.width(8.dp))
                            }
                            Text("接続テスト")
                        }
                    }

                    connectionTestResult?.let { result ->
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = if (result.success) "✓ ${result.summary}" else "✗ ${result.summary}",
                            color = if (result.success) MaterialTheme.colorScheme.primary else MaterialTheme.colorScheme.error,
                            style = MaterialTheme.typography.bodyMedium
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Text(
                            text = result.detail,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            style = MaterialTheme.typography.bodySmall,
                            modifier = Modifier.fillMaxWidth()
                        )
                    }

                    Spacer(modifier = Modifier.height(20.dp))

                    Button(
                        onClick = {
                            rootPathError = validateSmbRootPathInput(rootPath)
                            if (rootPathError == null) {
                                val candidate = currentConfig()
                                scope.launch {
                                    isValidatingHost = true
                                    val validation = validateHostTarget(candidate.hostname)
                                    isValidatingHost = false
                                    if (!validation.isIpAddress && !validation.isValid && validation.isLikelyShortLocalName) {
                                        pendingSaveConfig = candidate
                                        saveWarningMessage = validation.message
                                    } else {
                                        onSave(candidate)
                                    }
                                }
                            }
                        },
                        enabled = currentConfig().displayName.isNotBlank() &&
                            currentConfig().isConfigured &&
                            !isValidatingHost,
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        if (isValidatingHost) {
                            CircularProgressIndicator(
                                modifier = Modifier.size(16.dp),
                                strokeWidth = 2.dp
                            )
                            Spacer(modifier = Modifier.width(8.dp))
                            Text("確認中...")
                        } else {
                            Text("保存")
                        }
                    }
                }
            }
        }
    }

    pendingSaveConfig?.let { config ->
        AlertDialog(
            onDismissRequest = {
                pendingSaveConfig = null
                saveWarningMessage = null
            },
            title = { Text("ホスト名を確認してください") },
            text = {
                Text(
                    "このホスト名は現在の端末では解決できていない可能性があります。\n" +
                        "${saveWarningMessage.orEmpty()}\n" +
                        "接続できない場合は IP アドレスの使用を推奨します。\n" +
                        "このまま保存しますか？"
                )
            },
            confirmButton = {
                TextButton(
                    onClick = {
                        onSave(config)
                        pendingSaveConfig = null
                        saveWarningMessage = null
                    }
                ) {
                    Text("そのまま保存")
                }
            },
            dismissButton = {
                TextButton(
                    onClick = {
                        pendingSaveConfig = null
                        saveWarningMessage = null
                    }
                ) {
                    Text("IPに修正する")
                }
            }
        )
    }
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
