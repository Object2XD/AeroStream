Title: Dialogs – Material Design 3

URL Source: http://m3.material.io/components/dialogs/overview

Markdown Content:
Dialogs – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/dialogs/overview#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Dialogs
=======

Dialogs provide important prompts in a user flow

Resources

Close

[info Overview](https://m3.material.io/components/dialogs/overview)[style Specs](https://m3.material.io/components/dialogs/specs)[design_services Guidelines](https://m3.material.io/components/dialogs/guidelines)[head_mounted_device XR](https://m3.material.io/components/dialogs/xr)[accessibility_new Accessibility](https://m3.material.io/components/dialogs/accessibility)

On this page

*   [Availability & resources](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

*   Use dialogs to make sure users act on information

*   Two variants: basic Basic dialogs interrupt users with urgent information, details, or actions. They're often used for alerts, quick selection, or confirmation. [More on basic dialogs](https://m3.material.io/m3/pages/dialogs/guidelines#97ac3858-3932-4084-ae8e-73e42b7cb752) and full-screen Full-screen dialogs fill the entire screen, displaying actions that require a series of tasks to complete. They're often used for creating a calendar entry. [More on full-screen dialogs](https://m3.material.io/m3/pages/dialogs/guidelines#007536b9-76b1-474a-a152-2f340caaff6f)

*   Should be dedicated to completing a single task

*   Can also display information relevant to the task

*   Commonly used to confirm high-risk actions like deleting progress

link

Copy link Link copied

![Image 1: Basic and full-screen dialog.](https://lh3.googleusercontent.com/6kWyLPu-M7uuqJv2DLtnQd6MuRy2S5Pu5MzM-Q54y9MiOOFlX-2CLU9r1lATTgQLiUR7hUB2pBSVzT5qyoe9A3T1TWQ-3WOG9V50IM33Jkt3fg=w40)![Image 2: Basic and full-screen dialog.](https://lh3.googleusercontent.com/6kWyLPu-M7uuqJv2DLtnQd6MuRy2S5Pu5MzM-Q54y9MiOOFlX-2CLU9r1lATTgQLiUR7hUB2pBSVzT5qyoe9A3T1TWQ-3WOG9V50IM33Jkt3fg=s0)

1.   Basic dialog
2.   Full-screen dialog

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
| [android Jetpack Compose](https://developer.android.com/develop/ui/compose/components/dialog) | Available |
| [android MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/components/Dialog.md) | Available |
| [language Web](https://github.com/material-components/material-web/blob/main/docs/components/dialog.md) | Available |
Close

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

*   Color: New color mappings and compatibility with dynamic color Dynamic color takes a single color from a user's wallpaper or in-app content and creates an accessible color scheme assigned to elements in the UI. [More on dynamic color](https://m3.material.io/m3/pages/dynamic/choosing-a-source)
*   Layout Layout is the visual arrangement of elements on the screen. [More on layout](https://m3.material.io/m3/pages/understanding-layout/overview): Greater padding to account for the increased corner-radius and title size
*   Position: Option for custom basic dialog  Basic dialogs interrupt users with urgent information, details, or actions. They're often used for alerts, quick selection, or confirmation. [More on basic dialogs](https://m3.material.io/m3/pages/dialogs/guidelines#97ac3858-3932-4084-ae8e-73e42b7cb752)positioning
*   Shape: Increased corner-radius
*   Typography: Larger and darker headline

![Image 3: Basic dialog with rounded corner, larger headline.](https://lh3.googleusercontent.com/q8W8RpwCCScus4cQl-dtCeOGIWywtLjjCh3cFLmwYvEpaaKbny2HwDpi7qmX4qLlO9nOlnP5F0TYG8TozuGaZNbIis9Nu2zoaa806nkO-Wo=w40)![Image 4: Basic dialog with rounded corner, larger headline.](https://lh3.googleusercontent.com/q8W8RpwCCScus4cQl-dtCeOGIWywtLjjCh3cFLmwYvEpaaKbny2HwDpi7qmX4qLlO9nOlnP5F0TYG8TozuGaZNbIis9Nu2zoaa806nkO-Wo=s0)

New updates to color, layout, position, shape, and typography

[arrow_left_alt Previous Time pickers: Overview](https://m3.material.io/components/time-pickers)[Up next arrow_right_alt Dialogs: Specs](https://m3.material.io/components/dialogs/specs)

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
