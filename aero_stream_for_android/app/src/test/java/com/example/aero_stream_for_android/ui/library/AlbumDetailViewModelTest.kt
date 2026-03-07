package com.example.aero_stream_for_android.ui.library

import androidx.lifecycle.SavedStateHandle
import com.example.aero_stream_for_android.data.download.DownloadManager
import com.example.aero_stream_for_android.data.local.db.entity.DownloadEntity
import com.example.aero_stream_for_android.data.local.db.entity.DownloadState
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.navigation.Screen
import io.mockk.every
import io.mockk.mockk
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.verify
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.async
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.flow.first
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
class AlbumDetailViewModelTest {

    private val dispatcher = StandardTestDispatcher()
    private val musicRepository: MusicRepository = mockk()
    private val downloadManager: DownloadManager = mockk()
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
    fun loadAlbum_smbSource_usesSmbSongsOnly_withTrackOrder() = runTest(dispatcher) {
        val smbSong1 = Song(
            id = 1L,
            title = "B Song",
            artist = "Artist",
            albumArtist = "Artist",
            album = "Album",
            duration = 1000L,
            source = MusicSource.SMB,
            smbConfigId = "cfg",
            trackNumber = 2
        )
        val smbSong2 = Song(
            id = 2L,
            title = "A Song",
            artist = "Artist",
            albumArtist = "Artist",
            album = "Album",
            duration = 900L,
            source = MusicSource.SMB,
            smbConfigId = "cfg",
            trackNumber = 1
        )

        every {
            musicRepository.getSongsByAlbumSourceAndSmbConfig(
                album = "Album",
                albumArtist = "Artist",
                source = MusicSource.SMB,
                smbConfigId = "cfg"
            )
        } returns flowOf(listOf(smbSong1, smbSong2))
        every { downloadManager.observeAllDownloads() } returns flowOf(emptyList())
        coEvery { settingsRepository.getSmbConfigById(any()) } returns null
        coEvery { settingsRepository.getSelectedSmbConfig() } returns null

        val savedStateHandle = SavedStateHandle(
            mapOf(
                Screen.AlbumDetail.albumNameArg to "Album",
                Screen.AlbumDetail.albumArtistArg to "Artist",
                Screen.AlbumDetail.sourceArg to MusicSource.SMB.name,
                Screen.AlbumDetail.smbConfigIdArg to "cfg"
            )
        )
        val viewModel = AlbumDetailViewModel(musicRepository, downloadManager, settingsRepository, savedStateHandle)
        advanceUntilIdle()

        assertEquals(listOf(smbSong1, smbSong2), viewModel.uiState.value.songs)
        assertEquals(false, viewModel.uiState.value.isLoading)
        verify(exactly = 1) {
            musicRepository.getSongsByAlbumSourceAndSmbConfig("Album", "Artist", MusicSource.SMB, "cfg")
        }
        verify(exactly = 0) {
            musicRepository.getSongsByAlbumSourceAndSmbConfig("Album", "Artist", MusicSource.DOWNLOAD, "cfg")
        }
    }

    @Test
    fun cacheAlbumTracks_smbSource_startsNewAndSkipsExisting() = runTest(dispatcher) {
        val smbSong1 = Song(
            id = 1L,
            title = "Song1",
            artist = "Artist",
            albumArtist = "Artist",
            album = "Album",
            duration = 1000L,
            source = MusicSource.SMB,
            smbPath = "dir\\song1.mp3",
            smbConfigId = "cfg"
        )
        val smbSong2 = Song(
            id = 2L,
            title = "Song2",
            artist = "Artist",
            albumArtist = "Artist",
            album = "Album",
            duration = 1000L,
            source = MusicSource.SMB,
            smbPath = "dir\\song2.mp3",
            smbConfigId = "cfg"
        )
        val smbSong3 = Song(
            id = 3L,
            title = "Song3",
            artist = "Artist",
            albumArtist = "Artist",
            album = "Album",
            duration = 1000L,
            source = MusicSource.SMB,
            smbPath = "dir\\song3.mp3",
            smbConfigId = "cfg"
        )

        every {
            musicRepository.getSongsByAlbumSourceAndSmbConfig("Album", "Artist", MusicSource.SMB, "cfg")
        } returns flowOf(listOf(smbSong1, smbSong2, smbSong3))
        every { downloadManager.observeAllDownloads() } returns flowOf(emptyList())

        val config = SmbConfig(id = "cfg", hostname = "host", shareName = "share")
        coEvery { settingsRepository.getSmbConfigById("cfg") } returns config
        coEvery { settingsRepository.getSelectedSmbConfig() } returns null

        coEvery { downloadManager.hasDownloadEntry("dir\\song1.mp3") } returns false
        coEvery { downloadManager.hasDownloadEntry("dir\\song2.mp3") } returns true
        coEvery { downloadManager.hasDownloadEntry("dir\\song3.mp3") } returns false
        coEvery { downloadManager.startDownload(any(), any(), any()) } returns 10L

        val savedStateHandle = SavedStateHandle(
            mapOf(
                Screen.AlbumDetail.albumNameArg to "Album",
                Screen.AlbumDetail.albumArtistArg to "Artist",
                Screen.AlbumDetail.sourceArg to MusicSource.SMB.name,
                Screen.AlbumDetail.smbConfigIdArg to "cfg"
            )
        )
        val viewModel = AlbumDetailViewModel(musicRepository, downloadManager, settingsRepository, savedStateHandle)
        advanceUntilIdle()

        val message = async { viewModel.toastMessages.first() }
        viewModel.cacheAlbumTracks()
        advanceUntilIdle()

        assertEquals("開始:2 スキップ:1 失敗:0", message.await())
        coVerify(exactly = 2) { downloadManager.startDownload(any(), any(), "cfg") }
    }

