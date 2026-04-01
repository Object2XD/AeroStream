Title: Bottom sheets – Material Design 3

URL Source: http://m3.material.io/components/bottom-sheets/guidelines

Markdown Content:
Bottom sheets show secondary content anchored to the bottom of the screen

Close

On this page

*   [Usage](https://m3.material.io/)
*   [Anatomy](https://m3.material.io/)
*   [Standard bottom sheets](https://m3.material.io/)
*   [Modal bottom sheets](https://m3.material.io/)
*   [Responsive layout](https://m3.material.io/)
*   [Behavior](https://m3.material.io/)

link

Copy link Link copied

![Image 1: Two variants of bottom sheets.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp7eqa7-1.png?alt=media&token=7a1b0b63-7f7a-48b1-9be2-7d0b84457733)

1.   Standard bottom sheets
2.   Modal bottom sheets

link

Copy link Link copied

Usage
-----

link

Copy link Link copied

Bottom sheets display supplementary content and actions on a mobile screen.

![Image 2: Photo sharing bottom sheet with contact list, app icons, and action buttons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp7jb72-2.png?alt=media&token=56a1f44f-75e1-4b64-b89a-af51f31743bf)

Bottom sheet containing contacts and applications

link

Copy link Link copied

Bottom sheets are a versatile component that can contain a wide variety of information and layouts Layout is the visual arrangement of elements on the screen. [More on layout](https://m3.material.io/m3/pages/understanding-layout/overview), including menu Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview) items (in list Lists are continuous, vertical indexes of text and images. [More on lists](https://m3.material.io/m3/pages/lists/overview) or grid layouts), actions, and supplemental content.

![Image 3: Bottom sheet displaying 3 menu options.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp7jy07-3.png?alt=media&token=cb9aef4d-3f8f-4d7a-bcae-c81ca2267ec2)

Bottom sheet with menu items in a list

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

A container is the only required element of a bottom sheet. Bottom sheet layouts Layout is the visual arrangement of elements on the screen. [More on layout](https://m3.material.io/m3/pages/understanding-layout/overview) can vary widely to support the kinds of content they contain.

link

Copy link Link copied

![Image 4: 3 elements of a bottom sheet.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp7l25p-4.png?alt=media&token=26b70d10-837b-47dc-8c19-66941c28cf55)

1.   Container
2.   Drag handle (optional)
3.   Scrim (modal only)

link

Copy link Link copied

### Container

link

Copy link Link copied

Bottom sheet containers hold all bottom sheet elements. Their size is determined by the space those elements occupy.

The container is the only required element of a bottom sheet. All other elements are optional.

![Image 5: Empty bottom sheet container.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp7llpd-5.png?alt=media&token=8dd51782-efbc-480d-b8d1-fc9703331372)

Bottom sheets are flexible containers that adapt to their content and available space

link

Copy link Link copied

### List items (optional)

link

Copy link Link copied

Lists Lists are continuous, vertical indexes of text and images. [More on lists](https://m3.material.io/m3/pages/lists/overview) are a continuous group of text or images. List items can include label text, icons, and text buttons Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/overview), among other elements.

![Image 6: A bottom sheet displaying a list of actions for a song.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp7m0a5-6.png?alt=media&token=f5e46b6c-e4a2-4691-8be7-6531cac198f8)

Bottom sheet containing a list with icons

link

Copy link Link copied

### Dividers (optional)

link

Copy link Link copied

Dividers Dividers are thin lines that group content in lists or other containers. [More on dividers](https://m3.material.io/m3/pages/divider/overview) can be used to separate related content in bottom sheets.

![Image 7: Bottom sheet with image action buttons and contact list separated by an inset divider.
](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp7t324-7.png?alt=media&token=3415430e-1af4-44bb-9b80-a419efd68993)

Bottom sheet with a divider separating kinds of actions

link

Copy link Link copied

### Media (optional)

link

Copy link Link copied

**Thumbnail**

Bottom sheets can include thumbnails for an avatar or logo.

**Image**

Bottom sheets can include photos, illustrations, and other graphics, such as weather icons.

**Video**

Bottom sheets can include video.

![Image 8: A bottom sheet displaying various media formats, including thumbnails, images, and video.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp7tqb3-8.png?alt=media&token=ec559377-ab42-40ae-b622-14e39ed36b06)

Bottom sheets can contain thumbnails, images, and video

link

Copy link Link copied

Standard bottom sheets
----------------------

link

Copy link Link copied

Standard bottom sheets co-exist with the screen’s main UI region and allow for simultaneously viewing and interacting with both regions, especially when the main UI region is frequently scrolled or panned.

Use a standard bottom sheet to display content that complements the screen’s primary content, such as an audio player in a music app.

![Image 9: Bottom sheet with music player controls visible while browsing albums.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp7ubva-9.png?alt=media&token=bc8efc23-0926-4ab3-8f15-284858ef6d08)

The music player in this standard bottom sheet allows people to control their music while browsing albums

link

Copy link Link copied

At full-screen height, standard bottom sheets contain a collapse icon in an app bar to return to their initial position.

Standard bottom sheets can contain supplementary content that continues below the screen, such as location information over a map.

A bottom sheet can have preset positions from full-screen height to preview

link

Copy link Link copied

Modal bottom sheets
-------------------

link

Copy link Link copied

Like dialogs Dialogs provide important prompts in a user flow. [More on dialogs](https://m3.material.io/m3/pages/dialogs/overview), modal bottom sheets appear in front of app content, disabling all other app functionality when they appear, and remaining on screen until confirmed, dismissed, or a required action has been taken.

![Image 10: A modal sheet with filter options to categorize files in the app. ](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp7yz9g-11.png?alt=media&token=88ce960b-06e9-49fb-85cf-e02a44792b1c)

A modal bottom sheet must be interacted with or dismissed. Its blocking behavior makes it suitable for a menu, such as in this files app, to help people focus on their available choices.

link

Copy link Link copied

Use a modal bottom sheet as an alternative to inline menus Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview) or simple dialogs Dialogs provide important prompts in a user flow. [More on dialogs](https://m3.material.io/m3/pages/dialogs/overview) on mobile, especially when offering a long list Lists are continuous, vertical indexes of text and images. [More on lists](https://m3.material.io/m3/pages/lists/overview) of action items, or when items require longer descriptions and icons.

Modal bottom sheets are used in mobile apps only.

![Image 11: A modal bottom sheet displayed as an alternative to a traditional menu, presenting a list of actions.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvqcnuc5-12.png?alt=media&token=5f8e64bf-e732-4bf6-a53b-bfda05089971)

Modal bottom sheets can be used instead of menus to present additional actions

link

Copy link Link copied

### Visibility

link

Copy link Link copied

To provide access to its top actions, the initial vertical position of modal bottom sheets Modal bottom sheets appear in front of app content, disabling all other app functionality when they appear, and remaining on screen until confirmed, dismissed, or a required action has been taken.  is capped at 50% of the screen height.

Modal bottom sheets whose contents exceed 50% of the screen height can then be pulled across the full screen and scrolled internally to access their remaining items.

![Image 12: A modal bottom sheet covering half of the screen, so both images and actions are accessible.](https://lh3.googleusercontent.com/0hAPkL3uzyvqMvvRWFno-49bG4xDEWveRgFgP06QiwL9TTPtIatzwZnFBVZI70GmAn_NyU9lVQQ-8JkRQ8Zo7385AFopIBou3f5sD8YuZLIT=w40)

The initial vertical position of modal bottom sheets can't exceed 50% of the screen height

link

Copy link Link copied

Modal bottom sheets Modal bottom sheets appear in front of app content, disabling all other app functionality when they appear, and remaining on screen until confirmed, dismissed, or a required action has been taken.  appear when triggered by a user action, such as tapping a button Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/overview) or an overflow icon. They can be dismissed by:

*   Tapping a menu Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview) item or action within the bottom sheet
*   Tapping the scrim
*   Swiping the sheet down
*   Using a close affordance within the bottom sheet’s app bar App bars display information and actions at the top of a screen. [More on app bars](https://m3.material.io/m3/pages/app-bars/overview), if available

Display a close affordance in a full-screen modal bottom sheet.

![Image 13: A modal bottom sheet disappearing by tapping the scrim.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp80k55-14.png?alt=media&token=9201f643-2086-4620-b7d0-0bc4c1f60ce8)

Tapping the scrim dismisses a modal bottom sheet

![Image 14: A modal bottom sheet disappearing by swiping the sheet down.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp81a31-Bottom_sheet_dismiss_swipe.png?alt=media&token=d0275463-fc3a-459f-b4c0-b0285236638e)

A modal bottom sheet can be dismissed by swiping the sheet down

link

Copy link Link copied

Responsive layout
-----------------

link

Copy link Link copied

### Compact window size

In compact window sizes Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact), like mobile devices, bottom sheets extend across the width of a screen and are elevated above the primary content.

![Image 15: A bottom sheet extended to the width of a mobile screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp86bt1-15.png?alt=media&token=9f8beb94-0e17-4f0d-991f-ba04bb46270d)

Bottom sheets should extend to the width of the screen on mobile

link

Copy link Link copied

### Medium and expanded window sizes

For larger screens with medium Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium) and expanded window sizes Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded), bottom sheets have a default max-width to prevent undesired layouts Layout is the visual arrangement of elements on the screen. [More on layout](https://m3.material.io/m3/pages/understanding-layout/overview) and awkward spacing. However, this can be overridden if needed. For more complex tasks and flows, consider using a non-transient surface such as a floating sheet Floating sheets show secondary content on a surface that can be anchored to the screen or moved. .

![Image 16: A bottom sheet extended to its max-width on a large screen device, not spanning the full screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp86pgb-16.png?alt=media&token=52847dda-fc2f-4c38-9d06-6cd94604456b)

Bottom sheets on larger screens like tablet have a max width that can be overridden

link

Copy link Link copied

On larger expanded window sizes Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded), like desktop, a bottom sheet can be swapped for a side sheet Side sheets show secondary content anchored to the side of the screen. [More on side sheets](https://m3.material.io/m3/pages/side-sheets/overview) that shows similar content.

![Image 17: A side sheet on desktop.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp877lp-17.png?alt=media&token=3c16d91e-e6ee-4f55-8677-253ce146a929)

Side sheets can contain the same content as bottom sheets and may be more suitable for desktop

link

Copy link Link copied

Behavior
--------

link

Copy link Link copied

Bottom sheets can offer an expansion option where the sheet is fully raised and toggled between a collapsed and expanded state States show the interaction status of a component or UI element. [More on states](https://m3.material.io/m3/pages/interaction-states/overview). This provides a more predictable footprint of the sheet, and can be set by the system or toggled by the user.

![Image 18: Bottom sheet fully raised, showing photo actions, sharing options, and albums to add the photo to.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp87qvd-18.png?alt=media&token=d9e9bffb-5011-41e2-b919-66246450697f)

A bottom sheet for sharing can appear fully raised if needed

![Image 19: Collapsed bottom sheet, showing focused set of options.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp8870t-19.png?alt=media&token=3f9b36b6-7621-48f9-bec4-8260503c7e75)

Alternately, a bottom sheet for sharing can appear collapsed for a more focused set of actions

link

Copy link Link copied

### Custom positioning

link

Copy link Link copied

The drag handle can be dragged or selected to change the bottom sheet height.
Sheets should be able to cycle through preset heights and close completely without dragging. Selecting the drag handle should toggle through preset heights or close the sheet, while selecting the scrim should always close the bottom sheet.

If the bottom sheet has multiple preset heights but can’t use a drag handle, Material requires the inclusion of a single-pointer alternative to change height.

![Image 20: Bottom sheet with a visible drag handle that can be used to adjust its height.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp8argg-20.png?alt=media&token=231c71e3-b060-4163-907b-540125d26d9d)

Interacting with the drag handle can quickly move a bottom sheet through preset heights

![Image 21: Bottom sheet resized using the visible drag handle.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp8b6u5-21.png?alt=media&token=787093f2-94a4-49fd-92a5-b12b6020c915)

A bottom sheet can automatically resize to another height after interacting with the drag handle

link

Copy link Link copied

### Scrolling

link

Copy link Link copied

Bottom sheets can be horizontally scrolled, independent of the rest of the screen’s content.

![Image 22: Bottom sheet that can be scrolled horizontally.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flvp8bo42-22.png?alt=media&token=7d24f701-094b-47fe-9a78-5712e0e61cde)

Bottom sheets should be scrollable when their content exceeds the initial viewable height

link

Copy link Link copied

### Back

link

Copy link Link copied

On Android, a gesture Gestures are all the ways people interact with UI elements using touch. [More on gestures](https://m3.material.io/m3/pages/gestures) called predictive back allows a user to swipe left or right on the bottom sheet.

*   Bottom sheet detaches from the left and right edges of the screen to signal it will close
*   Previous screen is revealed in a preview

A list of compatible components is available in the[gestures article](https://m3.material.io/m3/pages/gestures).

Preview of the result of the gesture, **release** to commit, **fling** to commit, and **cancel**
