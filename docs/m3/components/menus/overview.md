Title: Menus – Material Design 3

URL Source: http://m3.material.io/components/menus/overview

Markdown Content:
Menus – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/menus/overview#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Menus
=====

Resources

Close

[info Overview](https://m3.material.io/components/menus/overview)[style Specs](https://m3.material.io/components/menus/specs)[design_services Guidelines](https://m3.material.io/components/menus/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/menus/accessibility)

On this page

*   [Availability & resources](https://m3.material.io/)
*   [M3 Expressive update](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

*   Use a **menu** to show a temporary set of actions. To show actions on screen at all times, use a **toolbar Toolbars display frequently used actions relevant to the current page. [More on toolbars](https://m3.material.io/m3/pages/toolbars/overview)** instead
*   Menus can open from many components, including icon buttons Icon buttons help people take minor actions with one tap. [More on icon buttons](https://m3.material.io/m3/pages/icon-buttons/overview), split buttons The split button opens a menu to give people more options related to an action. [More on split buttons](https://m3.material.io/m3/pages/split-buttons/overview), and text fields Text fields let users enter text into a UI. [More on text fields](https://m3.material.io/m3/pages/text-fields/overview)
*   **Context menus** provide actions for a specific element, like an image or highlighted text, and usually open with a secondary click

link

Copy link Link copied

![Image 1: 1 vertical menu with vibrant colors opens from a split button, and 1 vertical menu with a submenu.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmhkajj6i-01.png?alt=media&token=b7e5017f-ef26-4526-8d0c-759c47445705)

Vertical menus can include vibrant colors, gaps, dividers, and submenus to organize a list of choices

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
| [Flutter](https://api.flutter.dev/flutter/material/ThemeData/useMaterial3.html) | Available |
| [android Jetpack Compose](https://developer.android.com/develop/ui/compose/components/menu) | Available |
| [android Jetpack Compose: Expressive](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#DropdownMenuGroup%28androidx.compose.material3.MenuGroupShapes,androidx.compose.ui.Modifier,androidx.compose.ui.graphics.Color,androidx.compose.ui.unit.Dp,androidx.compose.ui.unit.Dp,androidx.compose.foundation.BorderStroke,androidx.compose.foundation.layout.PaddingValues,androidx.compose.foundation.interaction.MutableInteractionSource,kotlin.Function1%29) | Available |
| [android MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/components/Menu.md) | Available |
| android MDC-Android: Expressive | Unavailable |
| [language Web](https://github.com/material-components/material-web/blob/main/docs/components/menu.md) | Available |
| language Web: Expressive | Unavailable |
Close

link

Copy link Link copied

M3 Expressive update
--------------------

link

Copy link Link copied

**November 2025**

**Vertical menus** were introduced with new shapes, color styles, selection states, and refined submenu motion. Gaps can be used for a more flexible layout on Android. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

link

Copy link Link copied

Variants:

*   Added **vertical menus**, recommended for new designs
*   Baseline Baseline variants are the M3 component designs. They may not have the latest features introduced in M3 Expressive, like updated motion, shapes, type, and styles. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)**menu** is still available 

Color styles:

*   Standard
*   Vibrant

![Image 2: A vertical menu using shape and vibrant color to show a selected state.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmhk9jsmw-02.png?alt=media&token=3e48c83b-95fa-49ff-b870-925785fb4a04)

Vibrant colors help selected menu items stand out

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

*   **Color**: New color mappings and compatibility with dynamic color Dynamic color takes a single color from a user's wallpaper or in-app content and creates an accessible color scheme assigned to elements in the UI. [More on dynamic color](https://m3.material.io/m3/pages/dynamic/choosing-a-source)
*   **Variants**: Dropdown menu and exposed dropdown menu are now both referred to as menu, since they differ only in the element which opens the menu surface

![Image 3: Menu with gray color.](https://lh3.googleusercontent.com/lRkDtzZzv1cQwgvOMTY_hxx5v6LvsZjXrAo_zSvv-cqgB6vH92PvSw1XJMN925XPqGDdMB1OgVKZcud6-w4b9LZg709o_yEZGMjqyhsgs6Wz=w40)![Image 4: Menu with gray color.](https://lh3.googleusercontent.com/lRkDtzZzv1cQwgvOMTY_hxx5v6LvsZjXrAo_zSvv-cqgB6vH92PvSw1XJMN925XPqGDdMB1OgVKZcud6-w4b9LZg709o_yEZGMjqyhsgs6Wz=s0)

M2: Former menu colors don’t contrast with the background

![Image 5: Menu with purple background and outline.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmhlt7xid-04.png?alt=media&token=10f6b199-9664-4a24-b811-2980270f499c)

M3: Menus feature new color mappings and dynamic color

[arrow_left_alt Previous Progress indicators: Overview](https://m3.material.io/components/progress-indicators)[Up next arrow_right_alt Menus: Specs](https://m3.material.io/components/menus/specs)

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
