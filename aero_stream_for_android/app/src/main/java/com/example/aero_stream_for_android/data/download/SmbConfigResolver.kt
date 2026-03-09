package com.example.aero_stream_for_android.data.download

import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.SmbConfig
import javax.inject.Inject
import javax.inject.Singleton

sealed interface SmbConfigResolutionResult {
    data class Resolved(val config: SmbConfig) : SmbConfigResolutionResult
    data class Failed(val reason: String) : SmbConfigResolutionResult
}

@Singleton
class SmbConfigResolver @Inject constructor(
    private val settingsRepository: SettingsRepository,
    private val songDao: SongDao
) {
    suspend fun resolveForDownloadStart(songId: Long, explicitSmbConfigId: String?): SmbConfigResolutionResult {
        val candidateId = explicitSmbConfigId?.takeIf { it.isNotBlank() }
            ?: songDao.getSongById(songId)?.smbConfigId?.takeIf { it.isNotBlank() }
            ?: return SmbConfigResolutionResult.Failed("SMB設定IDを特定できません")

        val config = settingsRepository.getSmbConfigById(candidateId)
            ?: return SmbConfigResolutionResult.Failed("SMB設定が見つかりません")
        if (!config.isConfigured) {
            return SmbConfigResolutionResult.Failed("SMB設定が未構成です")
        }
        return SmbConfigResolutionResult.Resolved(config)
    }
}
