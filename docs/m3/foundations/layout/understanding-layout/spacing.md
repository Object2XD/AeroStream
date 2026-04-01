Title: Layout – Material Design 3

URL Source: http://m3.material.io/foundations/layout/understanding-layout/spacing

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Layout – Material Design 3
===============

[Skip to main content](https://m3.material.io/foundations/layout/understanding-layout/spacing#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

*   [Grouping](https://m3.material.io/)
*   [Margins](https://m3.material.io/)
*   [Spacers](https://m3.material.io/)
*   [Padding](https://m3.material.io/)

link

Copy link Link copied

Grouping
--------

link

Copy link Link copied

Grouping is a method for connecting related elements that share a context, such as an image grouped with a caption. It visually relates elements and establishes boundaries to differentiate unrelated elements.

![Image 1: Photo of dumplings with a caption reading “restaurants in the area”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwwvqdk-1.png?alt=media&token=ee88043a-8222-4c39-912f-f0b6336ee653)

By placing a caption under an image this composition shows an explicit group

link

Copy link Link copied

**Explicit grouping** uses visual boundaries such as outlines, dividers, and shadows to group related elements in an enclosed area. Explicit grouping can also indicate that an item is interactive, such as list items contained between dividers, or a card displaying an image and its caption.

![Image 2: Container of a contact grouped with photo and caption](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwwxa8g-2.png?alt=media&token=62385ee2-6bc3-492b-a60b-db12f75d2580)

The elements in this card are explicitly grouped

link

Copy link Link copied

**Implicit grouping** uses close proximity and open space (rather than lines and shadows) to group related items. For example, a headline closely followed by a subhead and thumbnail image are implicitly grouped together by proximity and separated from other headline-subhead-thumbnail groups by open space.

![Image 3: Carousel of images](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwwyais-3.png?alt=media&token=1f6813ec-a502-4adb-abd9-7cb648575f45)

Images in a carousel are grouped by their proximity

link

Copy link Link copied

Margins
-------

link

Copy link Link copied

Margins are the spaces between the edge of a window area and the elements within that window area.

Margin widths are defined using fixed or scaling values for each window size class. To better adapt to the window, the margin width can change at different breakpoints. Wider margins are more appropriate for larger screens, as they create more open space around the perimeter of content.

See margin measurements for each window class:compact Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact), medium Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium), expanded Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded), large Window widths 1200dp to 1599dp, such as desktop. [More on large window size](https://m3.material.io/m3/pages/applying-layout/large-extra-large), and extra-large. Window widths 1600dp and larger, such as ultra-wide monitors. [More on extra-large window size](https://m3.material.io/m3/pages/applying-layout/large-extra-large)

![Image 4: Screen highlighting vertical blue margin on left side of screen](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwx04xw-1.png?alt=media&token=3a716354-4106-42c6-920c-3692da759a86)

A margin separates the edge of the screen from the elements on the screen

link

Copy link Link copied

Spacers
-------

link

Copy link Link copied

A spacer refers to the space between two panes Panes are layout containers that house other components and elements within a single app. A pane can be: fixed, flexible, floating, or semi permanent. [More on panes](https://m3.material.io/m3/pages/understanding-layout/parts-of-layout#667b32c0-56e2-4fc2-a618-4066c79a894e) in a layout. Spacers measure 24dp wide.

![Image 5: Screen highlighting vertical blue margin on left side of screen](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwx1ijr-5.png?alt=media&token=ab82125d-28cd-4500-a322-fd4c9606dd3c)

1.   A spacer splits two panes from each other

link

Copy link Link copied

A spacer can contain a drag handle A drag handle adjusts the layout when there are 2 or more panes. [More on drag handles](https://m3.material.io/m3/pages/understanding-layout/parts-of-layout#314a4c32-be52-414c-8da7-31f059f1776d) that adjusts the size and layout of the panes. The handle's touch target slightly overlaps the panes.

![Image 6: Pane drag handle touch target overlapping two panes.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwx2hj1-6.png?alt=media&token=697c271a-165d-4dbd-af2b-e98b49b4a95d)

1.   Drag handle touch target

link

Copy link Link copied

Padding
-------

link

Copy link Link copied

Padding refers to the space between UI elements. Padding can be measured vertically and horizontally and does not need to span the entire height or width of a layout. Padding is measured in increments of 4dp.

![Image 7: Full screen-width photo with padding below it and text below the padding](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxwx3xmp-3.png?alt=media&token=f9885d4f-f041-4a92-b7ea-2179ea08c0ab)

1.   Padding separates a headline from a image above

[arrow_left_alt Previous Layout basics: Overview](https://m3.material.io/foundations/layout/understanding-layout/overview)[Up next arrow_right_alt Layout basics: Parts of layout](https://m3.material.io/foundations/layout/understanding-layout/parts-of-layout)

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
