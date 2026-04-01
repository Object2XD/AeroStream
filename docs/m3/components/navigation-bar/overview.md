Title: Navigation bar – Material Design 3

URL Source: http://m3.material.io/components/navigation-bar/overview

Markdown Content:
Navigation bar – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/navigation-bar/overview#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Navigation bar
==============

Navigation bars let people switch between UI views on smaller devices

Resources

Close

[info Overview](https://m3.material.io/components/navigation-bar/overview)[style Specs](https://m3.material.io/components/navigation-bar/specs)[design_services Guidelines](https://m3.material.io/components/navigation-bar/guidelines)[head_mounted_device XR](https://m3.material.io/components/navigation-bar/xr)[accessibility_new Accessibility](https://m3.material.io/components/navigation-bar/accessibility)

On this page

*   [Availability & resources](https://m3.material.io/)
*   [M3 Expressive update](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

*   Use navigation bars in compact Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact) or medium Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium) window sizes
*   Can contain 3-5 destinations of equal importance
*   Destinations don't change. They should be consistent across app screens.

link

Copy link Link copied

![Image 1: Two navigation bars of different widths with 4 destinations.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fodjau-01.png?alt=media&token=2a83f14e-464f-4f96-9c01-eb770d98010e)

Navigation bar for compact and medium window sizes

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
| [Flutter](https://api.flutter.dev/flutter/material/NavigationBar-class.html) | Available |
| [android Jetpack Compose](https://developer.android.com/develop/ui/compose/components/navigation-bar) | Available |
| [android Jetpack Compose: Expressive](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#NavigationBar(androidx.compose.ui.Modifier,androidx.compose.ui.graphics.Color,androidx.compose.ui.graphics.Color,androidx.compose.ui.unit.Dp,androidx.compose.foundation.layout.WindowInsets,kotlin.Function1)) | Available |
| [android MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/components/BottomNavigation.md) | Available |
| [android MDC-Android: Expressive](https://github.com/material-components/material-components-android/blob/master/docs/components/BottomNavigation.md) | Available |
| language Web | Unavailable |
| language Web: Expressive | Unavailable |
Close

link

Copy link Link copied

M3 Expressive update
--------------------

link

Copy link Link copied

**May 2025**

A new flexible navigation bar was introduced to replace the baseline navigation bar. It’s shorter and supports horizontal navigation items in medium windows. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

link

Copy link Link copied

Variants and naming:

*   Baseline navigation bar is no longer recommended

*   Added **flexible**navigation bar

    *   Shorter height

    *   Can be used in medium window sizes with horizontal navigation items

Color:

*   Active label changed from **on-surface-variant** to **secondary**

![Image 2: Navigation bar in M3 Expressive. It’s shorter than the baseline nav bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmae7qe43-02.png?alt=media&token=52cdfa5b-8a10-45d5-af7c-0a92cc899672)

The flexible navigation bar is shorter and can be used in medium windows with horizontal nav items

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

*   Color: New color mappings and compatibility with dynamic color
*   Elevation: No shadow
*   Layout: Container height is taller
*   States: The active destination can be indicated with a pill shape in a contrasting color
*   Name: Bottom navigation has been renamed **navigation bar**

link

Copy link Link copied

![Image 3: M2 nav bar with a drop shadow and no active indicator.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0ddmjvm-03.png?alt=media&token=9e50be86-5460-46f5-90a7-0805ec3c9127)

M2: A drop shadow indicates placement on top of content. Filled and regular weight icons indicate active states.

![Image 4: M3 nav bar with a surface color and active indicator.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmae7pvz8-04.png?alt=media&token=98531a7d-df77-4d8e-a56b-7164db497bd9)

M3: Taller and no drop shadow. Filled icons and an active indicator indicate active state.

[arrow_left_alt Previous Menus: Overview](https://m3.material.io/components/menus)[Up next arrow_right_alt Navigation bar: Specs](https://m3.material.io/components/navigation-bar/specs)

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
