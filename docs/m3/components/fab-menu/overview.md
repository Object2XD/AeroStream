Title: FAB menu

URL Source: http://m3.material.io/components/fab-menu/overview

Markdown Content:
FAB menu
===============

[Skip to main content](https://m3.material.io/components/fab-menu/overview#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

FAB menu
========

The floating action button (FAB) menu opens from a FAB to display multiple related actions

Resources

Close

[info Overview](https://m3.material.io/components/fab-menu/overview)[style Specs](https://m3.material.io/components/fab-menu/specs)[design_services Guidelines](https://m3.material.io/components/fab-menu/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/fab-menu/accessibility)

On this page

*   [Availability & resources](https://m3.material.io/)
*   [M3 Expressive update](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

*   Opens from a FAB Floating action buttons (FABs) help people take primary actions. [More on FABs](https://m3.material.io/m3/pages/fab/overview) to show 2–6 related actions floating on screen
*   One FAB menu size for all sizes of FABs
*   Not used with extended FABs Extended floating action buttons (extended FABs) help people take primary actions. [More on extended FABs](https://m3.material.io/m3/pages/extended-fab/overview)
*   Available in primary, secondary, and tertiary color sets

link

Copy link Link copied

![Image 1: 3 FAB menus in different color schemes.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0aj37mw-01.png?alt=media&token=1ac9e775-2541-4a63-8818-d76cf8570699)

The FAB menu comes in three color sets: primary, secondary, tertiary

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
| [android Jetpack Compose: Expressive](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#FloatingActionButtonMenu(kotlin.Boolean,kotlin.Function0,androidx.compose.ui.Modifier,androidx.compose.ui.Alignment.Horizontal,kotlin.Function1)) | Available |
| android MDC-Android: Expressive | Unavailable |
| language Web: Expressive | Unavailable |
Close

link

Copy link Link copied

M3 Expressive update
--------------------

link

Copy link Link copied

**May 2025**

The FAB menu adds more options to the FAB. It should replace the speed dial and any usage of stacked small FABs. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

link

Copy link Link copied

New component added to catalog:

*   One menu size that pairs with any FAB
*   Replaces any usage of stacked small FABs

Color:

*   Contrasting close button and item colors
*   Supports dynamic color
*   Compatible with any FAB color style

![Image 2: 4 screens. The FAB menu is on the first, and 3 FABs of different sizes are on the others.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0aj3ip6-02.png?alt=media&token=fde56cc4-c285-45ef-9019-faa06da95454)

The FAB menu uses contrasting color and large items to focus attention. It can open from any size FAB.

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

![Image 3: M2 speed dial.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0aj3w24-Diff%20GM2.png?alt=media&token=e358569f-0a63-4ead-a844-ad98804cee2d)

M2: The speed dial used small round FABs

![Image 4: GM3 FAB menu.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0aj42vs-Diff%20GM3%20Expressive.png?alt=media&token=b0d9f87d-66c0-48f4-9a11-e312b5b207ef)

M3: The FAB menu uses dynamic color and a larger item size

[arrow_left_alt Previous Extended FABs: Overview](https://m3.material.io/components/extended-fab)[Up next arrow_right_alt FAB menu: Specs](https://m3.material.io/components/fab-menu/specs)

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
