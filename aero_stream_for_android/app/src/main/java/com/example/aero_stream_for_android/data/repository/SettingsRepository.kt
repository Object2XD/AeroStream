package com.example.aero_stream_for_android.data.repository

import com.example.aero_stream_for_android.data.local.preferences.UserPreferencesDataStore
import com.example.aero_stream_for_android.domain.model.AudioEngine
import com.example.aero_stream_for_android.domain.model.SmbConfig
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.combine
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SettingsRepository @Inject constructor(
    private val preferencesDataStore: UserPreferencesDataStore
) {
    val audioEngine: Flow<AudioEngine> = preferencesDataStore.audioEngine
    val themeMode: Flow<String> = preferencesDataStore.themeMode
    val recentSearches: Flow<List<String>> = preferencesDataStore.recentSearches
    val smbConfigs: Flow<List<SmbConfig>> = preferencesDataStore.smbConfigs
    val selectedSmbConfigId: Flow<String?> = preferencesDataStore.selectedSmbConfigId
    val selectedSmbConfig: Flow<SmbConfig?> = combine(
        smbConfigs,
        selectedSmbConfigId
    ) { configs, selectedId ->
        configs.firstOrNull { it.id == selectedId } ?: configs.firstOrNull()
    }
    val shuffleEnabled: Flow<Boolean> = preferencesDataStore.shuffleEnabled
    val repeatMode: Flow<String> = preferencesDataStore.repeatMode

    suspend fun migrateLegacySmbConfigIfNeeded() = preferencesDataStore.migrateLegacySmbConfigIfNeeded()

    suspend fun setAudioEngine(engine: AudioEngine) = preferencesDataStore.setAudioEngine(engine)
    suspend fun setThemeMode(mode: String) = preferencesDataStore.setThemeMode(mode)
    suspend fun saveRecentSearch(query: String) = preferencesDataStore.saveRecentSearch(query)
    suspend fun clearRecentSearches() = preferencesDataStore.clearRecentSearches()
    suspend fun addSmbConfig(config: SmbConfig) = preferencesDataStore.addSmbConfig(config)
    suspend fun updateSmbConfig(config: SmbConfig) = preferencesDataStore.updateSmbConfig(config)
    suspend fun deleteSmbConfig(id: String) = preferencesDataStore.deleteSmbConfig(id)
    suspend fun selectSmbConfig(id: String) = preferencesDataStore.selectSmbConfig(id)
    suspend fun getSelectedSmbConfig() = preferencesDataStore.getSelectedSmbConfig()
    suspend fun getSmbConfigById(id: String) = preferencesDataStore.getSmbConfigById(id)
    fun selectedSmbLibraryBuckets(smbConfigId: String) = preferencesDataStore.selectedSmbLibraryBuckets(smbConfigId)
    suspend fun setSelectedSmbLibraryBuckets(smbConfigId: String, buckets: List<String>) =
        preferencesDataStore.setSelectedSmbLibraryBuckets(smbConfigId, buckets)
    suspend fun setShuffleEnabled(enabled: Boolean) = preferencesDataStore.setShuffleEnabled(enabled)
    suspend fun setRepeatMode(mode: String) = preferencesDataStore.setRepeatMode(mode)

    suspend fun saveLastQueue(songIds: List<Long>, currentIndex: Int, position: Long) =
        preferencesDataStore.saveLastQueue(songIds, currentIndex, position)

    val lastQueueState = preferencesDataStore.lastQueueState
}
