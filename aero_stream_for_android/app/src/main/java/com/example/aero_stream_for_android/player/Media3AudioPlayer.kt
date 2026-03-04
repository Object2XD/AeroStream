package com.example.aero_stream_for_android.player

import android.content.Context
import android.net.Uri
import androidx.media3.common.MediaItem
import androidx.media3.common.MediaMetadata
import androidx.media3.common.Player
import androidx.media3.exoplayer.ExoPlayer
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
 * Media3 (ExoPlayer) ベースの再生エンジン実装。
 */
@Singleton
class Media3AudioPlayer @Inject constructor(
    @ApplicationContext private val context: Context
) : AudioPlayer {

    private var exoPlayer: ExoPlayer? = null
    private val queueManager = QueueManager()
    private val _playerState = MutableStateFlow(PlayerState())
    override val playerState: StateFlow<PlayerState> = _playerState.asStateFlow()

    private val scope = CoroutineScope(Dispatchers.Main + SupervisorJob())
    private var positionUpdateJob: Job? = null

    private fun getOrCreatePlayer(): ExoPlayer {
        return exoPlayer ?: ExoPlayer.Builder(context).build().also { player ->
            exoPlayer = player
            player.addListener(object : Player.Listener {
                override fun onPlaybackStateChanged(playbackState: Int) {
                    updateState()
                }

                override fun onIsPlayingChanged(isPlaying: Boolean) {
                    updateState()
                    if (isPlaying) startPositionUpdates() else stopPositionUpdates()
                }

                override fun onMediaItemTransition(mediaItem: MediaItem?, reason: Int) {
                    updateState()
                }
            })
        }
    }

    override fun play(song: Song) {
        val player = getOrCreatePlayer()
        val uri = getPlaybackUri(song) ?: return

        val mediaItem = MediaItem.Builder()
            .setUri(uri)
            .setMediaMetadata(
                MediaMetadata.Builder()
                    .setTitle(song.title)
                    .setArtist(song.artist)
                    .setAlbumTitle(song.album)
                    .setArtworkUri(song.albumArtUri)
                    .build()
            )
            .build()

        player.setMediaItem(mediaItem)
        player.prepare()
        player.play()

        queueManager.setQueue(listOf(song), 0)
        updateState()
    }

    override fun pause() {
        exoPlayer?.pause()
    }

    override fun resume() {
        exoPlayer?.play()
    }

    override fun stop() {
        exoPlayer?.stop()
        stopPositionUpdates()
        updateState()
    }

    override fun seekTo(positionMs: Long) {
        exoPlayer?.seekTo(positionMs)
        updateState()
    }

    override fun setQueue(songs: List<Song>, startIndex: Int) {
        val player = getOrCreatePlayer()
        queueManager.setQueue(songs, startIndex)

        val mediaItems = songs.map { song ->
            val uri = getPlaybackUri(song) ?: Uri.EMPTY
            MediaItem.Builder()
                .setUri(uri)
                .setMediaMetadata(
                    MediaMetadata.Builder()
                        .setTitle(song.title)
                        .setArtist(song.artist)
                        .setAlbumTitle(song.album)
                        .setArtworkUri(song.albumArtUri)
                        .build()
                )
                .build()
        }

        player.setMediaItems(mediaItems, startIndex, 0)
        player.prepare()
        player.play()
        updateState()
    }

    override fun skipToNext() {
        val player = exoPlayer ?: return
        if (player.hasNextMediaItem()) {
            player.seekToNextMediaItem()
            queueManager.skipToNext(_playerState.value.repeatMode)
        }
        updateState()
    }

    override fun skipToPrevious() {
        val player = exoPlayer ?: return
        if (player.currentPosition > 3000) {
            // 3秒以上再生していたら曲の先頭に戻る
            player.seekTo(0)
        } else if (player.hasPreviousMediaItem()) {
            player.seekToPreviousMediaItem()
            queueManager.skipToPrevious()
        }
        updateState()
    }

    override fun setRepeatMode(mode: RepeatMode) {
        exoPlayer?.repeatMode = when (mode) {
            RepeatMode.OFF -> Player.REPEAT_MODE_OFF
            RepeatMode.ALL -> Player.REPEAT_MODE_ALL
            RepeatMode.ONE -> Player.REPEAT_MODE_ONE
        }
        updateState()
    }

    override fun setShuffleEnabled(enabled: Boolean) {
        exoPlayer?.shuffleModeEnabled = enabled
        queueManager.setShuffle(enabled)
        updateState()
    }

    override fun getCurrentPosition(): Long {
        return exoPlayer?.currentPosition ?: 0L
    }

    override fun release() {
        stopPositionUpdates()
        scope.cancel()
        exoPlayer?.release()
        exoPlayer = null
        queueManager.clear()
        _playerState.value = PlayerState()
    }

    private fun getPlaybackUri(song: Song): Uri? {
        return when (song.source) {
            MusicSource.LOCAL -> song.contentUri ?: song.localPath?.let { Uri.parse(it) }
            MusicSource.DOWNLOAD -> song.localPath?.let { Uri.parse(it) }
            MusicSource.SMB -> {
                // SMBファイルの場合、ダウンロード済みのローカルパスがあればそれを使用
                song.localPath?.let { Uri.parse(it) }
                // TODO: SMBストリーミング用のカスタムDataSourceを実装
            }
        }
    }

    private fun updateState() {
        val player = exoPlayer
        _playerState.value = PlayerState(
            currentSong = queueManager.currentSong,
            isPlaying = player?.isPlaying ?: false,
            currentPosition = player?.currentPosition ?: 0L,
            duration = player?.duration?.coerceAtLeast(0) ?: 0L,
            queue = queueManager.currentQueue,
            currentQueueIndex = player?.currentMediaItemIndex ?: -1,
            repeatMode = when (player?.repeatMode) {
                Player.REPEAT_MODE_ALL -> RepeatMode.ALL
                Player.REPEAT_MODE_ONE -> RepeatMode.ONE
                else -> RepeatMode.OFF
            },
            isShuffleEnabled = player?.shuffleModeEnabled ?: false,
            isBuffering = player?.playbackState == Player.STATE_BUFFERING
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
