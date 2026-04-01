Title: Layout – Material Design 3

URL Source: http://m3.material.io/foundations/layout/understanding-layout/bidirectionality-rtl

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
link

Copy link Link copied

[Over 2 billion people](https://www.w3.org/International/questions/qa-scripts.en.html) read and write in right-to-left (RTL) languages like Arabic, Hebrew, Farsi and Urdu. Layouts should support both left-to-right (LTR) and RTL languages through mirroring and other best practices to ensure content is easy for global audiences to understand and navigate. Consider the holistic experience including [global writing](https://m3.material.io/m3/pages/global-writing/overview#0d0f8403-e5ff-4579-be74-0c4dbcef7fcb), localizing voice and [design principles for culturally appropriate icons](https://m3.material.io/m3/pages/icons/designing-icons#1056d971-81ca-4abe-b931-42185dd76638). Material's components are built to support RTL, such as naming elements and tokens as "leading" and "trailing." However, extra configuration may be needed to achieve specific RTL situations.

link

Copy link Link copied

Mirroring
---------

link

Copy link Link copied

When a layout is changed from LTR to RTL (or vice-versa), and flipped horizontally, it’s often called mirroring. UI elements and text that typically appear on the left in LTR aligns to the right. Reading flow starts from the top right corner, instead of the top left.

Not all elements mirror with RTL languages. For example, graphs and charts maintain a LTR directionality for Persian and Urdu.

![Image 1: Layout in LTR and mirrored for RTL language.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rr3ndk-1.png?alt=media&token=05901f6f-b35f-43a1-907c-fed9b464bfea)

A mirrored layout in an RTL language reverses the alignment and ordering of elements.

link

Copy link Link copied

Text rendering
--------------

link

Copy link Link copied

Correct text rendering is foundational for a great user experience and it’s critical for readability and usability. Text rendering has two parts:

1.   Alignment: How the edges of the text box are placed alongside other elements.
2.   Directionality: How text and other elements flow within a text box, like left-to-right, or right-to-left.

In RTL languages, text is usually right-aligned, and elements flow from right-to-left. Common issues with RTL language rendering are text entry, cursor position, punctuation, phone numbers, and URLs. Improperly rendering text in RTL languages can create cognitive overload and negatively impact user sentiment and trust.

![Image 2: Text field incorrectly displaying the word order of an email address and cursor placement.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rr60jz-2%20-%20A.png?alt=media&token=0187472e-4278-4a06-897a-612c671ce24e)

close Don’t 

Don't reverse the order of the email username and domain (@google.com). The domain should always be to the right of the username. Usernames can still be written RTL, with the cursor moving to the left.

Note this example is not translated to illustrate a common issue with text rendering

![Image 3: Dialog window incorrectly displaying word order decreasing readability.](https://lh3.googleusercontent.com/LF2lHKz-y2dHfC1eRLilwX8m2_AGCUvSt_bgVe-Qai7o129OK1nKLNHd1_1cdpjOO_YBM9wcGPce855LPc2eXl6IbUc2LhVGKvoF5RAZjEZm=w40)

![Image 4: Dialog window incorrectly displaying word order decreasing readability.](https://lh3.googleusercontent.com/LF2lHKz-y2dHfC1eRLilwX8m2_AGCUvSt_bgVe-Qai7o129OK1nKLNHd1_1cdpjOO_YBM9wcGPce855LPc2eXl6IbUc2LhVGKvoF5RAZjEZm=s0)

close Don’t 
Don’t apply LTR directionality to RTL content because it may scramble word order. To ensure readability across all languages. The content should have both RTL alignment and directionality.

Note this example is not translated to illustrate a common issue with text rendering

link

Copy link Link copied

Icons and symbols
-----------------

link

Copy link Link copied

In RTL languages, directional UI icons, like back and forward, should be mirrored. However, in Hebrew timelines and media controls on a page should retain left-to-right directionality.

The meaning of icons and symbols can vary significantly across cultures.

![Image 5: Back and forward icons in LTR and RTL.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rre3h2-3%20-%20A.png?alt=media&token=480dc1d4-5c16-4902-af1d-2218f293590e)

Back and foward icons are mirrored in RTL

![Image 6: Send and question mark in LTR and RTL.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rrfly7-3%20-%20B.png?alt=media&token=050695fe-3339-4996-afa5-1b2876660828)

Send buttons are mirrored in RTL. Help icons are mirrored in some RTL languages, like Urdu and Persian.

link

Copy link Link copied

Time
----

link

Copy link Link copied

Linear representations of time are often mirrored in RTL language experiences.

Linear progress indicators should move from right to left for most RTL languages, except Hebrew where it should remain LTR.

Circular representations of time remain the same.

![Image 7: RTL linear progress indicators filling from right to left  and circular progress indicators filling clockwise .](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rrip79-4.png?alt=media&token=c9e3ba41-c747-4bfb-b76a-70e3ae6258bd)

1.   RTL linear progress indicator starts to fill progress from the right
2.   Circular progress indicators move clockwise

link

Copy link Link copied

### Media players

Media controls for video or audio players are always LTR.

![Image 8: Media player with control and progress in LTR and all other content is RTL.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rt3wci-5_urdu.png?alt=media&token=a69ecb25-1698-4a55-9bd3-5d954c939b56)

In Urdu, controls and progress for media and a podcast title are shown in LTR, while all other content is RTL.

link

Copy link Link copied

### Clock

For RTL languages, the directionality of time remains LTR, and clocks still turn clockwise. However, the AM/PM symbols for 12h clocks should be placed to the left. The 24-hour clock is often used in countries where the primary language is not English.

Clock icons, circular refresh icons, and progress indicators with arrows pointing clockwise should not be mirrored.

![Image 9: 24 hour clock in RTL.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rt5hlh-6%20-%20A_hebrew.png?alt=media&token=b2ee3bb4-76e2-4337-8109-234dd7847476)

24-hour clocks in RTL move clockwise, but mirror elements such as buttons

![Image 10: 12 hour clock in RTL. ](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rt6mj7-3%20-%20B_arabic.png?alt=media&token=bcaabbc8-50d2-4baa-9b8e-799267cb02d9)

12-hour clocks in RTL move clockwise, but mirror UI elements such as AM/PM and buttons

link

Copy link Link copied

Canonical layout examples
-------------------------

link

Copy link Link copied

### List-detail

The [list-detail](https://m3.material.io/m3/pages/canonical-layouts/list-detail) layout divides the app window into two side-by-side panes, and is mirrored in RTL.

![Image 11: RTL list layout.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rt95z5-7_hebrew.png?alt=media&token=69d513fe-7989-4805-b65a-e3d6c9b39985)

List-detail mirrored for RTL, where text and other elements are aligned to the right and flow from right to left

link

Copy link Link copied

### Feed

Use a [feed layout](https://m3.material.io/m3/pages/canonical-layouts/feed) to arrange content elements like cards in a configurable grid for quick, convenient viewing of a large amount of content. The feed layout is mirrored in RTL.

![Image 12: RTL feed layout.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rtc29p-8.png?alt=media&token=c763352b-86e5-4455-a1ab-b84f51ab6841)

Feed layout mirrored for RTL, where the order of text, grid, and other elements align to the right and flow from right to left

link

Copy link Link copied

### Supporting pane

Use the [supporting pane](https://m3.material.io/m3/pages/canonical-layouts/supporting-pane) layout to organize app content into primary and secondary display areas. The supporting pane layout is mirrored in RTL.

![Image 13: RTL supporting pane in a RTL language.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rtekg5-9_urdu.png?alt=media&token=6b70a1dc-2d88-4d86-82c3-c03201df33a1)

Supporting pane to the left of the primary content. Text and other elements within the pane are aligned to the right and flow from right to left.

link

Copy link Link copied

Component examples
------------------

link

Copy link Link copied

### Badges

Change the position and alignment of [badges](https://m3.material.io/m3/pages/badges/specs) for RTL languages.

![Image 14: Small badge on the top left of the icon.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rtgvbk-10%20-%20A_urdu.png?alt=media&token=f90702ee-35c3-4470-b083-6d34d392e437)

Small badge appears on the top left of the icon

![Image 15: Large badge on the top left of the icon.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rtjdwz-10%20-%20B_urdu.png?alt=media&token=2833dd15-ab4f-4300-adf4-524f48a5fc9d)

Large badge appears on the top left of the icon

link

Copy link Link copied

### Toolbar

[Toolbars](https://m3.material.io/m3/pages/toolbars/guidelines) provide actions related to the current page. For RTL languages, mirror the order of the tools.

![Image 16: RTL floating toolbar](https://lh3.googleusercontent.com/vJXzgBPOhjldo7WY5RopuHczELv2Q6gFFOV9qfzbScgrdaaPlNe-tfWaDy1ExbeYJokecz57a9NcPlKJVJ-_Ax-4kUbCuKUbnPZXzwZYhd__Pw=w40)

Mirrored floating toolbar, where the FAB appears on the left of the screen

link

Copy link Link copied

### App bar

[App bars](https://m3.material.io/m3/pages/app-bars/overview) are placed at the top of the screen to help people navigate through a product.

Mirror app bar layout in RTL, and flip appropriate icons, such as arrows.

![Image 17: 3 app bars in RTL.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rtqm4b-12_urdu.png?alt=media&token=55e68798-60d9-46b5-ac42-c502f21a81a1)

1.   RTL center-aligned/small
2.   RTL medium flexible
3.   RTL large flexible

link

Copy link Link copied

### Navigation drawer

[Navigation drawers](https://m3.material.io/m3/pages/navigation-drawer) that open from the side are always placed on the leading edge of the screen, on the left for LTR languages, and on the right for RTL.

![Image 18: RTL navigation drawer, including a mirrored icons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rttjl0-13_arabic.png?alt=media&token=0316e66f-2626-4521-ba3a-abd21ce031e0)

RTL navigation drawer, including a mirrored icon for outbox

link

Copy link Link copied

### Navigation rail

The [navigation rail](https://m3.material.io/m3/pages/navigation-rail/guidelines) is placed on the leading edge of the screen, on the left side for LTR, and on the right for RTL.

![Image 19: Nav rail in the right side for RTL languages, and left side for LTR languages.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rtvteh-14_hebrew.png?alt=media&token=560c411f-1a34-43f6-90c5-6a9c7edbe837)

Based on the language being used, a navigation rail is set on a screen’s leading edge. This is the right side for RTL languages, and left side for LTR languages.

link

Copy link Link copied

### Text fields

Icons in [text fields](https://m3.material.io/m3/pages/text-fields/guidelines#5c8a5f07-b1a5-455f-bf76-7ff0d724f6b0) are optional. Leading and trailing icons change their position based on LTR or RTL contexts.

![Image 20: Text fields in RTL with leading and trailing icons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6rtykdl-15.png?alt=media&token=ae3edcc2-1c08-44dd-a767-7de671b9a584)

Icons, symbols and label text for RTL:

1.   Icon signifier
2.   Valid or error icon
3.   Clear icon
4.   Voice input icon
5.   Dropdown icon
6.   Image

link

Copy link Link copied

### Chips

The leading icon of input chips can be an icon, logo, or circular image.

The trailing icon is always aligned to the end side of the container. It’s placed on the right for LTR and on the left for RTL.

![Image 21: Filter chips in RTL layout.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm8rhslpk-16.png?alt=media&token=a7178733-70fc-4052-b74a-385de64cd9e4)

Filter chips shown in an RTL layout. Note this example is not translated to help illustrate mirroring.

link

Copy link Link copied

Swipe gestures
--------------

link

Copy link Link copied

Gestures are the ways people interact with UI elements using touch or body motion.

People can navigate horizontally between peer views like tabs, and to complete actions.

RTL swiping and gestures should mirror their counterparts in LTR. If an app includes a "delete" icon revealed when swiped from the right for LTR languages, the same should be possible on the left for RTL languages.

![Image 22: RTL list layout with swipe gesture revealing additional actions.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm6ru2ith-17.png?alt=media&token=fccfef3f-de43-402f-a1c6-7240f9e4e66b)

Swiping reveals additional action in RTL list layout

link

Copy link Link copied

On Android, [predictive back](https://github.com/material-components/material-components-android/blob/master/docs/foundations/PredictiveBack.md) allows people to swipe left or right on the screen to go back or dismiss modal components.

RTL predictive back features should mirror those found in a LTR context.

Preview of the result of the gesture for RTL languages
