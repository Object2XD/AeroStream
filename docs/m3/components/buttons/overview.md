Title: Buttons – Material Design 3

URL Source: http://m3.material.io/components/buttons/overview

Markdown Content:
Buttons prompt most actions in a UI

Resources

Close

On this page

*   [Availability & resources](https://m3.material.io/)
*   [M3 Expressive update](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

*   Two variants: default and toggle

*   Can contain an optional leading icon

*   Five color options: elevated, filled, tonal, outlined, and text

*   Five size recommendations: extra small, small, medium, large, and extra large

*   Two shape options: round and square

*   Keep labels concise and use sentence case

link

Copy link Link copied

![Image 1: 5 variants of buttons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm5v1rzsx-1.png?alt=media&token=307f6d37-e5f3-4b47-8d02-691cbb79a328)

1.   Elevated button

2.   Filled button

3.   Filled tonal button

4.   Outlined button

5.   Text button

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
| [Flutter](https://api.flutter.dev/flutter/material/ThemeData/useMaterial3.html) | Available |
| [Jetpack Compose](https://developer.android.com/develop/ui/compose/components/button) | Available |
| [Jetpack Compose: Expressive](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#Button(kotlin.Function0,androidx.compose.ui.Modifier,kotlin.Boolean,androidx.compose.ui.graphics.Shape,androidx.compose.material3.ButtonColors,androidx.compose.material3.ButtonElevation,androidx.compose.foundation.BorderStroke,androidx.compose.foundation.layout.PaddingValues,androidx.compose.foundation.interaction.MutableInteractionSource,kotlin.Function1)) | Available |
| [MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/components/Button.md) | Available |
| [MDC-Android: Expressive](https://github.com/material-components/material-components-android/blob/master/docs/components/Button.md) | Available |
| [Web](https://github.com/material-components/material-web/blob/main/docs/components/button.md) | Available |
| Web: Expressive | Unavailable |
Close

link

Copy link Link copied

M3 Expressive update
--------------------

link

Copy link Link copied

**May 2025**

Buttons now have a wider variety of shapes and sizes, toggle functionality, and can change shape when selected.[More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

link

Copy link Link copied

Variants and naming:

*   Default and toggle (selection)

*   Color styles are now configurations. (elevated, filled, tonal, outlined, text)

Shapes:

*   Round and square

*   Shape morphs when pressed

*   Shape morphs when selected

Sizes:

*   Extra small

*   Small (existing, default)

*   Medium

*   Large

*   Extra large

New padding for **small** buttons:

*   16dp (recommended to match padding of new sizes)

*   24dp (not recommended)

![Image 2: 4 button changes in the expressive update.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm35yfd18-2.png?alt=media&token=2eab9629-ed61-4e7f-baab-05539529d0c3)

1.   Five sizes

2.   Toggle (selection)

3.   Two shapes

4.   Two small padding widths

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

*   Color: New color mappings and compatibility with dynamic color. Icons and labels now share the same color.Neutral text button is no longer recommended.

*   Icons: Standard size for leading and trailing icons is now 20dp

*   Shape: Fully-rounded corner radius and additional height options

link

Copy link Link copied

![Image 3: Rectangular M2 buttons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm5r6kn3n-2.png?alt=media&token=b7295c30-9c9d-44cf-80d2-a48f56668966)

M2: Buttons have a height of 36dp and slightly rounded corner radius

![Image 4: Round-cornered M3 buttons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm5r6n6xk-3-1p.png?alt=media&token=b30a4d13-9717-4af8-9f2d-fa83d864a0a9)

M3: Default buttons are taller at 40dp and have fully rounded corners
