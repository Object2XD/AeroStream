package com.example.aero_stream_for_android.ui.root

import androidx.activity.ComponentActivity
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assert
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.library.LibraryFeatureState
import com.example.aero_stream_for_android.ui.library.LibrarySort
import com.example.aero_stream_for_android.ui.library.LibrarySortKey
import com.example.aero_stream_for_android.ui.library.LibrarySource
import com.example.aero_stream_for_android.ui.library.SortOrder
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

class QuickReturnHeaderContainerTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun topHeader_showsTitleAndActions_withoutLibraryAccessory() {
        composeRule.setContent {
            AeroStreamTheme {
                QuickReturnHeaderContainer(
                    spec = HeaderSpec(
                        enabled = true,
                        title = "Top",
                        actions = listOf(HeaderAction.Search, HeaderAction.Settings)
                    ),
                    onHeaderHeightChanged = {},
                    onActionClick = {},
                    onCategorySelected = {},
                    onOpenSortPicker = {}
                )
            }
        }

        composeRule.onNodeWithText("Top").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("Search").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("Settings").assertIsDisplayed()
        composeRule.onAllNodesWithText("曲").assertCountEquals(0)
        composeRule.onAllNodesWithText("アルバム").assertCountEquals(0)
    }

    @Test
    fun libraryHeader_showsAccessoryAndSelectedCategorySemantics() {
        composeRule.setContent {
            AeroStreamTheme {
                QuickReturnHeaderContainer(
                    spec = libraryHeaderSpec(),
                    onHeaderHeightChanged = {},
                    onActionClick = {},
                    onCategorySelected = {},
                    onOpenSortPicker = {}
                )
            }
        }

        composeRule.onNodeWithText("Library").assertIsDisplayed()
        composeRule.onNodeWithText("曲").assertIsDisplayed()
        composeRule.onNodeWithText("アルバム").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("並び替え: 名前 / 昇順").assertIsDisplayed()
        composeRule.onNodeWithText("アルバム")
            .assert(SemanticsMatcher.expectValue(SemanticsProperties.Selected, true))
    }

    @Test
    fun headerActions_andAccessoryCallbacks_flowToCallers() {
        val actions = mutableListOf<HeaderAction>()
        val selectedCategories = mutableListOf<LibraryCategory>()
        var sortPickerOpened = false
        var reportedHeight = -1

        composeRule.setContent {
            AeroStreamTheme {
                QuickReturnHeaderContainer(
                    spec = libraryHeaderSpec(),
                    onHeaderHeightChanged = { reportedHeight = it },
                    onActionClick = { actions += it },
                    onCategorySelected = { selectedCategories += it },
                    onOpenSortPicker = { sortPickerOpened = true }
                )
            }
        }

        composeRule.onNodeWithContentDescription("Search").performClick()
        composeRule.onNodeWithContentDescription("Settings").performClick()
        composeRule.onNodeWithText("曲").performClick()
        composeRule.onNodeWithContentDescription("並び替え: 名前 / 昇順").performClick()

        composeRule.runOnIdle {
            assertEquals(listOf(HeaderAction.Search, HeaderAction.Settings), actions)
            assertEquals(listOf(LibraryCategory.Songs), selectedCategories)
            assertTrue(sortPickerOpened)
            assertTrue(reportedHeight > 0)
        }
    }

    private fun libraryHeaderSpec(): HeaderSpec {
        val featureState = LibraryFeatureState(
            source = LibrarySource.LocalFiles,
            category = LibraryCategory.Albums,
            sort = LibrarySort(LibrarySortKey.Name, SortOrder.Asc)
        )
        return HeaderSpec(
            enabled = true,
            title = "Library",
            actions = listOf(HeaderAction.Search, HeaderAction.Settings),
            accessory = LibraryAccessorySpec(
                categories = listOf(LibraryCategory.Songs, LibraryCategory.Albums, LibraryCategory.Artists),
                selectedCategory = LibraryCategory.Albums,
                sort = featureState.sort,
                featureState = featureState
            )
        )
    }
}
