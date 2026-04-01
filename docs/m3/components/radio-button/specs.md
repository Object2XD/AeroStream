Title: Radio button – Material Design 3

URL Source: http://m3.material.io/components/radio-button/specs

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Radio button – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/radio-button/specs#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Radio button
============

Radio buttons let people select one option from a set of options

Resources flutter android+2

Close

[info Overview](https://m3.material.io/components/radio-button/overview)[style Specs](https://m3.material.io/components/radio-button/specs)[design_services Guidelines](https://m3.material.io/components/radio-button/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/radio-button/accessibility)

On this page

*   [Tokens & specs](https://m3.material.io/)
*   [Color](https://m3.material.io/)
*   [States](https://m3.material.io/)
*   [Measurements](https://m3.material.io/)

link

Copy link Link copied

![Image 1: Diagram of enabled radio button.](https://lh3.googleusercontent.com/dhK9o6CpKl0rU0nNthzBHEz_WjPB264BCIZiXJisj5qoYSGwynygzLH2JUgl2RyYjyArXkZNMdlpDOC6MEm1gY36QdhZED-VFVcPsQuff1rHZg=s0)

1.   Radio button icon

link

Copy link Link copied

Tokens & specs
--------------

[Learn more about design tokens](https://m3.material.io/m3/pages/design-tokens/overview)

link

Copy link Link copied

 Radio Button arrow_drop_down

search

visibility grid_view expand_all

Token

 Default, Light arrow_drop_down

folder Enabled

keyboard_arrow_down

folder Disabled

keyboard_arrow_down

folder Hovered

keyboard_arrow_down

folder Focused

keyboard_arrow_down

folder Pressed (ripple)

keyboard_arrow_down

Close

link

Copy link Link copied

Color
-----

link

Copy link Link copied

Color values are implemented through design tokens Design tokens are the building blocks of all UI elements. The same tokens are used in designs, tools, and code. [More on tokens](https://m3.material.io/m3/pages/design-tokens/overview). For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/m3/pages/design-tokens/overview)

link

Copy link Link copied

![Image 2: Diagram of selected and unselected radio button colors.](https://lh3.googleusercontent.com/AiZMdjDtHEF9acx935WgjONj_Kvnb5Zl00C7Q1pxV56QjHx29o9tmyo4ACyJzafBGMDlrnOQBqScIiZY2mk205cbNAtBBqmtDAQR2ya7bcny=w40)![Image 3: Diagram of selected and unselected radio button colors.](https://lh3.googleusercontent.com/AiZMdjDtHEF9acx935WgjONj_Kvnb5Zl00C7Q1pxV56QjHx29o9tmyo4ACyJzafBGMDlrnOQBqScIiZY2mk205cbNAtBBqmtDAQR2ya7bcny=s0)

Radio button color roles used for light and dark themes:

1.   Primary
2.   On surface variant

link

Copy link Link copied

### Adjacent text label color

Use the color role Color roles are assigned to UI elements based on emphasis, container type, and relationship with other elements. This ensures proper contrast and usage in any color scheme. **on surface** for adjacent text labels. This remains the same even if interacting with the label or component.

![Image 4: Radio buttons with labels. The labels are the same color for both selected and unselected radio buttons.](https://lh3.googleusercontent.com/aFf7EK2cXKvdJegnbGx-u44UtDR9NZkQxw81UNCX4Q_D6_dvx_psq5rttJYfH9qytzYEkAxpFiNcej-7JO8Q0Mu6ySIq2h6sfDJN-BHFygZr=w40)![Image 5: Radio buttons with labels. The labels are the same color for both selected and unselected radio buttons.](https://lh3.googleusercontent.com/aFf7EK2cXKvdJegnbGx-u44UtDR9NZkQxw81UNCX4Q_D6_dvx_psq5rttJYfH9qytzYEkAxpFiNcej-7JO8Q0Mu6ySIq2h6sfDJN-BHFygZr=s0)

The text color remains the same regardless if the button is selected or not

link

Copy link Link copied

States
------

States States show the interaction status of a component or UI element. [More on states](https://m3.material.io/m3/pages/interaction-states/overview) are visual representations used to communicate the status of a component or interactive element. [Learn more about interaction states](https://m3.material.io/m3/pages/interaction-states/overview)

link

Copy link Link copied

![Image 6: Diagram of radio button states including enabled, hover, focus, pressed, and disabled.](https://lh3.googleusercontent.com/batG4K9NgonMPOe8NtbqKBf_5HbQhLrGbpIrPzKU2lPdbMfVm8nbualfdj3tFA5cfGE9OLgj4lxybNV6a8-d90gixbpw7mm11V6ky0s5-ik=w40)

1.   Enabled
2.   Hover
3.   Focus
4.   Pressed
5.   Disabled

link

Copy link Link copied

[State specs are in the token module above](https://m3.material.io/m3/pages/radio-button/specs#3eef19a6-cdcb-4ecf-b1af-2b8095d485ac)

link

Copy link Link copied

Measurements
------------

link

Copy link Link copied

![Image 7: Diagram of radio button layout values.](https://lh3.googleusercontent.com/Mix21eJwewQUVsSEPZiI8V9QtuoPH_Fw_CYVBaXX1vwpGyYgkN0dC8tdrO6WXjS-ADSW8GMMsDP5MNkMUF1i4izhNjHk7lsA8tAHRlZZ-L8H=w40)

Radio button size measurements

link

Copy link Link copied

| Attribute | Value |
| --- | --- |
| Icon size | 20dp |
| State layer size | 40dp |
| Target size | 48dp |

[arrow_left_alt Previous Radio button: Overview](https://m3.material.io/components/radio-button/overview)[Up next arrow_right_alt Radio button: Guidelines](https://m3.material.io/components/radio-button/guidelines)

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

Default, Light

Radio Button

Hide previews

Switch to grid view

Expand all
