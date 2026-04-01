Title: Layout – Material Design 3

URL Source: http://m3.material.io/foundations/layout/understanding-layout/density

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Layout – Material Design 3
===============

[Skip to main content](https://m3.material.io/foundations/layout/understanding-layout/density#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

*   [Overview](https://m3.material.io/)
*   [Information density](https://m3.material.io/)
*   [Component scaling](https://m3.material.io/)
*   [Targets](https://m3.material.io/)
*   [Pixel density](https://m3.material.io/)

link

Copy link Link copied

Overview
--------

link

Copy link Link copied

*   Information density is the consideration of the amount of information visible on the screen
*   The default target size should be at least 48x48 CSS pixels
*   Users can change density as long as the density controls are accessible
*   Apply density thoughtfully; not every layout needs it
*   Layout and component scaling (component adaptation or component density) can allow users to scan, view, or compare more information at once

link

Copy link Link copied

pause

Information density

pause

Component scaling

link

Copy link Link copied

**Information density**

*   Information density can be achieved through layout and design decisions without using component scaling
*   Users may not benefit from increased density

**Component scaling**

*   Components can adapt and change dimensions to allow users to scan, view, or compare different amounts of information
*   Don't apply component scaling by default if it would result in a target below 48x48 CSS pixels

link

Copy link Link copied

pause

Information density and component scaling can be used together to provide more information and additional user control

link

Copy link Link copied

Information density
-------------------

link

Copy link Link copied

Information density refers to the amount of content (such as text, images, or videos) in a given screen space.

A layout’s spacing dimensions, including margins, spacers, and padding, can change to increase or decrease its information density. High density layouts can be useful when users need to scan, view, or compare a lot of information, such as in a data table. Increasing the layout density of lists, tables, and long forms makes more content available on-screen.

Consider density settings in the context of a device. Although a user may prefer a denser layout for desktop, they may not for mobile. Density shouldn’t automatically change across window-size classes or device orientation without users changing it.

![Image 1: High density layout](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzjckoeo-3.png?alt=media&token=1586220d-a76c-4bf0-b086-ac4b932144c2)

check Do 
Consider using higher density information design when users need to scan lots of information

link

Copy link Link copied

![Image 2: News website on desktop displaying a high information density. ](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzjcmxrs-4.png?alt=media&token=dc7bd078-f7d4-46e4-9685-d4a248f9b37b)

Consider the amount and priority of information on-screen. Higher density can be useful for data-rich sites (news, financial portals, dashboards) where users expect lots of information quickly.

![Image 3: News website on desktop displaying a low information density. ](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzjcnouc-5.png?alt=media&token=f05c1dff-6a12-4bb2-ba50-8ee6494a10b7)

Lower density can be better for sites prioritizing aesthetics, a focused message, less information, or easier navigation

link

Copy link Link copied

Component scaling
-----------------

link

Copy link Link copied

The component density scale controls the internal spacing of individual components.

The density scale is numbered, starting at 0 for a component’s default density. The scale moves to negative numbers (-1, -2, -3) as space decreases, creating higher density.

Higher density is typically applied by decreasing the top and bottom padding or overall height by 4dp.

![Image 4: Three buttons, with densities  of +1, 0, and -1.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzje0jnk-7.png?alt=media&token=3c357518-6c0a-4ca3-a637-e159430ff40f)

Buttons in 3 different densities. Apply button density based on the needs and layout of a design.

link

Copy link Link copied

Center the grouped element within the component container.

Text size shouldn’t change as the container size scales.

![Image 5: Stacked element showing 20 dp between label and input](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzje23wv-8.png?alt=media&token=886dc00f-73a5-485e-8bd7-2b6271c65482)

The measurement between the label and input is 20dp

![Image 6: Parent container showing label above input.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzje3e0s-9.png?alt=media&token=13938623-bd72-4399-b745-99f5a4e34c4e)

The label and input are centered within their parent container

link

Copy link Link copied

![Image 7: Dropdown menu selectable space  height of 36 dp](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzje4oe2-10-dont.png?alt=media&token=1e4ca720-f5d4-4657-b46e-95a328a8c983)

close Don’t 
Don’t increase density in UIs that involve focused tasks, such as selecting from a menu. It reduces usability by limiting selectable space.

![Image 8: Single-line snackbar](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzje5tgh-11-dont.png?alt=media&token=fa510b50-4502-4398-a69a-8bcba6cbeb7a)

close Don’t 
Don't increase the density in components that alert the user of changes, such as snackbars or dialogs

link

Copy link Link copied

### Avoid applying component scaling by default

link

Copy link Link copied

*   Don't apply component scaling to layouts by default that lower the target size below a default size of 48x48 CSS pixels
*   Allow users to opt for a higher density layout or theme, and provide a simple, accessible way to revert to default best practices

link

Copy link Link copied

People should be able to **opt****in** to dense layouts and components.

To ensure that density settings can be easily reverted, targets in settings interactions must follow defaults (48x48 CSS pixels).

![Image 9: A density menu with large, medium, and small options to customize the screen layout of a table on desktop. ](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzje9ukn-12a.png?alt=media&token=a179a73f-0d78-4809-ac1d-b1cc696d9901)

link

Copy link Link copied

Targets
-------

link

Copy link Link copied

Dense components can be less accessible because interactive elements are smaller, so use caution when increasing information density.

![Image 10: Selectable target of only 40 dp](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzjqo90o-13-caution.png?alt=media&token=6f36346e-923d-4b40-9453-764afeaaf502)

exclamation Caution 
Use caution when applying component scaling where selectable targets will be reduced to less than the 48x48dp best practice and only apply density where it provides a better user experience.

link

Copy link Link copied

Use caution when applying density to interaction targets. Following best practices, accessible targets should retain a minimum of 48x48dp, even if their visual element (such as an icon) is smaller.

![Image 11: Settings button is 24 by 24 dp, but has interaction target of 48 x 48 dp.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzk8ysbx-15.png?alt=media&token=51c7c9b4-9426-4e91-93b9-3c22e90ab6bf)

The target should remain 48x48, even if the icon is smaller.

![Image 12: Button with height of 36 dp and interaction target of 48 dp](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzjqrzlp-15.png?alt=media&token=b7dcf871-268a-403f-825b-09dc0c9e6ae1)

The interaction target of a common button can be larger, as long as it meets the 48x48dp minimum size.

link

Copy link Link copied

Pixel density
-------------

link

Copy link Link copied

The number of pixels that fit into an inch is referred to as pixel density. High-density screens have more pixels per inch than low-density ones. As a result, UI elements of the same pixel dimensions appear larger on low-density screens, and smaller on high-density screens.

To calculate pixel density:

Screen density = Screen width (or height) in pixels / Screen width (or height) in inches

![Image 13: Magnified UI element  showing a high number pixels in the focus area](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzjquwp8-16.png?alt=media&token=1f84c301-af60-49ea-a158-aa8ff21bf1cc)

A high-density ui element

![Image 14: Magnified UI element  showing the low number of pixels in the focus area ](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzjqw7id-17.png?alt=media&token=5b626bbc-0279-4d3a-ad2b-d44931cc552a)

A low-density UI element

link

Copy link Link copied

### Density-independent pixels

Density-independent pixels, written as dp, are flexible units that scale to have uniform dimensions on any screen. They provide a flexible way to accommodate a design across devices. Material design system uses density-independent pixels to display elements consistently on screens with different densities.

A dp is equal to one physical pixel on a screen with a density of 160.

To calculate dp: dp = (width in pixels * 160) / screen density

![Image 15: Screen with grid representing  low number of pixels](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzjqylun-18.png?alt=media&token=0d6a5447-b65e-4bfc-bc2e-0d155c09cea1)

Low-density screen displayed with density independence

![Image 16: Screen with grid representing  high number of pixels](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flzjr0140-19.png?alt=media&token=ef52565c-7aef-4004-8bec-078cb24cbb93)

High-density screen displayed with density independence

link

Copy link Link copied

| Screen physical width | Screen density | Screen width in pixels | Screen width in dps |
| --- | --- | --- | --- |
| 1.5 in | 120 | 180 px | 240 dp |
| 1.5 in | 160 | 240 px |
| 1.5 in | 240 | 360 px |

[arrow_left_alt Previous Layout basics: Parts of layout](https://m3.material.io/foundations/layout/understanding-layout/parts-of-layout)[Up next arrow_right_alt Layout basics: Hardware considerations](https://m3.material.io/foundations/layout/understanding-layout/hardware-considerations)

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
