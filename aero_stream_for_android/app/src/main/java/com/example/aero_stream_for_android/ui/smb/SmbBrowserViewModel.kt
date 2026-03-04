package com.example.aero_stream_for_android.ui.smb

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.download.DownloadManager
import com.example.aero_stream_for_android.data.remote.smb.SmbConnectionManager
import com.example.aero_stream_for_android.data.remote.smb.SmbDirectoryListing
import com.example.aero_stream_for_android.data.remote.smb.SmbFileInfo
import com.example.aero_stream_for_android.data.remote.smb.SmbMediaDataSource
import com.example.aero_stream_for_android.data.remote.smb.normalizeSmbRootPath
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.SmbConfig
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SmbBrowserUiState(
    val currentPath: String = "",
    val pathHistory: List<String> = listOf(""),
    val listing: SmbDirectoryListing? = null,
    val isLoading: Boolean = false,
    val isConnected: Boolean = false,
    val error: String? = null,
    val smbConfig: SmbConfig = SmbConfig()
)

@HiltViewModel
class SmbBrowserViewModel @Inject constructor(
    private val smbMediaDataSource: SmbMediaDataSource,
    private val smbConnectionManager: SmbConnectionManager,
    private val settingsRepository: SettingsRepository,
    private val musicRepository: MusicRepository,
    private val downloadManager: DownloadManager
) : ViewModel() {

    private val _uiState = MutableStateFlow(SmbBrowserUiState())
    val uiState: StateFlow<SmbBrowserUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            settingsRepository.migrateLegacySmbConfigIfNeeded()
            settingsRepository.selectedSmbConfig.collect { config ->
                val resolvedConfig = config ?: SmbConfig()
                val initialPath = normalizeSmbRootPath(resolvedConfig.rootPath)
                _uiState.update {
                    it.copy(
                        smbConfig = resolvedConfig,
                        currentPath = initialPath,
                        pathHistory = listOf(initialPath),
                        listing = null,
                        isConnected = false,
                        error = if (resolvedConfig.isConfigured) null else "SMBサーバーが設定されていません"
                    )
                }
                if (resolvedConfig.isConfigured) {
                    browseTo(initialPath)
                }
            }
        }
    }

    fun browseTo(path: String) {
        val config = _uiState.value.smbConfig
        val normalizedPath = normalizeSmbRootPath(path)
        if (!config.isConfigured) {
            _uiState.update { it.copy(error = "SMBサーバーが設定されていません") }
            return
        }

        viewModelScope.launch {
            _uiState.update { it.copy(isLoading = true, error = null) }
            try {
                val listing = smbMediaDataSource.listDirectory(config, normalizedPath)
                val history = if (_uiState.value.pathHistory.lastOrNull() == normalizedPath) {
                    _uiState.value.pathHistory
                } else if (normalizedPath.isEmpty()) {
                    listOf("")
                } else {
                    _uiState.value.pathHistory + normalizedPath
                }
                _uiState.update {
                    it.copy(
                        currentPath = normalizedPath,
                        pathHistory = history,
                        listing = listing,
                        isLoading = false,
                        isConnected = true
                    )
                }
            } catch (e: Exception) {
                _uiState.update {
                    it.copy(
                        isLoading = false,
                        isConnected = false,
                        error = smbConnectionManager.formatConnectionError(
                            config = config,
                            stage = if (normalizedPath.isBlank()) "ルート一覧取得" else "一覧取得: $normalizedPath",
                            throwable = e
                        )
                    )
                }
            }
        }
    }

    fun navigateUp(): Boolean {
        val history = _uiState.value.pathHistory
        val rootPath = normalizeSmbRootPath(_uiState.value.smbConfig.rootPath)
        if (history.size <= 1 || _uiState.value.currentPath == rootPath) return false
        val parentPath = history[history.size - 2]
        _uiState.update { it.copy(pathHistory = history.dropLast(1)) }
        browseTo(parentPath)
        return true
    }

    fun downloadFile(fileInfo: SmbFileInfo) {
        viewModelScope.launch {
            try {
                val song = smbMediaDataSource.toSong(fileInfo).copy(
                    smbConfigId = _uiState.value.smbConfig.id,
                    sourceUpdatedAt = System.currentTimeMillis()
                )
                val songId = musicRepository.insertSong(song)
                val smbConfigId = _uiState.value.smbConfig.id
                if (smbConfigId.isBlank()) {
                    _uiState.update { it.copy(error = "SMBサーバーが設定されていません") }
                    return@launch
                }
                downloadManager.startDownload(songId, fileInfo.path, smbConfigId)
            } catch (e: Exception) {
                _uiState.update { it.copy(error = "ダウンロード開始エラー: ${e.message}") }
            }
        }
    }

    fun playSmbFile(fileInfo: SmbFileInfo) {
        viewModelScope.launch {
            val song = smbMediaDataSource.toSong(fileInfo).copy(
                smbConfigId = _uiState.value.smbConfig.id,
                sourceUpdatedAt = System.currentTimeMillis()
            )
            val songId = musicRepository.insertSong(song)
            // PlayerViewModel経由で再生する
        }
    }
}
