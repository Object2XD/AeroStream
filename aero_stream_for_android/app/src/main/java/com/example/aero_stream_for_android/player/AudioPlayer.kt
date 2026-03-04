package com.example.aero_stream_for_android.player

import com.example.aero_stream_for_android.domain.model.PlayerState
import com.example.aero_stream_for_android.domain.model.RepeatMode
import com.example.aero_stream_for_android.domain.model.Song
import kotlinx.coroutines.flow.StateFlow

/**
 * オーディオプレイヤーの抽象インターフェース。
 * Media3 と MediaPlayer の実装を切り替え可能にする。
 */
interface AudioPlayer {

    /** 現在のプレイヤー状態を監視する */
    val playerState: StateFlow<PlayerState>

    /** 楽曲を再生する */
    fun play(song: Song)

    /** 一時停止する */
    fun pause()

    /** 再生を再開する */
    fun resume()

    /** 停止する */
    fun stop()

    /** 指定位置にシークする（ミリ秒） */
    fun seekTo(positionMs: Long)

    /** 再生キューをセットして開始する */
    fun setQueue(songs: List<Song>, startIndex: Int = 0)

    /** 次の曲へスキップする */
    fun skipToNext()

    /** 前の曲へスキップする */
    fun skipToPrevious()

    /** リピートモードを設定する */
    fun setRepeatMode(mode: RepeatMode)

    /** シャッフルモードを設定する */
    fun setShuffleEnabled(enabled: Boolean)

    /** 現在の再生位置を取得する（ミリ秒） */
    fun getCurrentPosition(): Long

    /** リソースを解放する */
    fun release()
}
