package com.example.aero_stream_for_android.data.download

import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.local.db.entity.SongEntity
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.SmbConfig
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Test

class SmbConfigResolverTest {
    private val settingsRepository: SettingsRepository = mockk()
    private val songDao: SongDao = mockk()
    private val resolver = SmbConfigResolver(settingsRepository, songDao)

    @Test
    fun resolveForDownloadStart_explicitConfigId_returnsResolved() = runTest {
        val config = SmbConfig(id = "cfg", hostname = "host", shareName = "share")
        coEvery { settingsRepository.getSmbConfigById("cfg") } returns config
        coEvery { songDao.getSongById(any()) } returns null

        val result = resolver.resolveForDownloadStart(songId = 1L, explicitSmbConfigId = "cfg")

        assertEquals(SmbConfigResolutionResult.Resolved(config), result)
    }

    @Test
    fun resolveForDownloadStart_fallsBackToSongConfigId() = runTest {
        val config = SmbConfig(id = "cfg-song", hostname = "host", shareName = "share")
        coEvery { settingsRepository.getSmbConfigById("cfg-song") } returns config
        coEvery { songDao.getSongById(10L) } returns songEntity(id = 10L, smbConfigId = "cfg-song")

        val result = resolver.resolveForDownloadStart(songId = 10L, explicitSmbConfigId = null)

        assertEquals(SmbConfigResolutionResult.Resolved(config), result)
    }

    @Test
    fun resolveForDownloadStart_missingConfigId_returnsFailed() = runTest {
        coEvery { songDao.getSongById(3L) } returns songEntity(id = 3L, smbConfigId = null)

        val result = resolver.resolveForDownloadStart(songId = 3L, explicitSmbConfigId = null)

        assertEquals(SmbConfigResolutionResult.Failed("SMB設定IDを特定できません"), result)
    }

    @Test
    fun resolveForDownloadStart_unconfiguredConfig_returnsFailed() = runTest {
        val unconfigured = SmbConfig(id = "bad")
        coEvery { settingsRepository.getSmbConfigById("bad") } returns unconfigured
        coEvery { songDao.getSongById(any()) } returns null

        val result = resolver.resolveForDownloadStart(songId = 5L, explicitSmbConfigId = "bad")

        assertEquals(SmbConfigResolutionResult.Failed("SMB設定が未構成です"), result)
    }

    private fun songEntity(id: Long, smbConfigId: String?): SongEntity = SongEntity(
        id = id,
        title = "Song",
        artist = "Artist",
        album = "Album",
        duration = 1000L,
        source = "SMB",
        smbPath = "dir\\song.mp3",
        smbConfigId = smbConfigId
    )
}
