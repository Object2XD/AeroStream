Title: Dialogs – Material Design 3

URL Source: http://m3.material.io/components/dialogs/guidelines

Markdown Content:
Dialogs provide important prompts in a user flow

Close

On this page

*   [Usage](https://m3.material.io/)
*   [Anatomy](https://m3.material.io/)
*   [Basic dialog](https://m3.material.io/)
*   [Full-screen dialog](https://m3.material.io/)
*   [Adaptive design](https://m3.material.io/)
*   [Behavior](https://m3.material.io/)

link

Copy link Link copied

![Image 1: Basic dialog in isolation](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sf9qay-01.png?alt=media&token=5e8c7d9f-1451-4104-b5a4-c64b2e98296f)

A basic dialog

link

Copy link Link copied

Usage
-----

link

Copy link Link copied

A dialog is a modal window that appears in front of app content to provide critical information or ask for a decision. Dialogs disable all app functionality when they appear, and remain on screen until confirmed, dismissed, or a required action has been taken.

Dialogs are purposefully interruptive, so they should be used sparingly. A less disruptive alternative is to use a dropdown menu Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview), which provides options without interrupting a user’s experience.

link

Copy link Link copied

![Image 2: Diagram of basic and full-screen dialogs.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfc7pz-02.png?alt=media&token=48e473e3-7381-4089-8e91-11de31b32586)

There are two variants of dialogs:

1.   Basic dialog

2.   Full-screen dialog

link

Copy link Link copied

![Image 3: Dialog in front of app content.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfcqhr-03_do.png?alt=media&token=3655fc78-54b9-44f6-a239-d93670bb087e)

check Do 
Use dialogs for prompts that block an app’s normal operation, and for critical information that requires a specific user task, decision, or acknowledgement

![Image 4: Low-priority dialog in front of app content.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfdc9w-03_dont.png?alt=media&token=6a548db0-3131-46af-9f44-d30b74de4904)

close Don’t 
Don’t use dialogs for low- or medium-priority information. Instead use a snackbar, which can be dismissed or disappear automatically.

link

Copy link Link copied

### Similar components

Snackbars Snackbars show short updates about app processes at the bottom of the screen. [More on snackbars](https://m3.material.io/m3/pages/snackbar/overview) are also designed to show important messages.

Choose the right component based on the importance of the message. This component messaging strategy helps avoid overusing dialogs.

![Image 5: Snackbar on a phone saying that new photos were synced to the device. No buttons exist.](https://lh3.googleusercontent.com/XLiUu7mOltTNoUojZheRl95_BXn_O9vc9-PwyzL2W_vZPBccPC1bntpTZ6KwgzKDMDt8UGih90E9GPDGd-uyGWZz0eqLMZOItywMT-yiDxS7=w40)

Snackbars can disappear automatically

link

Copy link Link copied

| **Component** | **Importance** | **Action needed** |
| --- | --- | --- |
| Snackbar | Low importance | Optional: Snackbars may not have a button Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/overview), and can disappear automatically |
| Dialog | High importance | Required: Dialogs block the main content until an action is confirmed |

link

Copy link Link copied

Anatomy
-------

### Basic dialog

link

Copy link Link copied

![Image 6: Diagram of 7 elements of basic dialog.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfhos4-07.png?alt=media&token=c26b3dc0-c5bd-4fe6-8081-13019a21814c)

1.   Container
2.   Icon (optional)
3.   Headline (optional)
4.   Supporting text
5.   Divider (optional)
6.   Buttons label text
7.   Scrim

link

Copy link Link copied

### Full-screen dialog

link

Copy link Link copied

![Image 7: 6 elements of full-screen dialog.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfick9-08.png?alt=media&token=7287dba3-0638-4a9f-afde-dcc94ce608e2)

1.   Container
2.   Header region
3.   Icon (close affordance)
4.   Headline (optional)
5.   Button label text
6.   Divider (optional)

link

Copy link Link copied

### Container and scrim

Dialog containers appear above other screen elements and hold the dialog’s headline, text, buttons Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/overview), and list Lists are continuous, vertical indexes of text and images. [More on lists](https://m3.material.io/m3/pages/lists/overview) items.

To focus attention on the dialog, surfaces behind the container are scrimmed with a temporary overlay to make them less prominent.

![Image 8: Basic dialog shown above a scrim overlay that reduces the prominence of the background elements.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfkf69-09.png?alt=media&token=76b7d3c2-c1db-4dc4-aabb-8df0851f4dd7)

Basic dialogs appear over a background scrim

link

Copy link Link copied

### Headline (optional)

A dialog’s purpose should be communicated by its headline and buttons or actionable items.

Headlines should:

*   Contain a brief, clear statement or question
*   Avoid apologies (“Sorry for the interruption”), alarm (“Warning!”), or ambiguity (“Are you sure?”)

![Image 9: Dialog title asking “Use location service?”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfl8j1-10_do.png?alt=media&token=6685809e-faa9-4002-a1ca-7b6355cc0c4a)

check Do 
This dialog title poses a specific question, concisely explains what’s involved in the request, and provides clear actions

![Image 10: Dialog title asking “Are you sure?”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sflmm0-11_don't.png?alt=media&token=2b32fc1c-10ea-4041-8719-5a0bbd515d5e)

close Don’t 
Don’t use dialog titles that pose an ambiguous question

link

Copy link Link copied

Headlines should always be succinct. They can wrap to a second line if necessary, and be truncated.

In full-screen dialogs, long headlines or headlines of variable lengths (such as translations), can be placed in the content area instead of the app bar.

![Image 11: Example full-screen dialog with truncated long headline.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfm2yt-12_Caution.png?alt=media&token=bb20aab8-9a35-4eaf-9f8c-f2fc29f20a6c)

exclamation Caution 
Avoid placing long headlines in a full-screen dialog’s app bar (1), as the truncated text may lead to misunderstanding

![Image 12: Example full-screen dialog with short headline, and longer text in content area.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfmezr-13_do.png?alt=media&token=5244a6e2-9faa-44ec-998d-12d486666021)

check Do 
Find ways to shorten app bar text, and place longer headlines into the content area (1) of a full-screen dialog

link

Copy link Link copied

### Buttons

Dialog actions are most often represented as buttons Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/overview) and allow users to confirm, dismiss, or acknowledge something.

Buttons are aligned to the trailing edge of the dialog for easier interaction. The confirmation button is always closest to the edge.

Button alignment responds automatically for right-to-left languages, where the confirmation button is aligned to the left edge.

![Image 13: Dialog with the confirmation button disabled because a required radio selection is missing.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfmqqd-14_do.png?alt=media&token=12972233-4c46-4c82-9b80-86136ae125ca)

check Do 
Disable confirming actions (1) until a choice is made. Dismissive actions are never disabled.

![Image 14: Dialog with the dismissing action "Cancel" on the right of the 2 buttons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfn276-15_don't.png?alt=media&token=51d3809f-8761-4ad0-91d1-d3b4b9bc21dc)

close Don’t 
Don’t place dismissive actions (1) to the right of confirming actions. Instead, place them to the left of confirming actions.

link

Copy link Link copied

![Image 15: Dialog with a single-action button: “OK”.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfq9tm-16_do.png?alt=media&token=1ac568e8-5f77-443d-9a0f-ee24e2d5ae71)

check Do 
A single action may be provided only if it’s an acknowledgement

![Image 16: Dialog with 2 button choices: “Cancel”, “Got it”.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfqm2i-17_don't.png?alt=media&token=834d6d37-9c33-4d38-a72a-ba3fc1c84783)

close Don’t 
Avoid presenting people with unclear choices. **Cancel** doesn't make sense here because no clear action is proposed.

link

Copy link Link copied

Dialogs should contain a maximum of two actions.

*   If a single action is provided, it must be an acknowledgement action
*   If two actions are provided, one must be a confirming action, and the other a dismissing action

![Image 17: Dialog with 2 buttons side-by-side: “Disagree”, “Agree”.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfqzp1-18_do.png?alt=media&token=0c0f6350-ea79-41f6-a82b-8adcb6ef4f5d)

check Do 
Display two text buttons next to one another

![Image 18: Dialog with 2 stacked buttons: “Turn on speed boost”, “No thanks”.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfre4i-19_caution.png?alt=media&token=e19e944e-1e50-437b-81e7-643e4dd9dd6b)

exclamation Caution 
Stacked buttons accommodate longer button text, but take up more room. Confirming actions appear above dismissive actions.

link

Copy link Link copied

Providing a third action, such as **Learn more**, is not recommended as it navigates the user away from the dialog, leaving the dialog task unfinished.

Rather than adding a third action, an inline expansion can display more information. If more extensive information is needed, provide it prior to entering the dialog.

![Image 19: Dialog with 3 text buttons: Learn more, Disagree, Agree.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfrskh-20.png?alt=media&token=ce701d0c-c122-4fda-9244-be331795f9a5)

exclamation Caution 
The **Learn more** action (1) navigates away from this dialog, potentially leaving it in an indeterminate state

link

Copy link Link copied

Basic dialog
------------

Basic dialogs interrupt users with urgent information, details, or actions. Common use cases for basic dialogs include alerts, quick selection Selection lets users choose specific items to act on. [More on selection](https://m3.material.io/m3/pages/selection), and confirmation.

link

Copy link Link copied

![Image 20: Example of basic dialog action request.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfumns-21.png?alt=media&token=f60188e3-24f3-4ede-a5c2-ae41ebbda58f)

Basic dialogs require a person to take action before it will close

![Image 21: Example of basic dialog confirmation.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfuxlx-22.png?alt=media&token=356b591f-4aa3-4889-95f5-2c579e0c699f)

Basic dialogs can give people the ability to provide confirmation of a choice before committing to it

link

Copy link Link copied

Basic dialogs most often appear as alerts or lists Lists are continuous, vertical indexes of text and images. [More on lists](https://m3.material.io/m3/pages/lists/overview), but can have a variety of layouts Layout is the visual arrangement of elements on the screen. [More on layout](https://m3.material.io/m3/pages/understanding-layout/overview) and component combinations, including lists, date pickers Date pickers let people select a date, or a range of dates. [More on date pickers](https://m3.material.io/m3/pages/date-pickers/overview), and time pickers Time pickers help users select and set a specific time. [More on time pickers](https://m3.material.io/m3/pages/time-pickers/overview).

![Image 22: Date picker dialog.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfzk1g-23.png?alt=media&token=5d0f7fb7-2646-4c2d-9450-71e463c72f7f)

Date picker dialogs allow people to tap a date, then confirm it by tapping **OK**

![Image 23: Time picker dialog.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sfxxnd-24.png?alt=media&token=3b205d81-1479-4bf5-aa8c-c803aa41e7de)

Time picker dialogs allow people to move the clock hand and then confirm by tapping **OK**

link

Copy link Link copied

Full-screen dialog
------------------

link

Copy link Link copied

Full-screen dialogs fill the entire screen, containing actions that require a series of tasks to complete. One example is creating a calendar entry with the event title, date, location, and time.

Because they take up the entire screen, full-screen dialogs are the only dialogs over which other dialogs can appear.

Use a [container transform](https://m3.material.io/m3/pages/motion-transitions/transition-patterns#b67cba74-6240-4663-a423-d537b6d21187) pattern to transition a FAB Floating action buttons (FABs) help people take primary actions. [More on FABs](https://m3.material.io/m3/pages/fab/overview) into a full-screen dialog.

Full-screen dialogs contain actions that require a series of tasks to complete

link

Copy link Link copied

When a full-screen dialog is closed without being saved, a basic dialog appears in front of it to confirm selections Selection lets users choose specific items to act on. [More on selection](https://m3.material.io/m3/pages/selection) should be discarded without saving changes.

A basic modal dialog appears when a full-screen dialog is closed without being saved

link

Copy link Link copied

Full-screen dialogs may be used for content or tasks that meet any of these criteria:

*   Dialogs that include components which require keyboard input Inputs are devices that provide interactive control of an app. Common inputs are a mouse, keyboard, and touchpad. , such as form fields
*   When changes aren’t saved instantly
*   When components within the dialog open additional dialogs

Full-screen dialogs are for compact window sizes Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact) only, like mobile devices. For medium and expanded window sizes Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded), use a basic dialog.

link

Copy link Link copied

### Saving selections

link

Copy link Link copied

To save a selection in a full-screen dialog, use **Save**. The close icon or dismissive action, such as **Cancel** or **Back**, should close the dialog.

link

Copy link Link copied

### Confirmation

link

Copy link Link copied

The confirmation action should be clear about what happens next, like **Send** or **Create**. Avoid using vague terms like **Done**, **OK**, or **Close**. Only trigger an additional basic dialog if the action fails. Don’t disable A disabled state communicates an inoperable component or element. [More on disabled state](https://m3.material.io/m3/pages/interaction-states/applying-states#4aff9c51-d20f-4580-a510-862d2e25e931) the confirmation button.

link

Copy link Link copied

![Image 24: Full-screen dialog with create button as confirmation action.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sg5wkr-27_do.png?alt=media&token=8aa1b2c7-d3e9-4c8d-a171-dd8f5920102a)

check Do 
A **Create** button is clear that the event will be created

![Image 25: Full-screen dialog with an additional basic dialog asking if you want to create this event.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sg67kv-28_don't.png?alt=media&token=a6a5c838-d758-4465-b05e-f29ac5eb0d3f)

close Don’t 
Don’t trigger a basic dialog when the confirming action is selected

link

Copy link Link copied

### Dismissing

link

Copy link Link copied

When someone dismisses a full-screen dialog, a basic dialog should appear to confirm that they want to discard the unsaved changes.

link

Copy link Link copied

![Image 26: A basic dialog with options to either keep editing or discard unsaved changes.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sg91cq-29_do.png?alt=media&token=1829089e-6440-4fcf-8d7b-5b4dd688ad92)

check Do 
Use a basic dialog to confirm that the user wants to discard unsaved changes

![Image 27: A full-screen dialog with a Close button as the confirming action.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sg9bz5-30_don't.png?alt=media&token=0d99e0df-e3f2-4c02-9a9c-598c311f8e7c)

close Don’t 
Don’t use the confirming action to dismiss the full-screen dialog

link

Copy link Link copied

### Error messages

link

Copy link Link copied

Errors about the dialog fields should always appear inline where they occur. Some components like text fields Text fields let users enter text into a UI. [More on text fields](https://m3.material.io/m3/pages/text-fields/overview) have built-in error messaging, while others like checkboxes Checkboxes let users select one or more items from a list, or turn an item on or off. [More on checkboxes](https://m3.material.io/m3/pages/checkbox/overview) and radio buttons Radio buttons let people select one option from a set of options. [More on radio buttons](https://m3.material.io/m3/pages/radio-button/overview) need error messages to be added next to the fields.
General errors such as network issues preventing saving or submitting should appear in a basic dialog when the confirming action fails.

Error messages should clearly but briefly explain the source of the error and how to fix it. Show all errors on the page at once so people can fix everything before trying again.

link

Copy link Link copied

![Image 28: A full-screen dialog with inline error messages for text fields.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sg9nzm-31_do.png?alt=media&token=80b7cdd4-6892-4661-a674-6e85c62b9122)

check Do 
Error messages related to the fields should be displayed inline

![Image 29: A basic dialog mentioning that entries were not saved due to a connection issue.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sg9xoh-32_caution.png?alt=media&token=5d180627-2303-4b00-92e5-39d90741c8fd)

exclamation Caution 
Errors unrelated to the fields can be displayed in a basic dialog

link

Copy link Link copied

### Dialog windows

Launching a full-screen dialog temporarily resets the app’s perceived elevation, allowing simple menus Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview) or dialogs to appear above the full-screen dialog. They cover the screen and don’t appear as a floating modal window.

### Navigation

Because full-screen dialogs can only be completed, dismissed, or closed, the close “X” icon button should be the only navigation option in the app bar App bars display information and actions at the top of a screen. [More on app bars](https://m3.material.io/m3/pages/app-bars/overview).

link

Copy link Link copied

Adaptive design
---------------

link

Copy link Link copied

Dialogs can swap variants as the window size class Window size classes are opinionated breakpoints where layouts need to change to optimize for available space, device conventions, and ergonomics. [More on window size classes](https://m3.material.io/foundations/layout/applying-layout/window-size-classes) changes. For example, a full-screen dialog Full-screen dialogs fill the entire screen, displaying actions that require a series of tasks to complete. They're often used for creating a calendar entry. [More on full-screen dialogs](https://m3.material.io/m3/pages/dialogs/guidelines#007536b9-76b1-474a-a152-2f340caaff6f) can change into a basic dialog Basic dialogs interrupt users with urgent information, details, or actions. They're often used for alerts, quick selection, or confirmation. [More on basic dialogs](https://m3.material.io/m3/pages/dialogs/guidelines#97ac3858-3932-4084-ae8e-73e42b7cb752) at larger breakpoints.

link

Copy link Link copied

![Image 30: Example of full-screen dialog on left, simple dialog on right](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sgbmj3-33.png?alt=media&token=17fd8879-6435-409a-a3a9-8bd390799892)

1.   Full-screen dialog on mobile
2.   Dialog on a tablet

link

Copy link Link copied

### Medium window size

Basic dialogs appear in a center position by default.

Their position can be overridden to provide a more ergonomic experience.

![Image 31: Basic dialog on tablet photos app.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sgc676-34.png?alt=media&token=9bc72c88-69cf-49e2-a631-070890d60754)

Dialog custom positioned on the right side of the screen

link

Copy link Link copied

### Expanded window size

Dialogs on expanded window sizes Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded), like desktop, are modal windows above a scrim. This puts the dialog at the forefront of a person's view, calling attention to the action prompted in the dialog.

![Image 32: Example of desktop dialog.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sgj2r1-35.png?alt=media&token=a9f16af1-69fe-43cc-9806-883818a87845)

Desktop dialogs call attention to the required action

link

Copy link Link copied

Basic dialogs can be custom-positioned anywhere on larger screens, respecting margins Margins are the spaces between the edge of a nested element and its parent element, such as the space between a button's label text and the edge of its container. [More on margins](https://m3.material.io/m3/pages/understanding-layout/spacing#38a538d7-991f-4c39-8449-195d32caf397) to prevent edge collision.

![Image 33: Basic dialog position diagram.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sgjir4-36.png?alt=media&token=e2dd2b5a-1e2e-4051-a0da-4ec15079f2ce)

Custom placement area for basic dialogs that respects a 56dp margin from the edges of the screen

link

Copy link Link copied

Behavior
--------

link

Copy link Link copied

### Appearing

Dialogs appear without warning, requiring users to stop their current task. They should be used sparingly, as not every choice or setting warrants interruption.

Dialogs use an [enter and exit](https://m3.material.io/m3/pages/motion-transitions/transition-patterns#e1c2a650-d7a4-4a6d-9025-e6b7845291ed) transition pattern to appear on screen.

A dialog appears with an enter and exit transition

link

Copy link Link copied

### Position

Dialogs retain focus until dismissed or an action has been taken, such as choosing a setting. They shouldn’t be obscured by other elements or appear partially on screen, with the exception of full-screen dialogs.

![Image 34: A basic dialog covering a full-screen dialog.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8sgqe15-38.png?alt=media&token=9a9c7716-0f17-4ee5-a3c9-a6fb5114547a)

Dialogs shouldn’t be obscured by other elements except for full-screen dialogs

link

Copy link Link copied

### Scrolling

Most dialog content should avoid scrolling. Even when scrolling is required, the dialog title is pinned at the top, with buttons Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/overview) pinned at the bottom. This ensures selected content remains visible alongside the title and buttons, even upon scroll.

Dialogs don’t scroll with elements outside of the dialog, such as the background.

When viewing a scrollable list of options, the dialog title and buttons remain fixed
