Title: Toolbar

URL Source: http://m3.material.io/components/toolbars/specs

Markdown Content:
Toolbar
===============

[Skip to main content](https://m3.material.io/components/toolbars/specs#main_content)[search](https://m3.material.io/search.html)[material_design Home](https://m3.material.io/)[apps Get started](https://m3.material.io/get-started)[code Develop](https://m3.material.io/develop)[book Foundations](https://m3.material.io/foundations)[palette Styles](https://m3.material.io/styles)[add_circle Components](https://m3.material.io/components)[pages Blog](https://m3.material.io/blog)

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

Toolbars
========

Toolbars display frequently used actions relevant to the current page

Close

[info Overview](https://m3.material.io/components/toolbars/overview)[style Specs](https://m3.material.io/components/toolbars/specs)[design_services Guidelines](https://m3.material.io/components/toolbars/guidelines)[head_mounted_device XR](https://m3.material.io/components/toolbars/xr)[accessibility_new Accessibility](https://m3.material.io/components/toolbars/accessibility)

On this page

*   [Variants](https://m3.material.io/)
*   [Configurations](https://m3.material.io/)
*   [Tokens & specs](https://m3.material.io/)
*   [Anatomy](https://m3.material.io/)
*   [Color](https://m3.material.io/)
*   [Measurements](https://m3.material.io/)
*   [Bottom app bar (baseline)](https://m3.material.io/)

link

Copy link Link copied

Variants
--------

link

Copy link Link copied

![Image 1: 2 variants of toolbars.](https://lh3.googleusercontent.com/j7SkkZwP6mNfPUFrpFyRIcGSsfI3_5Kv8VI0whqh3B1cGJq3v0lx_xaG3wOnjjjRl6GIEV4EZATztyOcGm6n3BbHH6QXE4KMPnSmk1EmvGpm=w40)![Image 2: 2 variants of toolbars.](https://lh3.googleusercontent.com/j7SkkZwP6mNfPUFrpFyRIcGSsfI3_5Kv8VI0whqh3B1cGJq3v0lx_xaG3wOnjjjRl6GIEV4EZATztyOcGm6n3BbHH6QXE4KMPnSmk1EmvGpm=s0)

1.   Docked toolbar
2.   Floating toolbar

link

Copy link Link copied

### Baseline variant

link

Copy link Link copied

The baseline bottom app bar is no longer recommended. It should be replaced with the docked toolbar, which is very similar and more flexible.

link

Copy link Link copied

![Image 3: Baseline bottom app bar, which looks like the docked toolbar, but is not recommended.](https://lh3.googleusercontent.com/tIdFhkPyYLLkFb4gUvrKPLzfIPcmAx4al6ORcGUGmS8oukJMF7ZzittOV7r-Nxwq0V63i9VTRfaVICziXGg4J8hd5TKaoZaDr28KS-7jQkI=w40)![Image 4: Baseline bottom app bar, which looks like the docked toolbar, but is not recommended.](https://lh3.googleusercontent.com/tIdFhkPyYLLkFb4gUvrKPLzfIPcmAx4al6ORcGUGmS8oukJMF7ZzittOV7r-Nxwq0V63i9VTRfaVICziXGg4J8hd5TKaoZaDr28KS-7jQkI=s0)

1.   Bottom app bar (not recommended)

link

Copy link Link copied

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Docked toolbar | -- | Available |
| Floating toolbar | -- | Available |
| Bottom app bar | Available | Not recommended. Use **docked toolbar**. |

link

Copy link Link copied

star

Note:

Implementation differs per platform. On Jetpack Compose, the floating toolbar is a separate component from the docked toolbar and bottom app bar.

link

Copy link Link copied

Configurations
--------------

link

Copy link Link copied

![Image 5: Color configuration of toolbars.](https://lh3.googleusercontent.com/o4tXTZsCpct2GOpIk9NZcIqwhbbw1CLCMMGKI8rjcbmGoiECpJUHMaKtCGRJ_bL-ngPgBlo5zJAj0wdfLm7PRdk93iZI0BvB08Ull7JZB7SqoQ=w40)

1.   Standard and vibrant toolbars
2.   Vertical floating toolbar
3.   Floating toolbar with FAB

link

Copy link Link copied

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Color | Standard (default) | Available as bottom app bar | Available |
| Vibrant | -- | Available |
| Floating toolbar layout | Horizontal (default) | -- | Available |
| Vertical | -- | Available |
| Other elements | With FAB | Available as bottom app bar | Available* |

link

Copy link Link copied

star

Note:

*Implementation differs per platform. On Jetpack Compose, floating toolbar with FAB is [fully supported](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#HorizontalFloatingToolbar(kotlin.Boolean,androidx.compose.ui.Modifier,androidx.compose.material3.FloatingToolbarColors,androidx.compose.foundation.layout.PaddingValues,androidx.compose.material3.FloatingToolbarScrollBehavior,androidx.compose.ui.graphics.Shape,kotlin.Function1,kotlin.Function1,androidx.compose.ui.unit.Dp,androidx.compose.ui.unit.Dp,kotlin.Function1)). On other platforms, each component needs to be added separately.

link

Copy link Link copied

Tokens & specs
--------------

Browse the component elements, attributes, tokens, and their values. [Jump to baseline bottom app bar specs](https://m3.material.io/m3/pages/toolbars/specs#ad142675-3e3b-43b8-ba53-12c1f0b7138d)

link

Copy link Link copied

Close

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

![Image 6: 2 elements of a toolbar.](https://lh3.googleusercontent.com/q5KTYC5SjXAnSvSVvP72h2InKksCupfh4xqfQsa8eqO3ImcNxSiNEvyVzwrM54a_bgMyYUG2oOrljsquGFjeuEhoQ-lfYIhLhcYRjTURpOs0mQ=w40)

1.   Container
2.   Placed components

link

Copy link Link copied

### Flexibility & slots

link

Copy link Link copied

When configuring a toolbar, think of it as a container with several slots.

Each slot can be a different element. The most common elements are icon buttons When configuring a toolbar, think of it as a container with several slots. Each slot can be a different element. The most common elements are icon buttons, buttons, and text fields. [More on icon buttons](https://m3.material.io/m3/pages/icon-buttons/specs), buttons Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/specs), and text fields Text fields let users enter text into a UI. [More on text fields](https://m3.material.io/m3/pages/text-fields/overview).

![Image 7: A toolbar with 5 slots, conceptual spaces for UI elements, next to each other.](https://lh3.googleusercontent.com/U8tAffspM1NK0nWpYaxRxJHvPJOXWBX8GEuuEMeW6b-RjRo7OKtlMaYohHO-8Rn9QzwodfT_aJgLSocPQnHQDqhiMpfonWKsTd8XBUj-kKs=w40)

A toolbar is essentially a container with configurable slots

link

Copy link Link copied

Color
-----

link

Copy link Link copied

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. For implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/m3/pages/design-tokens/overview)

link

Copy link Link copied

### Standard

link

Copy link Link copied

![Image 8: 4 color roles in the standard color scheme  of the floating toolbar in light and dark scheme.](https://lh3.googleusercontent.com/vnb-hvZkhHov6Q_xpnqsRpE-v1-ahJAuOOAS49Uw7K1JgYNot331UJ_viioRQnCmG5c_kqdBCgTXYkFkIfdYmd2lUUnIiqJes4VaQa_i30dvYg=w40)

Standard color schemes and icon button types:

1.   Surface container
2.   Filled button (Primary, On primary)

3.   Toggle tonal button (Secondary container, On secondary container)
4.   Standard button (Primary)

link

Copy link Link copied

### Vibrant

link

Copy link Link copied

![Image 9: 4 color roles in the vibrant color scheme of the floating toolbar in light and dark scheme.](https://lh3.googleusercontent.com/MSHjbfagavP64_aZ8he_iw3phiUh6IkZDUjRhPkoMvHcSGsAh-0j3khoUTMDeaPdCVcRwhCp9XyMVOQuvKVvIDxcYcqgTe1tZ5YBzAxchYzx=w40)

Vibrant color scheme and icon button types:

1.   Primary container
2.   Filled button (Primary, On primary)
3.   Toggle tonal button: (Surface container, On surface)
4.   Standard button (On primary container)

link

Copy link Link copied

Measurements
------------

link

Copy link Link copied

By default all toolbars are 64dp high, center-aligned, have equal padding between items, and have a minimum outside padding of 16dp.

link

Copy link Link copied

### Docked toolbar

link

Copy link Link copied

![Image 10: Default internal padding of a docked toolbar.](https://lh3.googleusercontent.com/Eovie9hEPA5n7suVT8sw4C5TaWOwLmXIl0J3WBMBVOcBFDGyGqhwTTePHEyqXbPNsWb4kH1PH0QZ0llhRfnV9iozSM-bZFjevV4HNZio2qCD=w40)

1.   Default margins and padding
2.   Margins and padding with leading, middle, and trailing content

link

Copy link Link copied

![Image 11: 2 docked toolbars with different margins and alignment.](https://lh3.googleusercontent.com/Vsgw_yvIWA9pxAKEs4qmxtfhofUIoJnSXq6bO3_6v_OmMq4BZhQnS5FaT70GZEHJOzMm7DPuYd-ZUVsVtbJ1WuLqVCQ9khS6P6J8EMzlyOo=w40)

Alignment and padding can be configured to create unique layouts:

1.   Left and right alignment
2.   Center-aligned, 8dp padding between items

link

Copy link Link copied

### Floating toolbar

link

Copy link Link copied

![Image 12: Diagram noting margin around edge of floating toolbar.](https://lh3.googleusercontent.com/BmOWzjQZ3a-oyRtJT94Nez52vT0DHXNgDWueCiIVnteA35K89UKvwAP_gs8fdqn450QEN9oEnw_yWK0oIKbqEZ9xhqope0Jt4C0lM83X4pc3ng=w40)

Default padding of floating toolbar

link

Copy link Link copied

![Image 13: Diagram noting layout measurements.](https://lh3.googleusercontent.com/OStcy-GlT-NRB63inDLnhvNm3czBqigQcIhixAV3N7fMvikSrBtiJtNJc_r0m8yP6nyxDkzhLQnsxBdp_FG6qDARNyB0S52U-CDXNkkG89E=w40)

Floating toolbar size and padding measurements

link

Copy link Link copied

![Image 14: Diagram noting layout margins.](https://lh3.googleusercontent.com/l1zIH0wA5J3kRRwuwvmIpG4gmlFXXYK88L4lF0q5vQ0_ThjPiPwpPJk0mOT8zbMyO20rMum-TPkHfY651sPtrWzVPiiVl7MXQxtWq3IthryT=w40)

Floating toolbar margins

link

Copy link Link copied

* * *

Bottom app bar (baseline)
-------------------------

link

Copy link Link copied

![Image 15: Diagram of bottom app bar indicating the container.](https://lh3.googleusercontent.com/XW6h1Afu7o0EPJEU5KC5OEODx1r67sQMqU9pUmqzyOAPy1b_y8-pMDrw-GqoWeSbEXhBR7cA_qDpTDdG8qwlAYoSH0Vc9jh5lviGtvZ76pekyw=w40)

1.   Container

link

Copy link Link copied

### Tokens & specs

link

Copy link Link copied

Bottom app bar tokens are in one token set.

link

Copy link Link copied

Close

link

Copy link Link copied

### Color

link

Copy link Link copied

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/m3/pages/design-tokens/overview)

link

Copy link Link copied

![Image 16: Diagram of bottom app bar indicating its color mappings.](https://lh3.googleusercontent.com/RDMrnLfQpoptezvVbHosgCQV_qq-MEVY3hKWH4U1fo8wYZLg0Zv4Z1jqiQT1FxojqUYoCEZ8lekjZ3SYJe3-vuO50wNCzsNx7lBpp6iWgqN0rQ=w40)

Bottom app bar color role used for light and dark themes:

1.   Surface container

link

Copy link Link copied

### Measurements

link

Copy link Link copied

![Image 17: Diagram showing layout values and paddings for bottom app bar.](https://lh3.googleusercontent.com/42HaRTtyV44uEgw2rZzgGwWNqlOy1g0mCiaUjMy7iuiG2lAJ4ACu5xe9PEJgOfE2PFIJ_8TjIRqrk75Wc2YmtrtcrYklJzE3nSV8HbBbW7Y=w40)

Bottom app bar padding and size measurements

link

Copy link Link copied

### Common layouts

link

Copy link Link copied

![Image 18: Side by side view of bottom app bars in different configurations.](https://lh3.googleusercontent.com/JvPTixMCyejczwwssuEezKtZO-2y_RmCjTIrMEpHFu5HOAApXlYpEt-Pq3GV4Bd1LJQlgRd4O3PPpK7YpOkaQMUvEo3Sg2E1I8iLh56BNKvC=w40)

1.   Icon buttons and FAB
2.   Icon buttons and no FAB

[arrow_left_alt Previous Toolbars: Overview](https://m3.material.io/components/toolbars/overview)[Up next arrow_right_alt Toolbars: Guidelines](https://m3.material.io/components/toolbars/guidelines)

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
