Title: Checkbox – Material Design 3

URL Source: http://m3.material.io/components/checkbox/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Checkbox – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/checkbox/accessibility#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Checkbox
========

Checkboxes let users select one or more items from a list, or turn an item on or off

Resources flutter android+2

Close

[info Overview](https://m3.material.io/components/checkbox/overview)[style Specs](https://m3.material.io/components/checkbox/specs)[design_services Guidelines](https://m3.material.io/components/checkbox/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/checkbox/accessibility)

On this page

*   [Use cases](https://m3.material.io/)
*   [Interaction & style](https://m3.material.io/)
*   [Avoid applying density by default](https://m3.material.io/)
*   [Keyboard navigation](https://m3.material.io/)
*   [Labeling elements](https://m3.material.io/)

link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to use assistive technology to:

*   Navigate to a checkbox

*   Toggle the checkbox on and off

*   Get appropriate feedback based on input type documented under [Interaction & style](https://m3.material.io/m3/pages/checkbox/accessibility#6a2f55e5-2fa0-4204-b6d1-62362dda89c7)

link

Copy link Link copied

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

Users should be able to select either the text label or the checkbox to select an option.

![Image 1: In a list, checkboxes for 2 items are selected via their text labels.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmg0vkh7s-1.png?alt=media&token=7e1977e6-bb1a-4a66-b82b-3e0fddb18e2f)

A checkbox selected via the text label

link

Copy link Link copied

The parent checkbox has three states: selected, unselected, and indeterminate.

Checkboxes can be selected or unselected regardless of the state of the other checkboxes in a group.

If some, but not all, child checkboxes are checked, the parent checkbox becomes indeterminate. Selecting an indeterminate parent checkbox will check all of its child checkboxes.

![Image 2: In a list, a child checkbox for 1 item is selected and the parent checkbox is in indeterminate state.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmcyq4z51-2.png?alt=media&token=e2bf5c82-a9b2-403d-a5cd-fe09f708969a)

An indeterminate selection indicating that at least one checkbox is selected within a group

link

Copy link Link copied

Avoid applying density by default
---------------------------------

link

Copy link Link copied

Don't apply density to checkboxes by default — this lowers their targets below our best practice of 48x48 CSS pixels. Instead, give people a way to choose a higher density, like selecting a denser layout or changing the theme.

To ensure that this density setting can be easily reverted when it's active, keep all the targets to change it at minimum 48x48 CSS pixels each.

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| Keys | Actions |
| --- | --- |
| **Tab** | Moves focus to enabled An enabled state communicates an interactive component or element. [More on enabled state](https://m3.material.io/m3/pages/interaction-states/applying-states#39b2fc90-01db-41b5-b6f8-47be61ed1479) chip or chip group |
| **Space** or **Enter** | Activates, selects, or deselects the focused chip |
| **Backspace** or **Delete** | Removes currently focused A focused state communicates when a user has highlighted an element, using an input method such as a keyboard or voice. [More on focused state](https://m3.material.io/m3/pages/interaction-states/applying-states#bc6d6853-48ef-490e-8076-448e89e69f0f) input chip |
| **Arrows** | Moves focus between chips |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

If the UI text is correctly linked to the checkbox, assistive tech (such as a screen reader) will read the UI text followed by the component’s role.

The accessibility Accessible design makes products usable for people with all kinds of abilities. [More on accessibility](https://m3.material.io/m3/pages/overview/principles) label for an individual checkbox is typically the same as its adjacent text label.

![Image 3: Accessibility labels of a checkbox.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmg0vlqi0-3.png?alt=media&token=991b19e5-257d-4db0-9f2b-bc0ab092eeda)

The accessibility label clearly states the text label of the checkbox

[arrow_left_alt Previous Checkbox: Guidelines](https://m3.material.io/components/checkbox/guidelines)[Up next arrow_right_alt Chips: Overview](https://m3.material.io/components/chips)

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
