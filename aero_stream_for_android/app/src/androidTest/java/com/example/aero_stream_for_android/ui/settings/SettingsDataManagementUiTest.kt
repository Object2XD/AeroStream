package com.example.aero_stream_for_android.ui.settings

import androidx.activity.ComponentActivity
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onNodeWithText
import androidx.compose.ui.test.performClick
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Assert.assertEquals
import org.junit.Rule
import org.junit.Test

class SettingsDataManagementUiTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun clearLoadedMusicItem_isVisible() {
        composeRule.setContent {
            AeroStreamTheme {
                ClearLoadedMusicDatabaseItem(
                    isClearing = false,
                    onClick = {}
                )
            }
        }

        composeRule.onNodeWithText("読み込み済み曲DBをクリア").assertIsDisplayed()
        composeRule.onNodeWithText("曲DB・ダウンロード履歴・キャッシュファイルを削除します").assertIsDisplayed()
    }

    @Test
    fun clearLoadedMusicDialog_confirmAndCancel_triggerCallbacks() {
        var dismissCount = 0
        composeRule.setContent {
            AeroStreamTheme {
                ClearLoadedMusicDatabaseDialog(
                    isClearing = false,
                    onConfirm = {},
                    onDismiss = { dismissCount += 1 }
                )
            }
        }

        composeRule.onNodeWithText("キャンセル").performClick()
        composeRule.runOnIdle {
            assertEquals(1, dismissCount)
        }

        var confirmCount = 0
        composeRule.setContent {
            AeroStreamTheme {
                ClearLoadedMusicDatabaseDialog(
                    isClearing = false,
                    onConfirm = { confirmCount += 1 },
                    onDismiss = {}
                )
            }
        }
        composeRule.onNodeWithText("クリア").performClick()

        composeRule.runOnIdle {
            assertEquals(1, confirmCount)
        }
    }
}
