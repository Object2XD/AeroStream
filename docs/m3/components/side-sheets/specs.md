Title: Side sheets – Material Design 3

URL Source: http://m3.material.io/components/side-sheets/specs

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Side sheets – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/side-sheets/specs#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Resources android

Close

[info Overview](https://m3.material.io/components/side-sheets/overview)[style Specs](https://m3.material.io/components/side-sheets/specs)[design_services Guidelines](https://m3.material.io/components/side-sheets/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/side-sheets/accessibility)

On this page

*   [Tokens & specs](https://m3.material.io/)
*   [Standard side sheet](https://m3.material.io/)
*   [Modal side sheet](https://m3.material.io/)

link

Copy link Link copied

Tokens & specs
--------------

Browse the component elements, attributes, tokens, and their values. [Learn more about design tokens](https://m3.material.io/m3/pages/design-tokens/overview)

link

Copy link Link copied

 Sheets - Side arrow_drop_down

search

visibility grid_view expand_all

Token

 Default, Light arrow_drop_down

folder Enabled

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

Standard side sheet
-------------------

link

Copy link Link copied

![Image 1: 4 elements of a standard side sheet.](https://lh3.googleusercontent.com/lg2svhv9DuP5FMVqxsmnsLS5m2S1aSqU4fcUuQacBh9lHSy2DiPpaUpGpphS0iiVcuOJvSHp95mF9Z55dmy9F9KeGE5I-_-OOsgSuKRp_feW=s0)

1.   Divider (optional)
2.   Headline
3.   Container
4.   Close icon button

link

Copy link Link copied

### Standard side sheet color

Color values are implemented through design tokens Design tokens are the building blocks of all UI elements. The same tokens are used in designs, tools, and code. [More on tokens](https://m3.material.io/m3/pages/design-tokens/overview). For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/m3/pages/design-tokens/overview/)

link

Copy link Link copied

![Image 2: 4 color roles applied to a side sheet in light and dark themes.](https://lh3.googleusercontent.com/LqFhUoIZJCxI-xrg-swaOn2vwlyswPNvs2JQfS2oNHhVms4yvkJE1tCBaFLUxKH_B-NWUoZ9Wo5QF2x437thBA0uzYeoBxeJ2NMWg2jmqbgL=w40)![Image 3: 4 color roles applied to a side sheet in light and dark themes.](https://lh3.googleusercontent.com/LqFhUoIZJCxI-xrg-swaOn2vwlyswPNvs2JQfS2oNHhVms4yvkJE1tCBaFLUxKH_B-NWUoZ9Wo5QF2x437thBA0uzYeoBxeJ2NMWg2jmqbgL=s0)

Side sheet color roles used for light and dark themes:

1.   Outline variant
2.   On surface variant
3.   Surface
4.   On surface variant

link

Copy link Link copied

### Standard side sheet measurements

link

Copy link Link copied

![Image 4: Standard side sheet padding and size measurements.](https://lh3.googleusercontent.com/2LAblBbcF_ZBcupC3Q2aXZlYse3imp3Y1ePIVfC3DY5iefsYPzFRDPu20wDJmkgcAxlpprO9NpnBwJdHjBTiA32q7BduBlHaREVzxLLbrKkDwA=w40)

Side sheet padding and size measurements

link

Copy link Link copied

| Attribute | Value |
| --- | --- |
| Start/end padding | 24dp |
| Padding between top elements | 12dp |
| Bottom actions height | 72dp |
| Bottom actions top padding | 16dp |
| Bottom actions bottom padding | 24dp |
| Bottom actions alignment (horizontal) | Left |
| Max-width | 400dp |
| Margins (when detached) | 16dp |

link

Copy link Link copied

Modal side sheet
----------------

link

Copy link Link copied

![Image 5: 7 elements of a modal side sheet.](https://lh3.googleusercontent.com/mCkCbKeP2EQNehrmAoIhTh8csAxLh6TS5YKqEtZWs-p6OhXjXK3OQ-8GxAiPRoDu7tQQ_qh6pdkkvtk5LLT2ACRvlqzzCn6QkW5TORe1go6W=w40)

1.   Back icon button (optional)
2.   Headline
3.   Container
4.   Close icon button
5.   Divider (optional)
6.   Action buttons (optional)
7.   Scrim

link

Copy link Link copied

### Modal side sheet color

Color values are implemented through design tokens Design tokens are the building blocks of all UI elements. The same tokens are used in designs, tools, and code. [More on tokens](https://m3.material.io/m3/pages/design-tokens/overview). For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/m3/pages/design-tokens/overview/).

link

Copy link Link copied

![Image 6: 4 color roles applied to a modal side sheet in light and dark themes.](https://lh3.googleusercontent.com/MCbwK4pOf-VBkCt3qXBvBVReNnD3TzDuwLJdajh_CvxUT_TN3_5Ho5v3QyV0SHhv5IHbZP0V5UbCSy8rXaQFJ79cocKme0PSXGWzZT5HUvU=w40)

Side sheet color roles used for light and dark themes:

1.   On surface variant

2.   On surface variant

3.   Surface container low

4.   On surface variant

link

Copy link Link copied

### Modal side sheet measurements

link

Copy link Link copied

![Image 7: Modal side sheet padding and size measurements](https://lh3.googleusercontent.com/ggmDZsvw6x0ei4ktaEtZbG_D-SvR-dKw59udjcKCr7KdED37SNpjgIxFdBL6ySJrdglC7AeXbchojJM7pgxlhcVmcXVp26aCBCmnQ1utyjDL=w40)

Modal side sheet padding and size measurements

link

Copy link Link copied

| Attribute | Value |
| --- | --- |
| Start/end padding | 24dp |
| Start padding with icon | 16dp |
| Padding between top elements | 12dp |
| Bottom actions height | 72dp |
| Bottom actions top padding | 16dp |
| Bottom actions bottom padding | 24dp |
| Bottom actions alignment (horizontal) | Left |
| Max-width | 400dp |
| Margins (when detached) | 16dp |

[arrow_left_alt Previous Side sheets: Overview](https://m3.material.io/components/side-sheets/overview)[Up next arrow_right_alt Side sheets: Guidelines](https://m3.material.io/components/side-sheets/guidelines)

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

Sheets - Side

Hide previews

Switch to grid view

Expand all
