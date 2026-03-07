package com.example.aero_stream_for_android.ui.root.overlay

import androidx.activity.ComponentActivity
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assert
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.LibrarySource
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test

class BottomCardSheetsTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun sourceSheet_usesJapaneseLabels_andSelectsImmediately() {
        var selectedSource: LibrarySource? = null

        composeRule.setContent {
            AeroStreamTheme {
                LibrarySourcePickerSheet(
                    selectedSource = LibrarySource.LocalFiles,
                    onDismiss = {},
                    onSelect = { selectedSource = it }
                )
            }
        }

        composeRule.onNodeWithText("ライブラリソース").assertIsDisplayed()
        composeRule.onNodeWithText("ローカルファイル").assertIsDisplayed()
        composeRule.onNodeWithText("SMB").assertIsDisplayed()
        composeRule.onNodeWithText("キャッシュ").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("ライブラリソース: ローカルファイル")
            .assert(
                SemanticsMatcher.expectValue(SemanticsProperties.Selected, true)
            )

        composeRule.onNodeWithText("SMB").performClick()
        composeRule.runOnIdle {
            assertEquals(LibrarySource.SMB, selectedSource)
        }
    }

    @Test
    fun sortSheet_usesJapaneseSections_andConfirmsImmediately() {
        var confirmedSort: LibrarySort? = null
        val initialSort = LibrarySort(key = LibrarySortKey.Name, order = SortOrder.Asc)

        composeRule.setContent {
            AeroStreamTheme {
                LibrarySortPickerSheet(
                    selectedSort = initialSort,
                    availableKeys = listOf(LibrarySortKey.Name, LibrarySortKey.Artist, LibrarySortKey.Year),
                    onDismiss = {},
                    onConfirm = { confirmedSort = it }
                )
            }
        }

        composeRule.onNodeWithText("並び替えオプション").assertIsDisplayed()
        composeRule.onNodeWithText("キー").assertIsDisplayed()
        composeRule.onNodeWithText("順序").assertIsDisplayed()
        composeRule.onNodeWithText("名前").assertIsDisplayed()
        composeRule.onNodeWithText("アーティスト").assertIsDisplayed()
        composeRule.onNodeWithText("昇順").assertIsDisplayed()
        composeRule.onNodeWithText("降順").assertIsDisplayed()

        composeRule.onNodeWithText("降順").performClick()
        composeRule.runOnIdle {
            assertEquals(SortOrder.Desc, confirmedSort?.order)
        }
    }
}
