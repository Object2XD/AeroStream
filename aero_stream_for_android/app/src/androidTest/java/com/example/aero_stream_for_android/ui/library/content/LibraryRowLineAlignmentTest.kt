package com.example.aero_stream_for_android.ui.library.content

import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Column
import androidx.compose.ui.geometry.Rect
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithText
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.components.SongListItem
import com.example.aero_stream_for_android.ui.components.SongListItemStyle
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test
import kotlin.math.abs

class LibraryRowLineAlignmentTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun songRow_andAlbumRow_haveAlignedTitleAndSubtitleLines() {
        val song = Song(
            id = 1L,
            title = "Song Row Title",
            artist = "Song Artist",
            album = "Song Album",
            duration = 180_000L,
            source = MusicSource.SMB,
            smbPath = "seed/demo/track_1.mp3",
            isCached = false
        )
        val album = Album(
            id = 10L,
            name = "Album Row Title",
            artist = "Album Artist",
            songCount = 3,
            isFullyCached = false
        )

        composeRule.setContent {
            AeroStreamTheme {
                Column {
                    SongListItem(
                        song = song,
                        onClick = {},
                        style = SongListItemStyle.WithStatusBadge
                    )
                    AlbumRow(
                        album = album,
                        onClick = {},
                        showStatusBadge = true
                    )
                }
            }
        }

        val songTitleBounds = composeRule.onNodeWithText("Song Row Title").fetchSemanticsNode().boundsInRoot
        val songSubtitleBounds = composeRule.onNodeWithText("Song Artist · 3:00").fetchSemanticsNode().boundsInRoot
        val albumTitleBounds = composeRule.onNodeWithText("Album Row Title").fetchSemanticsNode().boundsInRoot
        val albumSubtitleBounds = composeRule.onNodeWithText("アルバム・Album Artist").fetchSemanticsNode().boundsInRoot

        assertLineAligned(songTitleBounds, songSubtitleBounds, albumTitleBounds, albumSubtitleBounds)
    }

    @Test
    fun songRow_andLocalAlbumRow_haveAlignedTitleAndSubtitleLines() {
        val song = Song(
            id = 2L,
            title = "Song Local Title",
            artist = "Local Artist",
            album = "Local Album",
            duration = 181_000L,
            source = MusicSource.LOCAL
        )
        val album = Album(
            id = 20L,
            name = "Album Local Title",
            artist = "Local Artist",
            songCount = 5,
            isFullyCached = true
        )

        composeRule.setContent {
            AeroStreamTheme {
                Column {
                    SongListItem(
                        song = song,
                        onClick = {},
                        style = SongListItemStyle.CompactNoBadge
                    )
                    AlbumRow(
                        album = album,
                        onClick = {},
                        showStatusBadge = false
                    )
                }
            }
        }

        val songTitleBounds = composeRule.onNodeWithText("Song Local Title").fetchSemanticsNode().boundsInRoot
        val songSubtitleBounds = composeRule.onNodeWithText("Local Artist · 3:01").fetchSemanticsNode().boundsInRoot
        val albumTitleBounds = composeRule.onNodeWithText("Album Local Title").fetchSemanticsNode().boundsInRoot
        val albumSubtitleBounds = composeRule.onNodeWithText("アルバム・Local Artist").fetchSemanticsNode().boundsInRoot

        assertLineAligned(songTitleBounds, songSubtitleBounds, albumTitleBounds, albumSubtitleBounds)
    }

    private fun assertLineAligned(
        songTitle: Rect,
        songSubtitle: Rect,
        albumTitle: Rect,
        albumSubtitle: Rect
    ) {
        val tolerancePx = 2f
        val songGap = songSubtitle.top - songTitle.top
        val albumGap = albumSubtitle.top - albumTitle.top

        assertTrue(
            "title top mismatch: song=${songTitle.top}, album=${albumTitle.top}",
            abs(songTitle.top - albumTitle.top) <= tolerancePx
        )
        assertTrue(
            "subtitle top mismatch: song=${songSubtitle.top}, album=${albumSubtitle.top}",
            abs(songSubtitle.top - albumSubtitle.top) <= tolerancePx
        )
        assertTrue(
            "line gap mismatch: songGap=$songGap, albumGap=$albumGap",
            abs(songGap - albumGap) <= tolerancePx
        )
    }
}
