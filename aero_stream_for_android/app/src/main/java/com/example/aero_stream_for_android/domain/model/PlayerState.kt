package com.example.aero_stream_for_android.domain.model

/**
 * プレイヤーの状態を表すドメインモデル。
 */
data class PlayerState(
    val currentSong: Song? = null,
    val isPlaying: Boolean = false,
    val currentPosition: Long = 0L,
    val duration: Long = 0L,
    val queue: List<Song> = emptyList(),
    val currentQueueIndex: Int = -1,
    val repeatMode: RepeatMode = RepeatMode.OFF,
    val isShuffleEnabled: Boolean = false,
    val isBuffering: Boolean = false,
    val error: String? = null
)

/**
 * リピートモード。
 */
enum class RepeatMode {
    /** リピートなし */
    OFF,
    /** 全曲リピート */
    ALL,
    /** 1曲リピート */
    ONE
}

/**
 * 使用する再生エンジンの種類。
 */
enum class AudioEngine {
    MEDIA3,
    MEDIA_PLAYER
}
