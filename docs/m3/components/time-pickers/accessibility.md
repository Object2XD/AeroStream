Title: Time pickers – Material Design 3

URL Source: http://m3.material.io/components/time-pickers/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Time pickers – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/time-pickers/accessibility#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Time pickers
============

Resources flutter android android

Close

[info Overview](https://m3.material.io/components/time-pickers/overview)[style Specs](https://m3.material.io/components/time-pickers/specs)[design_services Guidelines](https://m3.material.io/components/time-pickers/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/time-pickers/accessibility)

On this page

*   [Use cases](https://m3.material.io/)
*   [Interaction & style](https://m3.material.io/)
*   [Keyboard navigation](https://m3.material.io/)
*   [Labeling elements](https://m3.material.io/)

link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to use assistive technology to:

*   Select or enter hours/minutes, and in some cases, seconds/milliseconds
*   Choose from multiple time formats, including 24-hour clock view and AM/PM
*   Enter time selection manually using input fields

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

Time pickers should allow manual time entry through text input, rather than exclusively through the dial selector. This makes it easier for those using keyboard inputs Inputs are devices that provide interactive control of an app. Common inputs are a mouse, keyboard, and touchpad.  rather than touchscreens.

If a screen is not large enough to display the dial selector, consider displaying the input selector alone. Currently for Android Views, the dial selector is always visible.

The input selector should be accessible from the dial selector via the keyboard icon. This interaction allows multiple input methods and makes the time picker accessible for assistive technology users.

![Image 1: Time picker with active manual text input for hours.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmd2w3xxn-01.png?alt=media&token=84c832db-808d-448c-a8dd-9d89620c4d1f)

For time selection that doesn’t require a dial view, make a time input picker the default option

link

Copy link Link copied

### Targets

Targets for dial selectors should be 48x48dp.

![Image 2: Time picker dial selector specs, selecting hour 7.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmd2w61b9-02.png?alt=media&token=92a4708a-fda3-4fca-b285-153413dd00b4)

Dial selector targets should be 48x48dp

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| Keys | Actions |
| --- | --- |
| **Tab** | Focus lands on (non-disabled) time slot |
| **Space** or **Enter** | Activates the (non-disabled) time slot |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

If the input text is correctly linked, assistive tech like a screenreader will read the component’s role first, then the UI text.

![Image 3: Accessibility tags on the time picker's hour input field.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmd2w8i4o-03.png?alt=media&token=da4a19d6-ee3a-4eaf-bce3-256e3d0681b1)

The hour and minute fields have the text input role

link

Copy link Link copied

The dial selector will read a selection of total hours, such as **Hour 7 of 12**.

![Image 4: Accessibility tag on the time picker's dial selector.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmd2w9ugu-04.png?alt=media&token=07079a68-62a9-49fd-ab7f-2638edda3047)

A screen reader reads the text label of a dial selector

link

Copy link Link copied

### Dial selector

| Element | Accessibility label | Role (Wiz and Jetpack Compose) | Role (Android Views) |
| --- | --- | --- | --- |
| Hour input (input picker) | Hour | Text input | - |
| Minutes input | Minute | Text input | - |
| AM/PM selection | AM or PM | Radio button (in list) | Checkbox (in list) |
| Keyboard button | Toggle input picker | Button | Button |
| Cancel button | Cancel | Button | Button |
| OK button | OK | Button | Button |
| Clock dial time selection (dial selector) | {Value} Hours or minutes of {Total} | Button | - |

link

Copy link Link copied

### Input selector

| Element | Accessibility label | Role (Wiz and Jetpack Compose) | Role (Android Views) |
| --- | --- | --- | --- |
| Hour input (input picker) | Hour | Text input | - |
| Minutes input | Minute | Text input | - |
| Clock button | Toggle dial picker | Button | Button |
| Cancel button | Cancel | Button | Button |
| OK button | OK | Button | Button |

[arrow_left_alt Previous Time pickers: Guidelines](https://m3.material.io/components/time-pickers/guidelines)[Up next arrow_right_alt Dialogs: Overview](https://m3.material.io/components/dialogs)

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
