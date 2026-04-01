Title: Navigation rail – Material Design 3

URL Source: http://m3.material.io/components/navigation-rail/guidelines

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Navigation rail – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/navigation-rail/guidelines#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

 play_arrow 

 pause 

 dark_mode 

 light_mode 

[](https://m3.material.io/components)[](https://m3.material.io/components/app-bars)[](https://m3.material.io/components/badges)

[](https://m3.material.io/components/all-buttons)[](https://m3.material.io/components/button-groups)[](https://m3.material.io/components/buttons)[](https://m3.material.io/components/extended-fab)[](https://m3.material.io/components/fab-menu)[](https://m3.material.io/components/floating-action-button)[](https://m3.material.io/components/icon-buttons)[](https://m3.material.io/components/segmented-buttons)[](https://m3.material.io/components/split-button)

[](https://m3.material.io/components/cards)[](https://m3.material.io/components/carousel)[](https://m3.material.io/components/checkbox)[](https://m3.material.io/components/chips)

[](https://m3.material.io/components/date-pickers)[](https://m3.material.io/components/time-pickers)

[](https://m3.material.io/components/dialogs)[](https://m3.material.io/components/divider)[](https://m3.material.io/components/lists)

[](https://m3.material.io/components/loading-indicator)[](https://m3.material.io/components/progress-indicators)

[](https://m3.material.io/components/menus)

[](https://m3.material.io/components/navigation-bar)[](https://m3.material.io/components/navigation-drawer)[](https://m3.material.io/components/navigation-rail)

[](https://m3.material.io/components/radio-button)[](https://m3.material.io/components/search)

[](https://m3.material.io/components/bottom-sheets)[](https://m3.material.io/components/side-sheets)

[](https://m3.material.io/components/sliders)[](https://m3.material.io/components/snackbar)[](https://m3.material.io/components/switch)[](https://m3.material.io/components/tabs)[](https://m3.material.io/components/text-fields)[](https://m3.material.io/components/toolbars)[](https://m3.material.io/components/tooltips)

Navigation rail
===============

Navigation rails let people switch between UI views on mid-sized devices

Resources flutter android+3

Close

[info Overview](https://m3.material.io/components/navigation-rail/overview)[style Specs](https://m3.material.io/components/navigation-rail/specs)[design_services Guidelines](https://m3.material.io/components/navigation-rail/guidelines)[head_mounted_device XR](https://m3.material.io/components/navigation-rail/xr)[accessibility_new Accessibility](https://m3.material.io/components/navigation-rail/accessibility)

On this page

*   [Usage](https://m3.material.io/)
*   [Anatomy](https://m3.material.io/)
*   [Placement](https://m3.material.io/)
*   [Adaptive design](https://m3.material.io/)
*   [Behavior](https://m3.material.io/)

link

Copy link Link copied

![Image 1: Colorful, purple navigation rail shown collapsed and expanded.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fueyh1-01.png?alt=media&token=c9edba18-9dee-44b1-9657-4dd1cdf2ff74)

Use the menu icon to transition between collapsed and expanded navigation rails

link

Copy link Link copied

Usage
-----

link

Copy link Link copied

The navigation rail can display navigation items, a menu, and a floating action button Floating action buttons (FABs) help people take primary actions. [More on FABs](https://m3.material.io/m3/pages/fab/overview) (FAB) in a vertical orientation.

There are two variants of navigation rails, **collapsed** and **expanded**, which can easily transform into each other when the menu button is selected.

### Collapsed

The **collapsed** nav rail runs along the leading edge of the window, and should contain 3–7 navigation items. It should not be hidden.

It can be used in medium Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium) to extra large window sizes Window widths 1600dp and larger, such as ultra-wide monitors. [More on extra-large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large), such as tablets and desktop. In medium windows with few destinations, consider using a navigation bar Navigation bars let people switch between UI views on smaller devices. [More on navigation bars](https://m3.material.io/m3/pages/navigation-bar/overview) instead. Compact windows Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact) should always use a navigation bar.

![Image 2: Collapsed navigation rail with “timer” icon on FAB.](https://lh3.googleusercontent.com/2h46aO3pI3H6sk6nAElUSXgQFeS-w8ASJc8WcVkSbZ4bM8FJoTDWdNodAqWyROvWADumQNodvIQiUGDoBjq162uNRm52qDDoSVxUvoCDeNDx=w40)![Image 3: Collapsed navigation rail with “timer” icon on FAB.](https://lh3.googleusercontent.com/2h46aO3pI3H6sk6nAElUSXgQFeS-w8ASJc8WcVkSbZ4bM8FJoTDWdNodAqWyROvWADumQNodvIQiUGDoBjq162uNRm52qDDoSVxUvoCDeNDx=s0)

A navigation rail should be the only visible navigation element

link

Copy link Link copied

### Expanded

The**expanded** navigation rail can be standard or modal, and should always open from a menu icon. An expanded rail can reveal secondary destinations not visible when collapsed.

The**standard** configuration is placed beside body content. It’s best for larger windows with lots of available space.

The **modal** configuration overlaps the body content, and should be opened from a menu icon. Use the modal configuration for:

*   Information dense layouts where space is limited
*   Products with many navigation items

![Image 4: Expanded navigation rail shown expanded by default and expanded over screen content.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fuf9qz-03.png?alt=media&token=3377b89c-7c1c-4a94-8282-d48530c4d81e)

A navigation rail can be expanded by default on larger screen sizes, or can be expanded over content on smaller screen sizes

link

Copy link Link copied

In immersive experiences, the expanded navigation rail can be hidden entirely, appearing only when the menu icon is selected.

The collapsed navigation rail should not be hidden.

![Image 5: Navigation rail and hidden navigation rail with menu icon button for expansion.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fufhuq-04.png?alt=media&token=e13c10f7-7c71-4702-a6e5-a4d6842ad1b9)

The expanded navigation rail can also be hidden, appearing only when the menu icon is selected

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

![Image 6: 10 elements of expanded and collapsed navigation rails.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fug0sy-05.png?alt=media&token=465bf07d-fe91-4cfa-97c3-e9624609ed50)

1.   Container
2.   Menu (optional)

3.   Floating action button (FAB) (optional)

4.   Icon - active

5.   Label text - active

6.   Active indicator

7.   Icon - inactive

8.   Large badge (optional)

9.   Large badge label

10.   Small badge

11.   Label text - inactive

link

Copy link Link copied

### Container

The navigation rail should be placed on the leading edge of the window. This is the left side for left-to-right languages, and the right side for right-to-left languages.

The container fill can be turned off so the nav rail appears directly on the surface. When doing this, make sure all items have a minimum of 3:1 color contrast.

![Image 7: Right-to-left navigation rail in Hebrew, and left-to-right navigation rail in English.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fugb5b-06.png?alt=media&token=9bd7ddad-b14f-4131-bdd4-bbdb07283569)

The navigation rail should be placed on the leading edge of the window

link

Copy link Link copied

The navigation rail should always run vertically along the side of a layout. Don’t make it horizontal.

Use a navigation bar Navigation bars let people switch between UI views on smaller devices. [More on navigation bars](https://m3.material.io/m3/pages/navigation-bar/overview) for horizontal navigation.

![Image 8: Horizontal navigation rail on timer screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmacys6lz-07.png?alt=media&token=274b5d1b-6978-4123-9456-4a822df58bc7)

close Don’t 
Don’t use the navigation rail horizontally. Use a navigation bar instead.

link

Copy link Link copied

Navigation rail items can be aligned as a group to the top or center of a layout. On tablets, use center alignment to make it easier to reach items.

The menu icon and FAB should always be top-aligned.

![Image 9: Navigation rails with different alignments.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fuh0i5-08.png?alt=media&token=32641191-5400-4aba-829c-138e2f3c6d1e)

Top and center aligned rail destination placement

link

Copy link Link copied

### Menu (optional)

The menu button can transition between the **collapsed**and **expanded** navigation rails.

Once expanded, the rail can reveal secondary destinations.

When the navigation rail is expanded, the menu icon should change to represent that it can be collapsed.

![Image 10: Expanded and collapsed navigation rails controlled by a menu icon button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fuh7km-09.png?alt=media&token=ae84210a-74d7-4fac-82f1-f7a0356b23d0)

A navigation rail can expand to reveal more destinations

link

Copy link Link copied

### Floating action button (FAB) (optional)

The container of the navigation rail is ideal for anchoring the FAB to the top of a screen, placing the app’s key action above navigation destinations.

When nested within another component, such as the navigation rail, the FAB's resting elevation should be[level 0](https://m3.material.io/m3/pages/elevation/applying-elevation).

![Image 11: Navigation rail with a FAB button at the top of the screen.](https://lh3.googleusercontent.com/oYiKoFrv-NTEJMP1NoGGpnlw0RTHmfpGWDm7KmDgeKzvpXq6tMZvMjBzUcZkXpnEK2Lb_cbeWRkwS4i4RGn1zfW0N4RcwSGVgltbcvmD6vY=w40)

check Do 
A top-aligned FAB in the navigation rail

![Image 12: Navigation rail with a FAB button at the bottom of the screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fuhrl8-11.png?alt=media&token=5e953e4b-20d1-4d7f-99f0-c89d39b052e9)

close Don’t 
Avoid placing the FAB below navigation items

link

Copy link Link copied

The top of the rail can also be used for a logo, however avoid using logos that could be mistaken as buttons.

Don’t use a logo as a menu button to expand the navigation rail.

![Image 13: Navigation rail with Material design logo at the top of the screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fuhyto-12.png?alt=media&token=3e219498-f5cc-4a46-824c-4fb660bc7743)

exclamation Caution 
Use caution when placing logos in the rail where they might be confused with an action or destination

link

Copy link Link copied

### Active indicator

The active indicator shows which page is being displayed.

![Image 14: Navigation rail with active indicators present for the current screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fuicr9-13.png?alt=media&token=7755879a-0c18-40e2-89c8-e51757d7c7b2)

check Do 
Use the active indicator only for the current open page

![Image 15: Navigation rail with active indicators present for all navigation items.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fujiob-14.png?alt=media&token=ed0b9441-30cf-444e-9fde-c84be948b56d)

close Don’t 
Don’t use the active indicator for more than one navigation item at a time

link

Copy link Link copied

The active indicator hugs the label text in the expanded nav rail. To achieve a similar style to the baseline navigation drawer Navigation drawers let people switch between UI views on larger devices. In the expressive update, use an expanded navigation rail. [More on navigation drawers](https://m3.material.io/m3/pages/navigation-drawer/overview), consider modifying the active indicator to fill the container.

The target area should always span the full width.

![Image 16: Navigation rail with active indicator that hugs the text and icon.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fujt7v-15.png?alt=media&token=8405c84a-2929-4d68-8bbd-97120c4c41ab)

The active indicator hugs contents in the expanded nav rail

![Image 17: Navigation rail with active indicator that is larger than the content within it.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fujxyu-16.png?alt=media&token=bb433446-a6c0-433d-bdcb-181431e6e126)

Override the indicator to fill the container to more closely resemble the baseline navigation drawer

link

Copy link Link copied

### Icons

Navigation rail items must use icons that symbolize the content of their page. Browse popular icons on [Google Fonts](http://fonts.google.com/icons).

![Image 18: Navigation rail with icons that fit the destinations, like a timer icon and label leading to a timer feature.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fuk4ze-17.png?alt=media&token=8210a6c6-b488-46e3-aa46-ec3c18a3021d)

Icons should symbolize the content of the page they open

link

Copy link Link copied

When a destination is selected, the icon fills and changes color. An active indicator appears behind the icon.

![Image 19: Icons with and without an active indicator.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fukavr-18.png?alt=media&token=fa0ab3db-3f7a-47ff-84c2-b0d63ac890f7)

Selected navigation items have an active indicator, a filled icon, and a more prominent color

link

Copy link Link copied

### Label text

The label text should be a short, meaningful description of each navigation destination and another way for users to understand an icon’s meaning.

All navigation items require a one word label text.

![Image 20: Navigation rail with clear text labels.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fukhnw-19.png?alt=media&token=a2fe92ce-45d4-4c7b-8c51-5066b3cf7596)

check Do 
Write clear and concise labels that describe the destination page

link

Copy link Link copied

Avoid wrapping long labels when possible. If necessary, create a line break between words, or hyphenate longer words.

![Image 21: Navigation rail with lengthy text labels.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fune8p-20.png?alt=media&token=aaa6d4fd-a007-4a85-ac3c-8063f4f0767e)

exclamation Caution 
Break up longer phrases into two text lines if necessary

link

Copy link Link copied

Labels should be short enough to not be truncated. Don’t shrink the type scale to fit longer text labels.

![Image 22: Navigation rail with truncated text label with ellipses. ](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0funlrw-21.png?alt=media&token=756fbcf4-1cf8-4157-8a41-69c43e76bc2e)

close Don’t 
Don’t truncate or display an ellipsis in place of label text

![Image 23: Navigation rail with small text label.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0funqlw-22.png?alt=media&token=f25512e4-0821-4d53-9b71-41f2870830fc)

close Don’t 
Don’t reduce the type size to fit more characters into a destination label

link

Copy link Link copied

### Badges

Navigation rail icons can include badges to communicate dynamic information about the destination, such as counts or status.

In compact nav rails, the badge is placed in the upper right corner of the icon. In expanded nav rails, the badge should be placed next to the label text.

![Image 24: Navigation rail with badges on each icon.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fuomdi-23.png?alt=media&token=faa3cb30-f478-4450-946a-5be944155717)

1. Small badge on a rail destination

2. Large badge with a number

3. Large badge with a maximum character count

link

Copy link Link copied

### Divider (optional)

A vertical divider can help separate the rail from app content. The divider should be positioned on the edge of the rail container that’s adjacent to the app’s content area.

![Image 25: Navigation rail with divider separating it from screen content.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fuouq0-24.png?alt=media&token=92b886dc-b887-4991-9487-e7b720f909a8)

A divider can make the navigation rail container distinct from other on-screen content

link

Copy link Link copied

Placement
---------

link

Copy link Link copied

In adaptive layouts, the navigation rail should be placed outside any panes Panes are layout containers that house other components and elements within a single app. A pane can be: fixed, flexible, floating, or semi permanent. [More on panes](https://m3.material.io/m3/pages/understanding-layout/parts-of-layout#73de653a-fc57-4a7c-bc3b-5b9e94207de8), always along the leading edge of the window. Don’t place it within body content.

When the navigation rail is hidden, the body content can fill in the remaining space as long as the menu icon is still accessible.

Tabs Tabs organize content across different screens and views. [More on tabs](https://m3.material.io/m3/pages/tabs/overview) can be used alongside a navigation rail to create an extra layer of visible navigation.

pause

Expanded navigation rails can open from menu buttons on mobile

link

Copy link Link copied

Adaptive design
---------------

link

Copy link Link copied

For more, see [adaptive design](https://m3.material.io/m3/pages/adaptive-design/).

link

Copy link Link copied

### Resizing

When moving from a large screen to a small screen, a navigation rail can transform into a navigation bar, providing the same quick access in a configuration that’s easier to use on smaller displays. Never use the navigation rail and navigation bar simultaneously.

Only use navigation rails for medium window size classes and larger. Don’t use a navigation bar. If there are more than five destinations, consider using a modal expanded nav rail instead.

**Compact:** Don’t use a standard navigation rail for compact layouts due to space constraints. Use a navigation bar instead.

**Medium:** Use a navigation rail, especially if prioritizing persistent vertical navigation over maximizing vertical content space.

**Expanded to extra-large:** Use a navigation rail, not a navigation bar. Consider available horizontal space and the number of destinations when choosing between standard and modal.

![Image 26: Navigation bar on a phone screen and navigation rail on a tablet screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0fupcvd-26.png?alt=media&token=b1915086-e325-4b2a-946e-eb41d37a9ae7)

On smaller devices, use a navigation bar. On larger displays, use a navigation rail.

link

Copy link Link copied

### Presentation

When the navigation rail transitions from collapsed to expanded, the contents of the page should automatically adjust to fit.

The contents of the navigation rail also expand to fill the space. For example, the FAB should transition into an extended FAB.

Extra destinations can be shown in an expanded nav rail.

pause

Use a standard expanded rail when there are secondary destinations or actions that have lower priority than the main navigation items

link

Copy link Link copied

Behavior
--------

link

Copy link Link copied

### Scrolling

Destinations in the navigation rail should remain visible and fixed when scrolling vertically.

pause

Rail destinations remain fixed while on-screen content scrolls vertically

link

Copy link Link copied

If a layout scrolls horizontally, the rail can scroll off-screen or remain fixed. To distinguish that content is scrolling underneath the rail, use a divider or add elevation to the rail.

pause

A divider and color fill change create visual distinction between the rail and horizontally scrolling content

pause

Elevating the rail to level 1 creates visual distinction between the rail and horizontally scrolling content

link

Copy link Link copied

### Selection

When a destination is tapped, the destination screen uses a[top level](https://m3.material.io/m3/pages/motion-transitions/transition-patterns#f852afd2-396f-49fd-a265-5f6d96680e16)transition pattern. In addition, the icon becomes filled and the active indicator expands from the center of the icon.

pause

Tapping a destination uses a top level transition pattern

link

Copy link Link copied

### Back

On Android, a gesture called predictive back allows people to swipe left or right on the screen to go back or dismiss modal components.

*   Previous screen is revealed in a preview to signal the destination

*   Predictive back only applies to the **modal expanded** navigation rail.

A list of compatible components is available on the[gestures page](https://m3.material.io/m3/pages/gestures/).

pause

The nav rail pops off the edge of the window during the predictive back gesture

[arrow_left_alt Previous Navigation rail: Specs](https://m3.material.io/components/navigation-rail/specs)[Up next arrow_right_alt Navigation rail: XR](https://m3.material.io/components/navigation-rail/xr)

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
