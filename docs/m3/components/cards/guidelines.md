Title: Top app bar – Material Design 3

URL Source: http://m3.material.io/components/app-bars/guidelines

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
App bars
--------

App bars are placed at the top of the screen to help people navigate through a product

Resources

flutter

android

+3

Close

On this page

*   [Usage](https://m3.material.io/)
*   [Search app bar](https://m3.material.io/)
*   [Anatomy](https://m3.material.io/)
*   [Adaptive design](https://m3.material.io/)
*   [Behavior](https://m3.material.io/)

link

Copy link Link copied

![Image 1: 4 app bars with headlines and action icons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnt9v4x-01.png?alt=media&token=0cdcf9fb-c1f2-4dd5-8746-6e414feee9bb)

App bars show information about the page, key actions, and navigation actions like **Back** or **Menu**

link

Copy link Link copied

Usage
-----

link

Copy link Link copied

Use an app bar to provide content and actions related to the current page, such as page navigation actions, headlines, images, and 1–2 essential actions.

The information and actions in the app bar should be contextual and specific to a page, but can also include global product controls, such as search or notifications.

![Image 2: App bar with navigation icon buttons and a 2-line title.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlntdon8-02.png?alt=media&token=7474bc26-0192-42ed-9ae4-d429ee924607)

App bars provide content and actions related to the current page

link

Copy link Link copied

App bars should only have one action, two if necessary.

The primary action should alter or exit the entire page, like **Send**, **Save**, or **Edit**.

If the product has many actions, place those in a toolbar Toolbars display frequently used actions relevant to the current page. [More on toolbars](https://m3.material.io/m3/pages/toolbars/overview). Avoid placing an overflow menu in the app bar when possible.

![Image 3: App bar with content below.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnth1j3-03.png?alt=media&token=20971f34-e3ce-481d-ab93-7e6515060d07)

App bars can display one high visibility action to boost its prominence

link

Copy link Link copied

To boost visibility of a primary action, change the style of the icon button to filled or tonal, and consider using a wide icon button.

Avoid using multiple filled or tonal buttons.

![Image 4: App bar with 1 filled button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlntiy4b-04-do.png?alt=media&token=377f38d5-e584-48cc-bc4c-7b6924efb2bd)

check Do
Use a filled or tonal button for important actions

![Image 5: App bar with 2 filled buttons, side by side.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlntjjnv-05-dont.png?alt=media&token=7edfa0f2-f8ca-4ccc-a273-8fc079488693)

close Don’t
Don’t put multiple filled or tonal buttons in the app bar

link

Copy link Link copied

The four variants of app bars are:

1.   **Search app bar**

Use on home pages when search is key to the product.
2.   **Small**

Use in dense layouts or when a page is scrolled.
3.   **Medium flexible**

Use to display a larger headline. It can collapse into a small app bar on scroll.
4.   **Large flexible**

Use to emphasize the headline of the page.

![Image 6: The 4 app bar variants.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlntmieq-06.png?alt=media&token=c19118e7-becf-4020-9834-4808d65dff6e)

1.   Search app bar
2.   Small
3.   Medium flexible
4.   Large flexible

link

Copy link Link copied

### Baseline app bars

There are two baseline app bars that are no longer recommended:

1.   **Medium**

Replace with medium flexible.
2.   **Large**

Replace with large flexible.

![Image 7: 2 baseline app bars.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlntnwot-07.png?alt=media&token=dda26bc8-d2d7-4573-a638-b392ab477962)

1.   Medium
2.   Large

link

Copy link Link copied

Search app bar
--------------

link

Copy link Link copied

Use a search app bar to provide an emphasized entry-point to open the search view.

![Image 8: A search bar within an app bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlntr0ls-08.png?alt=media&token=3d8eef75-94d0-4d8f-9ccf-fbda3f747b4e)

Search app bars have a search field instead of heading text

link

Copy link Link copied

Search bars The search bar is a persistent and prominent search field at the top of the screen. [More on search bars](https://m3.material.io/m3/pages/search/overview) should always include the word **Search**. They can use various capitalization styles depending on the product.

1.   **Search**

2.   Searching a specific area

Example: **Search inbox**

3.   Search [Product]

Example: **Search Photos**

![Image 9: 3 examples of search text in an app bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlntrvt2-09.png?alt=media&token=1cbbdac4-2b41-433c-a6f0-f9eaefdb7f86)

Use proper capitalization depending on what’s being searched

link

Copy link Link copied

### Buttons in search app bar

In addition to a trailing avatar, search app bars can have up to two trailing icons on mobile.

Trailing icons can be placed inside or outside the search bar.

![Image 10: 2 icons placed in the search bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlntvpyq-10.png?alt=media&token=e8605375-74f6-4f86-95ba-3cbf97a0abb9)

Put the most used actions on the left and least used on the right

link

Copy link Link copied

The leading element of a search app bar can be used for a product’s logo to brand the app’s overall experience.

This logo can be purely cosmetic, or can trigger an action like returning to the home screen or refreshing it.

Avoid using a logo to open an expanded navigation rail Expanded navigation rails show text labels and an extended FAB, and can be default or modal. .

![Image 11: A search app bar with a logo, search bar, and avatar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlntz91y-11.png?alt=media&token=9075c294-0618-48e2-ad59-fa6c078f1d9f)

The leading element can be a product logo

link

Copy link Link copied

Don’t use more than two trailing icon buttons with an avatar.

If more actions are needed, place them in a toolbar Toolbars display frequently used actions relevant to the current page. [More on toolbars](https://m3.material.io/m3/pages/toolbars/overview) instead.

![Image 12: 3 icons placed in a search app bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnu01cf-12-Dont.png?alt=media&token=0e553615-403a-4262-82e9-e288d7c660e0)

close Don’t
Don’t use three icons and an avatar in a search app bar

link

Copy link Link copied

### Large screens

The search app bar dynamically adapts to available width. There should be up to four trailing icons on larger screens.

link

Copy link Link copied

![Image 13: 4 actions placed in a search app bar on a large screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnu4je0-13.png?alt=media&token=7e18830b-0ad8-4daf-bd6c-a4444703e399)

Increased horizontal space on larger screens allows for up to four trailing icons.

link

Copy link Link copied

### Alternate color options

By default, search containers in app bars use the **surface container** color to distinguish it from the app background. If the background is darker, use a lighter container color on the search bar, like **surface bright**.

When choosing alternate colors, make sure the search text and container have at least 3:1 contrast for readability.

![Image 14: App bar with a light search container color.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnu68g2-14.png?alt=media&token=1a01e007-1a24-4d4e-844e-2974b56e060b)

Search app bars can use different colors, like **surface bright**, for improved contrast with surrounding elements

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

![Image 15:  Diagram of app bar layout.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnub2xp-15.png?alt=media&token=3c28ab87-33b2-4e09-b2b7-207d28656b2f)

1.   Container
2.   Headline
3.   Trailing icons
4.   Subtitle
5.   Leading button

link

Copy link Link copied

### Container

The app bar container holds all information and actions at the top of a screen, including navigation icons, headlines, and buttons.

Avoid changing the position or shape of the container.

![Image 16: App bar with square corners.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnuf0r2-16-do.png?alt=media&token=1fb862a0-8a65-4d93-af58-23b8f45e9603)

check Do
Use straight corners for app bars

![Image 17: App bar with curved corners.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnugbt5-17-dont.png?alt=media&token=c7c569a5-2a81-4583-a069-489e9e24fba9)

close Don’t
Don’t use curved shapes. This implies that the container can expand upon interaction.

link

Copy link Link copied

Always use the default height of the app bar, and make it span the full width of the window.

![Image 18: App bar at default height.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnuiiym-18-Do.png?alt=media&token=9eb7bc81-3b55-4eea-bd7b-056e75806c41)

check Do
Default heights were chosen to ensure readability of on-screen elements

![Image 19: App bar with reduced height.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnuja9a-19-Don't.png?alt=media&token=1545b8ba-fdf0-47ac-8a4a-ff46376cd5d3)

close Don’t
Don't make an app bar shorter than its default height

link

Copy link Link copied

### Adding logos

Image logos can be used in app bars to bolster brand identity or visual appeal.

The image should be high quality and pertinent, and shouldn’t disrupt the app bar's functionality.

![Image 20: A logo added to an app bar.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnuliot-20.png?alt=media&token=adba677c-2152-4281-8bd4-f8716770b7af)

Image logos can replace all text in small app bars, and appear above the text in other app bars

link

Copy link Link copied

### Leading button

The leading button should be used for navigating the product.

It typically is one of the following:

*   A menu icon, which opens a modal expanded navigation rail Expanded navigation rails show text labels and an extended FAB, and can be default or modal.

*   A back arrow, which returns to the previous screen

![Image 21: Leading navigation icon aligned on left of app bar](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnumedg-21.png?alt=media&token=3e674e2f-9102-4572-8d2d-b53da2435447)

1.   Leading **Back** button

link

Copy link Link copied

### Headline

The headline can describe:

*   The current page
*   The current section
*   The product

Headline text should be brief enough to easily fit in the app bar.

In medium flexible and large flexible app bars, the headline can wrap to a second line.

Don’t truncate the headline text.

![Image 22: App bar headline text set in 2 lines.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnurf1u-22-Do.png?alt=media&token=3a5b3bbb-92c1-4a5b-9bd1-7e14e49c3ad2)

check Do
If headline text is long, use a medium flexible or large flexible app bar and wrap the headline to two lines maximum

![Image 23: Small app bar headline text wrapped on 2 lines.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnus8yg-23-Don't.png?alt=media&token=5fd85933-3b19-4bd6-8d78-f0740a229798)

close Don’t
Don’t wrap text in a small app bar

link

Copy link Link copied

Headlines can be aligned to the leading edge or centered.

The headline’s typography size and style change depending on the app bar variant.

![Image 24: Search, small, medium and large flexible app bars with headline styles.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnuwnod-24.png?alt=media&token=b7d50c26-4b22-499d-937e-b8a46da6c6d2)

Headline typography style for each app bar

1.   Search: Body large
2.   Small: Title large
3.   Medium flexible: Headline medium
4.   Large flexible: Display small

link

Copy link Link copied

### Subtitle

Subtitles can add additional context to a page.

These can be leading-aligned or center-aligned with the headline text.

![Image 25: Small to large flexible app bars with headline and subtitle styles.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnvaru4-25.png?alt=media&token=2f11cf07-6128-4ce8-b884-25d866b7a3ab)

Subtitle typography style for each app bar:

1.   Small: Label medium
2.   Medium flexible: Label large
3.   Large flexible: Title medium

link

Copy link Link copied

### Trailing icon buttons

Up to two icon buttons can be placed after the headline, aligned to the trailing edge of the app bar. Place most-used actions closest to the leading edge.

Avoid using these buttons to open a menu with more actions. If more actions are needed, place them in a toolbar Toolbars display frequently used actions relevant to the current page. [More on toolbars](https://m3.material.io/m3/pages/toolbars/overview) instead.

If changing the icon button color style to filled or tonal, only use one icon button.

![Image 26: 2 icons placed to right of headline, from most to least used.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnvbo80-26.png?alt=media&token=486aa96c-7657-4afe-9ef1-79af0f159f63)

Put the most used actions on the left and least used on the right

link

Copy link Link copied

Use filled icons when possible for the best visibility. Outlined icons can also be used, particularly for unselected toggle buttons Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/overview).

![Image 27: App bar with 2 filled icons, “save” and “download.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnvcdyc-27-Do.png?alt=media&token=cdca83fa-7075-404b-aa93-c226a2252ef5)

check Do
Use filled icons for clear, visible actions

![Image 28: App bar with 2 outlined icons, “save” and “download.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlnvcyu3-28-Caution.png?alt=media&token=bc0b91fe-454e-4dcc-ba4c-37c03fd1633c)

exclamation Caution
Outlined icons can be used as needed, or when using toggle buttons

link

Copy link Link copied

Adaptive design
---------------

link

Copy link Link copied

Adaptive design allows an interface to respond or change based on context, such as the user, device, and usage. [More on adaptive design](https://m3.material.io/m3/pages/adaptive-design1)

link

Copy link Link copied

### Resizing

The width of the app bar container responds to the view or device width.

It should always span 100% of the window width.

The app bar’s container responds to always fill the window width

link

Copy link Link copied

Resizing may cause actions at the trailing edge of the app bar to collapse into an overflow menu at smaller window sizes.

These actions become visible again at larger sizes.

Actions at the trailing edge collapse into an overflow menu

link

Copy link Link copied

The search container of the search app bar should fill 100% of the space between leading and trailing app bar elements until it reaches 312dp. Then, it should only grow further to fill 50% of that space.

link

Copy link Link copied

The search field adapts to the amount of space between other elements in the app bar

link

Copy link Link copied

### Presentation

The app bar automatically supports right-to-left (RTL) languages by aligning the layout of elements to the leading and trailing edges of the container.

This means that in RTL languages, the layout of the app bar is mirrored.

![Image 29: App bar in RTL with Hebrew text.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlp6doc5-32.png?alt=media&token=c3eed041-8305-4c9b-94de-18360f723822)

The app bar’s layout is mirrored for right-to-left (RTL) languages

link

Copy link Link copied

Behavior
--------

link

Copy link Link copied

### Scrolling

App bars should initially be the same color as the background, then fill with a contrasting color on scroll to provide visual separation from the background.

The app bar can remain on a page at all times, or can hide and reappear when scrolling.

Upon scrolling, an app bar container fills with contrasting color to create a visual separation

link

Copy link Link copied

To focus more on body content, consider setting the app bar container to be transparent on scroll. This allows the buttons to float above the content.

Make sure icon buttons have a container fill.

Consider using narrow-width icon buttons Icon buttons help people take minor actions with one tap. [More on icon buttons](https://m3.material.io/m3/pages/icon-buttons/overview) for actions, like **Back**, to reduce the amount of space they take up.

Upon scrolling, an app bar container remains transparent and actions inside become filled icon buttons

link

Copy link Link copied

Selecting the search bar should open the search view The search view is a full-screen modal often used to display a list of search results. It can also be opened by selecting a search icon. [More on search view](https://m3.material.io/m3/pages/search/overview) component.

When selected, a search app bar opens a search view

link

Copy link Link copied

When scrolled, **medium flexible** and **large flexible** app bars can transform into **small** app bars. They should remain small until the page is scrolled back to the top. Don’t transform app bars into a **search app bar**.

link

Copy link Link copied

The app bar can hide when scrolling up and reveal when scrolling down

Medium and large flexible app bars can use the compress effect to transform into small app bars when scrolled