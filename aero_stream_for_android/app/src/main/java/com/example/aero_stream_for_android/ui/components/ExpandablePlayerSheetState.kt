package com.example.aero_stream_for_android.ui.components

enum class ExpandablePlayerSheetValue {
    Hidden,
    Collapsed,
    Expanded
}

fun reconcilePlayerSheetValue(
    currentValue: ExpandablePlayerSheetValue,
    hasCurrentSong: Boolean
): ExpandablePlayerSheetValue = when {
    !hasCurrentSong -> ExpandablePlayerSheetValue.Hidden
    currentValue == ExpandablePlayerSheetValue.Hidden -> ExpandablePlayerSheetValue.Collapsed
    else -> currentValue
}

fun expandPlayerSheet(currentValue: ExpandablePlayerSheetValue): ExpandablePlayerSheetValue =
    when (currentValue) {
        ExpandablePlayerSheetValue.Hidden -> ExpandablePlayerSheetValue.Hidden
        else -> ExpandablePlayerSheetValue.Expanded
    }

fun collapsePlayerSheet(currentValue: ExpandablePlayerSheetValue): ExpandablePlayerSheetValue =
    when (currentValue) {
        ExpandablePlayerSheetValue.Hidden -> ExpandablePlayerSheetValue.Hidden
        else -> ExpandablePlayerSheetValue.Collapsed
    }

internal enum class ExpandablePlayerSheetAnchor {
    Collapsed,
    Expanded
}

internal fun ExpandablePlayerSheetAnchor.toSheetValue(): ExpandablePlayerSheetValue =
    when (this) {
        ExpandablePlayerSheetAnchor.Collapsed -> ExpandablePlayerSheetValue.Collapsed
        ExpandablePlayerSheetAnchor.Expanded -> ExpandablePlayerSheetValue.Expanded
    }
