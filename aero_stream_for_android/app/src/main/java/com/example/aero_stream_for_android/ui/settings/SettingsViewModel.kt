package com.example.aero_stream_for_android.ui.settings

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.remote.smb.HostValidationResult
import com.example.aero_stream_for_android.data.remote.smb.SmbConnectionTestResult
import com.example.aero_stream_for_android.data.remote.smb.SmbConnectionManager
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.data.repository.SmbLibraryRepository
import com.example.aero_stream_for_android.domain.model.AudioEngine
import com.example.aero_stream_for_android.domain.model.SmbConfig
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch
import java.util.UUID
import javax.inject.Inject

data class SettingsUiState(
    val audioEngine: AudioEngine = AudioEngine.MEDIA3,
    val themeMode: String = "system",
    val smbConfigs: List<SmbConfig> = emptyList(),
    val selectedSmbConfigId: String? = null,
    val isTestingConnection: Boolean = false,
    val connectionTestResult: SmbConnectionTestResult? = null
)

@HiltViewModel
class SettingsViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository,
    private val smbConnectionManager: SmbConnectionManager,
    private val smbLibraryRepository: SmbLibraryRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(SettingsUiState())
    val uiState: StateFlow<SettingsUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            settingsRepository.migrateLegacySmbConfigIfNeeded()
        }
        viewModelScope.launch {
            settingsRepository.audioEngine.collect { engine ->
                _uiState.update { it.copy(audioEngine = engine) }
            }
        }
        viewModelScope.launch {
            settingsRepository.themeMode.collect { mode ->
                _uiState.update { it.copy(themeMode = mode) }
            }
        }
        viewModelScope.launch {
            settingsRepository.smbConfigs.collect { configs ->
                _uiState.update { it.copy(smbConfigs = configs) }
            }
        }
        viewModelScope.launch {
            settingsRepository.selectedSmbConfigId.collect { selectedId ->
                _uiState.update { it.copy(selectedSmbConfigId = selectedId) }
            }
        }
    }

    fun setAudioEngine(engine: AudioEngine) {
        viewModelScope.launch {
            settingsRepository.setAudioEngine(engine)
        }
    }

    fun setThemeMode(mode: String) {
        viewModelScope.launch {
            settingsRepository.setThemeMode(mode)
        }
    }

    fun addSmbConfig(config: SmbConfig) {
        viewModelScope.launch {
            settingsRepository.addSmbConfig(
                config.copy(id = config.id.ifBlank { UUID.randomUUID().toString() })
            )
        }
    }

    fun updateSmbConfig(config: SmbConfig) {
        viewModelScope.launch {
            settingsRepository.updateSmbConfig(config)
        }
    }

    fun deleteSmbConfig(id: String) {
        viewModelScope.launch {
            settingsRepository.deleteSmbConfig(id)
        }
    }

    fun selectSmbConfig(id: String) {
        viewModelScope.launch {
            settingsRepository.selectSmbConfig(id)
        }
    }

    fun testSmbConnection(config: SmbConfig) {
        viewModelScope.launch {
            _uiState.update { it.copy(isTestingConnection = true, connectionTestResult = null) }
            val result = smbConnectionManager.testConnection(config)
            _uiState.update { it.copy(isTestingConnection = false, connectionTestResult = result) }
        }
    }

    fun refreshSmbLibrary(configId: String, quickScan: Boolean = true) {
        viewModelScope.launch {
            val config = settingsRepository.getSmbConfigById(configId)
            if (config == null || !config.isConfigured) return@launch
            smbLibraryRepository.enqueueScan(config.id, quickScan)
        }
    }

    suspend fun validateHostTarget(host: String): HostValidationResult {
        return smbConnectionManager.validateHostTarget(host)
    }

    fun clearConnectionTestResult() {
        _uiState.update { it.copy(connectionTestResult = null) }
    }
}
