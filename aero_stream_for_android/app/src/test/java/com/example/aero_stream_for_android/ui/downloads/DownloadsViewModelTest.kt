package com.example.aero_stream_for_android.ui.downloads

import com.example.aero_stream_for_android.data.local.db.entity.DownloadEntity
import com.example.aero_stream_for_android.data.local.db.entity.DownloadState
import com.example.aero_stream_for_android.data.repository.DownloadRepository
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.domain.model.Song
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertEquals
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class DownloadsViewModelTest {

    private val dispatcher = StandardTestDispatcher()
    private val musicRepository: MusicRepository = mockk()
    private val downloadRepository: DownloadRepository = mockk()
    private val settingsRepository: SettingsRepository = mockk()

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun loadDownloads_showsCachedSongs_andFiltersOutCompletedDownloads() = runTest(dispatcher) {
        val cachedSong = Song(
            id = 10L,
            title = "Cached",
            artist = "Artist",
            album = "Album",
            duration = 1_000L,
            source = MusicSource.SMB,
            smbPath = "a\\b.mp3",
            isCached = true
        )
        val allDownloads = listOf(
            DownloadEntity(id = 1L, songId = 10L, smbPath = "a\\b.mp3", state = DownloadState.PENDING),
            DownloadEntity(id = 2L, songId = 11L, smbPath = "a\\c.mp3", state = DownloadState.DOWNLOADING),
            DownloadEntity(id = 3L, songId = 12L, smbPath = "a\\d.mp3", state = DownloadState.COMPLETED)
        )

        every { musicRepository.getCachedSmbSongs() } returns flowOf(listOf(cachedSong))
        every { downloadRepository.getAllDownloads() } returns flowOf(allDownloads)

        val viewModel = DownloadsViewModel(musicRepository, downloadRepository, settingsRepository)
        advanceUntilIdle()

        assertEquals(listOf(cachedSong), viewModel.uiState.value.downloadedSongs)
        assertEquals(2, viewModel.uiState.value.activeDownloads.size)
        assertEquals(false, viewModel.uiState.value.activeDownloads.any { it.state == DownloadState.COMPLETED })
        assertEquals(false, viewModel.uiState.value.isLoading)
    }

    @Test
    fun retryDownload_usesSelectedConfigId() = runTest(dispatcher) {
        every { musicRepository.getCachedSmbSongs() } returns flowOf(emptyList())
        every { downloadRepository.getAllDownloads() } returns flowOf(emptyList())
        coEvery { settingsRepository.getSelectedSmbConfig() } returns SmbConfig(
            id = "cfg",
            hostname = "host",
            shareName = "share"
        )
        coEvery { downloadRepository.startDownload(any(), any(), any()) } returns 1L

        val viewModel = DownloadsViewModel(musicRepository, downloadRepository, settingsRepository)
        val failedDownload = DownloadEntity(
            id = 100L,
            songId = 99L,
            smbPath = "retry\\song.mp3",
            state = DownloadState.FAILED
        )

        viewModel.retryDownload(failedDownload)
        advanceUntilIdle()

        coVerify(exactly = 1) {
            downloadRepository.startDownload(99L, "retry\\song.mp3", "cfg")
        }
    }
}
