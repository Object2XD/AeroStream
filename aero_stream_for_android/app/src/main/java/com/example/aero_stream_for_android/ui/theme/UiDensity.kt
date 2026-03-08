package com.example.aero_stream_for_android.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp

object AeroCompactUiTokens {
    val screenHorizontalPadding = 16.dp
    val headerTopPadding = 6.dp
    val headerBottomPadding = 10.dp
    val headerActionIconSize = 20.dp
    val headerActionButtonVisualPadding = 8.dp
    val chipSpacing = 10.dp
    val chipMinHeight = 32.dp
    val chipCornerRadius = 18.dp
    val chipHorizontalPadding = 18.dp
    val chipVerticalPadding = 8.dp
    val sortRowTopPadding = 18.dp
    val sortRowBottomPadding = 14.dp
    val sortToggleInnerPadding = 8.dp
    val listArtworkSize = 60.dp
    val listRowVerticalPadding = 8.dp
    val listTextStartPadding = 12.dp
    val listTextEndPadding = 4.dp
    val statusBadgeIconSize = 14.dp
    val listOverflowIconSize = 20.dp
    val fastScrollerTouchWidth = 28.dp
    val fastScrollerTrackWidth = 3.dp
    val fastScrollerThumbWidth = 8.dp
    val fastScrollerThumbHeight = 24.dp
    val fastScrollerBubbleMinWidth = 36.dp
    val fastScrollerBubbleMinHeight = 28.dp
    val fastScrollerBubbleGap = 10.dp
    const val fastScrollerBubbleBackgroundAlpha = 0.92f
    val gridHorizontalSpacing = 16.dp
    val gridVerticalSpacing = 16.dp
    val gridCaptionSpacing = 8.dp
    val albumDetailHorizontalPadding = 24.dp
    val albumDetailTopOverlayPaddingTop = 8.dp
    val albumDetailHeroTopSpacing = 72.dp
    val albumDetailArtworkMaxWidth = 300.dp
    val albumDetailArtworkCornerRadius = 10.dp
    val albumDetailPrimaryPlayButtonSize = 80.dp
    val albumDetailSecondaryActionButtonSize = 56.dp
    val albumDetailFloatingPlayButtonSize = 76.dp
    val albumDetailBottomPlayTopPadding = 72.dp
    val albumDetailBottomPlayBottomClearance = 0.dp
    val albumDetailTrackRowVerticalPadding = 10.dp
    val albumDetailListBottomPadding = 24.dp
    val miniPlayerArtworkSize = 44.dp
    val miniPlayerRowPaddingHorizontal = 8.dp
    val miniPlayerRowPaddingVertical = 6.dp
    val miniPlayerTextPaddingHorizontal = 10.dp
    val playerSheetPeekHeight = 64.dp
    val playerSheetCollapsedArtworkSize = 44.dp
    val playerSheetCollapsedHorizontalPadding = 10.dp
    val playerSheetCollapsedVerticalPadding = 8.dp
    val playerSheetExpandedHorizontalPadding = 24.dp
    val playerSheetExpandedBottomPadding = 28.dp
    val playerSheetExpandedArtworkMaxSize = 320.dp
    val playerSheetExpandedArtworkCornerRadius = 20.dp
    val playerSheetExpandedMetadataTopGap = 20.dp
    val playerSheetExpandedControlsTopGap = 24.dp
    val playerSheetExpandedControlsBottomPadding = 28.dp
    val playerSheetExpandedQueueSummaryTopPadding = 16.dp
    val playerSheetCollapsedCornerRadius = 28.dp
    val playerSheetTopBarVerticalPadding = 10.dp
    val playerSheetDragHandleWidth = 40.dp
    val playerSheetDragHandleHeight = 4.dp
    val playerSheetDragHandleGap = 10.dp
    val playerSheetSeekBarIdleHeight = 4.dp
    val playerSheetSeekBarDraggingHeight = 12.dp
    val playerSheetContentBottomSpacing = 8.dp
    const val playerSheetSurfaceAlpha = 1f
    const val playerSheetScrimMaxAlpha = 0.22f
    val emptyStateIconSize = 56.dp
    // val bottomNavHeight = 64.dp
    val bottomNavHeight = 78.dp
    val bottomNavIconSize = 24.dp
    val cardCornerRadius = 14.dp
    val cardOuterHorizontalPadding = 16.dp
    val cardOuterVerticalPadding = 4.dp
    val cardContentHorizontalPadding = 12.dp
    val cardContentVerticalPadding = 10.dp
    val cardContentSpacing = 8.dp
    val chipActionMinHeight = 48.dp
    val chipIconSize = 20.dp
    val bottomCardHeaderHorizontalPadding = 20.dp
    val bottomCardHeaderVerticalPadding = 12.dp
    val bottomCardBodyTopPadding = 10.dp
    val bottomCardBodyBottomPadding = 24.dp
    val bottomCardSectionGap = 10.dp
    val bottomCardSectionTitleTopPadding = 14.dp
    val bottomCardSectionTitleBottomPadding = 8.dp
    val bottomCardOptionHorizontalPadding = 20.dp
    val bottomCardOptionVerticalPadding = 6.dp
    val bottomCardOptionCornerRadius = 14.dp
    val bottomCardOptionMinHeight = 52.dp
    val bottomCardOptionInnerHorizontalPadding = 14.dp
    val bottomCardOptionInnerVerticalPadding = 14.dp

