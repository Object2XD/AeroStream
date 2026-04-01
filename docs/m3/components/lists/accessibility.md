Title: Lists – Material Design 3

URL Source: http://m3.material.io/components/lists/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to do the following with assistive technology:

*   Navigate to a list item

*   Select a list item

link

Copy link Link copied

Indicate selection with more than color
---------------------------------------

link

Copy link Link copied

To make selected items clear for everyone, don't rely on color as the only visual cue.

Use an additional indicator that an item is selected such as:

*   Radio buttons Radio buttons let people select one option from a set of options. [More on radio buttons](https://m3.material.io/m3/pages/radio-button/overview) or checkboxes Checkboxes let users select one or more items from a list, or turn an item on or off. [More on checkboxes](https://m3.material.io/m3/pages/checkbox/overview)

*   Leading or trailing icons

*   A visual style not related to color, like underlined text

![Image 1: A selected list item with a colored background, and a check as the leading icon.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmif14iza-01.png?alt=media&token=140fabe0-eda0-43e7-8c49-95c7213f08f3)

Use two visual cues to show a list item is selected, like a leading checkmark and filled color

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

### Touch

When a person taps on a list item, a touch ripple appears, indicating interaction feedback.

A ripple appears when a person taps on a list item to select it

link

Copy link Link copied

### Cursor

When hovered, the hover A hover state communicates when a user has placed a cursor above an interactive element. [More on hover state](https://m3.material.io/m3/pages/interaction-states/applying-states#71c347c2-dd75-485b-892e-04d2900bd844) state provides a visual cue that a list item is interactive.

![Image 2: A list with the second item visually altered while hovered over, with a cursor and darker fill.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmif1lpwx-03.png?alt=media&token=fde07ebe-f294-4921-b6b3-fcbe40f28691)

Cursor: Hover

![Image 3: Selected list item with cursor, colored fill, and checked box.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmif1n85t-04.png?alt=media&token=2e422eae-b219-462c-91d2-76f6af7da235)

Cursor: Selected

link

Copy link Link copied

### Keyboard & switch

When a person tabs to a single-action list, a focus indicator appears, providing a visual cue that the first list item is now focused A focused state communicates when a user has highlighted an element, using an input method such as a keyboard or voice. [More on focused state](https://m3.material.io/m3/pages/interaction-states/applying-states#bc6d6853-48ef-490e-8076-448e89e69f0f) and action can be taken.

When a person interacts with the focused list item via **Space** or **Enter**, the action is performed.

**Tab** key navigates to the list. **Space** or **Enter** keys activate items.

link

Copy link Link copied

Focus
-----

link

Copy link Link copied

### Single-action lists

The first element in a list should always receive focus, unless the list has a selected element. In that case, focus should go to the selected list item instead.

After an element is focused A focused state communicates when a user has highlighted an element, using an input method such as a keyboard or voice. [More on focused state](https://m3.material.io/m3/pages/interaction-states/applying-states#bc6d6853-48ef-490e-8076-448e89e69f0f), a person should be able to navigate within the list using arrow keys.

![Image 4: The first list item is automatically focused.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmif1yik5-08.png?alt=media&token=e925d117-187b-4db5-a5fe-e21b9cab01ff)

**Tab**key focuses on the first item or the selected item

![Image 5: A second list item focused using an arrow key.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmif1z0du-09.png?alt=media&token=11096c65-8976-4b29-83d6-d0e6649c71f5)

**Arrow**keys navigate up and down through list items

link

Copy link Link copied

![Image 6: List item with focus indicator and filled checkbox, selected using the Space or Enter key.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmif21ldt-10.png?alt=media&token=36809b25-a375-4a87-9942-b8f1dda63fa4)

**Space** or **Enter** keys activate an element in a list

link

Copy link Link copied

### Multi-action lists

Multi-action list items contain a primary action and at least one supplementary action.

The list item as a whole isn't selectable; only the individual actions are.

A person should be able to use a keyboard to:

*   **Tab** to the list item, which focuses the first element

*   Move between between all focusable elements in the list using the **Up**, **Down**, **Left**, and **Right** arrow keys

*   Activate a focused element using **Space** or **Enter**

[More on multi-action lists](https://m3.material.io/m3/pages/lists/guidelines#db85439b-0e67-43b0-a2dc-61395738af64)

![Image 7: The first element in a multi-action list is focused automatically.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmi8um9bl-11-VQA.png?alt=media&token=6a474f8b-d3ef-4f9f-b356-3c5f87f3662f)

**Tab** brings the focus to the first action

![Image 8: The list action, a bookmark, is focused using the Down or Right arrow.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmi8uomf0-12-VQA.png?alt=media&token=c7508f6b-dd4b-4972-af0d-34a6010d313a)

**Down** and **Right** arrow keys move focus to the next action of the list item, or to the first action in the next item

link

Copy link Link copied

![Image 9: A trailing bookmark icon is focused in the second list item.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmi8uwmgu-13-VQA.png?alt=media&token=28964eee-ac95-4e56-947c-73a2864ec3cf)

**Up** and **Left** arrow keys move focus to the previous action of the list item

![Image 10: Label text and supporting text of the second list item is in focus using the Up or Left arrow.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmi8v0dqs-14-VQA.png?alt=media&token=dba9d2e6-ae72-4a63-ae46-a5f5df07c3b6)

If the focus is on a list item’s first action, the **Up** and **Left** arrows move focus back to the last action of the previous item

![Image 11: The Space or Enter key activates an overflow menu on a list item.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmi8v14y1-15-VQA.png?alt=media&token=288e0e31-8107-42b1-917f-061f6ef3e824)

The **Space** or **Enter** key activates a selected action in a list

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| **Keys** | **Actions** |
| --- | --- |
| **Tab** | To move focus to the first list item, last list item, or outside of the list component |
| Down and right arrow keys | Moves to the next element in the list; if the focused element is the last in the list, it wraps back to the top of the list |
| Up and left arrow keys | Moves to the previous element in the list; if the focused element is the first in the list, it wraps back to the bottom of the list |
| **Space** or **Enter** | To select a list item not yet selected |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

Accessibility Accessible design makes products usable for people with all kinds of abilities. [More on accessibility](https://m3.material.io/m3/pages/overview/principles)labels are used with assistive devices like screen readers.

The accessibility label for a list item is typically the same as the **label text** and **supporting text**.

Some labels, roles, and states are [dependent on platform](https://m3.material.io/m3/pages/lists/accessibility#09e32b7d-78a1-45c1-be12-4c6646cfe1d1).

![Image 12: List item selected to show label of “Bread, sourdough or wheat”.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmif3ecf9-16.png?alt=media&token=f3d78d78-8ba2-402e-a069-ca0552ca6868)

A list item’s **label text** and **supporting text** is used for its accessibility label

link

Copy link Link copied

### Platform-specific labels

link

Copy link Link copied

#### Single-select lists

| **Trait** | **Web** | **MDC-Android** | **Jetpack Compose** |
| --- | --- | --- | --- |
| Aria label | Container label: Should describe selection type List item: Should match the visible label text | List item: Should match the visible label text | List item: Should match the visible label text |
| Role | Container: List box List item: Option | List item: Radio button | List item: Radio button |
| State | Selected or Not-selected | Checked or Not-checked | Checked or Not-checked |

link

Copy link Link copied

#### Multi-select lists

| **Trait** | **Web** | **MDC-Android** | **Jetpack Compose** |
| --- | --- | --- | --- |
| Aria label | Container label: Should describe selection type List item: Should match the visible label text | List item: Should match the visible label text | List item: Should match the visible label text |
| Role | Container: List box List item: Option | List item: Checkbox | List item: Checkbox |
| State | Selected or Not-selected | Checked or Not-checked | Checked or Not-checked |

link

Copy link Link copied

On web, a list container’s accessibility label describes the type of selection that can be made, and the role is **List box**.

![Image 13: A list container is selected, showing a label of “Select either bread, pita, or rice” and role of “List box.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmi8wfvkj-17.png?alt=media&token=6abe0d86-e89d-46bf-b644-9c29820e651f)

On web, a list container’s role is **List box**

link

Copy link Link copied

On Jetpack Compose, the role applies to the list item as a whole.

If a list isn't selectable, the label text is read out without a role.

![Image 14: A selected list item shows a label of “Bread, sourdough, or wheat” and role of “Checkbox.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmi8wgxsf-18.png?alt=media&token=f2da7dd9-7edb-4a4e-ba75-861c0b9191bb)

When selectable, the role **Checkbox**applies to the entire list item on Jetpack Compose

link

Copy link Link copied

On MDC-Android, components contained within the list should be labeled according to that component’s specific guidelines:

*   [Checkbox](https://m3.material.io/m3/pages/checkbox/accessibility)

*   [Radio button](https://m3.material.io/m3/pages/radio-button/accessibility)

![Image 15: Checkbox of a selected list item shows label of “Bread, sourdough or wheat” and role of “Checkbox.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmif3mprn-19.png?alt=media&token=eb532a0d-fff0-43bc-a056-3452ef435faf)

On MDC-Android, the accessibility label and role are applied to the interactive component by default
