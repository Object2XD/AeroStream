Title: Text fields – Material Design 3

URL Source: http://m3.material.io/components/text-fields/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Text fields – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/text-fields/accessibility#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Text fields
===========

Text fields let users enter text into a UI

Resources flutter android+2

Close

[info Overview](https://m3.material.io/components/text-fields/overview)[style Specs](https://m3.material.io/components/text-fields/specs)[design_services Guidelines](https://m3.material.io/components/text-fields/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/text-fields/accessibility)

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

User should be able to:

*   Navigate to and activate a text field with assistive technology
*   Input information into the text field
*   Receive and understand supporting text and error messages
*   Navigate to and select interactive icons

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

The containers for both filled Filled text fields have more visual emphasis than outlined text fields. They're often used in dialogs and short forms where their style draws more attention.  and outlined text fields Outlined text fields have less visual emphasis than filled text fields. They're often used in long forms where their reduced emphasis helps simplify the layout.  provide the same functionality. Changes to color and thickness of stroke help provide clear visual cues for interaction.

![Image 1: Filled text field in enabled (empty) state and in focused (populated state) have visual cues to identify their state.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32f0bp-1.png?alt=media&token=2037cfd2-09f9-48c6-a723-7a73f2dd6d36)

Filled text fields

![Image 2: Outlined text field in enabled (empty) state and in focused (populated state) have visual cues to identify their state.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32f68l-2.png?alt=media&token=aa76ef86-da54-4f76-8437-26c0181d85c2)

Outlined text fields

link

Copy link Link copied

Containers improve the discoverability of text fields by creating contrast between the text field and surrounding content.

In some contexts, outlined text fields can improve the perception of the fields with a 3:1 or greater contrast ratio between the container outline and the background.

![Image 3: An outlined text field with label text that passes the minimum contrast of 3:1.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32k7wf-3.png?alt=media&token=679bc72b-1edd-4a37-9f0c-462d91c195a6)

check Do 
Make sure the container outline has a minimum contrast of 3:1 to the background

![Image 4: An outlined text field with label text fails the minimum 3:1 contrast.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32kef6-4.png?alt=media&token=9677297e-c97b-4210-9a25-2c9268b02806)

close Don’t 
Don't choose colors that won't pass Material's minimum contrast of 3:1

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| Keys | Actions |
| --- | --- |
| Tab | Focus lands on (non-disabled) text field |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

If the UI text is correctly linked, assistive tech (such as a screenreader) will read the UI text followed by the component’s role.

The accessibility Accessible design makes products usable for people with all kinds of abilities. [More on accessibility](https://m3.material.io/m3/pages/overview) label for a text field is the same as the text field label.

![Image 5: The text field  and accessibility label both read “Email.” The role is “textbox.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32ks8b-5.png?alt=media&token=12c43d38-d18f-417c-b8fc-13110c145ffa)

A text field’s label should include its UI text

link

Copy link Link copied

For text fields with interactive trailing icons, the accessibility label clarifies its function.

For example, when a password is hidden, the label for the view icon is "Show password," and when the password is visible, the label is"Hide password."

When an icon has no actionable role, like an error icon, the label is "Error."

![Image 6: The trailing icon’s accessibility label “Show Password.” The role is “Button.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32l5y8-6.png?alt=media&token=b4271bd0-47bf-4af4-b9f7-fb693bf843be)

When a trailing icon in the field acts as a button, the label should clarify function, while the role explains the component type

link

Copy link Link copied

The prefix and suffix of a text field provides symbols and abbreviations to help users enter the correct values.

The accessibility Accessible design makes products usable for people with all kinds of abilities. [More on accessibility](https://m3.material.io/m3/pages/overview) label for prefix and suffix needs to have a unique id attribute, for example, the currency name for a currency symbol prefix.

![Image 7: Text field accessibility labels “UI text” are “Euro” for a currency prefix and “At gmail dot com” for the email address suffix.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32leg0-7.png?alt=media&token=9d09f464-5f11-40c9-8310-af201dd18e29)

A form containing fields with both a prefix for currency, and a suffix for email address

link

Copy link Link copied

When there is an error, "alert" is applied to the role and the error message to the text label.

If a text field displays both supporting text and error text, the label should include the supporting text first, followed by the error text.

![Image 8: The text field accessibility labels is: UI text “Not a valid ZIP code.” The role is “Alert.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32lojq-8.png?alt=media&token=a55926cc-d2d2-4451-8fe2-74a515db3a16)

Text field error messages should be given an “alert” role in accessibility labels

link

Copy link Link copied

The accessibility label for the character counter clarifies the number of characters that can be entered into the text field.

![Image 9: A character counter's accessibility label  reads: UI text (“Character count, 5/20”)](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32m4pa-9.png?alt=media&token=aac93da1-54a2-4b87-a1bc-68807f59bbd4)

The remaining character counter should be called “character count” within the label

link

Copy link Link copied

The text displayed in the supporting text is also used for its accessibility label.

![Image 10: The accessibility label uses the supporting text. It reads: UI text (“Please use the company email address”). Role [No role].](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32meu7-10.png?alt=media&token=4caf165e-0a75-4e05-8be8-410f681c8874)

Text field supporting text should have its own accessibility label

link

Copy link Link copied

If a text field requires input, indicate so with an asterisk at the end of the text field label. The accessibility label must include the asterisk.

![Image 11: Accessibility label reads: UI text (“Username*”).  The role is “Textbox.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx32mlzg-11.png?alt=media&token=72a43825-5286-49d6-9f49-7bb37a11e0f4)

A required text field’s accessibility label should include any supporting text

[arrow_left_alt Previous Text fields: Guidelines](https://m3.material.io/components/text-fields/guidelines)[Up next arrow_right_alt Toolbars: Overview](https://m3.material.io/components/toolbars)

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
