package com.example.aero_stream_for_android.ui.settings

import com.example.aero_stream_for_android.data.remote.smb.SmbConnectionManager
import com.example.aero_stream_for_android.data.reset.LibraryDataResetService
import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.data.repository.SmbLibraryRepository
import com.example.aero_stream_for_android.domain.model.AudioEngine
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.every
import io.mockk.mockk
import kotlinx.coroutines.CompletableDeferred
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.flowOf
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.After
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

@OptIn(ExperimentalCoroutinesApi::class)
class SettingsViewModelTest {

    private val dispatcher = StandardTestDispatcher()
    private val settingsRepository: SettingsRepository = mockk()
    private val smbConnectionManager: SmbConnectionManager = mockk(relaxed = true)
    private val smbLibraryRepository: SmbLibraryRepository = mockk(relaxed = true)
    private val libraryDataResetService: LibraryDataResetService = mockk()

    @Before
    fun setUp() {
        Dispatchers.setMain(dispatcher)
        coEvery { settingsRepository.migrateLegacySmbConfigIfNeeded() } returns Unit
        every { settingsRepository.audioEngine } returns flowOf(AudioEngine.MEDIA3)
        every { settingsRepository.themeMode } returns flowOf("system")
        every { settingsRepository.smbConfigs } returns flowOf(emptyList())
        every { settingsRepository.selectedSmbConfigId } returns flowOf(null)
    }

    @After
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun clearLoadedMusicDatabase_callsResetService_andTogglesFlag() = runTest(dispatcher) {
        coEvery { libraryDataResetService.clearLoadedMusicDatabase() } returns Unit
        val viewModel = SettingsViewModel(
            settingsRepository,
            smbConnectionManager,
            smbLibraryRepository,
            libraryDataResetService
        )
        advanceUntilIdle()

        viewModel.clearLoadedMusicDatabase()
        assertTrue(viewModel.uiState.value.isClearingLoadedMusicDatabase)

        advanceUntilIdle()

        coVerify(exactly = 1) { libraryDataResetService.clearLoadedMusicDatabase() }
        assertFalse(viewModel.uiState.value.isClearingLoadedMusicDatabase)
    }

    @Test
    fun clearLoadedMusicDatabase_ignoresSecondRequestWhileRunning() = runTest(dispatcher) {
        val gate = CompletableDeferred<Unit>()
        coEvery { libraryDataResetService.clearLoadedMusicDatabase() } coAnswers {
            gate.await()
        }
        val viewModel = SettingsViewModel(
            settingsRepository,
            smbConnectionManager,
            smbLibraryRepository,
            libraryDataResetService
        )
        advanceUntilIdle()

        viewModel.clearLoadedMusicDatabase()
        viewModel.clearLoadedMusicDatabase()
        advanceUntilIdle()

        coVerify(exactly = 1) { libraryDataResetService.clearLoadedMusicDatabase() }
        assertTrue(viewModel.uiState.value.isClearingLoadedMusicDatabase)

        gate.complete(Unit)
        advanceUntilIdle()

        assertFalse(viewModel.uiState.value.isClearingLoadedMusicDatabase)
    }
}
