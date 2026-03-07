package com.example.aero_stream_for_android.ui.library.content

import android.net.Uri
import androidx.activity.ComponentActivity
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Album
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Rule
import org.junit.Test

class SmbLibraryContentTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun mediaArtwork_showsImageNode_whenAlbumArtUriExists() {
        composeRule.setContent {
            AeroStreamTheme {
                MediaArtwork(
                    imageModel = Uri.parse("file:///tmp/smb_art.jpg"),
                    placeholder = Icons.Default.Album,
                    testTagPrefix = "smb_album"
                )
            }
        }

        composeRule.onNodeWithTag("smb_album_image").assertIsDisplayed()
        composeRule.onAllNodesWithTag("smb_album_placeholder").assertCountEquals(0)
    }

    @Test
    fun mediaArtwork_showsPlaceholder_whenAlbumArtUriIsNull() {
        composeRule.setContent {
            AeroStreamTheme {
                MediaArtwork(
                    imageModel = null,
                    placeholder = Icons.Default.Album,
                    testTagPrefix = "smb_album"
                )
            }
        }

        composeRule.onNodeWithTag("smb_album_placeholder").assertIsDisplayed()
        composeRule.onAllNodesWithTag("smb_album_image").assertCountEquals(0)
    }
}
