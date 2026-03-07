package com.example.aero_stream_for_android.ui.root

import androidx.activity.ComponentActivity
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.LibrarySource
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

class OverlayHostTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun noOverlay_showsNoSheets() {
        composeRule.setContent {
            AeroStreamTheme {
                OverlayHost(
                    activeOverlay = NoOverlay,
                    selectedSource = LibrarySource.LocalFiles,
                    selectedSort = LibrarySort(),
                    availableSortKeys = listOf(LibrarySortKey.Name, LibrarySortKey.Artist),
                    onDismiss = {},
                    onSelectSource = {},
                    onConfirmSort = {}
                )
            }
        }

        composeRule.onAllNodesWithText("ライブラリソース").assertCountEquals(0)
        composeRule.onAllNodesWithText("並び替えオプション").assertCountEquals(0)
    }

    @Test
    fun sourceOverlay_showsSheet_andSelectionAndDismissCallbacksFlow() {
        var dismissed = false
        var selectedSource: LibrarySource? = null

        composeRule.setContent {
            AeroStreamTheme {
                OverlayHost(
                    activeOverlay = LibrarySourcePickerOverlay,
                    selectedSource = LibrarySource.LocalFiles,
                    selectedSort = LibrarySort(),
                    availableSortKeys = listOf(LibrarySortKey.Name, LibrarySortKey.Artist),
                    onDismiss = { dismissed = true },
                    onSelectSource = { selectedSource = it },
                    onConfirmSort = {}
                )
            }
        }

        composeRule.onNodeWithText("ライブラリソース").assertIsDisplayed()
        composeRule.onNodeWithText("SMB").performClick()
        composeRule.onNodeWithContentDescription("閉じる").performClick()

        composeRule.runOnIdle {
            assertEquals(LibrarySource.SMB, selectedSource)
            assertTrue(dismissed)
        }
    }

    @Test
    fun sortOverlay_showsSheet_respectsAvailableKeys_andReturnsConfirmedSort() {
        val confirmedSorts = mutableListOf<LibrarySort>()
        var dismissed = false

        composeRule.setContent {
            AeroStreamTheme {
                OverlayHost(
                    activeOverlay = LibrarySortPickerOverlay,
                    selectedSource = LibrarySource.LocalFiles,
                    selectedSort = LibrarySort(LibrarySortKey.Name, SortOrder.Asc),
                    availableSortKeys = listOf(LibrarySortKey.Name, LibrarySortKey.Year),
                    onDismiss = { dismissed = true },
                    onSelectSource = {},
                    onConfirmSort = { confirmedSorts += it }
                )
            }
        }

        composeRule.onNodeWithText("並び替えオプション").assertIsDisplayed()
        composeRule.onNodeWithText("名前").assertIsDisplayed()
        composeRule.onNodeWithText("年").assertIsDisplayed()
        composeRule.onAllNodesWithText("アーティスト").assertCountEquals(0)

        composeRule.onNodeWithText("年").performClick()
        composeRule.onNodeWithText("降順").performClick()
        composeRule.onNodeWithContentDescription("閉じる").performClick()

        composeRule.runOnIdle {
            assertEquals(
                listOf(
                    LibrarySort(LibrarySortKey.Year, SortOrder.Asc),
                    LibrarySort(LibrarySortKey.Name, SortOrder.Desc)
                ),
                confirmedSorts
            )
            assertTrue(dismissed)
        }
    }
}
