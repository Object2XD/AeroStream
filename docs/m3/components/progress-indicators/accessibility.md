Title: Progress indicators – Material Design 3

URL Source: http://m3.material.io/components/progress-indicators/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Progress indicators – Material Design 3
===============

[Skip to main content](https://m3.material.io/components/progress-indicators/accessibility#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Progress indicators
===================

Resources flutter android+4

Close

[info Overview](https://m3.material.io/components/progress-indicators/overview)[style Specs](https://m3.material.io/components/progress-indicators/specs)[design_services Guidelines](https://m3.material.io/components/progress-indicators/guidelines)[accessibility_new Accessibility](https://m3.material.io/components/progress-indicators/accessibility)

On this page

*   [Use cases](https://m3.material.io/)
*   [Interaction& style](https://m3.material.io/)
*   [Labeling elements](https://m3.material.io/)

link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to do the following using the assistive technology:

*   Navigate to the progress indicator
*   Understand what progress the indicator is communicating

link

Copy link Link copied

Interaction& style
------------------

link

Copy link Link copied

The active indicator, which displays progress, provides visual contrast of at least 3:1 against most background colors.

![Image 1: Dark line of progress indicator stands out against the lighter colored track.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlepc1r2-01.png?alt=media&token=db30ced4-ea77-4efd-b2e1-369f42d4961c)

The progress indicator and stop indicator provide visual contrast of at least 3:1 against most background colors

link

Copy link Link copied

When integrated into another component, such as a button, make sure that the active indicator provides visual contrast of at least 3:1 against the other component.

For the active indicator, use the same color as the label text or icon. The track should be removed.

![Image 2: Circular indicator on button passes 3 to 1 contrast test.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlepcmau-02.png?alt=media&token=817a604f-513b-4d2b-bce8-576092f29233)

check Do 
Ensure the indicator’s color provides at least 3:1 contrast against the surface it's on

![Image 3: Circular indicator on button fails 3 to 1 contrast test.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlepd6dk-03.png?alt=media&token=28250ceb-a903-4145-9423-59a609cf5049)

close Don’t 
Avoid using a color below 3:1 contrast

link

Copy link Link copied

For linear progress indicators, the stop indicator is required if the track has a contrast below 3:1 with its container or the surface behind the container.

Essentially, the end of the track must be easy to identify.

![Image 4: Bright container holding the progress bar is on a dark surface, passing the 3:1 color contrast.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlepdozy-04.png?alt=media&token=5c4c02ed-76e6-41bb-9431-d215f1cec071)

check Do 
Only remove the stop indicator when the linear progress indicator has at least a 3:1 color contrast with surrounding containers and surfaces

![Image 5: Bright container holding progress indicator is on a bright surface, failing the 3:1 color contrast.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlepe18t-05.png?alt=media&token=58f9d951-ddc2-47c4-9ab8-3707bfac503d)

close Don’t 
Avoid removing the stop indicator if any adjacent containers or surfaces are below the 3:1 color contrast

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

Since the progress indicator is a visual cue, it needs an accessibility label to describe the kind and amount of progress made.

Use the **progress bar**accessibility role, and write an accessibility label that describes the purpose of the progress indicator. The label should include the process, such as "loading,” and the affected content, such as a page, article, or episode. For example: "Loading news article" or "Refreshing page."

![Image 6: Determinate linear progress indicator has an accessibility label of “loading news article” and role of “progressbar”.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlepereg-06.png?alt=media&token=71630831-8fa7-41a6-acb2-ae63c344ab9f)

Progress indicator labels should explain which items are loading

link

Copy link Link copied

![Image 7: Indeterminate linear progress indicator has an accessibility label of “loading my episodes” and role of “progressbar.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmlepf1vr-07.png?alt=media&token=31415e5b-41fb-4ebe-a455-8ebbc9f47abd)

A label on an intedeterminate progress indicator on a screen which is loading a set of podcast episodes

[arrow_left_alt Previous Progress indicators: Guidelines](https://m3.material.io/components/progress-indicators/guidelines)[Up next arrow_right_alt Menus: Overview](https://m3.material.io/components/menus)

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
