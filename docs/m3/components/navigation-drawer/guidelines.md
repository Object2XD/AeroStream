Title: Navigation drawer – Material Design 3

URL Source: http://m3.material.io/components/navigation-drawer/guidelines

Markdown Content:
link

Copy link Link copied

link

Copy link Link copied

![Image 1: Navigation drawer with 4 primary destinations ](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwopun3e-1.png?alt=media&token=220f8c9f-c032-4185-9a2c-4ac8950d763f)

link

Copy link Link copied

Usage
-----

link

Copy link Link copied

Navigation drawers provide access to destinations and app functionality, such as switching accounts. They can either be permanently on-screen or opened and closed by a navigation menu Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview) icon. One navigation destination is always active.

Navigation drawers are recommended for:

*   Apps with 5 or more top-level destinations
*   Apps with 2 or more levels of navigation hierarchy
*   Quick navigation between unrelated destinations
*   Replacing the navigation rail Navigation rails let people switch between UI views on mid-sized devices. [More on navigation rails](https://m3.material.io/m3/pages/navigation-rail/overview) or navigation bar Navigation bars let people switch between UI views on smaller devices. [More on navigation bars](https://m3.material.io/m3/pages/navigation-bar/overview) on large screens

![Image 2: Navigation drawer with multiple destinations in a mail app.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwopv1qw-2.png?alt=media&token=a8455b6f-5918-42d9-aa1c-04d158c8eba1)

check Do Use a navigation drawer for 5 or more primary destinations, or more than 1 level of navigation hierarchy

link

Copy link Link copied

Avoid using a navigation drawer with other primary navigation components, such as a navigation bar.

Instead, choose a single navigation component based on product requirements, breakpoints, and window size class Window size classes are opinionated breakpoints where layouts need to change to optimize for available space, device conventions, and ergonomics. [More on window size classes](https://m3.material.io/m3/pages/applying-layout/window-size-classes):

*   Navigation bars Navigation bars let people switch between UI views on smaller devices. [More on navigation bars](https://m3.material.io/m3/pages/navigation-bar/overview) for compact window sizes Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact)
*   Navigation rails Navigation rails let people switch between UI views on mid-sized devices. [More on navigation rails](https://m3.material.io/m3/pages/navigation-rail/overview) for medium Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium) and expanded window sizes Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded)
*   Standard navigation drawers for expanded, large Window widths 1200dp to 1599dp, such as desktop. [More on large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large) and extra-large Window widths 1600dp and larger, such as ultra-wide monitors. [More on extra-large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large) window sizes

![Image 3: Standard navigation drawer and navigation bar used together.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwopvjco-3.png?alt=media&token=9df37deb-e7d3-4dea-88d1-b5b6a6040cab)

exclamation Caution 
Avoid using two navigation components on the same screen

link

Copy link Link copied

There are two variants of navigation drawers:

1.   Standard navigation drawer

2.   Modal navigation drawer

![Image 4: Standard navigation drawer with destinations in mail app.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwopw575-4.png?alt=media&token=0970e3a0-0963-4060-9aae-22d9e3689652)

Standard navigation drawer

![Image 5: Modal navigation drawer with destinations and scrim.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwopwhen-5.png?alt=media&token=81d4f11e-1cba-4620-ba30-78d3cc70ab55)

Modal navigation drawer

link

Copy link Link copied

### Standard navigation drawer

link

Copy link Link copied

Standard navigation drawers provide access to drawer destinations and app content for layouts Layout is the visual arrangement of elements on the screen. [More on layout](https://m3.material.io/m3/pages/understanding-layout/overview) in expanded Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded), large Window widths 1200dp to 1599dp, such as desktop. [More on large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large), and extra-large Window widths 1600dp and larger, such as ultra-wide monitors. [More on extra-large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large) window sizes.

Standard drawers can be permanently visible (best for frequently switching destinations) or opened and closed by tapping a menu Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview) icon (best for focusing more on screen content).

In medium Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium) and compact window sizes Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact), use modal drawers instead.

![Image 6: Standard navigation drawer in a mail app with active destination “Inbox” next to app content.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwopx4a0-6.png?alt=media&token=439663a8-dc1f-442d-a29a-54430caeb836)

Standard navigation drawer providing access to drawer destinations next to app content

link

Copy link Link copied

link

Copy link Link copied

### Modal navigation drawer

link

Copy link Link copied

Modal navigation drawers use a scrim to block interaction with the rest of an app’s content, and don’t affect the screen’s layout Layout is the visual arrangement of elements on the screen. [More on layout](https://m3.material.io/m3/pages/understanding-layout/overview) grid.

Modal navigation drawers can be used in any window size, but are primarily used in compact and medium sizes where space is limited or prioritized for app content.

They can be swapped with standard drawers on expanded, large Window widths 1200dp to 1599dp, such as desktop. [More on large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large), and extra-large Window widths 1600dp and larger, such as ultra-wide monitors. [More on extra-large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large) window sizes.

![Image 7: Modal navigation drawer with 1 active destination and scrim.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwopxvvj-7.png?alt=media&token=5d45f347-e521-48af-9ae9-d4c05965f42f)

Modal navigation drawer using a scrim to block interaction with the rest of an app’s content

link

Copy link Link copied

Modal navigation drawers are always opened by an action outside of the drawer, such as clicking a navigation menu Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview) icon in a navigation rail Navigation rails let people switch between UI views on mid-sized devices. [More on navigation rails](https://m3.material.io/m3/pages/navigation-rail/overview).

Modal drawers can be dismissed by:

*   Selecting a drawer item
*   Tapping the scrim
*   Swiping toward the drawer’s anchoring edge (for example, swiping right-to-left for a left-aligned navigation drawer)

![Image 8: Diagram noting a navigation menu icon in a navigation rail.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwopy7b1-8.png?alt=media&token=5ea39e51-4a7b-4e9b-ad02-2fef81e461cd)

A modal drawer opened by an action such as clicking a navigation menu icon (1)

link

Copy link Link copied

Modal drawers can be dismissed by tapping the scrim or swiping the drawer toward its anchoring screen edge.

![Image 9: 2 modal navigations illustrating tapping the scrim or swiping to dismiss a modal drawer](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwopyjta-9.png?alt=media&token=3090bcc0-a205-4695-b11b-931243b71061)

1. Dismiss by tapping the scrim

2. Dismiss by swiping the drawer

link

Copy link Link copied

Anatomy
-------

Navigation drawers are essentially a list Lists are continuous, vertical indexes of text and images. [More on lists](https://m3.material.io/m3/pages/lists/overview) contained within a side sheet Side sheets show secondary content anchored to the side of the screen. [More on side sheets](https://m3.material.io/m3/pages/side-sheets/overview). They can also include headers, subheads, and dividers Dividers are thin lines that group content in lists or other containers. [More on dividers](https://m3.material.io/m3/pages/divider/overview) to organize longer lists.

link

Copy link Link copied

![Image 10: Navigation drawer diagram numbering 8 elements.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwopzqbr-10.png?alt=media&token=4325d34c-753c-4cfa-8b60-fbf6aaa56358)

Navigation drawers can include headers, subheads, and dividers to organize longer lists

1.   Active Indicator
2.   Icon
3.   Label
4.   Badge label
5.   Sheet
6.   Divider
7.   Section label (optional)
8.   Scrim

link

Copy link Link copied

### Sheet

A sheet holds all navigation drawer elements. Side sheets Side sheets show secondary content anchored to the side of the screen. [More on side sheets](https://m3.material.io/m3/pages/side-sheets/overview) are used as the container for standard and modal navigation drawers.

Navigation drawers that open from the side are always placed on the start edge of the screen, on the left for left-to-right (LTR) languages, and on the right for right-to-left (RTL) languages.

![Image 11: Modal navigation drawer opening from left side of screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq08ti-11.png?alt=media&token=fa4df5c4-43a7-4979-83dd-4a50c3c28454)

check Do 
A navigation drawer opens from the left side of the screen for left-to-right languages

link

Copy link Link copied

### Divider (optional)

Dividers Dividers are thin lines that group content in lists or other containers. [More on dividers](https://m3.material.io/m3/pages/divider/overview) can be used to separate groups of destinations within the navigation drawer.

![Image 12: Navigation drawer using horizontal dividers to separate a group of destinations](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq1xf0-12.png?alt=media&token=1d041701-d74b-4495-a337-c858a9bd81b5)

check Do 
Use full-width dividers (1) to separate groups of destinations

![Image 13: Navigation drawer using horizontal dividers to separate individual destinations](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq29df-13.png?alt=media&token=612b4caa-99c1-4c3b-a835-2c1ed0bda36a)

close Don’t 
Don’t use dividers to separate individual destinations

link

Copy link Link copied

### Active indicator

The active indicator is a background shape communicating which destination of the navigation drawer is currently being displayed.

![Image 14: Navigation drawer diagram numbering 1 element.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq2qbs-14.png?alt=media&token=cefe950a-7624-4c32-a31d-3b596d729417)

The active indicator (1) is a background shape communicating which destination of the navigation drawer is currently being displayed

link

Copy link Link copied

### Label text and icons

Destinations in a navigation drawer take the form of actionable list Lists are continuous, vertical indexes of text and images. [More on lists](https://m3.material.io/m3/pages/lists/overview) items. Each item describes its destination using label text and an optional icon.

![Image 15: Navigation drawer diagram numbering 2 elements.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq358i-15.png?alt=media&token=ad709e8b-f932-4c40-a63c-cf893ff65b71)

Actionable list items in a navigation drawer describe each destination using (1) an optional icon and (2) required label text

link

Copy link Link copied

Label text should be clear and short enough that it isn’t cut off by the sheet.

![Image 16: Navigation drawer using only label text for 4 destinations. Label text “Inbox” in active destination.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq3i6v-16.png?alt=media&token=e855eb07-211a-44ba-a56f-9414dce6237b)

Navigation drawers can use text labels without icons

link

Copy link Link copied

![Image 17: Navigation drawer with 1 truncated text label.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq4gjj-17.png?alt=media&token=44f71647-6325-43c9-b93e-6a3bc059ae87)

check Do 
Keep text labels concise, but truncate them if they extend beyond the container width

![Image 18: Navigation drawer with 1 text label with wrapped label text.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq4tkk-18.png?alt=media&token=c152a72c-b231-4f97-81aa-1b14d827c8b9)

close Don’t 
Don’t wrap label text

![Image 19: Navigation drawer with 1 text label featuring smaller text.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq56gb-19.png?alt=media&token=218c541f-0e68-40b4-bf8c-59983f554512)

close Don’t 
Don’t shrink text size in order to fit a text label on a single line

link

Copy link Link copied

Icons can supplement labels as indicators of a destination. When used, they should always be placed before text. Other app components and content should reference these icons.

![Image 20: Navigation drawer with active destination “Inbox” featuring recognizable icon.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq67nf-20.png?alt=media&token=f5cdaabd-b70e-495e-9d1e-5cce1e0bb81d)

check Do 
Use recognizable icons when conventions exist

![Image 21: Navigation drawer with 4 destinations, 2 with text label and icon, 2 with only text label.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq6mto-21.png?alt=media&token=70a07030-1191-4f84-9e14-19c188d0452b)

close Don’t 
Don’t apply icons to some destinations and not others. Icons should be used for all destinations, or none.

link

Copy link Link copied

### Section label (optional)

Short subhead section labels can help group related destinations in the navigation drawer.

![Image 22: Navigation drawer showing subhead section labels.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq710s-22.png?alt=media&token=f9fc1eb9-1347-4515-bf7f-461d9100c605)

Related destinations can be grouped using short subhead section labels in the navigation drawer

link

Copy link Link copied

### Scrim (modal only)

Modal navigation drawers use a scrim to block interaction with the rest of the app. The scrim is placed directly behind the drawer’s sheet and can be tapped or clicked to dismiss the drawer.

![Image 23: Modal navigation drawer with scrim placed behind.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq7esu-23.png?alt=media&token=41cf34a6-52f4-48ad-8408-16f71ce0b744)

Scrim applied behind a modal navigation drawer

link

Copy link Link copied

Responsive layout
-----------------

link

Copy link Link copied

A product’s navigation component should change to suit the window size class Window size classes are opinionated breakpoints where layouts need to change to optimize for available space, device conventions, and ergonomics. [More on window size classes](https://m3.material.io/m3/pages/applying-layout/window-size-classes) and form factor of the screen.

Modal navigation drawers can be used at any window size but are most common in compact Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact) and medium window sizes Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium).

Standard navigation drawers are best for expanded Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded), large Window widths 1200dp to 1599dp, such as desktop. [More on large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large), and extra-large Window widths 1600dp and larger, such as ultra-wide monitors. [More on extra-large window size class](https://m3.material.io/m3/pages/applying-layout/large-extra-large) window sizes.

Use a transition when swapping components. For example, when switching from a portrait to landscape layout Layout is the visual arrangement of elements on the screen. [More on layout](https://m3.material.io/m3/pages/understanding-layout/overview), the navigation rail Navigation rails let people switch between UI views on mid-sized devices. [More on navigation rails](https://m3.material.io/m3/pages/navigation-rail/overview) should transform into a navigation drawer.

![Image 24: Navigation rail changing to navigation. drawer on a larger screen](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq7wck-24.png?alt=media&token=2e030b27-4348-4860-aac6-78e423e11c79)

Standard navigation drawers change size to suit the device’s screen

link

Copy link Link copied

### Compact window size

Use modal navigation drawers in compact window sizes Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact). Or swap the drawer for a navigation bar.

On web, when the screen size is smaller than 320 CSS pixels CSS pixels are the most common unit of measurement when developing for the web. [More on CSS pixels](https://www.w3.org/Style/Examples/007/units.en.html), swap the navigation drawer for a navigation bar to ensure accessibility Accessible design makes products usable for people with all kinds of abilities. [More on accessibility](https://m3.material.io/m3/pages/overview/principles).

![Image 25: Modal navigation drawer with 1 active destination.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoq8evf-25.png?alt=media&token=ef3a29d1-8e04-4b51-9774-8c7f118fbad4)

Use a modal navigation drawer on mobile screens

link

Copy link Link copied

### Medium & expanded window sizes

Use a modal navigation drawer alone or with a navigation rail on medium Window widths from 600dp to 839dp, such as a tablet or foldable in portrait orientation. [More on medium window size class](https://m3.material.io/m3/pages/applying-layout/medium) and expanded Window widths 840dp to 1199dp, such as a tablet or foldable in landscape orientation, or desktop. [More on expanded window size class](https://m3.material.io/m3/pages/applying-layout/expanded) window sizes.

When a navigation rail Navigation rails let people switch between UI views on mid-sized devices. [More on navigation rails](https://m3.material.io/m3/pages/navigation-rail/overview) and modal navigation drawer are used together, the drawer can repeat destinations in the navigation rail as long as the drawer offers enough visual separation between levels of the navigation hierarchy.

A standard navigation drawer can be used in [single pane layouts](https://m3.material.io/m3/pages/understanding-layout/parts-of-layout) in expanded window sizes.

Use a navigation rail on tablet screens, or also allow a drawer to open and close via a menu icon

link

Copy link Link copied

### Large and extra-large window sizes

For web experiences on laptop and desktop devices, use either a standard navigation drawer, or a navigation rail Navigation rails let people switch between UI views on mid-sized devices. [More on navigation rails](https://m3.material.io/m3/pages/navigation-rail/overview) that transitions into a modal navigation drawer.

![Image 26: Navigation drawer showing 1 active destination.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flx54v3bi-27.png?alt=media&token=444359b1-1e21-4971-b70d-bc624d900b19)

Use a standard navigation drawer on large and desktop screens

link

Copy link Link copied

Behavior
--------

link

Copy link Link copied

### Scrolling

Navigation drawers can be vertically scrolled, independent of the rest of the screen’s content and UI. If the list Lists are continuous, vertical indexes of text and images. [More on lists](https://m3.material.io/m3/pages/lists/overview) of navigation destinations is longer than the height of the drawer, the drawer’s contents can be scrolled within the drawer.

When a navigation drawer is scrolled, the body content should remain stationary

link

Copy link Link copied

### Visibility

**Dismissible standard drawers** can be used for layouts Layout is the visual arrangement of elements on the screen. [More on layout](https://m3.material.io/m3/pages/understanding-layout/overview) that prioritize content (such as a photo gallery) or for apps where users are unlikely to switch destinations often. They should use a visible navigation menu Menus display a list of choices on a temporary surface. [More on menus](https://m3.material.io/m3/pages/menus/overview) icon to open and close the drawer.

![Image 27: Side-by-side standard navigation drawer opened and then closed after tapping menu bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoqb1nm-27.png?alt=media&token=ed09af6e-928f-41f7-a7ca-fcf766ea4050)

A standard dismissible navigation drawer is opened and closed by tapping the navigation menu icon in the app bar (1), and remains open until the menu icon is tapped again (2)

link

Copy link Link copied

**Permanently visible standard drawers** allow quick navigation between unrelated destinations. They can’t be closed or dismissed by the user.

![Image 28: Standard navigation drawer moving between destinations.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwoqf0gp-28.png?alt=media&token=627872b2-dc97-4b2c-8234-2339a7730b18)

A permanently-visible standard navigation drawer on desktop

link

Copy link Link copied

### Appearing

When a navigation drawer animates on screen, it uses an [enter and exit](https://m3.material.io/m3/pages/motion-transitions) transition pattern.

A navigation drawer animating on screen
