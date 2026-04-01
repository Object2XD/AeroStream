Title: FAB menu

URL Source: http://m3.material.io/components/fab-menu/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to do the following using assistive technology:

*   Navigate and interact with the FAB menu
*   Ensure focus is correct when navigating through the menu

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

FAB menu elements meet the minimum target size of 48dp.

![Image 1: FAB menu measurement annotations. All elements are larger than the minimum target size.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0am5xpn-01.png?alt=media&token=537719c2-9f5f-4d5d-ba85-2b59cdcd2c5b)

FAB menus have 48x48dp minimum width and sufficient spacing by default

link

Copy link Link copied

When the FAB menu can scroll, make sure the items scroll behind the close button.

The close button should always be easy to access and unobstructed.

![Image 2: FAB menu items are scrolling behind the close button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0am8l9a-02.png?alt=media&token=989423d2-f7cd-4b11-8ac1-115565b2ccc2)

check Do 
Allow the menu items to scroll behind the close button

![Image 3: FAB menu items are scrolling in front of the close button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0am8ym2-03.png?alt=media&token=5fa58f68-9fae-4806-8754-4fe611b73f45)

close Don’t 
Don’t obstruct the close button in short screens like horizontal orientation

link

Copy link Link copied

Initial focus
-------------

link

Copy link Link copied

When the FAB is selected, the FAB menu opens, and initial focus remains on the close button, which takes the place of the original FAB.

Then the focus moves from the top menu item to the bottom.

![Image 4: 4 FAB menus with the focus order labelled. Focus moves from the close button at the bottom to the topmost menu item next.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmaejeaf9-04.png?alt=media&token=d8a732b5-ad7b-4566-a92d-eccca8795f38)

Focus lands on the close button. People can then navigate through all the items.

1.   Close button
2.   First menu item
3.   Second menu item
4.   Third menu item

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| Keys | Actions |
| --- | --- |
| Tab | Navigate to the next interactive element |
| Space or Enter | Activate the focused button or item |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

The close button of the FAB menu should have the **button** role and label **close**.

![Image 5: Accessibility labels for the close button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0amemaw-05.png?alt=media&token=c723fed3-2d4d-4ca1-a34a-14899768c332)

Label the close button with the button role

link

Copy link Link copied

On mobile web, the items should have the **menu item** roles.

The menu items should have labels matching the UI text.

![Image 6: Accessibility labels for the FAB menu items.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0ameviv-06.png?alt=media&token=861c3c91-6513-44ec-877a-bfa7c4cfc2ec)

Label each FAB menu item with the menu item role
