package com.example.aero_stream_for_android.data.debug
import com.example.aero_stream_for_android.data.local.db.dao.DownloadDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.local.db.entity.DownloadEntity
import com.example.aero_stream_for_android.data.local.db.entity.DownloadState
import com.example.aero_stream_for_android.data.local.db.entity.SongEntity
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SmbConfig
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class DebugSmbSeedManager @Inject constructor(
    private val settingsRepository: SettingsRepository,
    private val songDao: SongDao,
    private val downloadDao: DownloadDao
) {
    suspend fun seedIfDebug(isDebug: Boolean) {
        if (!isDebug) return
        seed()
    }

    suspend fun seed() {
        settingsRepository.migrateLegacySmbConfigIfNeeded()

        val config = buildDebugConfig()
        val existing = settingsRepository.getSmbConfigById(DEBUG_CONFIG_ID)
        if (existing == null) {
            settingsRepository.addSmbConfig(config)
        } else {
            settingsRepository.updateSmbConfig(config)
        }
        settingsRepository.selectSmbConfig(DEBUG_CONFIG_ID)

        val songs = buildDebugSongs(System.currentTimeMillis())
        songDao.insertSongs(songs)

        buildDebugDownloads().forEach { seedDownload ->
            val existingDownload = downloadDao.getDownloadBySmbPath(seedDownload.smbPath)
            if (existingDownload == null) {
                downloadDao.insertDownload(seedDownload)
            } else {
                downloadDao.updateDownload(
                    existingDownload.copy(
                        songId = seedDownload.songId,
                        localCachePath = seedDownload.localCachePath,
                        state = seedDownload.state,
                        fileSize = seedDownload.fileSize,
                        downloadedBytes = seedDownload.downloadedBytes,
                        errorMessage = seedDownload.errorMessage
                    )
                )
            }
        }
    }

    private fun buildDebugConfig(): SmbConfig {
        return SmbConfig(
            id = DEBUG_CONFIG_ID,
            displayName = "Debug SMB",
            hostname = DEBUG_SMB_HOST,
            shareName = DEBUG_SMB_SHARE,
            rootPath = DEBUG_SMB_ROOT
        )
    }

    private fun buildDebugSongs(now: Long): List<SongEntity> {
        return listOf(
            song(10001, "Neon Drift", "Astra", "Night Signal", 1, false, now),
            song(10002, "Cold Orbit", "Astra", "Night Signal", 2, true, now),
            song(10003, "Skyline Echo", "Astra", "Night Signal", 3, false, now),
            song(10004, "Amber Cloud", "Lumen", "Morning Relay", 1, true, now),
            song(10005, "Quiet Port", "Lumen", "Morning Relay", 2, false, now),
            song(10006, "Glass Harbor", "Lumen", "Morning Relay", 3, true, now),
            song(10007, "Pulse Runner", "Orbit Unit", "Transit Zero", 1, false, now),
            song(10008, "Last Terminal", "Orbit Unit", "Transit Zero", 2, true, now),
            song(10009, "Night Ferry", "Orbit Unit", "Transit Zero", 3, false, now),
            song(10010, "Blue Meridian", "Astra", "Open Sector", 1, true, now),
            song(10011, "Afterlight", "Astra", "Open Sector", 2, false, now),
            song(10012, "Terminal Bloom", "Lumen", "Open Sector", 3, true, now)
        )
    }

    private fun song(
        id: Long,
        title: String,
        artist: String,
        album: String,
        track: Int,
        cached: Boolean,
        now: Long
    ): SongEntity {
        val smbPath = "$DEBUG_SMB_ROOT/${album.lowercase().replace(' ', '_')}/track_$track.mp3"
        return SongEntity(
            id = id,
            title = title,
            artist = artist,
            albumArtist = artist,
            album = album,
            duration = 180_000L + track * 1_000L,
            source = MusicSource.SMB.name,
            smbPath = smbPath,
            smbConfigId = DEBUG_CONFIG_ID,
            smbLibraryBucket = album.lowercase().replace(' ', '_'),
            trackNumber = track,
            fileSize = 6_000_000L + track * 100_000L,
            mimeType = "audio/mpeg",
            smbLastWriteTime = now - 86_400_000L,
            isCached = cached,
            cachedAt = if (cached) now - 3_600_000L else null,
            cacheLastPlayedAt = if (cached) now - 1_800_000L else null,
            sourceUpdatedAt = now
        )
    }

    private fun buildDebugDownloads(): List<DownloadEntity> {
        return listOf(
            DownloadEntity(
                songId = 10001L,
                smbPath = "$DEBUG_SMB_ROOT/night_signal/track_1.mp3",
                state = DownloadState.PENDING
            ),
            DownloadEntity(
                songId = 10003L,
                smbPath = "$DEBUG_SMB_ROOT/night_signal/track_3.mp3",
                state = DownloadState.DOWNLOADING,
                fileSize = 7_000_000L,
                downloadedBytes = 2_500_000L
            ),
            DownloadEntity(
                songId = 10011L,
                smbPath = "$DEBUG_SMB_ROOT/open_sector/track_2.mp3",
                state = DownloadState.FAILED,
                errorMessage = "Simulated SMB timeout"
            )
        )
    }

    companion object {
        private const val DEBUG_CONFIG_ID = "debug-smb-seed-config"
        private const val DEBUG_SMB_HOST = "debug.local"
        private const val DEBUG_SMB_SHARE = "music"
        private const val DEBUG_SMB_ROOT = "seed"
    }
}
