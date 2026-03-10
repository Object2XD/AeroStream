package com.example.aero_stream_for_android.player

import com.example.aero_stream_for_android.domain.model.RepeatMode
import com.example.aero_stream_for_android.domain.model.Song

/**
 * 再生キュー管理。
 * シャッフル時のオリジナル順序保持やキュー操作を行う。
 */
class QueueManager {

    private var originalQueue: List<Song> = emptyList()
    private var shuffledQueue: List<Song> = emptyList()
    private var currentIndex: Int = -1
    private var isShuffled: Boolean = false

    val currentQueue: List<Song>
        get() = if (isShuffled) shuffledQueue else originalQueue

    val currentSong: Song?
        get() = currentQueue.getOrNull(currentIndex)

    val currentQueueIndex: Int
        get() = currentIndex

    val hasNext: Boolean
        get() = currentIndex < currentQueue.size - 1

    val hasPrevious: Boolean
        get() = currentIndex > 0

    fun setQueue(songs: List<Song>, startIndex: Int = 0) {
        originalQueue = songs
        currentIndex = startIndex
        if (isShuffled) {
            reshuffleQueue()
        }
    }

    fun skipToNext(repeatMode: RepeatMode): Song? {
        return when {
            repeatMode == RepeatMode.ONE -> currentSong
            hasNext -> {
                currentIndex++
                currentSong
            }
            repeatMode == RepeatMode.ALL && currentQueue.isNotEmpty() -> {
                currentIndex = 0
                if (isShuffled) reshuffleQueue()
                currentSong
            }
            else -> null
        }
    }

    fun skipToPrevious(): Song? {
        return if (hasPrevious) {
            currentIndex--
            currentSong
        } else if (currentQueue.isNotEmpty()) {
            currentIndex = 0
            currentSong
        } else {
            null
        }
    }

    fun skipToIndex(index: Int): Song? {
        if (index in currentQueue.indices) {
            currentIndex = index
            return currentSong
        }
        return null
    }

    fun setShuffle(enabled: Boolean) {
        if (enabled && !isShuffled) {
            // Read currentSong before flipping the flag so it reads from originalQueue.
            // If we set isShuffled = true first, currentSong would read from the (still-empty)
            // shuffledQueue and fail to place the playing song at the front of the shuffle.
            val current = currentSong
            isShuffled = true
            shuffledQueue = originalQueue.shuffled()
            if (current != null) {
                val mutable = shuffledQueue.toMutableList()
                // Use reference equality first so that only this specific instance is removed,
                // preserving other songs that share the same ID.
                val indexByReference = mutable.indexOfFirst { it === current }
                val idxToRemove = if (indexByReference >= 0) indexByReference else mutable.indexOfFirst { it.id == current.id }
                if (idxToRemove >= 0) mutable.removeAt(idxToRemove)
                mutable.add(0, current)
                shuffledQueue = mutable
                currentIndex = 0
            }
        } else if (!enabled && isShuffled) {
            // シャッフル解除：現在再生中の曲をoriginalQueueで探す
            val current = currentSong
            isShuffled = false
            if (current != null) {
                currentIndex = originalQueue.indexOfFirst { it.id == current.id }
                    .coerceAtLeast(0)
            }
        }
    }

    fun addToQueue(song: Song) {
        originalQueue = originalQueue + song
        if (isShuffled) {
            shuffledQueue = shuffledQueue + song
        }
    }

    fun removeFromQueue(index: Int) {
        if (index !in currentQueue.indices) return

        if (isShuffled) {
            val removedSong = shuffledQueue[index]
            shuffledQueue = shuffledQueue.toMutableList().apply { removeAt(index) }
            originalQueue = originalQueue.filter { it.id != removedSong.id }
        } else {
            originalQueue = originalQueue.toMutableList().apply { removeAt(index) }
        }

        when {
            index < currentIndex -> currentIndex--
            index == currentIndex -> {
                if (currentIndex >= currentQueue.size) {
                    currentIndex = (currentQueue.size - 1).coerceAtLeast(0)
                }
            }
        }
    }

    fun clear() {
        originalQueue = emptyList()
        shuffledQueue = emptyList()
        currentIndex = -1
    }

    private fun reshuffleQueue() {
        val current = currentSong
        shuffledQueue = originalQueue.shuffled()
        if (current != null) {
            // 現在の曲を先頭に持ってくる
            val mutable = shuffledQueue.toMutableList()
            // Use reference equality first so that only this specific instance is removed,
            // preserving other songs that share the same ID.
            val indexByReference = mutable.indexOfFirst { it === current }
            val idxToRemove = if (indexByReference >= 0) indexByReference else mutable.indexOfFirst { it.id == current.id }
            if (idxToRemove >= 0) mutable.removeAt(idxToRemove)
            mutable.add(0, current)
            shuffledQueue = mutable
            currentIndex = 0
        }
    }
}
