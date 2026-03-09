package com.example.aero_stream_for_android.ui.settings

import androidx.activity.ComponentActivity
import androidx.compose.ui.test.assertCountEquals
import androidx.compose.ui.test.assertIsDisplayed
import androidx.compose.ui.test.junit4.createAndroidComposeRule
import androidx.compose.ui.test.onAllNodesWithText
import androidx.compose.ui.test.onNodeWithContentDescription
import androidx.compose.ui.test.onNodeWithTag
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import org.junit.Assert.assertTrue
import org.junit.Rule
import org.junit.Test

class SettingsScreenSmbSectionTest {

    @get:Rule
    val composeRule = createAndroidComposeRule<ComponentActivity>()

    @Test
    fun smbSection_rendersTwoLevelCard_andIconOnlyActions() {
        val config = SmbConfig(
            id = "cfg1",
            displayName = "spica",
            hostname = "192.168.0.56",
            shareName = "archive",
            rootPath = "google_play_music/very/long/path/for/ellipsis/check"
        )

        composeRule.setContent {
            AeroStreamTheme {
                SmbServersSection(
                    smbConfigs = listOf(config),
                    onAdd = {},
                    onEdit = { _ -> },
                    onDelete = { _ -> },
                    onRefresh = {},
                    onBrowse = {}
                )
            }
        }

        composeRule.onNodeWithTag("settings_smb_section").assertIsDisplayed()
        composeRule.onNodeWithTag("smb_cfg1_status_icon").assertIsDisplayed()
        composeRule.onNodeWithTag("smb_cfg1_title").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("更新: spica").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("Browse: spica").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("編集: spica").assertIsDisplayed()
        composeRule.onNodeWithContentDescription("削除: spica").assertIsDisplayed()
        composeRule.onAllNodesWithText("更新").assertCountEquals(0)
        composeRule.onAllNodesWithText("Browse").assertCountEquals(0)
        composeRule.onAllNodesWithText("編集").assertCountEquals(0)
        composeRule.onAllNodesWithText("削除").assertCountEquals(0)
    }

    @Test
    fun smbSection_alignsStatusAndTitleToTopRowBaseline() {
        val config = SmbConfig(
            id = "cfg2",
            displayName = "orion",
            hostname = "10.0.0.1",
            shareName = "music",
            rootPath = "root"
        )

        composeRule.setContent {
            AeroStreamTheme {
                SmbServersSection(
                    smbConfigs = listOf(config),
                    onAdd = {},
                    onEdit = { _ -> },
                    onDelete = { _ -> },
                    onRefresh = {},
                    onBrowse = {}
                )
            }
        }

        val statusBounds = composeRule.onNodeWithTag("smb_cfg2_status_icon").fetchSemanticsNode().boundsInRoot
        val titleBounds = composeRule.onNodeWithTag("smb_cfg2_title").fetchSemanticsNode().boundsInRoot
        val anchorBounds = composeRule.onNodeWithTag("smb_cfg2_top_anchor").fetchSemanticsNode().boundsInRoot

        val statusCenter = (statusBounds.top + statusBounds.bottom) / 2f
        val titleCenter = (titleBounds.top + titleBounds.bottom) / 2f
        val anchorCenter = (anchorBounds.top + anchorBounds.bottom) / 2f

        assertTrue(kotlin.math.abs(statusCenter - titleCenter) < 20f)
        assertTrue(kotlin.math.abs(statusCenter - anchorCenter) < 20f)
    }
}
