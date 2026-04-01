Title: Chips – Material Design 3

URL Source: http://m3.material.io/components/chips/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to do the following with assistive technology:

*   Use a chip to perform an action
*   Navigate to a chip
*   Activate a chip

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

The chip label needs at least 3:1 contrast with the background.

A chip that performs an action should present the same semantics as a button Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/overview) to a platform's accessibility API.

![Image 1: The chip label needs to pass 3:1 contrast.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm99z66s4-01.png?alt=media&token=f43b4651-be9f-4a1a-a7d2-4658f1096a47)

High contrast helps differentiate chips clustered together

link

Copy link Link copied

### Horizontal overflow

When there are too many chips to fit on one row, provide a way to display them all at once and avoid scrolling.

**Reflow method:**Use a filter chip as a leading element to reflow the horizontal list. This should shift down the content below and make room for all chips to show.

The **Show all**filter chip is used to reflow the list, displaying all chips at once and pushing down the content below

link

Copy link Link copied

**Menu method:**Create a leading button to display all chip options in a menu. Use this option to avoid shifting the position of the content below.

Don’t use the menu method on chips with a second action, like a remove icon.

The **Show all** leading button shows a menu of chip options, keeping the place of content below

link

Copy link Link copied

### Avoid applying density by default

Don't apply density to chips by default — this lowers their targets below our best practice of 48x48 CSS pixels. Instead, give people a way to choose a higher density, like selecting a denser layout or changing the theme.

To ensure that this density setting can be easily reverted when it's active, keep all the targets to change it at minimum 48x48 CSS pixels each.

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| Keys | Actions |
| --- | --- |
| **Tab** | Moves focus to enabled An enabled state communicates an interactive component or element. [More on enabled state](https://m3.material.io/m3/pages/interaction-states/applying-states#79d4c7b3-bd64-49ba-90f1-3eeb62f1b328) chip or chip group |
| **Space** or **Enter** | Activates, selects, or deselects the focused chip |
| **Backspace** or **Delete** | Removes currently focused A focused state communicates when a user has highlighted an element, using an input method such as a keyboard or voice. [More on focused state](https://m3.material.io/m3/pages/interaction-states/applying-states#bfc1624f-6bcc-4306-b0c1-425e2d8a1bf9) input chip |
| **Arrows** | Moves focus between chips |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

| Element | A11y label | Role (Web) | Role (MDC-Android) | Role (Jetpack Compose) |
| --- | --- | --- | --- | --- |
| Image / Icon within chip | Hide image | - | - | - |
| Basic chip (one action) | “{chip content}” | gridcell | button | button |
| Selectable chip | “{chip content}” | gridcell | radio button | checkbox |
| Remove icon (no other action) | “Remove {chip content}” | - | - | - |
| Two actions (e.g., select + remove) | “{chip content}.” Then “Remove {chip content}”. | button or checkbox | button or checkbox | button or checkbox |

link

Copy link Link copied

The accessibility label for a chip is the chip's label text. Additional actions, like remove, are labeled separately.

![Image 2: Accessibility tags for a chip.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmderzcwe-02.png?alt=media&token=75d7c645-1d21-4915-8290-080815f8529c)

Accessibility tags should include both the label and role

link

Copy link Link copied

### Multi-select

For multi-select chip sets, **Space** or **Enter** will select the focused chip and allow you to select all of the chips. **Space** or **Enter** will also deselect a focused selected chip.

![Image 3: Accessibility tags for a multi-select chip.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmderoau5-25.png?alt=media&token=16369c04-2f10-46eb-b761-0d25cd0b85c7)

While multiple chips can be selected, only one can be in focus

link

Copy link Link copied

### Drop-down list

The accessibility label should align with each list item’s text label.

For list items with text and an icon, the accessibility label should be marked as decorative to avoid redundant verbalizations.

![Image 4: Accessibility tags for a drop-down list chip.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmd78nzr3-04.png?alt=media&token=4e0b3550-1e77-44ea-82a9-cfafaacadf98)

The accessibility label should be the text label

link

Copy link Link copied

### Input chip remove action

Display the remove icon whenever a chip can be removed. On mobile, if remove is the only chip action, the remove icon isn't necessary. Instead the chip can be removed by selecting it and pressing the **Delete** key on the keyboard.

Each chip is a focusable element.

*   If a chip only has a remove icon, the entire chip and icon are one focusable element.
*   If a chip has a second action, like select, then the chip content and remove icon are two separate focusable elements.

![Image 5: A focused remove action within a chip.](https://lh3.googleusercontent.com/6ogPU6jU6ecd-bIOHVBsztMIVbrMh9QFdEYLITFw2dbd9atxkbPCtGrNHZfykUnYCCmQUR4-XY9KTUDAeDG3GCh60nDvFFCG41_E8r2o88yq=w40)

The remove action is focused when the chip can also be selected
