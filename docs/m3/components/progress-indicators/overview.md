Title: Progress indicators – Material Design 3

URL Source: http://m3.material.io/components/progress-indicators/overview

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Resources

Close

On this page

*   [Availability & resources](https://m3.material.io/)
*   [M3 Expressive update](https://m3.material.io/)
*   [Previous updates](https://m3.material.io/)
*   [Differences from M2](https://m3.material.io/)

link

Copy link Link copied

*   Two variants: linear and circular

*   Use the same configuration for all instances of a process (like loading)

*   They capture attention through motion

*   Option to apply a wave to the active track for use cases that would benefit from increased expressiveness

link

Copy link Link copied

![Image 1: 8 progress indicators configured to show different thickness and shape.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmleotj2q-01.png?alt=media&token=8d1f2405-86ed-4634-8847-af33a549410d)

Linear and circular progress indicators have visual configurations for shape and thickness

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
| [Jetpack Compose](https://developer.android.com/develop/ui/compose/components/progress) | Available |
| [Jetpack Compose: Expressive](https://developer.android.com/reference/kotlin/androidx/compose/material3/package-summary#LinearWavyProgressIndicator(androidx.compose.ui.Modifier,androidx.compose.ui.graphics.Color,androidx.compose.ui.graphics.Color,androidx.compose.ui.graphics.drawscope.Stroke,androidx.compose.ui.graphics.drawscope.Stroke,androidx.compose.ui.unit.Dp,kotlin.Float,androidx.compose.ui.unit.Dp,androidx.compose.ui.unit.Dp)) | Available |
| [MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/components/ProgressIndicator.md) | Available |
| [MDC-Android: Expressive](https://github.com/material-components/material-components-android/blob/master/docs/components/ProgressIndicator.md) | Available |
| [Web](https://github.com/material-components/material-web/blob/main/docs/components/progress.md) | Available |
| Web: Expressive | Unavailable |
Close

link

Copy link Link copied

M3 Expressive update
--------------------

link

Copy link Link copied

**Aug 2024**

The progress indicators have configurations for height and wavy shape. Choose the visual style that best fits your product. [More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

link

Copy link Link copied

*   Track height: Configurable
*   Shape: Wavy

Progress indicators have a new rounded, colorful style, and more configurations to choose from, including a wavy shape and variable track height

link

Copy link Link copied

Previous updates
----------------

link

Copy link Link copied

**Dec 2023: Non-text contrast (NTC)**

*   Anatomy: Added an end stop indicator to improve accessibility
*   Contrast: Higher contrast between track and active indicator to enhance the perception of progress
*   Motion: New motion behavior
*   Shape: Rounded corners

![Image 2: GM3 linear and circular progress indicators](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmleov4bo-03.png?alt=media&token=ec54810c-b325-4dd1-a547-b66d15d3b260)

Progress indicators have a new rounded, colorful style

link

Copy link Link copied

Differences from M2
-------------------

link

Copy link Link copied

**July 2022: Added to Material 3**

*   **Color:** New color mappings and compatibility with dynamic color

link

Copy link Link copied

![Image 3: M2 linear and circular progress indicators.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c2if7i-04.png?alt=media&token=2cccabb4-c40c-4db4-9321-51c34cae3d25)

M2: Progress indicators have a boxier, neutral style

![Image 4: M3 linear and circular progress indicators.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c2jf26-05.png?alt=media&token=2ee132f7-2c47-46e2-8826-910fbdfe4547)

M3: Progress indicators are compatible with dynamic color

[Previous Loading indicator: Overview](https://m3.material.io/components/loading-indicator)[Up next Progress indicators: Specs](https://m3.material.io/components/progress-indicators/specs)

vertical_align_top
