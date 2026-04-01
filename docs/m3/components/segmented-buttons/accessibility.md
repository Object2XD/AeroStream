Title: Segmented button – Material Design 3

URL Source: http://m3.material.io/components/segmented-buttons/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Segmented buttons
-----------------

Segmented buttons help people select options, switch views, or sort elements

Resources

flutter

android

android

Close

On this page

*   [Use cases](https://m3.material.io/)

link

Copy link Link copied

link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

Users should be able to:

*   Navigate to and activate segmented buttons with assistive tech
*   Understand what each segment selection will do

link

Copy link Link copied

### Interaction & style

For keyboard navigation, **Tab** focuses on an individual segment.

For single-select segments, **Space** or **Enter** will select or unselect the focused A focused state communicates when a user has highlighted an element, using an input method such as a keyboard or voice. [More on focused states](https://m3.material.io/m3/pages/interaction-states/applying-states#bc6d6853-48ef-490e-8076-448e89e69f0f) segment.

For multi-select segments, **Space** or **Enter** will:

*   select an un-selected segment
*   select all of the segments
*   un-select a selected segment

![Image 1: Tab moves the focus through segments of a segmented button.  Space or enter selects and unselects segments.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flw7q4935-1.png?alt=media&token=99802213-76ba-4f6a-8e7b-ea8daf0b2bc3)

Use Tab to navigate through segments and Space/Enter to select/unselect.

link

Copy link Link copied

### Color contrast

Segmented buttons are clusters of similar components, so the outline should have at least a 3:1 contrast ratio with the background or surface. This helps distinguish each button.

Both a checkmark icon and a color change are used to distinguish selection. Make sure color isn’t the only way to show selection.

![Image 2: The outline of segmented buttons on the surface passes the minimum contrast of 3:1.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flw7q6k39-2_do.png?alt=media&token=15790494-3f50-40ef-990b-7dde7e714d61)

check Do 
Use an outline with a surface contrast of at least 3:1

![Image 3: The outline of segmented buttons on the surface fails the minimum contrast of 3:1.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flw7q87p2-3_dont.png?alt=media&token=f935fbc2-5a75-4d24-91a3-ed026030dd63)

close Don’t 
The segmented button shouldn't have a contrast outline less than 3:1

link

Copy link Link copied

### Initial focus

Focus will start in the first segment. Depending on the direction of the language, it is either the most left or the most right segment.

For single select and multi-select, the first segment will be focused regardless of selection state.

![Image 4: Segmented button focus starts on the left for left-to-right languages and on the right for right-to-left languages.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flw7q9t4x-4.png?alt=media&token=df0560b5-2880-402a-a0ad-ae84c4e2e2c1)

Focus begins on the left for left-to-right languages and on the right for right-to-left languages

link

Copy link Link copied

### Keyboard navigation

| Keys | Actions (single select) | Actions (multi select) |
| --- | --- | --- |
| **Tab** | Focus lands on next enabled An enabled state communicates an interactive component or element. [More on enabled state](https://m3.material.io/m3/pages/interaction-states/applying-states#39b2fc90-01db-41b5-b6f8-47be61ed1479) segment | Focus lands on next enabled segment |
| **Space** or **Enter** | Select focused A focused state communicates when a user has highlighted an element, using an input method such as a keyboard or voice. [More on focused state](https://m3.material.io/m3/pages/interaction-states/applying-states#bc6d6853-48ef-490e-8076-448e89e69f0f) segment | Select and unselect focused segment |

link

Copy link Link copied

### Labeling elements

The accessibility Accessible design makes products usable for people with all kinds of abilities. [More on accessibility](https://m3.material.io/m3/pages/overview/principles) label for a segmented button comes from the visible label text on such as **Relevance** and **Distance**.
If the segmented button displays icons without label text, the accessibility label describes the action that the button is expressing, such as **Inexpensive** for one currency symbol.

![Image 5: The the text and accessibility role for the left-most section of a segmented button following “sort by” is  is “relevance.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flw7qcq3h-5.png?alt=media&token=24534d45-c04c-46d9-a747-04aeeefd11ff)

The label for segmented button matches the text label

link

Copy link Link copied

Single-select segmented buttons behave like radio buttons Radio buttons let people select one option from a set of options. [More on radio buttons](https://m3.material.io/m3/pages/radio-button/overview): only one option can be selected at a time. The label is **Radiogroup**.

Multi-select buttons behave like checkboxes Checkboxes let users select one or more items from a list, or turn an item on or off. [More on checkboxes](https://m3.material.io/m3/pages/checkbox/overview): more than one option can be selected. The label is **Checkbox**.

![Image 6: Selected price range segmented buttons range from $ to $$$$. The accessibility label of the $ button is “inexpensive.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flw7qpwe0-6.png?alt=media&token=a73ad3f4-0a14-4075-b015-dbe86ef3ec0f)

The role for the multi-select segmented button is **Checkbox**
