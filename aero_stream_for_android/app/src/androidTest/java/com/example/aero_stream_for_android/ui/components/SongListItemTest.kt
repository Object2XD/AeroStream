package com.example.aero_stream_for_android.ui.components

import androidx.activity.ComponentActivity
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithContentDescription
import androidx.compose.ui.test.onNodeWithContentDescription
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Rule
import org.junit.Test

class SongListItemTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun songListItem_showsCloudBadge_andDownloadButton_forSmbNotCached() {
        val song = Song(
            id = 1L,
            title = "SMB Song",
            artist = "Artist",
            album = "Album",
            duration = 120_000L,
            source = MusicSource.SMB,
            smbPath = "share\\song.mp3",
            isCached = false
        )

        composeRule.setContent {
            AeroStreamTheme {
                SongListItem(
                    song = song,
                    onClick = {},
                    showDownloadIcon = true
                )
            }
        }

        composeRule.onNodeWithContentDescription("SMB").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("Download").assertIsDisplayed()
        composeRule.onAllNodesWithContentDescription("Downloaded").assertCountEquals(0)
    }

    @Test
    fun songListItem_showsDownloadedBadge_andHidesDownloadButton_forCachedSong() {
        val song = Song(
            id = 2L,
            title = "Cached Song",
            artist = "Artist",
            album = "Album",
            duration = 120_000L,
            source = MusicSource.SMB,
            smbPath = "share\\song_cached.mp3",
            isCached = true
        )

        composeRule.setContent {
            AeroStreamTheme {
                SongListItem(
                    song = song,
                    onClick = {},
                    showDownloadIcon = true
                )
            }
        }

        composeRule.onNodeWithContentDescription("Downloaded").assertIsDisplayed()
        composeRule.onAllNodesWithContentDescription("Download").assertCountEquals(0)
        composeRule.onAllNodesWithContentDescription("SMB").assertCountEquals(0)
    }
}