    @Test
    fun cacheAlbumTracks_nonSmbSource_doesNothing() = runTest(dispatcher) {
        val localSong = Song(
            id = 10L,
            title = "Local",
            artist = "Artist",
            albumArtist = "Artist",
            album = "Album",
            duration = 1000L,
            source = MusicSource.LOCAL
        )

        every {
            musicRepository.getSongsByAlbumAndSource("Album", "Artist", MusicSource.LOCAL)
        } returns flowOf(listOf(localSong))
        every { downloadManager.observeAllDownloads() } returns flowOf(emptyList())
        coEvery { settingsRepository.getSmbConfigById(any()) } returns null
        coEvery { settingsRepository.getSelectedSmbConfig() } returns null

        val savedStateHandle = SavedStateHandle(
            mapOf(
                Screen.AlbumDetail.albumNameArg to "Album",
                Screen.AlbumDetail.albumArtistArg to "Artist",
                Screen.AlbumDetail.sourceArg to MusicSource.LOCAL.name,
                Screen.AlbumDetail.smbConfigIdArg to ""
            )
        )
        val viewModel = AlbumDetailViewModel(musicRepository, downloadManager, settingsRepository, savedStateHandle)
        advanceUntilIdle()

        viewModel.cacheAlbumTracks()
        advanceUntilIdle()

        coVerify(exactly = 0) { downloadManager.startDownload(any(), any(), any()) }
        assertEquals(false, viewModel.uiState.value.isDownloadActionEnabled)
    }

    @Test
    fun loadAlbum_activeDownloads_mapsPendingAndDownloadingOnly() = runTest(dispatcher) {
        val smbSong = Song(
            id = 1L,
            title = "Song1",
            artist = "Artist",
            albumArtist = "Artist",
            album = "Album",
            duration = 1000L,
            source = MusicSource.SMB,
            smbPath = "dir\\song1.mp3",
            smbConfigId = "cfg"
        )
        every {
            musicRepository.getSongsByAlbumSourceAndSmbConfig("Album", "Artist", MusicSource.SMB, "cfg")
        } returns flowOf(listOf(smbSong))
        every { downloadManager.observeAllDownloads() } returns flowOf(
            listOf(
                DownloadEntity(
                    id = 10L,
                    songId = 1L,
                    smbPath = "dir\\song1.mp3",
                    state = DownloadState.DOWNLOADING,
                    fileSize = 100L,
                    downloadedBytes = 40L
                ),
                DownloadEntity(
                    id = 11L,
                    songId = 2L,
                    smbPath = "dir\\song2.mp3",
                    state = DownloadState.PENDING
                ),
                DownloadEntity(
                    id = 12L,
                    songId = 3L,
                    smbPath = "dir\\song3.mp3",
                    state = DownloadState.COMPLETED
                )
            )
        )
        coEvery { settingsRepository.getSmbConfigById(any()) } returns null
        coEvery { settingsRepository.getSelectedSmbConfig() } returns null

        val savedStateHandle = SavedStateHandle(
            mapOf(
                Screen.AlbumDetail.albumNameArg to "Album",
                Screen.AlbumDetail.albumArtistArg to "Artist",
                Screen.AlbumDetail.sourceArg to MusicSource.SMB.name,
                Screen.AlbumDetail.smbConfigIdArg to "cfg"
            )
        )
        val viewModel = AlbumDetailViewModel(musicRepository, downloadManager, settingsRepository, savedStateHandle)
        advanceUntilIdle()

        val active = viewModel.uiState.value.activeDownloadsBySmbPath
        assertEquals(2, active.size)
        assertEquals(true, active.containsKey("dir\\song1.mp3"))
        assertEquals(true, active.containsKey("dir\\song2.mp3"))
        assertEquals(false, active.containsKey("dir\\song3.mp3"))
        assertEquals(0.4f, active["dir\\song1.mp3"]?.progress)
        assertEquals(null, active["dir\\song2.mp3"]?.progress)
    }
}
