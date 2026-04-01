Title: Toolbar

URL Source: http://m3.material.io/components/toolbars/overview

Markdown Content:
Toolbar
===============

[Skip to main content](https://m3.material.io/components/toolbars/overview#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

 play_arrow 

 pause 

 dark_mode 

 light_mode 

[](https://m3.material.io/components)[](https://m3.material.io/components/app-bars)[](https://m3.material.io/components/badges)

[](https://m3.material.io/components/all-buttons)[](https://m3.material.io/components/button-groups)[](https://m3.material.io/components/buttons)[](https://m3.material.io/components/extended-fab)[](https://m3.material.io/components/fab-menu)[](https://m3.material.io/components/floating-action-button)[](https://m3.material.io/components/icon-buttons)[](https://m3.material.io/components/segmented-buttons)[](https://m3.material.io/components/split-button)

[](https://m3.material.io/components/cards)[](https://m3.material.io/components/carousel)[](https://m3.material.io/components/checkbox)[](https://m3.material.io/components/chips)

[](https://m3.material.io/components/date-pickers)[](https://m3.material.io/components/time-pickers)

[](https://m3.material.io/components/dialogs)[](https://m3.material.io/components/divider)[](https://m3.material.io/components/lists)

[](https://m3.material.io/components/loading-indicator)[](https://m3.material.io/components/progress-indicators)

[](https://m3.material.io/components/menus)

[](https://m3.material.io/components/navigation-bar)[](https://m3.material.io/components/navigation-drawer)[](https://m3.material.io/components/navigation-rail)

[](https://m3.material.io/components/radio-button)[](https://m3.material.io/components/search)

[](https://m3.material.io/components/bottom-sheets)[](https://m3.material.io/components/side-sheets)

[](https://m3.material.io/components/sliders)[](https://m3.material.io/components/snackbar)[](https://m3.material.io/components/switch)[](https://m3.material.io/components/tabs)[](https://m3.material.io/components/text-fields)[](https://m3.material.io/components/toolbars)[](https://m3.material.io/components/tooltips)

Toolbars
========

Toolbars display frequently used actions relevant to the current page

Resources

Close

[info Overview](https://m3.material.io/components/toolbars/overview)[style Specs](https://m3.material.io/components/toolbars/specs)[design_services Guidelines](https://m3.material.io/components/toolbars/guidelines)[head_mounted_device XR](https://m3.material.io/components/toolbars/xr)[accessibility_new Accessibility](https://m3.material.io/components/toolbars/accessibility)

On this page

*   [Availability & resources](https://m3.material.io/)
*   [M3 Expressive update](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

*   Two expressive variants: **docked toolbar** and **floating toolbar**

*   Use the vibrant color style for greater emphasis

*   Can display a wide variety of control types, like buttons, icon buttons, and text fields

*   Can be paired with FABs to emphasize certain actions

*   Don’t show at the same time as a navigation bar

link

Copy link Link copied

![Image 1: 2 variants of toolbars.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0aionfm-01.png?alt=media&token=0f1d71f5-1d22-4820-859d-fd952e995cf9)

Configurations of floating toolbars

link

Copy link Link copied

Availability & resources
------------------------

link

Copy link Link copied

| Type | Resource | Status |
| --- | --- | --- |
| Design |
| [Design Kit (Figma)](https://www.figma.com/community/file/1035203688168086460) | Available |
| Implementation |
| [Flutter](https://api.flutter.dev/flutter/material/BottomAppBar-class.html) | Available |
| [android Jetpack Compose](https://developer.android.com/develop/ui/compose/components/app-bars#bottom) | Available |
| [android Jetpack Compose: Expressive](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#FloatingToolbarState(kotlin.Float,kotlin.Float,kotlin.Float)) | Available |
| [android MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/components/BottomAppBar.md) | Available |
| [android MDC-Android: Expressive](https://github.com/material-components/material-components-android/blob/master/docs/components/BottomAppBar.md) | Available |
| language Web | Unavailable |
| language Web: Expressive | Unavailable |
Close

link

Copy link Link copied

M3 Expressive update
--------------------

link

Copy link Link copied

The **bottom app bar** is no longer recommended and should be replaced with the **docked toolbar**, which functions similarly, but is shorter and has more flexibility. The **floating toolbar** was created for more versatility, greater amounts of actions, and more variety in where it's placed.[More on GM3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

link

Copy link Link copied

Variants and naming:

*   Added **docked toolbar**to replace **bottom app bar**

    *   Size: Shorter height

    *   Color: Standard or vibrant

    *   Flexibility: More layout and element options

*   Added **floating toolbar** with the following configurations:

    *   Layout: Horizontal or vertical

    *   Color: Standard or vibrant

    *   Flexibility: Can hold many elements and components. Can be paired with FAB.

*   **Bottom app bar**is still available, but not recommended

![Image 2: 2 examples of toolbar variants.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0aiswog-02.png?alt=media&token=e5523e45-647f-4168-b257-c773be63adf6)

1.   Floating, vibrant color scheme and paired with FAB
2.   Docked with embedded primary action instead of FAB

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

*   Color: New color mappings and compatibility with dynamic color
*   Elevation: No shadow
*   Layout: Container height is taller and the FAB is now contained within the app bar container

link

Copy link Link copied

![Image 3: M2 bottom app bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0e7liab-2.png?alt=media&token=16c3ad53-7e83-4079-85ad-9b096bbb56fc)

M2: Bottom app bar had higher elevation of 8dp and didn't contain the FAB

![Image 4: M3 bottom app bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0e7mh6v-3.png?alt=media&token=9dfb6612-f40c-4d4c-a773-463109db7c5f)

M3: Bottom app bar has new colors, a taller container, no elevation or shadow, and contains the FAB

[arrow_left_alt Previous Text fields: Overview](https://m3.material.io/components/text-fields)[Up next arrow_right_alt Toolbars: Specs](https://m3.material.io/components/toolbars/specs)

vertical_align_top

[material_design](https://m3.material.io/)
Material Design is an adaptable system of guidelines, components, and tools that support the best practices of user interface design. Backed by open-source code, Material Design streamlines collaboration between designers and developers, and helps teams quickly build beautiful products.

*   ### Social

*   [GitHub](https://www.github.com/material-components)
*   [X](https://x.com/googledesign)
*   [YouTube](https://www.youtube.com/@googledesign)
*   [Blog RSS](https://material.io/feed.xml)

*   ### Libraries

*   [Android](https://m3.material.io/develop/android/mdc-android)
*   [Compose](https://m3.material.io/develop/android/jetpack-compose)
*   [Flutter](https://m3.material.io/develop/flutter)
*   [Web](https://m3.material.io/develop/web)

*   ### Archived versions

*   [Material Design 1](https://m1.material.io/)
*   [Material Design 2](https://m2.material.io/)

[](https://www.google.com/)

*   [Privacy Policy](https://policies.google.com/privacy)
*   [Terms of Service](https://policies.google.com/terms)
*   [Join research studies](https://google.qualtrics.com/jfe/form/SV_3NMIMtX0F2zkakR?utm_source=Website&Q_Language=en&utm_campaign=Q2&campaignDate=June2022&referral_code=UXRgbtM2422655&productTag=b2d)
*   [Feedback](javascript:void(0))
