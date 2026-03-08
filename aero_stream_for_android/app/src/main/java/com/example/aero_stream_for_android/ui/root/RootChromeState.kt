package com.example.aero_stream_for_android.ui.root

import com.example.aero_stream_for_android.ui.library.LibraryCategory
import com.example.aero_stream_for_android.ui.library.LibraryFeatureState
import com.example.aero_stream_for_android.ui.library.LibrarySort

data class HeaderSpec(
    val enabled: Boolean,
    val title: String,
    val actions: List<HeaderAction> = emptyList(),
    val accessory: HeaderAccessorySpec = NoAccessory
)

data class BottomNavSpec(
    val visible: Boolean = true,
    val selected: RootPrimaryRoute? = null
)

sealed interface HeaderAccessorySpec

data object NoAccessory : HeaderAccessorySpec

data class LibraryAccessorySpec(
    val categories: List<LibraryCategory>,
    val selectedCategory: LibraryCategory,
    val sort: LibrarySort,
    val featureState: LibraryFeatureState
) : HeaderAccessorySpec

enum class HeaderAction {
    Search,
    SmbScan,
    CancelSmbScan,
    Settings
}
