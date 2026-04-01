Title: Typography – Material Design 3

URL Source: http://m3.material.io/styles/typography

Markdown Content:
link

Copy link Link copied

*   M3 type scale has 30 type styles: 15 baseline and 15 emphasized
*   Use variable fonts for more control over expression in editorial treatments
*   Use Material tokens to easily define font, line height, size, tracking, weight, and more

link

Copy link Link copied

![Image 1: Type at different scales.](https://lh3.googleusercontent.com/Ow6KY2aDdXx4z-a13GYltf1azIa1Z7_G14M0uTeS0FODRiM87ScDy0_7hf5FPWHi3K2FhNto9ddP94U7DQ6SxWXOODeYz2gmfdaiz1amwgc=w40)

![Image 2: Type at different scales.](https://lh3.googleusercontent.com/Ow6KY2aDdXx4z-a13GYltf1azIa1Z7_G14M0uTeS0FODRiM87ScDy0_7hf5FPWHi3K2FhNto9ddP94U7DQ6SxWXOODeYz2gmfdaiz1amwgc=s0)

link

Copy link Link copied

Availability & resources
------------------------

link

Copy link Link copied

This shows where the type scale is available and implemented into Material components.

link

Copy link Link copied

| Type | Link | Status |
| --- | --- | --- |
| Design | [Design Kit](http://goo.gle/m3-design-kit) | Available |
| [Google Fonts](https://fonts.google.com/) | Available |
| Implementation | [Flutter](https://api.flutter.dev/flutter/material/Typography/Typography.material2021.html) | Available |
| [Jetpack Compose](https://developer.android.com/develop/ui/compose/designsystems/material3#typography) | Available |
| [Jetpack Compose: Expressive](https://developer.android.com/reference/kotlin/androidx/compose/material3/Typography) | Available |
| [MDC-Android](https://github.com/material-components/material-components-android/blob/master/docs/theming/Typography.md) | Available |
| [MDC-Android: Expressive](https://github.com/material-components/material-components-android/blob/master/docs/theming/Typography.md) | Available |
| [Web](https://github.com/material-components/material-web/blob/main/docs/theming/typography.md) | Available |
| Web: Expressive | Unavailable |

link

Copy link Link copied

M3 Expressive update
--------------------

link

Copy link Link copied

**May 2025**

### Updated M3 type scale with emphasized styles

Material’s type scale includes fifteen **baseline** type styles, the same as before, and fifteen new **emphasized** type styles.

The emphasized type styles add more expression to highlighted moments.

Roboto Flex can be used on its own to show a range of emotional states, but is not yet part of the M3 typescale.

[More on how to use emphasized styles](https://m3.material.io/m3/pages/typography/type-scale-tokens#0020d4d9-4f5b-4666-b3ce-c26db849bd73)

[More on M3 Expressive](https://m3.material.io/blog/building-with-m3-expressive)

![Image 3: Type scale showing roles for “display”, “headline,” “title,” “label,” and “body.”](https://lh3.googleusercontent.com/H7HQemhAdElVd6cCDlOyh0FhU3h8iD8kugnlLUFn1ScP8us3nqj1FslGURTVbbimZIHOCkIrjq5jOek3D3ixq8KMwNug0qPwL0lTzv_IgSFFjQ=w40)

The expressive type scale includes fifteen baseline type styles and fifteen emphasized type styles

link

Copy link Link copied

### Emphasized type style tokens

Design tokens offer an improved way to define typography in products by assigning an element's type style by a configurable value, rather than a set value.

Emphasized tokens allow for clearer hierarchies and prioritized components within a layout.

Type roles describe size—such as small, medium, and large—enabling them to adapt and respond to the device or context.

![Image 4: Close crop of markdown text showing type scales referenced as “display-large” and “display-large-emphasized.”](https://lh3.googleusercontent.com/FtpfhAnHzRkv9v64Ec7o6iT9LCg4Jz4rj6beaUd0tsyefFzccM8XPfIk8KUC3sKxmzAo86-JF6bqX9KbIDd9hKgLJssWwzkR_qv84q6XKLtGww=w40)

Typography tokens describe scalable size that adapts to devices or settings, including updating the style on boldness

link

Copy link Link copied

Previous updates
----------------

link

Copy link Link copied

### Variable fonts

**Roboto Flex, Roboto Serif, & Roboto Mono**

Updated considerations for using variable fonts and different combinations of their customizable axes An axis refers to an attribute of a font, such as weight or width, that can be altered to create visual variations. [Learn more about variable fonts](https://fonts.google.com/knowledge/introducing_type/introducing_variable_fonts), including grade, width, weight, slant, and optical size.

![Image 5: Roboto Flex, Roboto Mono, and Roboto Serif type rendered in different weights.](https://lh3.googleusercontent.com/we3vYf_MjDkGtTCWCHtjyBnTR8ZxGvmuFuINerK11qOETI1nPgsP4BGjVzHed9z-fxsd3CrRow9ZZZ_yiNszFXJ28JMSJXxiHB2dHLoJVeT84g=w40)

Roboto Flex, Roboto Serif, and Roboto Mono have a fluid range of axes, like weight, across all optical sizes

link

Copy link Link copied

### Style roles

Type styles are defined by five roles: display, headline, title, body, and label.

These names are more descriptive, allowing for easier matching of type style to use case.

![Image 6: Different examples of Roboto scaled to their respective roles: display, headline, title, body, and label.](https://lh3.googleusercontent.com/1ln7XGlJMAaZg3R5bogSK2Zon8ogE5VFdjtWg8khP2lcT9mS6Vf7zocKBH0gFLcSYCeAPhxsTK0QibKMM8dJpFD7E13YaNMv-JrAO42Gt59I=w40)

M3 has five distinct type styles: display, headline, title, body, and label
