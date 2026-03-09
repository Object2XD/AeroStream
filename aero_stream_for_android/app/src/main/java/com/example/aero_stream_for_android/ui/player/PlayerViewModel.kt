package com.example.aero_stream_for_android.ui.player

import androidx.lifecycle.ViewModel
import com.example.aero_stream_for_android.data.download.DownloadManager
import com.example.aero_stream_for_android.data.repository.MusicRepository
import com.example.aero_stream_for_android.domain.model.PlayerState
import com.example.aero_stream_for_android.domain.model.RepeatMode
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.player.PlayerManager
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class PlayerViewModel @Inject constructor(
    private val playerManager: PlayerManager,
    private val musicRepository: MusicRepository,
    private val downloadManager: DownloadManager
) : ViewModel() {

    val playerState: StateFlow<PlayerState> = playerManager.playerState

    fun playSong(song: Song) {
        playerManager.play(song)
        CoroutineScope(Dispatchers.IO).launch {
            musicRepository.updatePlayStats(song.id)
        }
    }

    fun playQueue(songs: List<Song>, startIndex: Int = 0) {
        playerManager.setQueue(songs, startIndex)
    }

    fun togglePlayPause() {
        val state = playerState.value
        if (state.isPlaying) playerManager.pause() else playerManager.resume()
    }

    fun skipToNext() = playerManager.skipToNext()
    fun skipToPrevious() = playerManager.skipToPrevious()
    fun seekTo(positionMs: Long) = playerManager.seekTo(positionMs)

    fun toggleRepeatMode() {
        val nextMode = when (playerState.value.repeatMode) {
            RepeatMode.OFF -> RepeatMode.ALL
            RepeatMode.ALL -> RepeatMode.ONE
            RepeatMode.ONE -> RepeatMode.OFF
        }
        playerManager.setRepeatMode(nextMode)
    }

    fun toggleShuffle() {
        playerManager.setShuffleEnabled(!playerState.value.isShuffleEnabled)
    }

    fun downloadCurrentSong() {
        val song = playerState.value.currentSong ?: return
        val smbPath = song.smbPath ?: return
        CoroutineScope(Dispatchers.IO).launch {
            downloadManager.startDownload(song.id, smbPath, song.smbConfigId)
        }
    }

    override fun onCleared() {
        super.onCleared()
        // PlayerManagerはSingletonなので解放しない
    }
}
