package com.example.aero_stream_for_android.ui.library.content

import androidx.activity.ComponentActivity
import androidx.compose.ui.test.assertHeightIsEqualTo
import androidx.compose.ui.test.assertWidthIsEqualTo
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithContentDescription
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.unit.dp
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Rule
import org.junit.Test

class AlbumCacheBadgeTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun albumCacheBadge_showsCheck_whenFullyCached() {
        composeRule.setContent {
            AeroStreamTheme {
                AlbumCacheBadge(isFullyCached = true)
            }
        }

        composeRule.onNodeWithContentDescription("アルバムはキャッシュ済み").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("アルバムはキャッシュ済み").assertWidthIsEqualTo(14.dp)
        composeRule.onNodeWithContentDescription("アルバムはキャッシュ済み").assertHeightIsEqualTo(14.dp)
        composeRule.onAllNodesWithContentDescription("アルバムに未キャッシュ曲あり").assertCountEquals(0)
    }

    @Test
    fun albumCacheBadge_showsCloud_whenNotFullyCached() {
        composeRule.setContent {
            AeroStreamTheme {
                AlbumCacheBadge(isFullyCached = false)
            }
        }

        composeRule.onNodeWithContentDescription("アルバムに未キャッシュ曲あり").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("アルバムに未キャッシュ曲あり").assertWidthIsEqualTo(14.dp)
        composeRule.onNodeWithContentDescription("アルバムに未キャッシュ曲あり").assertHeightIsEqualTo(14.dp)
        composeRule.onAllNodesWithContentDescription("アルバムはキャッシュ済み").assertCountEquals(0)
    }

    @Test
    fun localAlbumRow_hidesBadge_whenShowStatusBadgeIsFalse() {
        composeRule.setContent {
            AeroStreamTheme {
                AlbumRow(
                    album = Album(
                        id = 1L,
                        name = "Local Album",
                        artist = "Local Artist",
                        songCount = 10,
                        cachedSongCount = 10,
                        isFullyCached = true
                    ),
                    onClick = {},
                    showStatusBadge = false
                )
            }
        }

        composeRule.onAllNodesWithContentDescription("アルバムはキャッシュ済み").assertCountEquals(0)
        composeRule.onAllNodesWithContentDescription("アルバムに未キャッシュ曲あり").assertCountEquals(0)
    }
}
