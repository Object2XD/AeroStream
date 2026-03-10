package com.example.aero_stream_for_android.player

import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.RepeatMode
import com.example.aero_stream_for_android.domain.model.Song
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Before
import org.junit.Test

class QueueManagerTest {

    private lateinit var queueManager: QueueManager

    private fun song(id: Long) = Song(
        id = id,
        title = "Song $id",
        artist = "Artist",
        album = "Album",
        duration = 1000L,
        source = MusicSource.LOCAL
    )

    @Before
    fun setUp() {
        queueManager = QueueManager()
    }

    // =====================================================================
    // 空キューでの各操作
    // =====================================================================

    @Test
    fun emptyQueue_currentSong_isNull() {
        assertNull(queueManager.currentSong)
    }

    @Test
    fun emptyQueue_skipToNext_withRepeatOff_returnsNull() {
        assertNull(queueManager.skipToNext(RepeatMode.OFF))
    }

    @Test
    fun emptyQueue_skipToNext_withRepeatAll_returnsNull() {
        assertNull(queueManager.skipToNext(RepeatMode.ALL))
    }

    @Test
    fun emptyQueue_skipToPrevious_returnsNull() {
        assertNull(queueManager.skipToPrevious())
    }

    @Test
    fun emptyQueue_removeFromQueue_isNoop() {
        queueManager.removeFromQueue(0)
        assertNull(queueManager.currentSong)
        assertTrue(queueManager.currentQueue.isEmpty())
    }

    @Test
    fun emptyQueue_clear_doesNotThrow() {
        queueManager.clear()
        assertNull(queueManager.currentSong)
        assertEquals(-1, queueManager.currentQueueIndex)
    }

    @Test
    fun emptyQueue_setShuffle_doesNotThrow() {
        queueManager.setShuffle(true)
        assertNull(queueManager.currentSong)
    }

    @Test
    fun emptyQueue_addToQueue_appendsSong() {
        queueManager.addToQueue(song(1))
        assertEquals(1, queueManager.currentQueue.size)
    }

    // =====================================================================
    // setQueue に範囲外 index が渡された場合
    // =====================================================================

