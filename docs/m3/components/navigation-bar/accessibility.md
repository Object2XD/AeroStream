Title: Navigation bar – Material Design 3

URL Source: http://m3.material.io/components/navigation-bar/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to do the following using the assistive technology:

*   Move between navigation destinations
*   Select a particular navigation destination from a set
*   Get appropriate feedback based on input type

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

**Touch**

*   When a navigation item is tapped, the active indicator appears in place, providing feedback that it’s selected

*   A touch ripple passes through the indicator

*   The icon switches from outlined to filled

*   The icon changes color

Touch: Tap

link

Copy link Link copied

**Cursor**

*   When hovered, the active indicator appears in a reduced state providing a visual cue that the destination is interactive

*   When clicked (in both active and inactive states), a ripple passes through the indicator

*   The icon switches from outlined to filled

*   The icon changes color, becoming darker

Cursor: Hover, Click

link

Copy link Link copied

### Text scaling and truncation

When someone sets their device to show a larger text size, the navigation bar should grow vertically to accommodate larger labels while retaining the default padding. It’s okay for scaled text to wrap in navigation items.

To remain accessible, ensure the full label is always visible on-screen at up to 2x text sizing. Beyond this size, text can truncate.

![Image 1: Nav bar with text scaled to 1.5x size. Some labels are on two lines, others are on one line.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm2kua3ge-03.png?alt=media&token=f108d48f-851d-45d1-ba80-1e83568032f3)

Text scaled to 1.5 size

![Image 2: Nav bar with text scaled to 2x size. Some labels wrap to two lines.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm2kuaeol-04.png?alt=media&token=10e14f80-49cb-45ec-8388-cb1f010199ea)

Text scaled to 2x size

link

Copy link Link copied

Initial focus
-------------

link

Copy link Link copied

Initial focus lands directly on the first navigation item, since that is the first interactive element of the component.

![Image 3: Focus order and keyboard navigation of a nav bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fr7kb3-03.png?alt=media&token=84bac263-efdf-4665-a287-0e747b635270)

Focus lands on first navigation item

![Image 4: Activating a nav item with space on a keyboard.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fr7nd7-04.png?alt=media&token=f9921ae7-fcf3-45e4-9bcd-30cd1952f450)

The navigation item is selected with Space/Enter

link

Copy link Link copied

Visual indicators
-----------------

link

Copy link Link copied

Use a filled icon with a bold label for selected destinations. For unselected destinations use an outlined icon with a medium label.

If an icon doesn’t have a filled style, use a thicker or heavier version of the icon instead.

![Image 5: A nav bar with a filled icon for the selected nav item.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fr7qqu-05.png?alt=media&token=e630d9b4-cb7e-4880-8604-a9407ac24978)

check Do 
Use a filled icon for the selected navigation destination to differentiate from the other destinations

![Image 6: A nav bar with an outlined icon for the selected nav item.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fr7ugl-06.png?alt=media&token=b90be5ba-4212-42ac-95c4-7b1d6b44b4b1)

close Don’t 
Don’t use outlined icons on selected nav items

link

Copy link Link copied

![Image 7: 2 nav items, one selected, one unselected.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fr7yfn-07.png?alt=media&token=03133ebd-5e3b-41e0-92be-0e1d4c05cf2c)

When selected, the icon fills, darkens, and is backed by an active indicator shape

link

Copy link Link copied

Keyboard navigation
-------------------

| Keys | Actions |
| --- |
| Tab | Move between navigation items |
| Space / Enter | Selects the focused navigation item |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

The accessibility label for a navigation item is typically the same as the destination name.

![Image 8: Accessibility label and role defined for a Home icon on a navigation bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fr861i-08.png?alt=media&token=2a25c26a-fbf9-4ee1-8c0b-5395b7db904d)

A navigation bar’s accessibility label can incorporate its adjacent UI text

link

Copy link Link copied

When the visible UI text is ambiguous, accessibility labels need to be more descriptive. For example, a navigation destination visibly labeled**Library**would benefit from additional information in its accessibility label to clarify the destination’s intent.

Note: On MDC-Android, a more descriptive accessibility label is not available and the role is not announced.

![Image 9: Accessibility labels of a navigation bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fr8a8y-09.png?alt=media&token=7691ca2e-ae07-466a-9070-37fa398803aa)

While the visible label text reads **Library**, the accessibility label for this destination clarifies its function:**Music library**
