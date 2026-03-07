package com.example.aero_stream_for_android.data.debug

import com.example.aero_stream_for_android.data.local.db.dao.DownloadDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.local.db.entity.DownloadEntity
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.SmbConfig
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import io.mockk.slot
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.runTest
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class DebugSmbSeedManagerTest {

    private val settingsRepository: SettingsRepository = mockk(relaxed = true)
    private val songDao: SongDao = mockk(relaxed = true)
    private val downloadDao: DownloadDao = mockk(relaxed = true)

    @Test
    fun seedIfDebug_false_doesNothing() = runTest {
        val manager = DebugSmbSeedManager(settingsRepository, songDao, downloadDao)

        manager.seedIfDebug(isDebug = false)

        coVerify(exactly = 0) { settingsRepository.migrateLegacySmbConfigIfNeeded() }
        coVerify(exactly = 0) { songDao.insertSongs(any()) }
        coVerify(exactly = 0) { downloadDao.insertDownload(any()) }
    }

    @Test
    fun seed_upsertsConfigSongsAndDownloads() = runTest {
        coEvery { settingsRepository.getSmbConfigById("debug-smb-seed-config") } returns null
        coEvery { downloadDao.getDownloadBySmbPath(any()) } returns null

        val songsSlot = slot<List<com.example.aero_stream_for_android.data.local.db.entity.SongEntity>>()
        coEvery { songDao.insertSongs(capture(songsSlot)) } returns Unit

        val manager = DebugSmbSeedManager(settingsRepository, songDao, downloadDao)
        manager.seed()

        coVerify(exactly = 1) { settingsRepository.addSmbConfig(any()) }
        coVerify(exactly = 1) { settingsRepository.selectSmbConfig("debug-smb-seed-config") }
        coVerify(exactly = 1) { songDao.insertSongs(any()) }
        coVerify(exactly = 3) { downloadDao.insertDownload(any()) }
        coVerify(exactly = 0) { downloadDao.updateDownload(any()) }

        val songs = songsSlot.captured
        assertEquals(12, songs.size)
        assertEquals(6, songs.count { it.isCached })
        assertTrue(songs.all { it.source == "SMB" })
        assertTrue(songs.all { it.smbConfigId == "debug-smb-seed-config" })
    }

    @Test
    fun seed_existingConfigAndDownloads_updatesWithoutDuplication() = runTest {
        coEvery { settingsRepository.getSmbConfigById("debug-smb-seed-config") } returns SmbConfig(
            id = "debug-smb-seed-config",
            displayName = "Old",
            hostname = "old",
            shareName = "old"
        )
        coEvery { downloadDao.getDownloadBySmbPath(any()) } returns DownloadEntity(
            id = 99L,
            songId = 1L,
            smbPath = "seed/night_signal/track_1.mp3",
            state = "PENDING"
        )

        val manager = DebugSmbSeedManager(settingsRepository, songDao, downloadDao)
        manager.seed()

        coVerify(exactly = 0) { settingsRepository.addSmbConfig(any()) }
        coVerify(exactly = 1) { settingsRepository.updateSmbConfig(any()) }
        coVerify(exactly = 3) { downloadDao.updateDownload(any()) }
        coVerify(exactly = 0) { downloadDao.insertDownload(any()) }
    }
}
