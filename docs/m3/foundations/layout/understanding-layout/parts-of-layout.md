Title: Layout – Material Design 3

URL Source: http://m3.material.io/foundations/layout/understanding-layout/parts-of-layout

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Layout – Material Design 3
===============

[Skip to main content](https://m3.material.io/foundations/layout/understanding-layout/parts-of-layout#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

 play_arrow 

 pause 

 dark_mode 

 light_mode 

[](https://m3.material.io/foundations)

[](https://m3.material.io/foundations/overview)[](https://m3.material.io/foundations/designing)[](https://m3.material.io/foundations/writing)

[](https://m3.material.io/foundations/adaptive-design)[](https://m3.material.io/foundations/building-for-all)

[](https://m3.material.io/foundations/content-design/overview)[](https://m3.material.io/foundations/content-design/alt-text)[](https://m3.material.io/foundations/content-design/global-writing)[](https://m3.material.io/foundations/content-design/notifications)[](https://m3.material.io/foundations/content-design/style-guide)

[](https://m3.material.io/foundations/customization)[](https://m3.material.io/foundations/design-tokens)

[](https://m3.material.io/foundations/interaction/gestures)[](https://m3.material.io/foundations/interaction/inputs)[](https://m3.material.io/foundations/interaction/selection)[](https://m3.material.io/foundations/interaction/states)

[](https://m3.material.io/foundations/layout/understanding-layout)[](https://m3.material.io/foundations/layout/applying-layout)[](https://m3.material.io/foundations/layout/canonical-layouts)

[](https://m3.material.io/foundations/usability)[](https://m3.material.io/foundations/glossary)

Layout basics
=============

Layout is the visual arrangement of elements on the screen

pause

[Overview](https://m3.material.io/foundations/layout/understanding-layout/overview)[Spacing](https://m3.material.io/foundations/layout/understanding-layout/spacing)[Parts of layout](https://m3.material.io/foundations/layout/understanding-layout/parts-of-layout)[Density](https://m3.material.io/foundations/layout/understanding-layout/density)[Hardware considerations](https://m3.material.io/foundations/layout/understanding-layout/hardware-considerations)[Bidirectionality & RTL](https://m3.material.io/foundations/layout/understanding-layout/bidirectionality-rtl)

On this page

*   [Navigation region](https://m3.material.io/)
*   [Body region](https://m3.material.io/)
*   [Panes](https://m3.material.io/)
*   [How panes adapt](https://m3.material.io/)
*   [App bars](https://m3.material.io/)
*   [Columns](https://m3.material.io/)
*   [Drag handle](https://m3.material.io/)

link

Copy link Link copied

![Image 1: Navigation and body regions shown on 3 different screen types.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxhwoc-1.png?alt=media&token=8476ab2c-fd9d-4cd6-9235-2c62a8488e01)

Most layouts have two regions:

1.   Navigation
2.   Body

link

Copy link Link copied

### Windows

A window frames and contains the product. The window is divided into two primary regions: the navigation region and body region.

Multi-window views are a system UI feature used to display more than one app simultaneously.

[Multi-window support guide for Android](https://developer.android.com/develop/ui/compose/layouts/adaptive/support-multi-window-mode)

![Image 2: Side-by-side windows with single taskbar below.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxrdhk-10.png?alt=media&token=c4401716-3caf-42e5-bd9f-d931e9036051)

Two windows shown next to one another with a taskbar underneath

link

Copy link Link copied

Navigation region
-----------------

link

Copy link Link copied

The navigation region holds primary navigation components and elements such as:

*   Navigation drawer

*   Navigation rail

*   Navigation bar

Elements in this section help people navigate between destinations in an app or to access important actions.

Place navigation components close to edges of the window where they’re easier to reach; on the left side for left-to-right (LTR) languages, and on the right side for right-to-left (RTL) languages.

![Image 3: Navigation drawer, navigation rail, and navigation bar each shown on a separate screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxim8l-2.png?alt=media&token=5cc1d506-1c9d-46b0-9a29-72a897030457)

Three different navigation components suit a variety of device sizes and environments

link

Copy link Link copied

Body region
-----------

link

Copy link Link copied

The body region contains most of the content in an app, including:

*   Images
*   Text
*   Lists
*   Cards
*   Buttons
*   App bar
*   Search bar

Content in the body region is grouped into one or more panes.

![Image 4: Body region highlighted on a mobile screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxjjfr-3.png?alt=media&token=a1574fa9-6c4b-4d5a-bd0a-a240e9e1eb24)

1.   The body region is the area outside of the navigation region

link

Copy link Link copied

Panes
-----

link

Copy link Link copied

Just like panes of glass that make up a window in the real world, panes in Material Design make up the body region of the layout in a device window.

All content must be in a pane. A layout can contain 1–3 panes of various widths, which adapt dynamically to the window size class Window size classes are opinionated breakpoints where layouts need to change to optimize for available space, device conventions, and ergonomics. [More on window size classes](https://m3.material.io/m3/pages/applying-layout/window-size-classes) and the user’s language setting. For right-to-left (RTL) languages, navigation components will be on the right.

Users can navigate to or between panes. Presenting multiple panes at once can make the app more efficient and easier to use.

![Image 5: Two paned screen layout.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxkflt-4.png?alt=media&token=da6e7766-e738-470f-96ad-4ed0e6431276)

1.   First pane
2.   Second pane

link

Copy link Link copied

There are two pane types:

*   Fixed: Fixed width

*   Flexible: Responsive to available space, can grow and shrink

All layouts need at least one flexible pane to be responsive to any window size.

![Image 6: Fixed and flexible panes of a screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxloju-5.png?alt=media&token=19e4ab46-ab5e-4fe9-bc9d-3a5fd8393feb)

1.   Fixed pane
2.   Flexible pane

link

Copy link Link copied

How panes adapt
---------------

In addition to flexible resizing, pane layouts can adapt using three strategies: show and hide, levitate, and reflow. When horizontal space allows, panes are presented next to each other in a row. When the window is resized or changes orientation, panes use these strategies to reorganize themselves, preserving context and meaning.

link

Copy link Link copied

pause

Show and hide: Supporting panes enter and exit the screen based on available space

pause

Levitate: One pane is placed on top of another

pause

Reflow: Panes change position or orientation

link

Copy link Link copied

### Containment

On most devices, panes can blend in with the background while others can use a different color for emphasis. This is called implicit grouping, and helps show relationships between panes.

![Image 7: Two-pane layout on a tablet](https://lh3.googleusercontent.com/OeM74nDivtew7dBZEbqn9yVqxwNYLrZUUWpr6OiKMGn9A_IjSHcT2q9VVgZLhXysXuXmrbH1w4uf4mGvgznMgXS8QC3r2uy_423TsjsJ4edw2g=w40)

Implicit grouping can be used to create hierarchy among 2D panes

link

Copy link Link copied

In spatial environments, panes use a container color to separate panes from the passthrough or virtual environment.

![Image 8: Two-pane layout in a spatialized environment, with no background.](https://lh3.googleusercontent.com/a7t4QUE9U0F3PL5ozn8LBpe8MfCOSz0No25g58LTIZfLJgXROpqqXniCtP2X-9oXmLUqE7ogrEYXYTL4hC2o82LMOtjvUR94I3wP_mwQivc=w40)

Explicit containment is recommended in XR

link

Copy link Link copied

App bars
--------

link

Copy link Link copied

Panes can include a top app bar and bottom app bar.

![Image 9: Screen layout with app bar inside left pane.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxse9i-22.png?alt=media&token=a21a0d4f-96ae-44de-a6d2-79daf8f90f69)

App bars are placed inside panes

link

Copy link Link copied

Any nesting actions within the app bar should be hidden or revealed based on available width.

![Image 10: Top app bar of a compact window on a mobile device shows 2 items.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxuvra-23.png?alt=media&token=af07a67d-2a35-4536-9854-826cb8e3736f)

A compact window with two actions revealed

![Image 11: Top app bar of  expanded window  shows 5 items.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxvw9e-24.png?alt=media&token=1888fb07-bab7-41e2-b0eb-db7ad5744cd2)

An expanded window class with five items revealed

link

Copy link Link copied

When layouts transition from one to two panes, avoid shifting elements between panes.

![Image 12: Email preview erroneously shifted to left-hand pane.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxxac3-25.png?alt=media&token=7cc4ccf8-f719-45e8-806d-1e2846c7a33f)

close Don’t 
Don’t move elements to different UI objects when switching between window classes

link

Copy link Link copied

Columns
-------

link

Copy link Link copied

Content in a pane can be displayed in multiple columns to segment and align content.

Columns are exclusive to a pane and are not used at the window level.

![Image 13: A single pane containing 3 columns.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwxz8gj-26.png?alt=media&token=07d0f806-0957-4fd1-a6dc-f18b9fd5d7f8)

Using one pane, an app like News uses multiple columns of content to create its layout

link

Copy link Link copied

Drag handle
-----------

link

Copy link Link copied

Drag handles can be used to instantly resize panes in a layout. They adjust the width of flexible panes, and can fully collapse and expand fixed panes to quickly switch between a single-pane and two-pane layout.

pause

Drag handles can adjust pane size in a list-detail layout

link

Copy link Link copied

Drag handles can be used horizontally or vertically.

![Image 14: Mobile phone with two panes stacked vertically and a drag handle in between.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmfo2x7z3-drag-handle.png?alt=media&token=e4237702-53ec-484a-aa4e-b9ae3862a4e5)

Drag handles can be used vertically

link

Copy link Link copied

### Drag handle tokens

link

Copy link Link copied

 Drag handle arrow_drop_down

search

visibility grid_view expand_all

Token

Description info 

 Default, Light arrow_drop_down

folder Enabled

keyboard_arrow_down

folder Hovered

keyboard_arrow_down

folder Focused

keyboard_arrow_down

folder Pressed

keyboard_arrow_down

Close

link

Copy link Link copied

### Usage

link

Copy link Link copied

In expanded, large, and extra-large window sizes, two-pane layouts can be customized to snap to set widths when resized. The recommended custom widths are:

*   360dp

*   412dp

*   Split-pane with spacer centered visually

pause

Panes can snap to custom widths when a user releases the drag handle

link

Copy link Link copied

In a two-pane layout, the drag handle is placed in the spacer between the panes.

![Image 15: Drag handle centered in the spacer between panes.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxx1pvsg-13.png?alt=media&token=d806967b-4a5f-4f02-81d7-b49769e27d12)

1.   Pane drag handle between two panes

link

Copy link Link copied

When a single pane is fully expanded, the handle is placed inside the right or left pane edge.

![Image 16: Drag handle on the inside of a collapsed pane.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxx1rk6i-14.png?alt=media&token=be6b371b-2cee-4963-9cf3-cccb66ab2f6b)

1.   Pane drag handle on the left edge of a pane

link

Copy link Link copied

A touch region (A) around the drag handle takes priority over the back gesture, allowing people to perform a pane drag action instead of a system back gesture (B).

![Image 17: The drag handle touch target area covers part of the back gesture touch target area.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm2khd7s2-15.png?alt=media&token=d1e9278f-29ab-463e-af94-9af98160768f)

The pane drag handle UI overrides the back gesture

link

Copy link Link copied

In a two-pane[list-detail](https://m3.material.io/m3/pages/canonical-layouts/list-detail) layout, the pane drag handle doesn't appear until an item is selected.

![Image 18: A list-detail layout with no items selected, and no drag handle visible.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxx1u0o3-16.png?alt=media&token=b7b5c4f9-aba1-4fb5-978c-f40612fc4b9b)

A list-detail layout doesn’t need a drag handle when no list item selected

link

Copy link Link copied

Avoid customizing the drag handle.

For products that can't use a drag handle, consider these other options for changing layouts:

*   A toggle button to swap layouts
*   In-app layout settings

![Image 19: A list-detail layout for a chat app with a button for expanding the chat pane to a single-pane layout.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxx1v4ra-17.png?alt=media&token=8eda0901-41ac-4b27-9456-968afd1d9524)

A layout toggle button could be used if drag handles are not possible

link

Copy link Link copied

### Drag handle accessibility

link

Copy link Link copied

Avoid customizing the visual design of the drag handle.

The drag handle should have a hover state, like changing size, to indicate that the handle can be moved. A cursor should change to a hand when hovering.

By default, drag handles can only be dragged, not selected. Consider adding the ability to change layouts when tapped, double tapped, clicked, or activated using a keyboard. When using a keyboard, people should:

*   Use **Tab** to navigate to the drag handle.
*   Use **Space** or **Enter** to activate the drag handle. This can automatically resize the panes to a recommended size, or it can select the handle so **Arrows** can move the handle to predefined sizes.

For screen readers, describe the function of the drag handle in the accessibility label (like “Resize layout”). 

Use roles like **button** to explain that it’s interactive, and states like **left pane expanded**, **right pane expanded**, or **panes equally sized** to explain its current position.

![Image 20: Drag handle annotated with "Role = button."](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxx29wzb-22.png?alt=media&token=300e5767-6583-4f48-8248-9e43c6be68c9)

The drag handle should behave like a button for keyboard users

[arrow_left_alt Previous Layout basics: Spacing](https://m3.material.io/foundations/layout/understanding-layout/spacing)[Up next arrow_right_alt Layout basics: Density](https://m3.material.io/foundations/layout/understanding-layout/density)

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

Press space for more information.

Hide previews

Switch to grid view

Default, Light

Drag handle

Expand all
