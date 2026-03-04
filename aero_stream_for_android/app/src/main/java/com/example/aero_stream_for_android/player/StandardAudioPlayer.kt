package com.example.aero_stream_for_android.player

import android.content.Context
import android.media.AudioAttributes
import android.media.AudioFocusRequest
import android.media.AudioManager
import android.media.MediaPlayer
import android.net.Uri
import android.os.Build
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.PlayerState
import com.example.aero_stream_for_android.domain.model.RepeatMode
import com.example.aero_stream_for_android.domain.model.Song
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.*
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import javax.inject.Inject
import javax.inject.Singleton

/**
 * 標準 MediaPlayer ベースの再生エンジン実装。
 */
@Singleton
class StandardAudioPlayer @Inject constructor(
    @ApplicationContext private val context: Context
) : AudioPlayer {

    private var mediaPlayer: MediaPlayer? = null
    private val audioManager = context.getSystemService(Context.AUDIO_SERVICE) as AudioManager
    private val queueManager = QueueManager()
    private val _playerState = MutableStateFlow(PlayerState())
    override val playerState: StateFlow<PlayerState> = _playerState.asStateFlow()

    private var currentRepeatMode = RepeatMode.OFF
    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var positionUpdateJob: Job? = null
    private var audioFocusRequest: AudioFocusRequest? = null

    private fun requestAudioFocus(): Boolean {
        val attrs = AudioAttributes.Builder()
            .setUsage(AudioAttributes.USAGE_MEDIA)
            .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
            .build()

        val request = AudioFocusRequest.Builder(AudioManager.AUDIOFOCUS_GAIN)
            .setAudioAttributes(attrs)
            .setOnAudioFocusChangeListener { focusChange ->
                when (focusChange) {
                    AudioManager.AUDIOFOCUS_LOSS -> pause()
                    AudioManager.AUDIOFOCUS_LOSS_TRANSIENT -> pause()
                    AudioManager.AUDIOFOCUS_GAIN -> resume()
                }
            }
            .build()

        audioFocusRequest = request
        return audioManager.requestAudioFocus(request) == AudioManager.AUDIOFOCUS_REQUEST_GRANTED
    }

    private fun abandonAudioFocus() {
        audioFocusRequest?.let { audioManager.abandonAudioFocusRequest(it) }
    }

    private fun createMediaPlayer(): MediaPlayer {
        return MediaPlayer().apply {
            setAudioAttributes(
                AudioAttributes.Builder()
                    .setUsage(AudioAttributes.USAGE_MEDIA)
                    .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                    .build()
            )

            setOnCompletionListener {
                handlePlaybackCompletion()
            }

            setOnErrorListener { _, _, _ ->
                _playerState.value = _playerState.value.copy(error = "Playback error")
                true
            }

            setOnPreparedListener {
                if (requestAudioFocus()) {
                    start()
                    startPositionUpdates()
                    updateState()
                }
            }
        }
    }

    override fun play(song: Song) {
        releaseMediaPlayer()
        queueManager.setQueue(listOf(song), 0)
        playSongInternal(song)
    }

    override fun pause() {
        mediaPlayer?.pause()
        stopPositionUpdates()
        updateState()
    }

    override fun resume() {
        mediaPlayer?.start()
        startPositionUpdates()
        updateState()
    }

    override fun stop() {
        mediaPlayer?.stop()
        stopPositionUpdates()
        abandonAudioFocus()
        updateState()
    }

    override fun seekTo(positionMs: Long) {
        mediaPlayer?.seekTo(positionMs.toInt())
        updateState()
    }

    override fun setQueue(songs: List<Song>, startIndex: Int) {
        queueManager.setQueue(songs, startIndex)
        queueManager.currentSong?.let { playSongInternal(it) }
    }

    override fun skipToNext() {
        val nextSong = queueManager.skipToNext(currentRepeatMode)
        if (nextSong != null) {
            playSongInternal(nextSong)
        } else {
            stop()
        }
    }

    override fun skipToPrevious() {
        val position = mediaPlayer?.currentPosition ?: 0
        if (position > 3000) {
            seekTo(0)
        } else {
            val prevSong = queueManager.skipToPrevious()
            if (prevSong != null) {
                playSongInternal(prevSong)
            }
        }
    }

    override fun setRepeatMode(mode: RepeatMode) {
        currentRepeatMode = mode
        mediaPlayer?.isLooping = (mode == RepeatMode.ONE)
        updateState()
    }

    override fun setShuffleEnabled(enabled: Boolean) {
        queueManager.setShuffle(enabled)
        updateState()
    }

    override fun getCurrentPosition(): Long {
        return mediaPlayer?.currentPosition?.toLong() ?: 0L
    }

    override fun release() {
        stopPositionUpdates()
        abandonAudioFocus()
        scope.cancel()
        releaseMediaPlayer()
        queueManager.clear()
        _playerState.value = PlayerState()
    }

    private fun playSongInternal(song: Song) {
        releaseMediaPlayer()
        val player = createMediaPlayer()
        mediaPlayer = player

        try {
            val uri = getPlaybackUri(song) ?: return
            player.setDataSource(context, uri)
            player.prepareAsync()
            updateState()
        } catch (e: Exception) {
            _playerState.value = _playerState.value.copy(error = "Failed to play: ${e.message}")
        }
    }

    private fun getPlaybackUri(song: Song): Uri? {
        return when (song.source) {
            MusicSource.LOCAL -> song.contentUri ?: song.localPath?.let { Uri.parse(it) }
            MusicSource.DOWNLOAD -> song.localPath?.let { Uri.parse(it) }
            MusicSource.SMB -> song.localPath?.let { Uri.parse(it) }
        }
    }

    private fun handlePlaybackCompletion() {
        when (currentRepeatMode) {
            RepeatMode.ONE -> {
                mediaPlayer?.seekTo(0)
                mediaPlayer?.start()
            }
            else -> skipToNext()
        }
    }

    private fun releaseMediaPlayer() {
        mediaPlayer?.release()
        mediaPlayer = null
    }

    private fun updateState() {
        val player = mediaPlayer
        _playerState.value = PlayerState(
            currentSong = queueManager.currentSong,
            isPlaying = player?.isPlaying ?: false,
            currentPosition = player?.currentPosition?.toLong() ?: 0L,
            duration = player?.duration?.toLong()?.coerceAtLeast(0) ?: 0L,
            queue = queueManager.currentQueue,
            currentQueueIndex = queueManager.currentQueueIndex,
            repeatMode = currentRepeatMode,
            isShuffleEnabled = false
        )
    }

    private fun startPositionUpdates() {
        stopPositionUpdates()
        positionUpdateJob = scope.launch {
            while (isActive) {
                updateState()
                delay(500)
            }
        }
    }

    private fun stopPositionUpdates() {
        positionUpdateJob?.cancel()
        positionUpdateJob = null
    }
}
