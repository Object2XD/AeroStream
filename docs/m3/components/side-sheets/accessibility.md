Title: Side sheets – Material Design 3

URL Source: http://m3.material.io/components/side-sheets/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Side sheets – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/side-sheets/accessibility#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

*   [Use cases](https://m3.material.io/)
*   [Interaction & style](https://m3.material.io/)
*   [Initial focus](https://m3.material.io/)
*   [Keyboard navigation](https://m3.material.io/)
*   [Labeling](https://m3.material.io/)

link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to dismiss the side sheet using assistive technology.

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

Material requires that a close affordance, such as a close icon button Icon buttons help people take minor actions with one tap. [More on icon buttons](https://m3.material.io/m3/pages/icon-buttons/overview), is always present within a side sheet.

![Image 1: Side sheet correctly designed with close icon in upper right corner.](https://lh3.googleusercontent.com/0LSf0hnC19HAyDDf88fqzUUo62971bFb2XWjHguURc3jJbZpy8ejGuIyFR-2MSFM27gLA3LjupVjSj8E5kEuDJG7IqeHD17NaXUOXKsEHdP8=s0)

check Do 
A close icon button makes the side sheet easy to dismiss

![Image 2: Side sheet incorrectly designed with no close icon button.](https://lh3.googleusercontent.com/bGugN52A6j4bvI4smHp21cQzZbZv4qaF9YBYdKZDD51XL6yAkHSY_KVtpUF7HkL6G04T2w61MQeJo-E8SqmPJx6OuO9YMeBqpjP7AOhc_yNi=s0)

close Don’t 
Without a close icon button, people can’t predict the opening and closing flow of side sheets, or know if the sheet is transient or permanent

link

Copy link Link copied

Initial focus
-------------

link

Copy link Link copied

Actions within a side sheet can be focused A focused state communicates when a user has highlighted an element, using an input method such as a keyboard or voice. [More on focused state](https://m3.material.io/m3/pages/interaction-states/applying-states#bc6d6853-48ef-490e-8076-448e89e69f0f) by tab order using a keyboard or switch control.

![Image 3: Side sheet diagram showing the focus order of headline, close, save, cancel.](https://lh3.googleusercontent.com/MuS9aCeC3P_ukbbopUpL7M9rV8VhBbirg3UofV-_SA7g-v4ABLSE8zgMWQOlHo7WP5XEd7s-KyR15aPB360mGPFofc_F3uKb1Sy7iQ8iOZ0dGA=w40)![Image 4: Side sheet diagram showing the focus order of headline, close, save, cancel.](https://lh3.googleusercontent.com/MuS9aCeC3P_ukbbopUpL7M9rV8VhBbirg3UofV-_SA7g-v4ABLSE8zgMWQOlHo7WP5XEd7s-KyR15aPB360mGPFofc_F3uKb1Sy7iQ8iOZ0dGA=s0)

Visible focus shown on the available actions within a side sheet:

1.   Headline
2.   Close
3.   Cancel
4.   Save

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| Keys | Actions |
| --- | --- |
| **Tab** | Focus lands on (non-disabled) icon button |
| **Space** or **Enter** | Activates the (non-disabled) icon button |

link

Copy link Link copied

Labeling
--------

link

Copy link Link copied

The accessibility role for a side sheet is **Dialog**.

![Image 5: Side sheet showing the accessibility role as dialog.](https://lh3.googleusercontent.com/ogti7RlWzhZNIER0PGHxR2hM--wMncqBhexq_aLUiY6OPM1C5NeuaWV29SOOqi5gjdr7dGbCFrlPMnQ2hX5pgrWhVUrQVhUmESeeg09ZQhdB=w40)

The role for side sheets is **Dialog**

[arrow_left_alt Previous Side sheets: Guidelines](https://m3.material.io/components/side-sheets/guidelines)[Up next arrow_right_alt Sliders: Overview](https://m3.material.io/components/sliders)

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
