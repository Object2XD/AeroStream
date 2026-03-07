package com.example.aero_stream_for_android.ui.settings

import androidx.activity.ComponentActivity
import androidx.compose.ui.semantics.SemanticsProperties
import androidx.compose.ui.test.SemanticsMatcher
import androidx.compose.ui.test.assert
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import com.example.aero_stream_for_android.ui.components.AeroConfirmationSheet
import com.example.aero_stream_for_android.ui.components.AeroSheetScaffold
import com.example.aero_stream_for_android.ui.components.AeroSheetSectionTitle
import com.example.aero_stream_for_android.ui.components.AeroSingleChoiceOptionRow
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test

class SettingsModalsDesignTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun singleChoiceRow_exposesSelectedSemantics_andHandlesTap() {
        var clicked = 0
        composeRule.setContent {
            AeroStreamTheme {
                AeroSheetScaffold(
                    title = "テーマモード",
                    onDismiss = {}
                ) {
                    AeroSheetSectionTitle(text = "選択")
                    AeroSingleChoiceOptionRow(
                        label = "ダーク",
                        selected = true,
                        onClick = { clicked += 1 },
                        contentDescription = "テーマモード: ダーク"
                    )
                }
            }
        }

        composeRule.onNodeWithText("テーマモード").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("テーマモード: ダーク")
            .assert(SemanticsMatcher.expectValue(SemanticsProperties.Selected, true))
            .performClick()

        composeRule.runOnIdle {
            assertEquals(1, clicked)
        }
    }

    @Test
    fun confirmationSheet_showsContent_andCallsActions() {
        var confirmCount = 0
        var dismissCount = 0

        composeRule.setContent {
            AeroStreamTheme {
                AeroConfirmationSheet(
                    title = "SMB設定を削除",
                    message = "「spica」を削除しますか？",
                    confirmLabel = "削除",
                    dismissLabel = "キャンセル",
                    onConfirm = { confirmCount += 1 },
                    onDismiss = { dismissCount += 1 },
                    destructiveConfirm = true,
                    confirmContentDescription = "削除: spica",
                    dismissContentDescription = "キャンセル: spica"
                )
            }
        }

        composeRule.onNodeWithText("SMB設定を削除").assertIsDisplayed()
        composeRule.onNodeWithText("「spica」を削除しますか？").assertIsDisplayed()

        composeRule.onNodeWithContentDescription("キャンセル: spica").performClick()
        composeRule.onNodeWithContentDescription("削除: spica").performClick()

        composeRule.runOnIdle {
            assertEquals(1, dismissCount)
            assertEquals(1, confirmCount)
        }
    }
}
