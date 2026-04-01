Title: Button groups

URL Source: http://m3.material.io/components/button-groups/specs

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
link

Copy link Link copied

Variants
--------

link

Copy link Link copied

![Image 1: Various colors and shapes of standard and connected button groups.](https://lh3.googleusercontent.com/Zlys4Fta71zY-GAiCcT-oqug62NMk2muBeMcrPxVq_ZyoZhWxZrY5QlyYMHMI8wb6GSstakH8BmszYQQIEMg14U8WI6cX4v1uKZ_jSFIIYJGZA=s0)

1.   Standard button group
2.   Connected button group

link

Copy link Link copied

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| Standard button group | -- | Available |
| Connected button group | Available as segmented button Segmented buttons help people select options, switch views, or sort elements. Note: They're deprecated in the expressive update. Use a nav rail instead. [More on segmented buttons](https://m3.material.io/m3/pages/segmented-buttons/overview) | Available |

link

Copy link Link copied

Configurations
--------------

link

Copy link Link copied

![Image 2: Five sizes of button groups and two shapes of button groups.](https://lh3.googleusercontent.com/tXvGi5QNHXaEdYS0QIwTTJHGUdhlUv1s8dzEvt3yvdhs0CCvXGe3Y3bBOTJvHKv2VA3DPdHEWmLb9UAY_h5Gls6mTe6ihCadt0qIZbdLS7SY2g=w40)

![Image 3: Five sizes of button groups and two shapes of button groups.](https://lh3.googleusercontent.com/tXvGi5QNHXaEdYS0QIwTTJHGUdhlUv1s8dzEvt3yvdhs0CCvXGe3Y3bBOTJvHKv2VA3DPdHEWmLb9UAY_h5Gls6mTe6ihCadt0qIZbdLS7SY2g=s0)

Configurations for both variants of button groups:

1.   Extra small

2.   Small

3.   Medium

4.   Large

5.   Extra large

6.   Single-select and multi-select

7.   Round and square

link

Copy link Link copied

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Size | XS, S, M, L, XL | -- | Available |
| Default shape | Round, square | -- | Available |
| Selection | Single-select, multi-select, selection-required | Available as segmented button Segmented buttons help people select options, switch views, or sort elements. Note: They're deprecated in the expressive update. Use a nav rail instead. [More on segmented buttons](https://m3.material.io/m3/pages/segmented-buttons/overview) | Available |

link

Copy link Link copied

Tokens & specs
--------------

link

Copy link Link copied

link

Copy link Link copied

Button group xsmall container height

md.comp.button-group.standard.xsmall.container.height

32dp

Button group xsmall between space

md.comp.button-group.standard.xsmall.between-space

18dp

Close

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

Button groups are invisible containers that add padding between buttons and modify button shape. They don’t contain any buttons by default.

link

Copy link Link copied

![Image 4: The container outlined on both variants of button groups.](https://lh3.googleusercontent.com/909fUN1vEim33Fg-tzKVqEEl_EQRq_GsNWP9dPCSA181-jk63D2BmlLmh8pisBn2zBlyE581QGQUAggrzVLnD1e2dAv10jtBVs8_BMY5XsItOQ=w40)

1.   Container

link

Copy link Link copied

### Common layouts

Mix and match buttons and icon buttons for different scenarios.

link

Copy link Link copied

![Image 5: 4 common layouts of button groups.](https://lh3.googleusercontent.com/mB9JxUhRXlbUJhjAnZciD7yqHtJQpwyqJME-B-dTSOz6AQVQbdOHskFsAM7E60jDTOOPx9qjA7YiJt_46pxLrbnr8_wHmIAWBts0Nl1sd0IloA=w40)

1.   Label buttons
2.   Label buttons and icon buttons
3.   Extra small icon buttons
4.   Large icon buttons

link

Copy link Link copied

### Color

Button groups have no color properties. They can use the default button or toggle button color styles, like filled, tonal, and outlined. Avoid using standard icon buttons or text buttons, as they have no container treatment.

link

Copy link Link copied

![Image 6: The container outlined on both variants of button groups.](https://lh3.googleusercontent.com/9hbmv_ziBEblvbLNhjPIK994tZijzcHgGhHBn_z-e52FBeulOHrdGeVlk4y0G8YWkUVABgf5EvmfpWPJnsSxad4N_QjZ5bW-x3LJ4xRqO0s=w40)

1.   Filled

2.   Tonal

3.   Outlined

4.   Elevated

link

Copy link Link copied

Selection & activation
----------------------

link

Copy link Link copied

**Standard button groups** add interaction between adjacent buttons when a button is selected or activated.
This interaction changes the width, shape, and padding of the selected or activated button, which adjusts the width of buttons directly next to it.

A selected button changes shape, and briefly changes the width of itself and adjacent buttons

link

Copy link Link copied

**Connected button groups** don’t add any interaction between buttons when selected or activated.

They only affect the shape of the button being selected or activated.

A selected button changes shape without affecting adjacent buttons

link

Copy link Link copied

States
------

link

Copy link Link copied

### Standard button group

link

Copy link Link copied

When a button is pressed, standard button groups modify the width and shape of that button and adjacent buttons.

![Image 7: 5 states of a standard button group.](https://lh3.googleusercontent.com/aFlIDRoOBPpH_0juuRNNpzCDwdsk1sTKvaRtESfeqWWahAhThlrR5CwfDfGsxyVl6TstDE2D65kxcCX4I4W1LMxy2Xo72zCHihJFD8-_m5pmBQ=w40)

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

When a toggle button is selected in a standard button group, its shape should change between square and round. The color should change according to the[button specs](https://m3.material.io/m3/pages/common-buttons/specs).

![Image 8: 5 states of a standard button group with toggle buttons.](https://lh3.googleusercontent.com/81FApYiTXho8D7eyhKVzVF5qhIRk02bF6rEp6QoLXRtnuW94g2EoBt1EQLLK7h2vRiKsRbNHUyYa3OCvVQRVW3jGBVlkBqaiNrK6oiVZEIad1w=w40)

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

### Connected button group

link

Copy link Link copied

Connected button groups have different shape changes than standard button groups. Selecting a button does not affect adjacent buttons.

link

Copy link Link copied

![Image 9: 5 states of a segmented button group.](https://lh3.googleusercontent.com/zh7Dh6_ChlGUt5mWmhDpY_dTPHFXlFOmdfy2AJEpn013_utxmX5it3VZuG3iyveqk3N3Pj07dV4a2XtWhOkmn4FbvwvuPHUVa0YYRuTa6WJ3vw=w40)

Connected button group unselected states:

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

![Image 10: 4 states of a segmented button group with toggle buttons.](https://lh3.googleusercontent.com/N09iT9pfuy2j_ZfeAqJIUzPo31zdiKwWd0P-BH5eVSj3QR3JWxULGnjVnTbavy0VNZX5lhBc9Dyw1NTBThW5rbaOUcJ25kePIXmYaKTB0Ikx=w40)

Connected button group selected states:

1.   Enabled
2.   Hovered
3.   Focused
4.   Pressed

link

Copy link Link copied

Measurements
------------

link

Copy link Link copied

### Standard button group

link

Copy link Link copied

Standard groups apply padding between all buttons. The amount of padding changes based on button size to ensure a minimum accessible target size of 48dp. More details on padding:[Button specs](https://m3.material.io/m3/pages/common-buttons/specs),[icon button specs](https://m3.material.io/m3/pages/icon-buttons/specs)

link

Copy link Link copied

![Image 11: Standard button group padding measurements.](https://lh3.googleusercontent.com/RGY_WzbLD07B3K6DGITtC-0NcW5LQI1HS1L-g0O4Lt0wttv2BWMZQWR2LqpG39dzWUHBNqCx12noXUfNGg2PKUhJVJcW-ndLNWd0LJ-H8wVW=w40)

Standard button group inner padding:

1.   XS: 18dp
2.   S: 12dp
3.   M: 8dp
4.   L: 8dp
5.   XL: 8dp

link

Copy link Link copied

### Connected button group

link

Copy link Link copied

For all connected button groups, use 2dp padding. This provides visual consistency at scale.

link

Copy link Link copied

![Image 12: Connected button group padding and corner radius measurements.](https://lh3.googleusercontent.com/tyj4mLRYzA86JWOUFPOV0mFMQxD7ckw1kX2zjPh0iOs4KV_jy6SCEtBmeQASzBTE9ULLNl0NY_jT32BX76pcZDRzLsRJ4PQgdvoi0IfOyLs=w40)

Round connected button group inner padding is 2dp at every size. The outer shape is fully round, and the inner shape remains square with the following corner sizes:

1.   XS: 4dp
2.   S: 8dp
3.   M: 8dp
4.   L: 16dp
5.   XL: 20dp

link

Copy link Link copied

![Image 13: Connected button group padding and corner radius measurements for square buttons.](https://lh3.googleusercontent.com/DiysV2VqS8bJV3jH34XtaPeeGGi2Svo6ZIFJhmjAeYH0zOw7-6P-5qgZeRy2A6CoXA2mgQ0WMXanpp3k0FqLX7ez6AhGTGnztpRBRiqQzND0=w40)

Square connected button group inner padding is 2dp at every size. The outer shape has the following corner sizes:

1.   XS: 4dp
2.   S: 8dp
3.   M: 8dp
4.   L: 16dp
5.   XL: 20dp

link

Copy link Link copied

### Minimum widths

link

Copy link Link copied

Extra small and small connected button groups have 48dp target areas and a minimum width of 48dp.

link

Copy link Link copied

![Image 14: 48x48dp accessible target areas on the XS and S connected button groups.](https://lh3.googleusercontent.com/3YpaF7-0WXRLTv6vxHgKCSJBsLTOFIaTw5JZ5795oi7393Y_y8hlC-gNbJh57zwFbM8SJ6VsaQMH9dVZW3E6RTF2ZtysUXJaufAilOko_hZV=w40)

1.   Extra small
2.   Small

link

Copy link Link copied

Density
-------

Button groups adapt to density of the buttons inside. [More on density](https://m3.material.io/m3/pages/understanding-layout/density/)

![Image 15: Connected button groups at 0, -1, -2, and -3 density.](https://lh3.googleusercontent.com/yW6GJfPC6vob2O0uaXXiMDGwKXMv7majvHsxv9MEQGBjXCtZg0YERe27DGduNwB1ofpRLw4evKy_CZWsciavxwo6bvOHrDwnL_tjvUGXmB6t=w40)

Button groups adapt to the height of the buttons inside, including when density is applied
