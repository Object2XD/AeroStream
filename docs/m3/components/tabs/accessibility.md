Title: Tabs – Material Design 3

URL Source: http://m3.material.io/components/tabs/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Tabs – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/tabs/accessibility#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Tabs
====

Tabs organize content across different screens and views

Resources flutter android+2

Close

[info Overview](https://m3.material.io/components/tabs/overview)[style Specs](https://m3.material.io/components/tabs/specs)[design_services Guidelines](https://m3.material.io/components/tabs/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/tabs/accessibility)

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

Users should be able to:

*   Undertake actions or invoke navigation to a new destination with assistive tech
*   Select an action or destination from an off screen tab with assistive tech
*   Maintain access of primary actions when the content is in a scrolled state States show the interaction status of a component or UI element. [More on states](https://m3.material.io/m3/pages/interaction-states/overview)

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

**Touch**

*   When a user taps on an icon button Icon buttons help people take minor actions with one tap. [More on icon buttons](https://m3.material.io/m3/pages/icon-buttons/overview), a touch ripple appears, indicating interaction feedback
*   The selected indicator becomes active and shifts into position once the touch has been engaged

pause

Touch: Tap

link

Copy link Link copied

**Scrollable**

*   When a set of tabs cannot fit on screen, scrollable tabs are used. They are best used for browsing on touch interfaces.
*   To navigate between scrollable tabs, users swipe the set left or right. Users can also use arrow/tab to navigate through.
*   It's **not recommended** to loop a tab set where it scrolls infinitely. This can trap users who are navigating linearly with a screen reader.
*   To select an individual tab, users tap or press space/enter.
*   Horizontal scrolling tabs meet accessibility requirements because they need to increase in width to respond to label text without affecting the layout, and horizontal scrolling is necessary to view those labels.

pause

Scrollable: Scrollable Tabs

link

Copy link Link copied

**Cursor**

*   When hovered, the hover state A hover state communicates when a user has placed a cursor above an interactive element. [More on hover state](https://m3.material.io/m3/pages/interaction-states/applying-states#71c347c2-dd75-485b-892e-04d2900bd844) appears, providing a visual cue that the icon button Icon buttons help people take minor actions with one tap. [More on icon buttons](https://m3.material.io/m3/pages/icon-buttons/overview) is interactive. When clicked (in both active and inactive states), a ripple appears and the indicator shifts into position, showing the user feedback.

pause

Cursor: Hover, Click

link

Copy link Link copied

**Keyboard/Switch**

*   When tabbed, a focus indicator appears, providing a visual cue to the user that the destination is now selected
*   When the user engages with the selected tab via Space/Enter in active states States show the interaction status of a component or UI element. [More on states](https://m3.material.io/m3/pages/interaction-states/overview), the user is taken to a new destination
*   Within the tab menu, the user is able to arrow/tab through the menu items, Space/Enter to select an item, or tab to exit the active state

pause

Keyboard/Switch: Tab, Space/Enter, Arrow

link

Copy link Link copied

### Avoid applying density by default

Don't apply density to tabs by default — this lowers their targets below our best practice of 48x48 CSS pixels. Instead, give people a way to choose a higher density, like selecting a denser layout or changing the theme.

To ensure that this density setting can be easily reverted when it's active, keep all the targets to change it at minimum 48x48 CSS pixels each.

link

Copy link Link copied

Initial focus
-------------

link

Copy link Link copied

On arrow/tab in a tab menu Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview), the active indicator appears on the first interactive element, providing feedback to the user that it is selected. The user is then able to tab to additional interactive elements until all available items are complete within the tab menu.

pause

check Do 
Use Arrow/Tab to navigate through items

pause

close Don’t 
Don't use Space/Enter for navigating tabs. Space/Enter is only used for completing actions.

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| Keys | Actions |
| --- | --- |
| Arrow | Focus lands on the next available navigation destination |
| Space / Enter | Activates the focused A focused state communicates when a user has highlighted an element, using an input method such as a keyboard or voice. [More on focused state](https://m3.material.io/m3/pages/interaction-states/applying-states#bc6d6853-48ef-490e-8076-448e89e69f0f) navigation destination |
| Arrow | Allows navigation through menu Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview) items |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

When the visible UI text is ambiguous, or there is no visible UI text, accessibility Accessible design makes products usable for people with all kinds of abilities. [More on accessibility](https://m3.material.io/m3/pages/overview) labels need to be more descriptive. For example, an icon button Icon buttons help people take minor actions with one tap. [More on icon buttons](https://m3.material.io/m3/pages/icon-buttons/overview) that visually represents a “video camera” requires additional information in its accessibility label to clarify the icon’s intent.

![Image 1: Small device screen  with the tab highlighted and the label and role illustrated.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm2k3h2mn-7.png?alt=media&token=47b7122f-9754-488f-8436-39a6b015175a)

While the icon visually represents a “Video camera,” the accessibility label for this tab clarifies its function: “Video format media content”

[arrow_left_alt Previous Tabs: Guidelines](https://m3.material.io/components/tabs/guidelines)[Up next arrow_right_alt Text fields: Overview](https://m3.material.io/components/text-fields)

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
