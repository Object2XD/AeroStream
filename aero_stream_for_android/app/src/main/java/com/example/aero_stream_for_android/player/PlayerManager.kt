package com.example.aero_stream_for_android.player

import com.example.aero_stream_for_android.data.repository.SettingsRepository
import com.example.aero_stream_for_android.domain.model.AudioEngine
import com.example.aero_stream_for_android.domain.model.PlayerState
import com.example.aero_stream_for_android.domain.model.RepeatMode
import com.example.aero_stream_for_android.domain.model.Song
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch
import javax.inject.Inject
import javax.inject.Named
import javax.inject.Singleton

/**
 * 再生エンジンの切り替えを管理するマネージャー。
 * 設定に基づいて Media3 / MediaPlayer を動的に切り替える。
 */
@Singleton
class PlayerManager @Inject constructor(
    @Named("media3") private val media3Player: AudioPlayer,
    @Named("mediaPlayer") private val standardPlayer: AudioPlayer,
    private val settingsRepository: SettingsRepository
) : AudioPlayer {

    private var currentEngine: AudioEngine = AudioEngine.MEDIA3
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    private val _playerState = MutableStateFlow(PlayerState())
    override val playerState: StateFlow<PlayerState> = _playerState.asStateFlow()

    private val activePlayer: AudioPlayer
        get() = when (currentEngine) {
            AudioEngine.MEDIA3 -> media3Player
            AudioEngine.MEDIA_PLAYER -> standardPlayer
        }

    init {
        // 設定からエンジンを監視して切り替え
        scope.launch {
            settingsRepository.audioEngine.collect { engine ->
                if (engine != currentEngine) {
                    switchEngine(engine)
                }
            }
        }

        // アクティブプレイヤーの状態を転送
        scope.launch {
            media3Player.playerState.collect { state ->
                if (currentEngine == AudioEngine.MEDIA3) {
                    _playerState.value = state
                }
            }
        }

        scope.launch {
            standardPlayer.playerState.collect { state ->
                if (currentEngine == AudioEngine.MEDIA_PLAYER) {
                    _playerState.value = state
                }
            }
        }
    }

    private fun switchEngine(newEngine: AudioEngine) {
        val oldPlayer = activePlayer
        val oldState = oldPlayer.playerState.value

        // 旧エンジンを停止
        oldPlayer.stop()

        currentEngine = newEngine

        // 新エンジンで復元
        if (oldState.currentSong != null && oldState.queue.isNotEmpty()) {
            activePlayer.setQueue(oldState.queue, oldState.currentQueueIndex.coerceAtLeast(0))
            activePlayer.seekTo(oldState.currentPosition)
            activePlayer.setRepeatMode(oldState.repeatMode)
            activePlayer.setShuffleEnabled(oldState.isShuffleEnabled)
            if (oldState.isPlaying) {
                activePlayer.resume()
            }
        }
    }

    override fun play(song: Song) = activePlayer.play(song)
    override fun pause() = activePlayer.pause()
    override fun resume() = activePlayer.resume()
    override fun stop() = activePlayer.stop()
    override fun seekTo(positionMs: Long) = activePlayer.seekTo(positionMs)
    override fun setQueue(songs: List<Song>, startIndex: Int) = activePlayer.setQueue(songs, startIndex)
    override fun skipToNext() = activePlayer.skipToNext()
    override fun skipToPrevious() = activePlayer.skipToPrevious()
    override fun setRepeatMode(mode: RepeatMode) = activePlayer.setRepeatMode(mode)
    override fun setShuffleEnabled(enabled: Boolean) = activePlayer.setShuffleEnabled(enabled)
    override fun getCurrentPosition(): Long = activePlayer.getCurrentPosition()

    override fun release() {
        media3Player.release()
        standardPlayer.release()
    }
}
