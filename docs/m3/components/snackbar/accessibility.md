Title: Snackbar - Material Design 3

URL Source: http://m3.material.io/components/snackbar/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Snackbar - Material Design 3
===============

[Skip to main content](https://m3.material.io/components/snackbar/accessibility#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Snackbar
========

Snackbars show short updates about app processes at the bottom of the screen

Resources flutter android android

Close

[info Overview](https://m3.material.io/components/snackbar/overview)[style Specs](https://m3.material.io/components/snackbar/specs)[design_services Guidelines](https://m3.material.io/components/snackbar/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/snackbar/accessibility)

link

Copy link Link copied

### Use cases

Users should be able to:

*   Be alerted, but not disrupted, when a snackbar appears
*   Move focus to an actionable snackbar
*   Take action on a snackbar using assistive technology

link

Copy link Link copied

### Interaction & style

Snackbars with actions shouldn't auto-dismiss. This way, users can read and interact with it at their own pace.

Snackbars without actions can auto-dismiss after a sufficient amount of time, however this can still present difficulties on web without additional feedback.

Each platform has its own requirements for auto-dismiss durations, however common acceptable durations are 4–10 seconds.

![Image 1: A snackbar saying "Email marked as read" with no button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwp0j72d-1.png?alt=media&token=fbcb708c-f8d8-4b0a-810f-f68a6bfcc444)

Auto-dismissing snackbars should remain on screen long enough to read the information

link

Copy link Link copied

Snackbars use a color intended to stand out against UI elements. Use the default color mapping to avoid color conflict issues.

![Image 2: Snackbar with a dark container on a UI page in light theme.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwp0k0la-2.png?alt=media&token=0c86aabd-9c0f-47f6-9dcd-c872748ddfd2)

Snackbar should visually stand out

link

Copy link Link copied

### Accessibility requirements on web

On web, auto-dismissing snackbars can be difficult to navigate for people with low vision or who require additional time to perceive information. This information can be made clearer for all users in two ways:

#### 1. Add inline feedback

Information in auto-dismissing snackbars must also be communicated inline or near the action that triggered the snackbar.

For example, update the label on a "Save" button to “Saved”, and trigger an auto-dismissing snackbar that communicates the same message.

#### 2. Make the snackbar actionable

Alternatively, add actions to the snackbar so it doesn't dismiss until acted on. Actionable snackbars shouldn't auto-dismiss.

![Image 3: A "save" button changes to say "saved", alongside a snackbar that confirms changes were saved.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwp0kqjx-3.png?alt=media&token=cdc2d281-4288-4a6d-830f-8c72184d2dc8)

Communicate snackbar information near the action that triggered the snackbar

link

Copy link Link copied

**Note: Material Web doesn't yet include the snackbar component. This guidance still applies to custom-made snackbars.**

link

Copy link Link copied

### Focus

Snackbars have the following focus requirements:

*   When a snackbar appears, announce the message but don't move focus.
*   Don't automatically move focus.
*   Don't trap focus in the snackbar. Users should be able to freely navigate in and out.
*   On web, a shortcut should exist for users to move focus to snackbars with actions (like Alt+G). Ensure that this shortcut is clearly documented, like in a help article.

pause

Focus returns from the snackbar (1) to the previously focused element (2)

link

Copy link Link copied

Focus exits the snackbar differently per platform:

*   Ideally, focus should either return to the element that triggered the snackbar, or go to the next most logical element on the page.
*   On Android Compose, focus may move to the nearest visible element, or to the first actionable item on the page.

pause

If the previously focused element is no longer on the page, focus should move from the snackbar (1) to the next most logical element (2)

link

Copy link Link copied

### Keyboard navigation

| Keys | Actions |
| --- | --- |
| Tab | Moves focus between interactive elements |
| Esc | Dismisses the snackbar when in focus |

link

Copy link Link copied

### Labeling elements

Snackbars should be announced once they appear on the screen, but shouldn’t grab focus or prevent people from completing their current task.

*   On Android and web, use a live region with a polite (queued) announcement instead of an assertive announcement.
*   On iOS 17+, snackbars use polite announcements by default.

If a snackbar appears when the app is launched, it should be announced after the page’s title, but not receive focus.

![Image 4: Snackbar accessibility label examples.](https://lh3.googleusercontent.com/T_KwPf_rpSE3ree_3mFMt2C53xtXu1NZ67-FWB7-dRxb8jIeyk4T3J2-evC6G3Jly9WNV_gjKI-h98xqnBN3F_1npn_okXgBAUS4eo495UM=w40)

Snackbars are announced when they appear, but don't trap focus

[arrow_left_alt Previous Snackbar: Guidelines](https://m3.material.io/components/snackbar/guidelines)[Up next arrow_right_alt Switch: Overview](https://m3.material.io/components/switch)

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
