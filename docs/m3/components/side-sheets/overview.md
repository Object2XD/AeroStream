Title: Side sheets – Material Design 3

URL Source: http://m3.material.io/components/side-sheets/overview

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Side sheets – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/side-sheets/overview#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Side sheets
===========

Side sheets show secondary content anchored to the side of the screen

Resources

Close

[info Overview](https://m3.material.io/components/side-sheets/overview)[style Specs](https://m3.material.io/components/side-sheets/specs)[design_services Guidelines](https://m3.material.io/components/side-sheets/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/side-sheets/accessibility)

On this page

*   [Availability & resources](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

*   Use side sheets to provide optional content and actions without interrupting the main content

*   Two variants: standard Standard side sheets display content without blocking access to the screen’s primary content, such as an audio player at the side of a music app. They're often used in medium and expanded window sizes like tablet or desktop.  and modal Modal side sheets appear in front of app content, disabling all other app functionality when they appear, and remaining on screen until confirmed, dismissed, or a required action has been taken. They're often used in compact window sizes, like mobile, due to limited screen size.

*   People can navigate to another region within the sheet

*   Side sheets can contain a back icon for navigation

link

Copy link Link copied

![Image 1: The 2 variants of side sheets.](https://lh3.googleusercontent.com/5DQn6-h3w6BIR9DoXAncCck22WNg-86e7uh4meG22SsqcvVMb966220Fp-Ooiwui3eekiqk8p_Uq9BpNZ4wUYSQFPwovt6b_fOdpiU008vQ0Lw=w40)![Image 2: The 2 variants of side sheets.](https://lh3.googleusercontent.com/5DQn6-h3w6BIR9DoXAncCck22WNg-86e7uh4meG22SsqcvVMb966220Fp-Ooiwui3eekiqk8p_Uq9BpNZ4wUYSQFPwovt6b_fOdpiU008vQ0Lw=s0)

1.   Standard side sheet 
2.   Modal side sheet

link

Copy link Link copied

Availability & resources
------------------------

link

Copy link Link copied

| Type | Resource | Status |
| --- | --- | --- |
| Design |
| [Design Kit (Figma)](http://goo.gle/m3-design-kit) | Available |
| Implementation |
| Flutter | Unavailable |
| android Jetpack Compose | Unavailable |
| [android MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/components/SideSheet.md) | Available |
| language Web | Unavailable |
Close

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

*   Right-to-left (RTL) language support with left side sheet
*   Color: New color mappings and compatibility with dynamic color Dynamic color takes a single color from a user's wallpaper or in-app content and creates an accessible color scheme assigned to elements in the UI. [More on dynamic color](https://m3.material.io/m3/pages/dynamic/choosing-a-source)
*   Shape: Modal side sheets Modal side sheets appear in front of app content, disabling all other app functionality when they appear, and remaining on screen until confirmed, dismissed, or a required action has been taken. They're often used in compact window sizes, like mobile, due to limited screen size.  have a 16dp corner radius

![Image 3: A modal side sheet showing the 16dp corner radius.](https://lh3.googleusercontent.com/NcjJRXvRM56DuF0hrulvw3eixw8QXtodshjuhM6OgLXuC54E06Ov7JGxPSynfQiwGnaQspHgMps2all60Y81-oRaznUym7yDF1bg53VC-so8ag=w40)![Image 4: A modal side sheet showing the 16dp corner radius.](https://lh3.googleusercontent.com/NcjJRXvRM56DuF0hrulvw3eixw8QXtodshjuhM6OgLXuC54E06Ov7JGxPSynfQiwGnaQspHgMps2all60Y81-oRaznUym7yDF1bg53VC-so8ag=s0)

Side sheets have new color mappings to support dynamic color

[arrow_left_alt Previous Bottom sheets: Overview](https://m3.material.io/components/bottom-sheets)[Up next arrow_right_alt Side sheets: Specs](https://m3.material.io/components/side-sheets/specs)

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
