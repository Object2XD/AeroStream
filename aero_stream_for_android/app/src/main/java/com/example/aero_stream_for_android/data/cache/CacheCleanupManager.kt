package com.example.aero_stream_for_android.data.cache

import com.example.aero_stream_for_android.data.local.db.dao.DownloadDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import java.io.File
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class CacheCleanupManager @Inject constructor(
    private val songDao: SongDao,
    private val downloadDao: DownloadDao
) {
    companion object {
        private const val DEFAULT_RETENTION_DAYS = 30L
        private const val DAY_MILLIS = 24L * 60L * 60L * 1000L
    }

    suspend fun cleanupExpiredCache(retentionDays: Long = DEFAULT_RETENTION_DAYS) {
        val threshold = System.currentTimeMillis() - (retentionDays * DAY_MILLIS)
        val expiredSongs = songDao.getCachedSongsForCleanup(threshold)
        for (song in expiredSongs) {
            val localPath = song.localPath
            if (!localPath.isNullOrBlank()) {
                File(localPath).delete()
            }
            val smbPath = song.smbPath
            if (!smbPath.isNullOrBlank()) {
                val smbConfigId = song.smbConfigId
                if (!smbConfigId.isNullOrBlank()) {
                    songDao.clearCacheBySmbPathAndConfigId(smbPath, smbConfigId)
                    downloadDao.deleteBySmbPathAndConfigId(smbPath, smbConfigId)
                } else {
                    songDao.clearCacheBySmbPath(smbPath)
                    downloadDao.deleteBySmbPath(smbPath)
                }
            }
        }
    }
}
