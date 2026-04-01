Title: Buttons – Material Design 3

URL Source: http://m3.material.io/components/buttons/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Buttons prompt most actions in a UI

Resources

flutter

android

+4

Close

On this page

*   [Use cases](https://m3.material.io/)
*   [Interaction & style](https://m3.material.io/)
*   [Keyboard navigation](https://m3.material.io/)
*   [Labeling elements](https://m3.material.io/)

link

Copy link Link copied

Use cases
---------

People should be able to do the following using assistive technology:

*   Use a button to perform an action
*   Navigate to and activate a button

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

### Color contrast

Enabled buttons need a 3:1 contrast ratio with the background to meet accessibility best practices.

This is measured from the container for elevated, filled, and tonal button styles, and the label text for outlined and text button styles.

![Image 1: Diagram of color contrast ratios for buttons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmah4xmp9-1.png?alt=media&token=5db71bb4-7aa7-44a0-80e5-3500cbf19527)

Higher contrast helps differentiate elements

link

Copy link Link copied

### 200% text size

Avoid excessive text wrapping or truncation by choosing concise strings.

On Android, button labels should be kept concise enough to fit within two lines after the text size is increased to 200%. If a button label exceeds this limit and gets truncated, provide an alternative way to access the full content in a single tap.

![Image 2: 200% text size on a mobile screen. The overly long button text wraps to a second line: “Download playlist for offline access”.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8x27kbt-2.png?alt=media&token=4cf85c66-b195-41c0-85cd-f516c70f50b4)

exclamation Caution 
Avoid excessive text wrapping or truncation by choosing concise strings

link

Copy link Link copied

### Rapid clicks

On the web, you can use a modified motion curve to avoid resonant effects from overlapping animations. This provides a smoother experience for interactions where you anticipate multiple clicks or taps in succession.

Use the modified motion curve if rapid click or pointer interactions are expected

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| Keys | Actions |
| --- | --- |
| Tab | Navigate to a button |
| Space or Enter | Activate a button |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

The accessibility Accessible design makes products usable for people with all kinds of abilities. [More on accessibility](https://m3.material.io/m3/pages/overview/principles) label for a button should match the visible label text on the button such as **Done**, **Send**, or**Reply**.

It can contain extra contextual information if necessary.

![Image 3: Accessibility tags for a text-only button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0ghhzjt-4.png?alt=media&token=e25d75b4-2d6d-4532-b5e9-fdc04c79ed46)
