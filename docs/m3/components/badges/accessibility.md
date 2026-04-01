Title: Badge – Material Design 3

URL Source: http://m3.material.io/components/badges/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Badge – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/badges/accessibility#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Badges
======

Badges show notifications, counts, or status information on navigation items and icons

Resources flutter android android

Close

[info Overview](https://m3.material.io/components/badges/overview)[style Specs](https://m3.material.io/components/badges/specs)[design_services Guidelines](https://m3.material.io/components/badges/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/badges/accessibility)

On this page

*   [Use cases](https://m3.material.io/)
*   [Interaction & style](https://m3.material.io/)
*   [Visual indicators](https://m3.material.io/)
*   [Labeling elements](https://m3.material.io/)

link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to use assistive technology to:

*   Understand the dynamic information conveyed in badges, such as counts or labels
*   Address badge announcements by selecting corresponding navigation destinations

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

Badges are most commonly used within other components, such as navigation bar Navigation bars let people switch between UI views on smaller devices. [More on navigation bars](https://m3.material.io/m3/pages/navigation-bar/overview), navigation rail Navigation rails let people switch between UI views on mid-sized devices. [More on navigation rails](https://m3.material.io/m3/pages/navigation-rail/overview), app bars App bars display navigation, actions, and text at the top of a screen. [More on app bars](https://m3.material.io/m3/pages/app-bars/overview), and tabs Tabs organize content across different screens and views. [More on tabs](https://m3.material.io/m3/pages/tabs/overview).

When a badge is used to indicate an unread notification, the badge gets hidden once it's selected.

pause

link

Copy link Link copied

Visual indicators
-----------------

link

Copy link Link copied

Badges use a color intended to stand out against labels, icons, and navigation elements. Use the default color mapping to avoid color conflict issues.

![Image 1: Diagram of large and small badges showing that they need to pass 3 to 1 contrast.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmg0x2h51-02_do.png?alt=media&token=b6d4a7a7-0b46-4a00-84a8-96265cf1ef4b)

check Do 
Badges must use default color with at least 3:1 contrast

![Image 2: Diagram of large and small badges not passing 3 to 1 contrast.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmg0x2kti-03_dont.png?alt=media&token=5c3e26cc-09ca-4769-9f83-701d6e8d83cb)

close Don’t 
Avoid using custom color roles for the badge container and label text. If custom roles are necessary, make sure they have contrast of at least 3:1.

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

The accessibility Accessible design makes products usable for people with all kinds of abilities. [More on accessibility](https://m3.material.io/m3/pages/overview/principles) label for a badge item will be read after its navigation destination. Any numerical badges will have their number read, while non-counting badges will simply announce**New notification**.

![Image 3: Navigation bar highlighting numerical badge.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fme8l8lhl-04.png?alt=media&token=99d7e919-9bb3-45ed-a8b9-b961d31ef91c)

Numerical badges will have their number read

link

Copy link Link copied

![Image 4: Navigation bar highlighting non-counting badge.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fme8l9na6-05.png?alt=media&token=096422e0-2079-4674-8f91-1adb36552e46)

Non-counting badges will simply announce **New notification**

[arrow_left_alt Previous Badges: Guidelines](https://m3.material.io/components/badges/guidelines)[Up next arrow_right_alt All buttons](https://m3.material.io/components/all-buttons)

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
