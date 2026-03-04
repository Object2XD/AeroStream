package com.example.aero_stream_for_android.ui.library

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.SmbConfig
import dagger.hilt.android.lifecycle.HiltViewModel
import javax.inject.Inject
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

data class LibrarySourcesUiState(
    val smbConfigs: List<SmbConfig> = emptyList(),
    val selectedSmbConfigId: String? = null
)

@HiltViewModel
class LibrarySourcesViewModel @Inject constructor(
    private val settingsRepository: SettingsRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(LibrarySourcesUiState())
    val uiState: StateFlow<LibrarySourcesUiState> = _uiState.asStateFlow()

    init {
        viewModelScope.launch {
            settingsRepository.migrateLegacySmbConfigIfNeeded()
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

    fun selectSmbConfig(id: String) {
        viewModelScope.launch {
            settingsRepository.selectSmbConfig(id)
        }
    }
}
