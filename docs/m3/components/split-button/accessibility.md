Title: Split buttons

URL Source: http://m3.material.io/components/split-button/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Split buttons
===============

[Skip to main content](https://m3.material.io/components/split-button/accessibility#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Split buttons
=============

Split buttons open a menu to give people more options related to an action

Resources android android

Close

[info Overview](https://m3.material.io/components/split-button/overview)[style Specs](https://m3.material.io/components/split-button/specs)[design_services Guidelines](https://m3.material.io/components/split-button/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/split-button/accessibility)

On this page

*   [Use cases](https://m3.material.io/)
*   [Interaction & style](https://m3.material.io/)
*   [Initial focus](https://m3.material.io/)
*   [Keyboard navigation](https://m3.material.io/)
*   [Labeling elements](https://m3.material.io/)

link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to do the following using assistive technology:

*   Navigate to each button and interact with them
*   Navigate to any element opened by the trailing button
*   Understand the current selection state of the button

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

Each button in the split button needs a minimum target area of 48x48dp. Extra small and small split buttons are shorter than 48dp, so the target areas around them need to be at least 48dp tall.

![Image 1: Diagram showing extra small and small split buttons with visible 48x48dp target areas.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0dpv69h-1.png?alt=media&token=649cab35-4ea3-432c-b027-1dd04227d045)

Target areas should be at least 48x48dp

1.   Extra small

2.   Small

link

Copy link Link copied

Initial focus
-------------

link

Copy link Link copied

Focus should land on the leading button then move to the trailing button. This can depend on the operating system’s settings.

![Image 2: Focus on the leading button and trailing button for both LTR and RTL languages.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0dpwfdp-2.png?alt=media&token=8f646a31-a6f5-4330-b17d-1d8c11d2132f)

1.   Left to right

2.   Right to left

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| Keys | Actions |
| --- | --- |
| Tab | Navigate between buttons |
| Space or enter | Activate focused button |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

The accessibility label for the leading button is the same as buttons.

![Image 3: “Watch later” is both the button label text and the accessibility label.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0dq2sfs-3.png?alt=media&token=85b75ca9-ea9b-4199-939d-9b42767d223b)

Leading buttons should have the same labels as common buttons

link

Copy link Link copied

The trailing icon button should have an extra state or similar label indicating that the menu is expanded or collapsed.

Label the button to clearly indicate that there are more options. The label of the secondary button should indicate that it provides additional choices related to the action of the main button. For instance, if the main button says "Watch later," the secondary button should be something like "More watch options."

Label the opened menu according to the [menu accessibility guidance](https://m3.material.io/m3/pages/menus/accessibility/).

![Image 4: Collapsed state indicated for the trailing button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0dq40tg-4.png?alt=media&token=e787ddba-953d-423a-bdee-55583e4500a7)

Trailing buttons should communicate the state of the menu and that more options are available

[arrow_left_alt Previous Split button: Guidelines](https://m3.material.io/components/split-button/guidelines)[Up next arrow_right_alt Cards: Overview](https://m3.material.io/components/cards)

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
