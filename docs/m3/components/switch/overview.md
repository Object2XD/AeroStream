Title: Switch – Material Design 3

URL Source: http://m3.material.io/components/switch/overview

Markdown Content:
Switch – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/switch/overview#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Switch
======

Switches toggle the selection of an item on or off

Resources

Close

[info Overview](https://m3.material.io/components/switch/overview)[style Specs](https://m3.material.io/components/switch/specs)[design_services Guidelines](https://m3.material.io/components/switch/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/switch/accessibility)

On this page

*   [Availability & resources](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

*   Use switches (not radio buttons Radio buttons let people select one option from a set of options. [More on radio buttons](https://m3.material.io/m3/pages/radio-button/overview)) if the items in a list Lists are continuous, vertical indexes of text and images. [More on lists](https://m3.material.io/m3/pages/lists/overview) can be independently controlled

*   Switches are the best way to let people adjust settings

*   Make sure the switch’s selection Selection lets users choose specific items to act on. [More on selection](https://m3.material.io/m3/pages/selection) (on or off) is visible at a glance

link

Copy link Link copied

![Image 1: A switch in two states, off and on.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwa9bnl5-1.png?alt=media&token=8a4b85d3-5a30-49e2-b32d-927fc4c6fc2d)

Switches can be toggled on and off

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
| [android Jetpack Compose](https://developer.android.com/develop/ui/compose/components/switch) | Available |
| [android MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/components/Switch.md) | Available |
| [language Web](https://github.com/material-components/material-web/blob/main/docs/components/switch.md) | Available |
Close

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

*   Accessibility: Visual presentation is more accessible

*   Color: New color mappings meet Material's non-text-contrast requirements in addition to compatibility with dynamic color Dynamic color takes a single color from a user's wallpaper or in-app content and creates an accessible color scheme assigned to elements in the UI. [More on dynamic color](https://m3.material.io/m3/pages/dynamic/choosing-a-source)

*   Icons: Ability to have an optional icon within the switch handle

*   Layout: Track is taller and wider

link

Copy link Link copied

![Image 2: M2 switches in off and on states.](https://lh3.googleusercontent.com/8Q9gMTX5nAY3wJyezAw1JEzmJ6MbTAT3FkVUc7BIO9RUJ485PUwFFlXz7pAutMPh1eI0ScCnGFUd3nuAEfSb_Uo89uV3wfTPotf3njzsUwfo=w40)![Image 3: M2 switches in off and on states.](https://lh3.googleusercontent.com/8Q9gMTX5nAY3wJyezAw1JEzmJ6MbTAT3FkVUc7BIO9RUJ485PUwFFlXz7pAutMPh1eI0ScCnGFUd3nuAEfSb_Uo89uV3wfTPotf3njzsUwfo=s0)

M2: Switches have a circular handle that extends beyond the edge of the track

![Image 4: M3 switch shown toggled off and toggled on. When switched on, it has a checkmark icon.](https://lh3.googleusercontent.com/P_nhLNZtpt8oAPTScTR_d6oBLsidBWX0xG96t9fCkTURwNMReQpP9Etrpw4rc439wBfOAJBUeGZ39O8goRmRcPk_Ehhnq_wj7qNKFR4Sf70=w40)![Image 5: M3 switch shown toggled off and toggled on. When switched on, it has a checkmark icon.](https://lh3.googleusercontent.com/P_nhLNZtpt8oAPTScTR_d6oBLsidBWX0xG96t9fCkTURwNMReQpP9Etrpw4rc439wBfOAJBUeGZ39O8goRmRcPk_Ehhnq_wj7qNKFR4Sf70=s0)

M3: Switches have a taller and wider track, new color mappings, and the ability to show an icon in the handle

[arrow_left_alt Previous Snackbar: Overview](https://m3.material.io/components/snackbar)[Up next arrow_right_alt Switch: Specs](https://m3.material.io/components/switch/specs)

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