    @Test
    fun setQueue_withNegativeStartIndex_currentSongIsNull() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = -1)
        assertNull(queueManager.currentSong)
        assertEquals(-1, queueManager.currentQueueIndex)
    }

    @Test
    fun setQueue_withStartIndexEqualToSize_currentSongIsNull() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 3)
        assertNull(queueManager.currentSong)
    }

    @Test
    fun setQueue_withStartIndexBeyondSize_currentSongIsNull() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 100)
        assertNull(queueManager.currentSong)
    }

    @Test
    fun setQueue_withValidStartIndex_setsCurrentSong() {
        val songs = listOf(song(1), song(2), song(3))
        queueManager.setQueue(songs, startIndex = 1)
        assertEquals(song(2), queueManager.currentSong)
        assertEquals(1, queueManager.currentQueueIndex)
    }

    @Test
    fun setQueue_defaultStartIndex_setsFirstSongAsCurrent() {
        queueManager.setQueue(listOf(song(1), song(2)))
        assertEquals(song(1), queueManager.currentSong)
    }

    // =====================================================================
    // 先頭/末尾での skipToNext / skipToPrevious
    // =====================================================================

    @Test
    fun skipToNext_atLastPosition_withRepeatOff_returnsNull() {
        queueManager.setQueue(listOf(song(1), song(2)), startIndex = 1)
        assertNull(queueManager.skipToNext(RepeatMode.OFF))
        assertEquals(1, queueManager.currentQueueIndex)
    }

    @Test
    fun skipToNext_atLastPosition_withRepeatAll_wrapsToIndexZero() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 2)
        val result = queueManager.skipToNext(RepeatMode.ALL)
        assertNotNull(result)
        assertEquals(0, queueManager.currentQueueIndex)
    }

    @Test
    fun skipToNext_withRepeatOne_returnsSameSong_withoutMoving() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 1)
        val expected = queueManager.currentSong
        val result = queueManager.skipToNext(RepeatMode.ONE)
        assertEquals(expected, result)
        assertEquals(1, queueManager.currentQueueIndex)
    }

    @Test
    fun skipToNext_notAtEnd_advancesIndex() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 0)
        val result = queueManager.skipToNext(RepeatMode.OFF)
        assertEquals(song(2), result)
        assertEquals(1, queueManager.currentQueueIndex)
    }

    @Test
    fun skipToPrevious_atFirstPosition_returnsFirstSong_withoutMovingBack() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 0)
        val result = queueManager.skipToPrevious()
        assertEquals(song(1), result)
        assertEquals(0, queueManager.currentQueueIndex)
    }

    @Test
    fun skipToPrevious_notAtFirst_movesToPreviousSong() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 2)
        val result = queueManager.skipToPrevious()
        assertEquals(song(2), result)
        assertEquals(1, queueManager.currentQueueIndex)
    }

    // =====================================================================
    // shuffle ON/OFF 切り替え時の currentIndex の整合性
    // =====================================================================

    @Test
    fun setShuffle_enable_currentSongIsPreservedAtIndexZero() {
        val songs = listOf(song(1), song(2), song(3), song(4), song(5))
        queueManager.setQueue(songs, startIndex = 2) // playing song(3)
        val songBeforeShuffle = queueManager.currentSong

        queueManager.setShuffle(true)

        assertEquals(songBeforeShuffle, queueManager.currentSong)
        assertEquals(0, queueManager.currentQueueIndex)
    }

    @Test
    fun setShuffle_enable_shuffledQueueContainsAllOriginalSongs() {
        val songs = listOf(song(1), song(2), song(3), song(4), song(5))
        queueManager.setQueue(songs, startIndex = 0)
        queueManager.setShuffle(true)

        val shuffled = queueManager.currentQueue
        assertEquals(songs.size, shuffled.size)
        assertTrue(shuffled.containsAll(songs))
    }

    @Test
    fun setShuffle_disable_restoresOriginalQueuePositionOfCurrentSong() {
        val songs = listOf(song(1), song(2), song(3), song(4), song(5))
        queueManager.setQueue(songs, startIndex = 2) // song(3) at index 2
        queueManager.setShuffle(true)
        // current song is song(3) at index 0 in shuffled queue

        queueManager.setShuffle(false)

        assertEquals(song(3), queueManager.currentSong)
        assertEquals(2, queueManager.currentQueueIndex)
    }

    @Test
    fun setShuffle_disable_restoresOriginalQueue() {
        val songs = listOf(song(1), song(2), song(3))
        queueManager.setQueue(songs, startIndex = 0)
        queueManager.setShuffle(true)
        queueManager.setShuffle(false)

        assertEquals(songs, queueManager.currentQueue)
    }

    @Test
    fun setShuffle_toggleOnOff_currentSongRemainsConsistentThroughCycle() {
        val songs = listOf(song(1), song(2), song(3), song(4))
        queueManager.setQueue(songs, startIndex = 1) // song(2)

        queueManager.setShuffle(true)
        assertEquals(song(2), queueManager.currentSong)

        queueManager.setShuffle(false)
        assertEquals(song(2), queueManager.currentSong)
        assertEquals(1, queueManager.currentQueueIndex)
    }

    // =====================================================================
    // 現在再生中の曲を remove した場合の挙動
    // =====================================================================

    @Test
    fun removeFromQueue_currentSong_notLast_currentSongBecomesNext() {
        // Queue: [song1, song2, song3], playing song2 at index 1
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 1)
        queueManager.removeFromQueue(1)
        // After removal queue is [song1, song3]; index stays at 1 → song3
        assertEquals(song(3), queueManager.currentSong)
        assertEquals(1, queueManager.currentQueueIndex)
    }

    @Test
    fun removeFromQueue_currentSong_isLast_currentIndexClampsToNewLast() {
        // Queue: [song1, song2, song3], playing song3 at index 2
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 2)
        queueManager.removeFromQueue(2)
        // After removal queue is [song1, song2]; index clamped to 1 → song2
        assertEquals(song(2), queueManager.currentSong)
        assertEquals(1, queueManager.currentQueueIndex)
    }

    @Test
    fun removeFromQueue_currentSong_onlyOneSong_queueBecomesEmpty() {
        queueManager.setQueue(listOf(song(1)), startIndex = 0)
        queueManager.removeFromQueue(0)
        assertNull(queueManager.currentSong)
        assertTrue(queueManager.currentQueue.isEmpty())
    }

    @Test
    fun removeFromQueue_beforeCurrentIndex_currentSongUnchanged_indexDecrements() {
        // Queue: [song1, song2, song3], playing song3 at index 2
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 2)
        queueManager.removeFromQueue(0) // remove song1
        // After removal queue is [song2, song3]; current song still song3 at new index 1
        assertEquals(song(3), queueManager.currentSong)
        assertEquals(1, queueManager.currentQueueIndex)
    }

    @Test
    fun removeFromQueue_afterCurrentIndex_doesNotAffectCurrentSong() {
        // Queue: [song1, song2, song3], playing song1 at index 0
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 0)
        queueManager.removeFromQueue(2) // remove song3
        assertEquals(song(1), queueManager.currentSong)
        assertEquals(0, queueManager.currentQueueIndex)
    }

    @Test
    fun removeFromQueue_outOfBounds_isNoop() {
        val songs = listOf(song(1), song(2))
        queueManager.setQueue(songs, startIndex = 0)
        queueManager.removeFromQueue(-1)
        queueManager.removeFromQueue(2)
        assertEquals(2, queueManager.currentQueue.size)
        assertEquals(song(1), queueManager.currentSong)
    }

    // =====================================================================
    // repeatMode == ALL と shuffle の組み合わせ
    // =====================================================================

    @Test
    fun skipToNext_atEnd_withRepeatAll_notShuffled_wrapsToFirstSong() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 2)
        val result = queueManager.skipToNext(RepeatMode.ALL)
        assertEquals(song(1), result)
        assertEquals(0, queueManager.currentQueueIndex)
    }

    @Test
    fun skipToNext_atEnd_withRepeatAll_andShuffled_reshufflesAndReturnsSongAtIndexZero() {
        val songs = listOf(song(1), song(2), song(3))
        queueManager.setQueue(songs, startIndex = 0)
        queueManager.setShuffle(true)
        // Advance to the last position of the shuffled queue
        repeat(songs.size - 1) { queueManager.skipToNext(RepeatMode.OFF) }

        val result = queueManager.skipToNext(RepeatMode.ALL)

        assertNotNull(result)
        assertEquals(0, queueManager.currentQueueIndex)
        assertEquals(songs.size, queueManager.currentQueue.size)
    }

    @Test
    fun skipToNext_repeatAll_shuffled_afterWrap_queueContainsAllSongs() {
        val songs = listOf(song(1), song(2), song(3), song(4))
        queueManager.setQueue(songs, startIndex = 0)
        queueManager.setShuffle(true)
        // Play through entire queue and wrap around
        repeat(songs.size - 1) { queueManager.skipToNext(RepeatMode.ALL) }
        queueManager.skipToNext(RepeatMode.ALL)

        assertEquals(songs.size, queueManager.currentQueue.size)
        assertTrue(queueManager.currentQueue.containsAll(songs))
    }

    // =====================================================================
    // 同一 ID を持つ Song が混在した場合の挙動
    // =====================================================================

    @Test
    fun setQueue_withDuplicateIds_setsCurrentSongByIndex() {
        val songs = listOf(song(1), song(1), song(2))
        queueManager.setQueue(songs, startIndex = 1)
        // Index 1 is the second occurrence of song(1)
        assertEquals(song(1), queueManager.currentSong)
        assertEquals(1, queueManager.currentQueueIndex)
    }

    @Test
    fun setShuffle_disable_withDuplicateIds_resolvesToFirstMatchInOriginalQueue() {
        val songs = listOf(song(1), song(1), song(2))
        queueManager.setQueue(songs, startIndex = 0) // first song(1)
        queueManager.setShuffle(true)
        queueManager.setShuffle(false)
        // indexOfFirst for id=1 always returns 0
        assertEquals(0, queueManager.currentQueueIndex)
    }

    @Test
    fun removeFromQueue_shuffled_withDuplicateIds_removesAllMatchingFromOriginalQueue() {
        val songA1 = Song(id = 1L, title = "A1", artist = "A", album = "A", duration = 1000L, source = MusicSource.LOCAL)
        val songA2 = Song(id = 1L, title = "A2", artist = "A", album = "A", duration = 2000L, source = MusicSource.LOCAL)
        val songB  = song(2)
        queueManager.setQueue(listOf(songA1, songA2, songB), startIndex = 0)
        queueManager.setShuffle(true)

        // Remove whichever song with id=1 appears first in the shuffled queue
        val indexToRemove = queueManager.currentQueue.indexOfFirst { it.id == 1L }
        queueManager.removeFromQueue(indexToRemove)

        // originalQueue.filter removes ALL songs with that id, so both A1 and A2 are gone
        assertTrue(queueManager.currentQueue.none { it.id == 1L })
    }

    // =====================================================================
    // skipToIndex
    // =====================================================================

    @Test
    fun skipToIndex_validIndex_setsCurrentSong() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 0)
        val result = queueManager.skipToIndex(2)
        assertEquals(song(3), result)
        assertEquals(2, queueManager.currentQueueIndex)
    }

    @Test
    fun skipToIndex_negativeIndex_returnsNull() {
        queueManager.setQueue(listOf(song(1), song(2)), startIndex = 0)
        assertNull(queueManager.skipToIndex(-1))
    }

    @Test
    fun skipToIndex_beyondEnd_returnsNull() {
        queueManager.setQueue(listOf(song(1), song(2)), startIndex = 0)
        assertNull(queueManager.skipToIndex(2))
    }

    // =====================================================================
    // addToQueue
    // =====================================================================

    @Test
    fun addToQueue_notShuffled_appendsSong() {
        queueManager.setQueue(listOf(song(1), song(2)), startIndex = 0)
        queueManager.addToQueue(song(3))
        assertEquals(3, queueManager.currentQueue.size)
        assertEquals(song(3), queueManager.currentQueue.last())
    }

    @Test
    fun addToQueue_whileShuffled_appendsSongToShuffledQueue() {
        queueManager.setQueue(listOf(song(1), song(2)), startIndex = 0)
        queueManager.setShuffle(true)
        queueManager.addToQueue(song(3))
        assertEquals(3, queueManager.currentQueue.size)
        assertTrue(queueManager.currentQueue.contains(song(3)))
    }

    // =====================================================================
    // clear
    // =====================================================================

    @Test
    fun clear_resetsAllState() {
        queueManager.setQueue(listOf(song(1), song(2), song(3)), startIndex = 1)
        queueManager.clear()
        assertNull(queueManager.currentSong)
        assertEquals(-1, queueManager.currentQueueIndex)
        assertTrue(queueManager.currentQueue.isEmpty())
    }
}
