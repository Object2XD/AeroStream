package com.example.aero_stream_for_android.ui.root

sealed interface ActiveOverlay

data object NoOverlay : ActiveOverlay

data object LibrarySourcePickerOverlay : ActiveOverlay

data object LibrarySortPickerOverlay : ActiveOverlay
