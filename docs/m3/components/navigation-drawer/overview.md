Title: Navigation drawer – Material Design 3

URL Source: http://m3.material.io/components/navigation-drawer/overview

Markdown Content:
Navigation drawers let people switch between UI views on larger devices

Resources

Close

On this page

*   [Availability & resources](https://m3.material.io/)
*   [M3 Expressive update](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

link

Copy link Link copied

*   Use standard navigation drawers in expanded Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded), large Window widths 1200dp to 1599dp, such as desktop. [More on large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large), and extra-large window sizes Window widths 1600dp and larger, such as ultra-wide monitors. [More on extra-large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large)

*   Use modal navigation drawers in compact Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact) and medium Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium) window sizes

*   Can be open or closed by default

*   Two variants: standard and modal

*   Put the most frequent destinations at the top and group related destinations together

link

Copy link Link copied

![Image 1: 2 variants of navigation drawers: standard and modal.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoorr6v-1.png?alt=media&token=884dcde5-fdd3-438c-9825-1f6668eef908)

1.   Standard navigation drawer
2.   Modal navigation drawer

link

Copy link Link copied

Availability & resources
------------------------

link

Copy link Link copied

| Type | Resource | Status |
| --- | --- | --- |
| Design |
| [Design Kit (Figma)](https://www.figma.com/community/file/1035203688168086460) | Available |
| Implementation |
| [Flutter](https://api.flutter.dev/flutter/material/NavigationDrawer-class.html) | Available |
| [Jetpack Compose](https://developer.android.com/develop/ui/compose/components/drawer) | Available |
| [MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/components/NavigationDrawer.md) | Available |
| Web | Unavailable |
Close

link

Copy link Link copied

M3 Expressive update
--------------------

link

Copy link Link copied

**May 2025**

The navigation drawer is no longer recommended. Use the expanded navigation rail Expanded navigation rails show text labels and an extended FAB, and can be default or modal. [More on navigation rails](https://m3.material.io/m3/pages/navigation-rail/overview) instead. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

*   Color: New color mappings and compatibility with dynamic color Dynamic color takes a single color from a user's wallpaper or in-app content and creates an accessible color scheme assigned to elements in the UI. [More on dynamic color](https://m3.material.io/m3/pages/dynamic/choosing-a-source)

*   Variants: Distinguishes two separate variants of navigation drawer: Standard and modal

*   Shape: Rounded corners at the ending edge of the drawer

*   States States show the interaction status of a component or UI element. [More on states](https://m3.material.io/m3/pages/interaction-states/overview): Updated color and shape for indicating selected state

link

Copy link Link copied

![Image 2: M2 navigation drawer with 4 destinations in a mail app. The active destination “Inbox” is rectangular.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fldox2g48-navdrawer_OLD_M2.png?alt=media&token=192ac522-fc4c-4fd2-8fd2-ef6d0f6662e7)

M2: Navigation drawer had square corners and a rectangular shape indicating the active destination

![Image 3: M3 navigation drawer with 4 destinations in a mail app. The active destination “Inbox” has rounded corners.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzdbjtd0-4.png?alt=media&token=8621f0a5-d2d3-41b1-bed8-3d5d6c5fdf34)

M3: Navigation drawer has rounded corners, new color mappings, and an updated style for indicating the active destination

link

Copy link Link copied

[Previous Navigation bar: Overview](https://m3.material.io/components/navigation-bar)[Up next Navigation drawer: Specs](https://m3.material.io/components/navigation-drawer/specs)

vertical_align_top
