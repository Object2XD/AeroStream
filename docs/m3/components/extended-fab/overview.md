Title: Extended FAB – Material Design 3

URL Source: http://m3.material.io/components/extended-fab/overview

Markdown Content:
Extended FAB – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/extended-fab/overview#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Extended FABs
=============

Resources

Close

[info Overview](https://m3.material.io/components/extended-fab/overview)[style Specs](https://m3.material.io/components/extended-fab/specs)[design_services Guidelines](https://m3.material.io/components/extended-fab/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/extended-fab/accessibility)

On this page

*   [Availability & resources](https://m3.material.io/)
*   [M3 Expressive update](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

*   Use for the most common or important action on a screen

*   Three variants: small, medium, and large

*   Use instead of FAB when label text is needed to understand action

link

Copy link Link copied

![Image 1: 3 extended fab sizes.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0df17xu-01.png?alt=media&token=06dfec2a-47be-4659-a524-86f136cec764)

1.   Small extended FAB
2.   Medium extended FAB
3.   Large extended FAB

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
| [Flutter](https://api.flutter.dev/flutter/material/FloatingActionButton-class.html) | Available |
| [android Jetpack Compose](https://developer.android.com/develop/ui/compose/components/fab?hl=en#extended) | Available |
| [android Jetpack Compose: Expressive](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#ExtendedFloatingActionButton(kotlin.Function0,androidx.compose.ui.Modifier,androidx.compose.ui.graphics.Shape,androidx.compose.ui.graphics.Color,androidx.compose.ui.graphics.Color,androidx.compose.material3.FloatingActionButtonElevation,androidx.compose.foundation.interaction.MutableInteractionSource,kotlin.Function1)) | Available |
| [android MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/components/FloatingActionButton.md#extended-fabs) | Available |
| [android MDC-Android: Expressive](https://github.com/material-components/material-components-android/blob/master/docs/components/FloatingActionButton.md#extended-fabs) | Available |
| [language Web](https://github.com/material-components/material-web/blob/main/docs/components/fab.md) | Available |
| language Web: Expressive | Unavailable |
Close

link

Copy link Link copied

M3 Expressive update
--------------------

link

Copy link Link copied

**May 2025**

The extended FAB now has three sizes: small, medium, and large, each with updated type styles. These align with the FAB Floating action buttons (FABs) help people take primary actions. [More on FABs](https://m3.material.io/m3/pages/fab/overview) sizes for an easier transition between FABs. The baseline extended FAB is no longer recommended and should be replaced with the small extended FAB. Surface and FABs are also no longer recommended. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

link

Copy link Link copied

Variants and naming:

*   Added new sizes

    *   Small: 56dp

    *   Medium: 80dp

    *   Large: 96dp

*   No longer recommended

    *   Baseline extended FAB (56dp)

    *   Surface extended FAB

Updates:

*   Adjusted typography to be larger

![Image 2: The baseline extended FAB and the small, medium, and large extended FABs from the expressive update.](https://lh3.googleusercontent.com/o8RP_K8msVBonOVgmcnANIcH_obxNxoaP2OKhzTpcLR6f6W8f2TJH0x2t0k703n-EIp_WM4_fMyA4JBqwpHbw0Z7Xdvpub3Ulltel37QN-8=w40)![Image 3: The baseline extended FAB and the small, medium, and large extended FABs from the expressive update.](https://lh3.googleusercontent.com/o8RP_K8msVBonOVgmcnANIcH_obxNxoaP2OKhzTpcLR6f6W8f2TJH0x2t0k703n-EIp_WM4_fMyA4JBqwpHbw0Z7Xdvpub3Ulltel37QN-8=s0)

The baseline extended FAB is replaced with a set of small, medium, and large extended FABs with new typography

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

*   Color: New color mappings and compatibility with dynamic color
*   Layout: Extended FAB is the same height as the FAB
*   Shape: Boxier style with smaller corner radius

link

Copy link Link copied

![Image 4: Diagram comparing the M2 FAB and extended FAB.](https://lh3.googleusercontent.com/CLwhLFrMkpEgnOAWORcnTMHBqt8gZ67coHMiSw1taCuxR0nRqasV1w7XWJ50w6ZT6gD6aZql87KrxZHdqiWya-bPwCnZx20ibdoKjagt7kyW9Q=w40)

M2: Extended FABs are pill-shaped and have a different height and elevation

![Image 5: Diagram comparing the M3 FAB and extended FAB.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0dff6p3-05.png?alt=media&token=896b601f-21d9-4cae-854f-840ba268dd73)

M3: Extended FABs share the same height, boxier shape, and simpler elevation model as FABs

[arrow_left_alt Previous Buttons: Overview](https://m3.material.io/components/buttons)[Up next arrow_right_alt Extended FABs: Specs](https://m3.material.io/components/extended-fab/specs)

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
