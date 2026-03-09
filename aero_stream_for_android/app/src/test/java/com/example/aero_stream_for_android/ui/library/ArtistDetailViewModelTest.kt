package com.example.aero_stream_for_android.ui.library

import androidx.lifecycle.SavedStateHandle
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.navigation.Screen
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
class ArtistDetailViewModelTest {

    private val dispatcher = StandardTestDispatcher()
    private val musicRepository: MusicRepository = mockk()

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun loadSongs_smbSource_withoutConfigId_usesAllSmbSongs() = runTest(dispatcher) {
        val smbSong = Song(
            id = 30L,
            title = "SMB Track",
            artist = "Artist",
            album = "Album",
            duration = 1000L,
            source = MusicSource.SMB
        )
        every {
            musicRepository.getSongsByArtistAndSource("Artist", MusicSource.SMB)
        } returns flowOf(listOf(smbSong))

        val savedStateHandle = SavedStateHandle(
            mapOf(
                Screen.ArtistDetail.artistNameArg to "Artist",
                Screen.ArtistDetail.sourceArg to MusicSource.SMB.name,
                Screen.ArtistDetail.smbConfigIdArg to ""
            )
        )
        val viewModel = ArtistDetailViewModel(musicRepository, savedStateHandle)
        advanceUntilIdle()

        assertEquals(false, viewModel.uiState.value.isLoading)
        assertEquals(null, viewModel.uiState.value.error)
        assertEquals(listOf(smbSong), viewModel.uiState.value.songs)
        verify(exactly = 1) { musicRepository.getSongsByArtistAndSource("Artist", MusicSource.SMB) }
    }
}
