package com.example.aero_stream_for_android.ui.library

import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.data.repository.PlaylistRepository
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.Artist
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import io.mockk.every
import io.mockk.mockk
import io.mockk.verify
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
class LibraryViewModelTest {

    private val dispatcher = StandardTestDispatcher()

    private val musicRepository: MusicRepository = mockk()
    private val playlistRepository: PlaylistRepository = mockk()

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun loadLibraryData_usesLocalSourceApisOnly() = runTest(dispatcher) {
        val localSong = Song(
            id = 1L,
            title = "Local Song",
            artist = "Local Artist",
            album = "Local Album",
            duration = 1000L,
            source = MusicSource.LOCAL
        )
        val localAlbum = Album(
            id = 1L,
            name = "Local Album",
            artist = "Local Artist",
            albumArtist = "Local Artist",
            songCount = 1
        )
        val localArtist = Artist(
            id = 1L,
            name = "Local Artist",
            songCount = 1
        )

        every { musicRepository.getSongsBySource(MusicSource.LOCAL) } returns flowOf(listOf(localSong))
        every { musicRepository.getAlbumsBySource(MusicSource.LOCAL) } returns flowOf(listOf(localAlbum))
        every { musicRepository.getArtistsBySource(MusicSource.LOCAL) } returns flowOf(listOf(localArtist))
        every { playlistRepository.getAllPlaylists() } returns flowOf(emptyList())

        every { musicRepository.getAllSongs() } returns flowOf(
            listOf(localSong.copy(id = 2L, source = MusicSource.SMB))
        )
        every { musicRepository.getAlbums() } returns flowOf(
            listOf(localAlbum.copy(id = 2L, name = "SMB Album"))
        )
        every { musicRepository.getArtists() } returns flowOf(
            listOf(localArtist.copy(id = 2L, name = "SMB Artist"))
        )

        val viewModel = LibraryViewModel(musicRepository, playlistRepository)
        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertEquals(listOf(localSong), state.songs)
        assertEquals(listOf(localAlbum), state.albums)
        assertEquals(listOf(localArtist), state.artists)
        assertEquals(false, state.isLoading)

        verify(exactly = 1) { musicRepository.getSongsBySource(MusicSource.LOCAL) }
        verify(exactly = 1) { musicRepository.getAlbumsBySource(MusicSource.LOCAL) }
        verify(exactly = 1) { musicRepository.getArtistsBySource(MusicSource.LOCAL) }

        verify(exactly = 0) { musicRepository.getAllSongs() }
        verify(exactly = 0) { musicRepository.getAlbums() }
        verify(exactly = 0) { musicRepository.getArtists() }
    }
}
