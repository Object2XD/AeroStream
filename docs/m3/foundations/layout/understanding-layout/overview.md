Title: Layout – Material Design 3

URL Source: http://m3.material.io/foundations/layout/understanding-layout

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Layout basics
-------------

Layout is the visual arrangement of elements on the screen

On this page

*   [What’s new](https://m3.material.io/)
*   [Layout terms](https://m3.material.io/)

link

Copy link Link copied

*   Use layout to direct attention to the action users want to take
*   Adapt layouts to compact Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact), medium Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium), expanded Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded), large Window widths 1200dp to 1599dp, such as desktop. [More on large window size](https://m3.material.io/m3/pages/applying-layout/large-extra-large), and extra-large Window widths 1600dp and larger, such as ultra-wide monitors. [More on extra-large window size](https://m3.material.io/m3/pages/applying-layout/large-extra-large) window size classes
*   Build from an established canonical layout Designs for common screen layouts across window size classes 
*   Consider how spacing and the parts of the layout work together
*   Material layout guidance applies to Android and the web

link

Copy link Link copied

![Image 1: Terms shown on a screen.  Window means the whole screen.  From left to right are columns, a middle fold with a spacer, a pane and a right-side margin.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwwo5fb-1-1p.png?alt=media&token=3dacb934-f555-4a6f-a45e-bbef2f208a7f)

1.   Column
2.   Fold
3.   Margin
4.   Pane
5.   Drag handle
6.   Spacer
7.   Window

link

Copy link Link copied

What’s new
----------

link

Copy link Link copied

*   When creating new layouts, begin from a [canonical layout](https://m3.material.io/m3/pages/canonical-layouts/overview) rather than a layout grid. This helps ensure that your layouts can scale across devices and form factors.
*   [Window size classes](https://m3.material.io/m3/pages/applying-layout/window-size-classes) are opinionated breakpoints. Material Design recommends you create layouts for five window size classes: compact Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact), medium Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium), expanded Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded), large Window widths 1200dp to 1599dp, such as desktop. [More on large window size](https://m3.material.io/m3/pages/applying-layout/large-extra-large), and extra-large Window widths 1600dp and larger, such as ultra-wide monitors. [More on extra-large window size](https://m3.material.io/m3/pages/applying-layout/large-extra-large)
*   Layouts with multiple panes of content can be resized with a drag handle

![Image 2: Different layouts for differently sized screens ](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwwpg71-2.png?alt=media&token=5e7f0ae7-f5d5-44c6-8574-17b622fa7659)

M3 considers multiple layouts for a variety of sizes

link

Copy link Link copied

Layout terms
------------

link

Copy link Link copied

*   **Column**: one or more vertical blocks of content within a pane
*   **Drag handle:** The component that resizes panes
*   **Fold**: on foldable devices, a flexible area of the screen or, on dual-screen devices, a hinge that separates two displays
*   **Margin**: the space between the edge of the screen and any elements inside of it
*   **Multi-window mode**: enables multiple apps to share the same screen simultaneously
*   **Pane**: a layout container that houses other components and elements within a single app. A pane can be: fixed, flexible, floating, or semi permanent
*   **Spacer**: the space between two panes
*   **Window size class**: opinionated breakpoint, the window size at which a layout needs to change to match available space, device conventions, and ergonomics

[Previous States: Overview](https://m3.material.io/foundations/interaction/states)[Up next Layout basics: Spacing](https://m3.material.io/foundations/layout/understanding-layout/spacing)

vertical_align_top
