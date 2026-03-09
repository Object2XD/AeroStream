package com.example.aero_stream_for_android.ui.settings

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
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
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Folder
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Storage
import androidx.compose.material.icons.filled.Visibility
import androidx.compose.material.icons.filled.VisibilityOff
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.saveable.rememberSaveable
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.text.input.VisualTransformation
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import com.example.aero_stream_for_android.data.remote.smb.HostValidationResult
import com.example.aero_stream_for_android.data.remote.smb.SmbConnectionTestResult
import com.example.aero_stream_for_android.data.remote.smb.normalizeSmbRootPath
import com.example.aero_stream_for_android.data.remote.smb.validateSmbRootPathInput
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.ui.components.AeroModalSheet
import com.example.aero_stream_for_android.ui.components.AeroSheetScaffold
import com.example.aero_stream_for_android.ui.components.AeroTextInput
import kotlinx.coroutines.launch

internal const val SMB_SECTION_TAG = "settings_smb_section"

@Composable
internal fun SmbServersSection(
    smbConfigs: List<SmbConfig>,
    onAdd: () -> Unit,
    onEdit: (SmbConfig) -> Unit,
    onDelete: (SmbConfig) -> Unit,
    onRefresh: (String) -> Unit,
    onBrowse: (String) -> Unit
) {
    Column(modifier = Modifier.testTag(SMB_SECTION_TAG)) {
        Text(
            text = "更新 / Browse は各SMB行から実行できます",
            style = MaterialTheme.typography.bodySmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier.padding(horizontal = 16.dp, vertical = 6.dp)
        )
        if (smbConfigs.isEmpty()) {
            Text(
                text = "SMBサーバーはまだ登録されていません",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant,
                modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp)
            )
        } else {
            smbConfigs.forEach { config ->
                SmbServerCard(
                    config = config,
                    onRefresh = { onRefresh(config.id) },
                    onBrowse = { onBrowse(config.id) },
                    onEdit = { onEdit(config) },
                    onDelete = { onDelete(config) }
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
private fun SmbServerCard(
    config: SmbConfig,
    onRefresh: () -> Unit,
    onBrowse: () -> Unit,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    val hostShare = "${config.hostname}/${config.shareName}"
    val rootPathLabel = config.rootPath.ifBlank { null }?.let { "/$it" }
    val topDescription = buildString {
        append("${config.displayName} ")
        append(hostShare)
        rootPathLabel?.let { append(" $it") }
    }

    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .heightIn(min = 56.dp)
                .semantics(mergeDescendants = true) {
                    contentDescription = topDescription
                }
                .padding(horizontal = 4.dp, vertical = 10.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .width(36.dp)
                    .testTag("smb_${config.id}_status_icon"),
                contentAlignment = Alignment.CenterStart
            ) {
                Icon(
                    imageVector = Icons.Default.Storage,
                    contentDescription = null
                )
            }

            Column(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 8.dp)
            ) {
                Text(
                    text = config.displayName.ifBlank { "SMB" },
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    style = MaterialTheme.typography.titleMedium,
                    modifier = Modifier.testTag("smb_${config.id}_title")
                )
                Text(
                    text = hostShare,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis,
                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                    style = MaterialTheme.typography.bodyMedium
                )
                rootPathLabel?.let { root ->
                    Text(
                        text = root,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }

            Box(
                modifier = Modifier
                    .width(58.dp)
                    .testTag("smb_${config.id}_top_anchor"),
                contentAlignment = Alignment.CenterEnd
            ) {}
        }

        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 4.dp, vertical = 8.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp)
        ) {
            SmbActionButton(
                modifier = Modifier.weight(1f),
                icon = { Icon(Icons.Default.Refresh, contentDescription = null, modifier = Modifier.size(20.dp)) },
                contentDescription = "更新: ${config.displayName}",
                onClick = onRefresh
            )
            SmbActionButton(
                modifier = Modifier.weight(1f),
                icon = { Icon(Icons.Default.Folder, contentDescription = null, modifier = Modifier.size(20.dp)) },
                contentDescription = "Browse: ${config.displayName}",
                onClick = onBrowse
            )
            SmbActionButton(
                modifier = Modifier.weight(1f),
                icon = { Icon(Icons.Default.Edit, contentDescription = null, modifier = Modifier.size(20.dp)) },
                contentDescription = "編集: ${config.displayName}",
                onClick = onEdit
            )
            OutlinedButton(
                modifier = Modifier
                    .weight(1f)
                    .heightIn(min = 48.dp)
                    .semantics {
                        contentDescription = "削除: ${config.displayName}"
                    },
                onClick = onDelete
            ) {
                Icon(
                    Icons.Default.Delete,
                    contentDescription = null,
                    modifier = Modifier.size(20.dp),
                    tint = MaterialTheme.colorScheme.error
                )
            }
        }

        HorizontalDivider(color = MaterialTheme.colorScheme.outline.copy(alpha = 0.28f))
    }
}

@Composable
private fun SmbActionButton(
    modifier: Modifier = Modifier,
    icon: @Composable () -> Unit,
    contentDescription: String,
    onClick: () -> Unit
) {
    FilledTonalButton(
        modifier = modifier
            .heightIn(min = 48.dp)
            .semantics {
                this.contentDescription = contentDescription
            },
        onClick = onClick
    ) {
        icon()
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
internal fun SmbConfigEditorSheet(
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

    AeroModalSheet(onDismissRequest = onDismiss) {
        AeroSheetScaffold(
            title = if (initialConfig.displayName.isBlank()) "SMBを追加" else "SMBを編集",
            onDismiss = onDismiss
        ) {
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .heightIn(max = 720.dp)
                    .navigationBarsPadding()
                    .imePadding(),
                contentPadding = PaddingValues(start = 20.dp, end = 20.dp, top = 12.dp, bottom = 32.dp)
            ) {
                item {
                    AeroTextInput(
                        value = displayName,
                        onValueChange = { displayName = it },
                        label = { Text("表示名") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    AeroTextInput(
                        value = hostname,
                        onValueChange = { hostname = it },
                        label = { Text("ホスト名またはIPアドレス") },
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
                    AeroTextInput(
                        value = port,
                        onValueChange = { port = it },
                        label = { Text("ポート") },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Number),
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    AeroTextInput(
                        value = shareName,
                        onValueChange = { shareName = it },
                        label = { Text("共有名") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    AeroTextInput(
                        value = rootPath,
                        onValueChange = {
                            rootPath = it
                            rootPathError = null
                        },
                        label = { Text("開始フォルダ（任意）") },
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
                    AeroTextInput(
                        value = username,
                        onValueChange = { username = it },
                        label = { Text("ユーザー名（任意）") },
                        modifier = Modifier.fillMaxWidth()
                    )
                    Spacer(modifier = Modifier.height(8.dp))
                    AeroTextInput(
                        value = password,
                        onValueChange = { password = it },
                        label = { Text("パスワード（任意）") },
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
                    AeroTextInput(
                        value = domain,
                        onValueChange = { domain = it },
                        label = { Text("ドメイン（任意）") },
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
