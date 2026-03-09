package com.example.aero_stream_for_android.ui.components

import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.Alignment
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithTag
import androidx.compose.ui.test.onNodeWithTag
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import androidx.compose.ui.test.performTouchInput
import androidx.compose.ui.test.swipeDown
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.PlayerState
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.ui.root.LibrarySourcePickerOverlay
import com.example.aero_stream_for_android.ui.root.NoOverlay
import com.example.aero_stream_for_android.ui.root.OverlayHost
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.LibrarySource
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

class ExpandablePlayerSheetTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun noSong_rendersNothing() {
        composeRule.setContent {
            AeroStreamTheme {
                ExpandablePlayerSheet(
                    playerState = PlayerState(),
                    sheetValue = ExpandablePlayerSheetValue.Hidden,
                    onSheetValueChange = {},
                    onPlayPause = {},
                    onSkipNext = {},
                    onSkipPrevious = {},
                    onSeek = {},
                    onRepeatModeChange = {},
                    onShuffleToggle = {},
                    bottomBarHeight = AeroCompactUiTokens.bottomNavHeight
                )
            }
        }

        composeRule.onAllNodesWithTag("collapsed_player").assertCountEquals(0)
        composeRule.onAllNodesWithTag("expanded_player").assertCountEquals(0)
    }

    @Test
    fun songPresent_startsCollapsed_andExpandsAndCollapses() {
        var sheetValue by mutableStateOf(ExpandablePlayerSheetValue.Collapsed)

        composeRule.setContent {
            AeroStreamTheme {
                ExpandablePlayerSheet(
                    playerState = samplePlayerState(),
                    sheetValue = sheetValue,
                    onSheetValueChange = { sheetValue = it },
                    onPlayPause = {},
                    onSkipNext = {},
                    onSkipPrevious = {},
                    onSeek = {},
                    onRepeatModeChange = {},
                    onShuffleToggle = {},
                    bottomBarHeight = AeroCompactUiTokens.bottomNavHeight
                )
            }
        }

        composeRule.onNodeWithTag("collapsed_player").assertIsDisplayed()
        composeRule.onNodeWithTag("expand_player").performClick()
        composeRule.onNodeWithTag("expanded_player").assertIsDisplayed()
        composeRule.onNodeWithTag("player_queue_summary").assertIsDisplayed()
        composeRule.onNodeWithTag("expanded_player").performTouchInput { swipeDown() }
        composeRule.onNodeWithTag("collapsed_player").assertIsDisplayed()
    }

    @Test
    fun collapsedSheet_staysAboveBottomNav_andExpandedSheetCoversIt() {
        var sheetValue by mutableStateOf(ExpandablePlayerSheetValue.Collapsed)

        composeRule.setContent {
            AeroStreamTheme {
                PlayerChromeHost(
                    sheetValue = sheetValue,
                    onSheetValueChange = { sheetValue = it },
                    activeOverlay = NoOverlay
                )
            }
        }

        val navBounds = composeRule.onNodeWithTag("bottom_nav").fetchSemanticsNode().boundsInRoot
        val collapsedBounds = composeRule.onNodeWithTag("collapsed_player").fetchSemanticsNode().boundsInRoot
        assertTrue(collapsedBounds.bottom <= navBounds.top)

        composeRule.onNodeWithTag("expand_player").performClick()

        val expandedBounds = composeRule.onNodeWithTag("expanded_player").fetchSemanticsNode().boundsInRoot
        assertTrue(expandedBounds.bottom > navBounds.top)
    }

    @Test
    fun overlayHost_staysVisibleAboveExpandedPlayer() {
        composeRule.setContent {
            AeroStreamTheme {
                PlayerChromeHost(
                    sheetValue = ExpandablePlayerSheetValue.Expanded,
                    onSheetValueChange = {},
                    activeOverlay = LibrarySourcePickerOverlay
                )
            }
        }

        composeRule.onNodeWithTag("expanded_player").assertIsDisplayed()
        composeRule.onNodeWithTag("player_queue_summary").assertIsDisplayed()
        composeRule.onNodeWithText("ライブラリソース").assertIsDisplayed()
    }

    @Test
    fun expandedSheet_hidesCollapsedProgressBar() {
        composeRule.setContent {
            AeroStreamTheme {
                ExpandablePlayerSheet(
                    playerState = samplePlayerState(),
                    sheetValue = ExpandablePlayerSheetValue.Expanded,
                    onSheetValueChange = {},
                    onPlayPause = {},
                    onSkipNext = {},
                    onSkipPrevious = {},
                    onSeek = {},
                    onRepeatModeChange = {},
                    onShuffleToggle = {},
                    bottomBarHeight = AeroCompactUiTokens.bottomNavHeight
                )
            }
        }

        composeRule.onNodeWithTag("expanded_player").assertIsDisplayed()
        composeRule.onAllNodesWithTag("collapsed_progress").assertCountEquals(0)
    }

    @Composable
    private fun PlayerChromeHost(
        sheetValue: ExpandablePlayerSheetValue,
        onSheetValueChange: (ExpandablePlayerSheetValue) -> Unit,
        activeOverlay: com.example.aero_stream_for_android.ui.root.ActiveOverlay
    ) {
        Box(modifier = Modifier.fillMaxSize()) {
            NavigationBar(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .testTag("bottom_nav")
            ) {
                Text("Library")
            }

            ExpandablePlayerSheet(
                playerState = samplePlayerState(),
                sheetValue = sheetValue,
                onSheetValueChange = onSheetValueChange,
                onPlayPause = {},
                onSkipNext = {},
                onSkipPrevious = {},
                onSeek = {},
                onRepeatModeChange = {},
                onShuffleToggle = {},
                bottomBarHeight = AeroCompactUiTokens.bottomNavHeight
            )

            OverlayHost(
                activeOverlay = activeOverlay,
                selectedSource = LibrarySource.LocalFiles,
                selectedSort = LibrarySort(LibrarySortKey.Name, SortOrder.Asc),
                availableSortKeys = listOf(LibrarySortKey.Name, LibrarySortKey.Artist),
                onDismiss = {},
                onSelectSource = {},
                onConfirmSort = {}
            )
        }
    }

    private fun samplePlayerState(): PlayerState {
        val queue = listOf(
            Song(
                id = 1L,
                title = "星獣戦隊ギンガマン",
                artist = "希砂未竜",
                album = "スーパー戦隊シリーズ",
                duration = 228000L,
                source = MusicSource.LOCAL
            ),
            Song(
                id = 2L,
                title = "救急戦隊ゴーゴーファイブ",
                artist = "石原慎一",
                album = "スーパー戦隊シリーズ",
                duration = 235000L,
                source = MusicSource.LOCAL
            )
        )

        return PlayerState(
            currentSong = queue.first(),
            isPlaying = true,
            currentPosition = 18000L,
            duration = 228000L,
            queue = queue,
            currentQueueIndex = 0
        )
    }
}