    @Composable
    fun headerPrimaryTextStyle(): TextStyle {
        return MaterialTheme.typography.headlineLarge.copy(fontWeight = FontWeight.ExtraBold)
    }

    @Composable
    fun headerSecondaryTextStyle(): TextStyle {
        return MaterialTheme.typography.titleLarge
    }

    @Composable
    fun headerTertiaryTextStyle(): TextStyle {
        return MaterialTheme.typography.bodySmall
    }

    @Composable
    fun chipLabelTextStyle(): TextStyle {
        return MaterialTheme.typography.titleSmall
    }

    @Composable
    fun chipSelectedContainerColor(): Color {
        return MaterialTheme.colorScheme.onSurface
    }

    @Composable
    fun chipSelectedLabelColor(): Color {
        return MaterialTheme.colorScheme.surfaceVariant
    }

    @Composable
    fun sortLabelTextStyle(): TextStyle {
        return MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold)
    }

    @Composable
    fun rowTitleTextStyle(): TextStyle {
        return MaterialTheme.typography.bodyMedium.copy(fontWeight = FontWeight.SemiBold)
    }

    @Composable
    fun rowSubtitleTextStyle(): TextStyle {
        return MaterialTheme.typography.bodyMedium
    }

    @Composable
    fun gridSubtitleTextStyle(): TextStyle {
        return MaterialTheme.typography.bodySmall
    }

    @Composable
    fun albumDetailTitleTextStyle(): TextStyle {
        return MaterialTheme.typography.displaySmall.copy(fontWeight = FontWeight.SemiBold)
    }

    @Composable
    fun albumDetailMetaTextStyle(): TextStyle {
        return MaterialTheme.typography.titleMedium
    }

    @Composable
    fun albumDetailTrackNumberTextStyle(): TextStyle {
        return MaterialTheme.typography.titleMedium
    }

    @Composable
    fun albumDetailTrackTitleTextStyle(): TextStyle {
        return MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.Medium)
    }

    @Composable
    fun albumDetailTrackSubtitleTextStyle(): TextStyle {
        return MaterialTheme.typography.titleMedium
    }

    @Composable
    fun albumDetailCollapsedTitleTextStyle(): TextStyle {
        return MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold)
    }

    @Composable
    fun albumDetailFooterTextStyle(): TextStyle {
        return MaterialTheme.typography.titleLarge
    }

    @Composable
    fun topAppBarTitleTextStyle(): TextStyle {
        return MaterialTheme.typography.titleLarge.copy(fontWeight = FontWeight.SemiBold)
    }

    @Composable
    fun sectionHeaderTextStyle(): TextStyle {
        return MaterialTheme.typography.titleSmall
    }

    @Composable
    fun bottomNavLabelTextStyle(): TextStyle {
        return MaterialTheme.typography.labelMedium
    }

    @Composable
    fun cardContainerColor(): Color {
        return MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.46f)
    }
}
