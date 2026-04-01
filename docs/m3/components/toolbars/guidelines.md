Title: Toolbar

URL Source: http://m3.material.io/components/toolbars/guidelines

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Toolbars
--------

Toolbars display frequently used actions relevant to the current page

Resources

flutter

android

+3

Close

On this page

*   [Usage](https://m3.material.io/)
*   [Anatomy](https://m3.material.io/)
*   [Position & orientation](https://m3.material.io/)
*   [Adaptive design](https://m3.material.io/)
*   [Behavior](https://m3.material.io/)

link

Copy link Link copied

![Image 1: 5 toolbars of various colors, elements, and actions.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm7xi1w6d-01.png?alt=media&token=c58c89f5-5f11-410e-83e9-527495d6a51c)

Toolbars can be used for a wide variety of use cases

link

Copy link Link copied

Usage
-----

link

Copy link Link copied

Use a toolbar to provide actions related to the current page.

Toolbars can contain many actions and can scale to show more actions in larger windows.

![Image 2: Vibrant toolbar at bottom of mobile screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0akotbi-02.png?alt=media&token=7c57efcb-0ced-4383-923c-2bb9b0d8bb25)

A toolbar provides actions related to the current page

link

Copy link Link copied

There are two variants of toolbars:

*   **Docked toolbar**

Spans the full width of the window. It’s best used for global actions that remain the same across multiple pages.

*   **Floating toolbar**

Floats above the body content. It’s best used for contextual actions relevant to the body content or the specific page.

The baseline**bottom app bar**is no longer recommended, but is still supported.

link

Copy link Link copied

![Image 3: Docked toolbar example.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0akx0bq-03.png?alt=media&token=2ddeb9e7-904c-48c4-82d2-8eb2df8b511f)

Docked toolbar shows global controls

![Image 4: Floating toolbar example.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0akxxgm-04.png?alt=media&token=d1f96ec5-e3c6-4936-a0ff-9456fabe38b1)

Floating toolbar show controls relevant to the current page

link

Copy link Link copied

When actions don’t fit in a toolbar, add a menu Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview).

![Image 5: Toolbar showing local navigation.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm2ytl4us-05.png?alt=media&token=3beb745d-8031-460f-b3b5-400d481b0f7d)

Toolbar actions can open a menu

link

Copy link Link copied

There are two color configurations:

*   **Standard**

A low-emphasis color scheme best used for focusing attention on the body content.

*   **Vibrant**

A high-emphasis color scheme that draws attention to the controls. It can also indicate a temporary change in the page behavior, such as entering edit mode.

Consider using alternative color roles to create greater or lesser emphasis depending on the needs of the app. Experiment with different color roles to achieve different effects.

link

Copy link Link copied

![Image 6: Toolbar with low-emphasis controls.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0al28lo-06.png?alt=media&token=1f6d5d66-1407-4636-9e31-635eec6aac7b)

Use the standard color scheme to draw focus to content outside the toolbar

![Image 7: Toolbar with high-emphasis controls.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0al3avf-07.png?alt=media&token=c786ee9c-8199-4d30-99d7-ed8b8d659cb2)

Use the vibrant color scheme to emphasize controls or actions

link

Copy link Link copied

### Toolbars & navigation bars

link

Copy link Link copied

The toolbar and navigation bar Navigation bars let people switch between UI views on smaller devices. [More on navigation bars](https://m3.material.io/m3/pages/navigation-bar/overview) are both placed at the bottom of the window, so should **not** be shown at the same time. Show the navigation bar on primary pages, and toolbars on subsequent pages with actions.

link

Copy link Link copied

![Image 8: A navigation bar shown on the main email Inbox page, and a toolbar shown when reading the email.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0al4vpg-08.png?alt=media&token=006079a0-0c27-40f7-a3c6-72c86706ebe5)

1.   Navigation bar on a primary page

2.   Toolbar on a secondary page with contextual actions

link

Copy link Link copied

Floating toolbars can be used as tabs between related subsequent pages in the product hierarchy.

This helps group similar pages together, and shows that the selection affects the body content underneath.

![Image 9: Floating toolbar with secondary navigation labels.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0alklw0-09.png?alt=media&token=864f5358-84b4-4b4e-b438-9a58fae853f0)

check Do 
Keep navigation distinct, and use a toolbar to display local navigation on a specific page

link

Copy link Link copied

Consider the existing app hierarchy when using a toolbar for local navigation.

Avoid redundant or confusing navigation combinations in the same view.

![Image 10: Floating toolbar with secondary navigation labels displaying above a bottom navigation bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0aln2r9-10.png?alt=media&token=f547cd2c-f7aa-4780-a701-89480ad92506)

close Don’t 
Don’t show a navigation bar and a toolbar with navigation controls at the same time

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

![Image 11: Diagram of toolbar layouts.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm7xiiwbe-11.png?alt=media&token=df3567cb-3de9-4130-87b2-d6496e2b50d6)

1.   Container

2.   Elements

link

Copy link Link copied

### Container

The docked toolbar’s container spans the full width of the window.
Avoid applying rounded corners to the container. This can imply the container expands or changes upon interaction.

![Image 12: Docked toolbar with square corners.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0als248-12.png?alt=media&token=5de2e6dd-e260-460d-8b24-ec4616d068f3)

check Do 
Use straight corners for docked toolbars

![Image 13: Docked toolbar with rounded corners.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0alr7n0-13.png?alt=media&token=67d0f0c3-77bf-413d-b028-a3704d62ddde)

close Don’t 
Avoid modifying the container shape

link

Copy link Link copied

As long as there's a minimum of 16dp padding on the leading and trailing edge, arrange controls inside however you see fit. The 32dp padding between items is just the default.

All elements need a minimum 48x48dp target area to be accessible.
Be cautious of including too many controls as it can be overwhelming.

![Image 14: Docked toolbar with too many controls.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0altzpa-22.png?alt=media&token=982f6de8-05e5-4918-8395-3172ba98a767)

close Don’t 
Don’t overwhelm people with too many controls

link

Copy link Link copied

The floating toolbar’s container should be fully visible on screen. If more actions are needed, use an overflow menu.

link

Copy link Link copied

![Image 15: Floating toolbar with overflow menu icon.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0alvr9d-14.png?alt=media&token=43b6b0e0-3785-4b32-b814-9334d1df3604)

check Do 
Choose the most essential actions to show on screen by default

![Image 16: Floating toolbar that expands off edge of screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0alwqwe-15.png?alt=media&token=34941365-0b02-426e-98aa-5a7182146ef3)

close Don’t 
Floating toolbars shouldn’t exceed the edge of the window or pane

link

Copy link Link copied

#### Elevation

Floating toolbars have elevation by default.

If the content beneath the toolbar is visually distinct, elevation can be removed.

![Image 17: Vibrant floating toolbar that's easy to see in front of a neutral text background.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm7xiazxd-17.png?alt=media&token=1fb4d961-4c77-46d8-8e1a-bacee6d1344e)

The elevation on floating toolbars can be removed if on a visually distinct background

link

Copy link Link copied

### Flexibility & slots

When configuring a toolbar, think of it as a container with several slots.

These slots can be populated by buttons Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/overview), icon buttons Icon buttons help people take minor actions with one tap. [More on icon buttons](https://m3.material.io/m3/pages/icon-buttons/overview), images, text fields Text fields let users enter text into a UI. [More on text fields](https://m3.material.io/m3/pages/text-fields/overview), or any kind of custom component.

Icon buttons provide an even hierarchy of controls. Mixing in a filled icon button can help add emphasis to a single action.

![Image 18: 5 toolbars with slots, and various combinations of buttons, icon buttons, filled icon buttons, and text fields.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0aly7tp-16.png?alt=media&token=eef76f70-653b-4316-a4e5-b4c3efe04ec9)

Toolbars are made of slots that can contain many kinds of actions

link

Copy link Link copied

Visually emphasizing a single action more than others is an effective way to create hierarchy and guide people to controls they use most often. Avoid emphasizing more than one action at a time.
Some common ways to add emphasis to toolbar actions include:

*   Use different icon button Icon buttons help people take minor actions with one tap. [More on icon buttons](https://m3.material.io/m3/pages/icon-buttons/overview) color styles, such as filled, tonal, and standard
*   Customize the color roles Color roles are assigned to UI elements based on emphasis, container type, and relationship with other elements. This ensures proper contrast and usage in any color scheme. [More on color roles](https://m3.material.io/m3/pages/color-roles/) of a single action, such as a primary or secondary palette
*   Use wide and narrow icon buttons

*   Pair the toolbar with a FAB Floating action buttons (FABs) help people take primary actions. [More on FABs](https://m3.material.io/m3/pages/fab/overview)

![Image 19: 2 floating toolbars, 1 with a filled action button and 1 paired with a FAB.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0am06ae-18.png?alt=media&token=b78bd5dd-7b9b-4026-8782-bd7299a30180)

Two different ways to create a high emphasis action in toolbars

link

Copy link Link copied

![Image 20: Floating toolbar with primary action and FAB.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0am2tq8-19.png?alt=media&token=ade3aae3-04a8-48c5-ad34-a44e19f82385)

close Don’t 
Don’t emphasize multiple buttons with bold, primary colors, such as a button and FAB together. Emphasize one action at a time.

![Image 21: Floating toolbar with different control designs.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0am3wil-20.png?alt=media&token=fa9517c1-99a1-41ec-bb2a-3add03657f0a)

close Don’t 
Avoid mixing too many different controls in the same toolbar. A consistent control design keeps things clear.

link

Copy link Link copied

Avoid using square icon buttons in floating toolbars. Their square shape conflicts with the fully-rounded shape of the floating toolbar container.

Square buttons can be used in the docked toolbar.

![Image 22: A floating toolbar, which is rounded, with squared icon buttons inside.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm7xigk3q-22.png?alt=media&token=834f844e-bf4a-482b-a55c-58b8e2a5dc96)

close Don’t 
Don’t use square filled icon buttons in floating toolbars

link

Copy link Link copied

### Floating toolbar with FAB

A FAB Floating action buttons (FABs) help people take primary actions. [More on FABs](https://m3.material.io/m3/pages/fab/overview) can be placed next to a floating toolbar to present one high-priority action alongside a unified set of toolbar actions.

Use a FAB for the highest-priority action in the view, or to complement the controls.

![Image 23: 3 toolbars paired with FABs.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0am631l-21.png?alt=media&token=ea7acd11-1ec9-4fee-b237-adf2c9636730)

Floating toolbars can be paired with FABs

link

Copy link Link copied

Position & orientation
----------------------

link

Copy link Link copied

Only place docked toolbars at the bottom of the window.

If using other bottom-aligned elements, such as a navigation bar, don't use a docked toolbar.

![Image 24: Docked toolbar on mobile.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0ama5z3-22.png?alt=media&token=fcca3ccd-3347-4482-9732-ed9ce3b21b72)

Docked toolbars are always at the bottom of the window

link

Copy link Link copied

Floating toolbars can be horizontal or vertical.
Horizontal toolbars should have a minimum 16dp margin from the edge of the window.

![Image 25: Floating toolbar on mobile.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0amca2n-23.png?alt=media&token=f1c23645-3eec-4330-8159-b7add81a9481)

Horizontal floating toolbars should be at least 16dp from the edge of the window

link

Copy link Link copied

In larger window sizes, floating toolbars can be vertical and placed on either side of the screen.

Vertical toolbars should have a minimum 24dp margin.

![Image 26: Vertical floating toolbar with 24dp margin.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm7ximrxw-26.png?alt=media&token=e501bab9-334b-4454-ade0-c6f31b83ff75)

Maintain at least a 24dp margin for vertical toolbars

link

Copy link Link copied

To keep vertical toolbars compact, don’t use wide icon buttons.

Use narrow or default icon buttons instead.

![Image 27: Toolbar showing local navigation.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0amgeqc-24.png?alt=media&token=aad0bae2-9282-40cc-a472-3025c8addcdb)

close Don’t 
Using wide buttons with vertical toolbars can unnecessarily widen toolbar containers and hide other UI elements

link

Copy link Link copied

Vertical toolbars should be positioned opposite the navigation rail Navigation rails let people switch between UI views on mid-sized devices. [More on navigation rails](https://m3.material.io/m3/pages/navigation-rail/overview) to balance out the screen and keep actions easy to access.

When showing a navigation rail and vertical floating toolbar at once, use the centered configuration of the navigation rail.

![Image 28: Large screen UI showing both a navigation rail and vertical floating toolbar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0amkwhr-TBD.png?alt=media&token=596f104c-915a-47fb-a863-6bf778a8331a)

When a nav rail is visible, the floating toolbar should be vertical on the opposite edge of the window

link

Copy link Link copied

Adaptive design
---------------

link

Copy link Link copied

Adaptive design allows an interface to respond or change based on context, such as the user, device, and usage.[More on adaptive design](https://m3.material.io/m3/pages/adaptive-design)

link

Copy link Link copied

### Resizing

link

Copy link Link copied

#### Docked

The docked toolbar should always span 100% of the screen width.

In compact window sizes Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact), elements in the toolbar should be evenly spaced.

In medium window sizes Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium) and larger, adjust the padding between controls to create a comfortable layout. This can be achieved by:

*   Centering all elements

*   Customizing to center a key action, and aligning other elements to the edges

![Image 29: Docked toolbar with evenly spaced elements.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fma2vff01-29.png?alt=media&token=4ac502e5-7602-445e-834d-286226583b65)

Docked toolbar items should be evenly spaced in compact windows

link

Copy link Link copied

![Image 30: Docked toolbar with centered elements.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fma6y2uq6-30.png?alt=media&token=deab82d9-57fa-4c3f-a2da-b60dc77a01b4)

In medium window sizes and larger, create a spacious layout by centering all elements

link

Copy link Link copied

![Image 31: Docked toolbar with central action and some elements pushed to the edge.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fma6y2g0q-31.png?alt=media&token=06384f75-0a0a-43ce-9b0a-f8af3c53130e)

Align controls to the edge of the screen to make them easier to reach on tablets, and to better highlight a primary action in the middle

link

Copy link Link copied

On web and large screens, the docked toolbar can be rounded. Dividers can be used to organize large amounts of items. Only shrink the height and use extra small buttons if vertical space is limited.

link

Copy link Link copied

![Image 32: Docked toolbar with 15 actions for text editing on large screens, organized with dividers.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmbv5jv5l-33%20Old.png?alt=media&token=ac965689-4c43-4519-9ae8-bd2d100f65c4)

On web and other large screens, docked toolbars can be rounded and placed in different parts of the page

link

Copy link Link copied

#### Floating

The container should only be as big as needed to hold the items inside before reaching the 16dp margin.

If there’s not enough space for all items, put them in an overflow menu in the trailing slot. As the window size expands, more actions can be revealed.

The floating toolbar width can also be capped to keep it smaller and hide more elements.

![Image 33: Floating toolbar in compact window with excess padding.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fma1lkstz-32.png?alt=media&token=7c230191-dce6-498c-b7c6-e7a680fec810)

close Don’t 
Don’t add extra space to a toolbar beyond its necessary items

link

Copy link Link copied

![Image 34: Floating toolbar in expanded window class.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fma1lm7ro-33%20(1).png?alt=media&token=415f33b0-19f9-4b55-87e1-d94689e61122)

At larger screen sizes, the container can display more controls before hitting the 16dp margin

link

Copy link Link copied

Vertical toolbars aren’t recommended for compact windows.

They take up a significant area of the screen and may feel visually overwhelming, especially on screens with complex layouts.

Only use them when the screen is simple or when the toolbar has a few controls.

![Image 35: Vertical toolbar in a compact window.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm7xmqa2l-34.png?alt=media&token=b12e1381-1bc0-41e6-8898-1603c9aadc57)

exclamation Caution 
Vertical toolbars can cover important content in compact windows

link

Copy link Link copied

### Presentation

link

Copy link Link copied

In larger window sizes, floating toolbars can be aligned to opposite edges of the screen so they're easy to reach and group similar actions. For example, consider placing the undo and redo actions in one toolbar, and editing controls like highlight, erase, and select in another. Stylistic differences can help emphasize each toolbar’s purpose and clarify hierarchy.

link

Copy link Link copied

![Image 36: 2 toolbars, each with distinct stylistic treatment and actions.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0amsqw6-29.png?alt=media&token=a2c29c55-b09f-40a1-9a0d-48d3316f5811)

Multiple toolbars with different stylistic treatments can create hierarchy and distinguish different kinds of actions

link

Copy link Link copied

Don’t use multiple toolbars in compact windows. There typically isn’t enough room on screen.

Instead, use one toolbar for all actions.

![Image 37: Multiple toolbars in a compact window.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm7xmw01r-36.png?alt=media&token=488e8d77-d650-48d5-abed-a727d821d65c)

close Don’t 
Avoid using multiple toolbars in smaller windows

link

Copy link Link copied

Actions at the trailing edge of the toolbar can collapse into an overflow menu at smaller window sizes, and become visible again at larger sizes.

Actions at the trailing edge collapse into an overflow menu

link

Copy link Link copied

### Right-to-left languages

In right-to-left (RTL) languages, mirror individual items that need it, like icons and text direction. If the order of actions is important, flip the order of the actions as well.

link

Copy link Link copied

![Image 38: Next button is on trailing edge for a LTR language.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm7xmygdb-37.png?alt=media&token=9f00e9fc-1b60-4dac-8974-353a25084a2b)

In LTR languages, the **Next** button is intentionally placed on the trailing (right) edge

![Image 39: Next button is now on the trailing edge, at left, for RTL language.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm7xmz6n4-38.png?alt=media&token=0be61ff8-5427-4330-9ddf-e59303f1c9b5)

In RTL languages, reverse the order so **Next** remains on the trailing edge when flipped, now on the left. Text is not translated to illustrate mirroring.

link

Copy link Link copied

Behavior
--------

link

Copy link Link copied

### Scrolling

Docked toolbars can either remain on the screen during scroll, or animate offscreen.

Docked toolbars can animate offscreen

link

Copy link Link copied

Floating toolbars can remain on the screen, animate offscreen, or collapse into a single, high-emphasis action on scroll.

Floating toolbars can animate off screen

link

Copy link Link copied

On Jetpack Compose, the floating toolbar can collapse to a FAB or key action on scroll.

Floating toolbars can be customized to do other actions on scroll, like collapse into a single action

link

Copy link Link copied

Don't collapse actions and scroll at the same time.

close Don’t 
Toolbars shouldn't both collapse and transition off page
