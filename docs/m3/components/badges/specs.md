Title: Badge – Material Design 3

URL Source: http://m3.material.io/components/badges/specs

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Badge – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/badges/specs#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

*   [Tokens & specs](https://m3.material.io/)
*   [Color](https://m3.material.io/)
*   [Measurements](https://m3.material.io/)
*   [Configuration](https://m3.material.io/)

link

Copy link Link copied

![Image 1: 5 aspects of badge anatomy on a navigation bar.](https://lh3.googleusercontent.com/1c2wjkW2_C9l1HmNkRT8GpeQ7WqSDcJdMKdNym4xk_wPBfFSgVP3NhSXBwBV52vI3L-Z7CAmnY7c-1WM1I9xfyj4EfI_ucXRgOhWSRvfLy5E=s0)

Navigation bar

1.   Small badge
2.   Large badge container
3.   Large badge label
4.   Large badge maximum character count container
5.   Large badge maximum character count label

![Image 2: 5 aspects of badge anatomy on a navigation rail.](https://lh3.googleusercontent.com/9yjKmecr7ZJh2Tm71DBDcwftLy2cMEpCW2yl73CCr7kUctUtmKaW78yFdO-0ZUSBXShJh9CDLZtQhcOyVt9CmdNhywVGvneguYneZMeui26j=s0)

Navigation rail

1.   Small badge
2.   Large badge container
3.   Large badge label
4.   Large badge maximum character count container
5.   Large badge maximum character count label

link

Copy link Link copied

Tokens & specs
--------------

Browse the component elements, attributes, tokens, and their values.

link

Copy link Link copied

 Badges arrow_drop_down

search

visibility grid_view expand_all

Token

 Default, Light arrow_drop_down

folder Enabled

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

![Image 3: 5 applications of badge color on light and dark theme navigation bars.](https://lh3.googleusercontent.com/GXqQAaWohBPLwvJAZUGaxFwy8CI_R4BLcAXPDq-e4P67CObmbEHL-GzwJbo6hBOmuqFuoV8QrPMXhmL2Zfca9_o5bTyMbxGhVxeM1Fwf7KU=w40)![Image 4: 5 applications of badge color on light and dark theme navigation bars.](https://lh3.googleusercontent.com/GXqQAaWohBPLwvJAZUGaxFwy8CI_R4BLcAXPDq-e4P67CObmbEHL-GzwJbo6hBOmuqFuoV8QrPMXhmL2Zfca9_o5bTyMbxGhVxeM1Fwf7KU=s0)

Badge color roles used for light and dark schemes in navigation bar:

1.   Error
2.   Error
3.   On error
4.   On error
5.   Error

![Image 5: 5 applications of badge color on light and dark theme navigation rails.](https://lh3.googleusercontent.com/8-bcqHO-CggN9L5OTiWVxPDT-wPzcurO0xXI7dZeo5htfXRjDwMnoMl_Qco9Z8NGG9CE2_5qrO2QdLV-nmieRVopeqNZeeHavE0GJqJpLRA=w40)![Image 6: 5 applications of badge color on light and dark theme navigation rails.](https://lh3.googleusercontent.com/8-bcqHO-CggN9L5OTiWVxPDT-wPzcurO0xXI7dZeo5htfXRjDwMnoMl_Qco9Z8NGG9CE2_5qrO2QdLV-nmieRVopeqNZeeHavE0GJqJpLRA=s0)

Badge color roles used for light and dark schemes in navigation rail:

1.   Error
2.   On error
3.   Error
4.   On error
5.   Error

link

Copy link Link copied

Measurements
------------

link

Copy link Link copied

![Image 7: Annotation of badge sizes, padding, and measurements from the corner of the icon to the badge opposite corner.](https://lh3.googleusercontent.com/_9tsQOYHX4YH6bQJJwi1ylkI-nu2RJBNb84ivjXE8ksTqqpuE4w-riSO17Sh2gclSOMxjzlDHS_B2zKmb7uBo3Y1ZBPiLWi6UoHlHOAK9Zw=w40)

Badge padding and size measurements

link

Copy link Link copied

| Attribute | Value |
| --- | --- |
| Small badge shape | 3dp corner radius |
| Small badge size (HxW) | 6dp |
| Large badge shape | 8dp corner radius |
| Large badge one digit size (HxW) | 16dp |
| Large badge max character count size (HxW) | 16x34dp |
| Small badge: distance from top trailing icon corner to bottom leading badge corner (HxW) | 6x6dp |
| Large badge: distance from top trailing icon corner to bottom leading badge corner (HxW) | 14x12dp |
| Large badge padding between badge and text container | 4dp |

link

Copy link Link copied

Configuration
-------------

link

Copy link Link copied

Different badges are shown on navigation destinations in various states. States show the interaction status of a component or UI element. [More on states](https://m3.material.io/m3/pages/interaction-states/overview)

link

Copy link Link copied

![Image 8: Diagram of 3 badge variations shown on navigation destinations in various states.](https://lh3.googleusercontent.com/dmnjAmE1Ol38Ijd8REgLVSvLNv733cEX_WngU88yFKfiKjSdwanYmhHnCGueyMQAzJRxRMrvdgtC2KPaNzyG_B4Rn3ptMP-22440icqyFFKmFA=w40)

link

Copy link Link copied

1.   Inactive with label - small badge
2.   Inactive with label - large badge
3.   Inactive with label - large badge max character count
4.   Inactive - small badge
5.   Inactive - large badge
6.   Inactive - large badge max character count
7.   Active with label - small badge
8.   Active with label - large badge
9.   Active with label - large badge max character count
10.   Active nav bar no label - small badge
11.   Active nav bar no label - large badge
12.   Active nav bar no label - large badge max character count
13.   Active nav rail no label - small badge
14.   Active nav rail no label - large badge
15.   Active nav rail no label - large badge max character count

[arrow_left_alt Previous Badges: Overview](https://m3.material.io/components/badges/overview)[Up next arrow_right_alt Badges: Guidelines](https://m3.material.io/components/badges/guidelines)

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

Badges

Hide previews

Switch to grid view

Expand all
