package com.example.aero_stream_for_android.data.local.preferences

import android.content.Context
import androidx.datastore.core.DataStore
import androidx.datastore.preferences.core.Preferences
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.intPreferencesKey
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStore
import com.example.aero_stream_for_android.data.remote.smb.normalizeSmbRootPath
import com.example.aero_stream_for_android.domain.model.AudioEngine
import com.example.aero_stream_for_android.domain.model.SmbConfig
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import org.json.JSONArray
import org.json.JSONObject
import java.util.UUID
import javax.inject.Inject
import javax.inject.Singleton

private val Context.dataStore: DataStore<Preferences> by preferencesDataStore(name = "aero_stream_settings")

@Singleton
class UserPreferencesDataStore @Inject constructor(
    @ApplicationContext private val context: Context
) {
    private object Keys {
        val AUDIO_ENGINE = stringPreferencesKey("audio_engine")
        val THEME_MODE = stringPreferencesKey("theme_mode")
        val SMB_CONFIGS_JSON = stringPreferencesKey("smb_configs_json")
        val SELECTED_SMB_CONFIG_ID = stringPreferencesKey("selected_smb_config_id")
        val SELECTED_SMB_LIBRARY_BUCKETS_JSON = stringPreferencesKey("selected_smb_library_buckets_json")
        val SMB_HOSTNAME = stringPreferencesKey("smb_hostname")
        val SMB_PORT = intPreferencesKey("smb_port")
        val SMB_SHARE_NAME = stringPreferencesKey("smb_share_name")
        val SMB_USERNAME = stringPreferencesKey("smb_username")
        val SMB_PASSWORD = stringPreferencesKey("smb_password")
        val SMB_DOMAIN = stringPreferencesKey("smb_domain")
        val LAST_QUEUE_SONG_IDS = stringPreferencesKey("last_queue_song_ids")
        val LAST_QUEUE_INDEX = intPreferencesKey("last_queue_index")
        val LAST_POSITION = longPreferencesKey("last_position")
        val SHUFFLE_ENABLED = booleanPreferencesKey("shuffle_enabled")
        val REPEAT_MODE = stringPreferencesKey("repeat_mode")
    }

    val audioEngine: Flow<AudioEngine> = context.dataStore.data.map { prefs ->
        when (prefs[Keys.AUDIO_ENGINE]) {
            "MEDIA_PLAYER" -> AudioEngine.MEDIA_PLAYER
            else -> AudioEngine.MEDIA3
        }
    }

    suspend fun setAudioEngine(engine: AudioEngine) {
        context.dataStore.edit { prefs ->
            prefs[Keys.AUDIO_ENGINE] = engine.name
        }
    }

    val themeMode: Flow<String> = context.dataStore.data.map { prefs ->
        prefs[Keys.THEME_MODE] ?: "system"
    }

    suspend fun setThemeMode(mode: String) {
        context.dataStore.edit { prefs ->
            prefs[Keys.THEME_MODE] = mode
        }
    }

    suspend fun migrateLegacySmbConfigIfNeeded() {
        context.dataStore.edit { prefs ->
            val hasNewData = !prefs[Keys.SMB_CONFIGS_JSON].isNullOrBlank()
            if (hasNewData) return@edit

            val legacyConfig = readLegacySmbConfig(prefs) ?: return@edit
            prefs[Keys.SMB_CONFIGS_JSON] = serializeSmbConfigs(listOf(legacyConfig))
            prefs[Keys.SELECTED_SMB_CONFIG_ID] = legacyConfig.id
        }
    }

    val smbConfigs: Flow<List<SmbConfig>> = context.dataStore.data.map { prefs ->
        decodeSmbConfigs(prefs[Keys.SMB_CONFIGS_JSON]).ifEmpty {
            readLegacySmbConfig(prefs)?.let(::listOf) ?: emptyList()
        }
    }

    val selectedSmbConfigId: Flow<String?> = context.dataStore.data.map { prefs ->
        prefs[Keys.SELECTED_SMB_CONFIG_ID]
            ?: decodeSmbConfigs(prefs[Keys.SMB_CONFIGS_JSON]).firstOrNull()?.id
            ?: readLegacySmbConfig(prefs)?.id
    }

    suspend fun getSmbConfigs(): List<SmbConfig> = smbConfigs.first()

    suspend fun getSelectedSmbConfigId(): String? = selectedSmbConfigId.first()

    suspend fun getSelectedSmbConfig(): SmbConfig? {
        val configs = getSmbConfigs()
        val selectedId = getSelectedSmbConfigId()
        return configs.firstOrNull { it.id == selectedId } ?: configs.firstOrNull()
    }

    suspend fun getSmbConfigById(id: String): SmbConfig? {
        return getSmbConfigs().firstOrNull { it.id == id }
    }

    suspend fun addSmbConfig(config: SmbConfig) {
        migrateLegacySmbConfigIfNeeded()
        context.dataStore.edit { prefs ->
            val current = decodeSmbConfigs(prefs[Keys.SMB_CONFIGS_JSON])
            val normalized = normalizeConfig(config)
            prefs[Keys.SMB_CONFIGS_JSON] = serializeSmbConfigs(current + normalized)
            if (prefs[Keys.SELECTED_SMB_CONFIG_ID].isNullOrBlank()) {
                prefs[Keys.SELECTED_SMB_CONFIG_ID] = normalized.id
            }
        }
    }

    suspend fun updateSmbConfig(config: SmbConfig) {
        migrateLegacySmbConfigIfNeeded()
        context.dataStore.edit { prefs ->
            val current = decodeSmbConfigs(prefs[Keys.SMB_CONFIGS_JSON])
            val normalized = normalizeConfig(config)
            val updated = current.map { existing ->
                if (existing.id == normalized.id) normalized else existing
            }
            prefs[Keys.SMB_CONFIGS_JSON] = serializeSmbConfigs(updated)
            if (prefs[Keys.SELECTED_SMB_CONFIG_ID].isNullOrBlank() && updated.isNotEmpty()) {
                prefs[Keys.SELECTED_SMB_CONFIG_ID] = updated.first().id
            }
        }
    }

    suspend fun upsertSelectedSmbConfig(config: SmbConfig) {
        migrateLegacySmbConfigIfNeeded()
        context.dataStore.edit { prefs ->
            val current = decodeSmbConfigs(prefs[Keys.SMB_CONFIGS_JSON]).toMutableList()
            val selectedId = prefs[Keys.SELECTED_SMB_CONFIG_ID]
            val normalized = normalizeConfig(
                config.copy(id = config.id.ifBlank { selectedId.orEmpty() })
            )

            val existingIndex = current.indexOfFirst { it.id == normalized.id }
            if (existingIndex >= 0) {
                current[existingIndex] = normalized
            } else {
                current.add(normalized)
            }
            prefs[Keys.SMB_CONFIGS_JSON] = serializeSmbConfigs(current)
            prefs[Keys.SELECTED_SMB_CONFIG_ID] = normalized.id
        }
    }

    suspend fun deleteSmbConfig(id: String) {
        migrateLegacySmbConfigIfNeeded()
        context.dataStore.edit { prefs ->
            val current = decodeSmbConfigs(prefs[Keys.SMB_CONFIGS_JSON])
            val updated = current.filterNot { it.id == id }
            prefs[Keys.SMB_CONFIGS_JSON] = serializeSmbConfigs(updated)

            val selectedId = prefs[Keys.SELECTED_SMB_CONFIG_ID]
            if (selectedId == id) {
                if (updated.isEmpty()) {
                    prefs.remove(Keys.SELECTED_SMB_CONFIG_ID)
                } else {
                    prefs[Keys.SELECTED_SMB_CONFIG_ID] = updated.first().id
                }
            }
        }
    }

    suspend fun selectSmbConfig(id: String) {
        migrateLegacySmbConfigIfNeeded()
        context.dataStore.edit { prefs ->
            val current = decodeSmbConfigs(prefs[Keys.SMB_CONFIGS_JSON])
            if (current.any { it.id == id }) {
                prefs[Keys.SELECTED_SMB_CONFIG_ID] = id
            }
        }
    }

    fun selectedSmbLibraryBuckets(smbConfigId: String): Flow<List<String>> = context.dataStore.data.map { prefs ->
        decodeSelectedBuckets(prefs[Keys.SELECTED_SMB_LIBRARY_BUCKETS_JSON])[smbConfigId].orEmpty()
    }

    suspend fun setSelectedSmbLibraryBuckets(smbConfigId: String, buckets: List<String>) {
        context.dataStore.edit { prefs ->
            val current = decodeSelectedBuckets(prefs[Keys.SELECTED_SMB_LIBRARY_BUCKETS_JSON]).toMutableMap()
            current[smbConfigId] = buckets.distinct()
            prefs[Keys.SELECTED_SMB_LIBRARY_BUCKETS_JSON] = encodeSelectedBuckets(current)
        }
    }

    val shuffleEnabled: Flow<Boolean> = context.dataStore.data.map { prefs ->
        prefs[Keys.SHUFFLE_ENABLED] ?: false
    }

    val repeatMode: Flow<String> = context.dataStore.data.map { prefs ->
        prefs[Keys.REPEAT_MODE] ?: "OFF"
    }

    suspend fun setShuffleEnabled(enabled: Boolean) {
        context.dataStore.edit { prefs ->
            prefs[Keys.SHUFFLE_ENABLED] = enabled
        }
    }

    suspend fun setRepeatMode(mode: String) {
        context.dataStore.edit { prefs ->
            prefs[Keys.REPEAT_MODE] = mode
        }
    }

    suspend fun saveLastQueue(songIds: List<Long>, currentIndex: Int, position: Long) {
        context.dataStore.edit { prefs ->
            prefs[Keys.LAST_QUEUE_SONG_IDS] = songIds.joinToString(",")
            prefs[Keys.LAST_QUEUE_INDEX] = currentIndex
            prefs[Keys.LAST_POSITION] = position
        }
    }

    data class LastQueueState(
        val songIds: List<Long>,
        val currentIndex: Int,
        val position: Long
    )

    val lastQueueState: Flow<LastQueueState?> = context.dataStore.data.map { prefs ->
        val idsStr = prefs[Keys.LAST_QUEUE_SONG_IDS] ?: return@map null
        val ids = idsStr.split(",").mapNotNull { it.toLongOrNull() }
        if (ids.isEmpty()) return@map null
        LastQueueState(
            songIds = ids,
            currentIndex = prefs[Keys.LAST_QUEUE_INDEX] ?: 0,
            position = prefs[Keys.LAST_POSITION] ?: 0L
        )
    }

    private fun readLegacySmbConfig(prefs: Preferences): SmbConfig? {
        val hostname = prefs[Keys.SMB_HOSTNAME] ?: ""
        val shareName = prefs[Keys.SMB_SHARE_NAME] ?: ""
        if (hostname.isBlank() || shareName.isBlank()) return null

        return SmbConfig(
            id = "legacy-default",
            displayName = hostname,
            hostname = hostname,
            port = prefs[Keys.SMB_PORT] ?: 445,
            shareName = shareName,
            rootPath = "",
            username = prefs[Keys.SMB_USERNAME] ?: "",
            password = prefs[Keys.SMB_PASSWORD] ?: "",
            domain = prefs[Keys.SMB_DOMAIN] ?: ""
        )
    }

    private fun normalizeConfig(config: SmbConfig): SmbConfig {
        val normalizedId = config.id.ifBlank { UUID.randomUUID().toString() }
        val normalizedName = config.displayName.ifBlank { config.hostname.ifBlank { "SMB" } }
        return config.copy(
            id = normalizedId,
            displayName = normalizedName,
            rootPath = normalizeSmbRootPath(config.rootPath)
        )
    }

    private fun serializeSmbConfigs(configs: List<SmbConfig>): String {
        val array = JSONArray()
        configs.forEach { config ->
            array.put(
                JSONObject().apply {
                    put("id", config.id)
                    put("displayName", config.displayName)
                    put("hostname", config.hostname)
                    put("port", config.port)
                    put("shareName", config.shareName)
                    put("rootPath", config.rootPath)
                    put("username", config.username)
                    put("password", config.password)
                    put("domain", config.domain)
                }
            )
        }
        return array.toString()
    }

    private fun decodeSmbConfigs(raw: String?): List<SmbConfig> {
        if (raw.isNullOrBlank()) return emptyList()
        return runCatching {
            val array = JSONArray(raw)
            buildList {
                for (index in 0 until array.length()) {
                    val item = array.getJSONObject(index)
                    add(
                        SmbConfig(
                            id = item.optString("id"),
                            displayName = item.optString("displayName"),
                            hostname = item.optString("hostname"),
                            port = item.optInt("port", 445),
                            shareName = item.optString("shareName"),
                            rootPath = normalizeSmbRootPath(item.optString("rootPath")),
                            username = item.optString("username"),
                            password = item.optString("password"),
                            domain = item.optString("domain")
                        )
                    )
                }
            }.filter { it.id.isNotBlank() }
        }.getOrDefault(emptyList())
    }

    private fun encodeSelectedBuckets(value: Map<String, List<String>>): String {
        val objectValue = JSONObject()
        value.forEach { (configId, buckets) ->
            objectValue.put(configId, JSONArray(buckets))
        }
        return objectValue.toString()
    }

    private fun decodeSelectedBuckets(raw: String?): Map<String, List<String>> {
        if (raw.isNullOrBlank()) return emptyMap()
        return runCatching {
            val objectValue = JSONObject(raw)
            buildMap {
                objectValue.keys().forEach { key ->
                    val array = objectValue.optJSONArray(key) ?: JSONArray()
                    put(
                        key,
                        buildList {
                            for (index in 0 until array.length()) {
                                add(array.optString(index))
                            }
                        }.filter { it.isNotBlank() }
                    )
                }
            }
        }.getOrDefault(emptyMap())
    }
}
