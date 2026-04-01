Title: FAB menu

URL Source: http://m3.material.io/components/fab-menu/specs

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
link

Copy link Link copied

Variants
--------

link

Copy link Link copied

![Image 1: 1 FAB menu.](https://lh3.googleusercontent.com/aEJrDU0HXKoBxMGFWOq1I7O6QB2fl6EPJGEDSP0L7CVDgvAjMdaM_LX10txGb1GDquvp0R-IiszOHSY23xw1qRcCit1YcAxSgB4P3HKa4wGs=w40)

![Image 2: 1 FAB menu.](https://lh3.googleusercontent.com/aEJrDU0HXKoBxMGFWOq1I7O6QB2fl6EPJGEDSP0L7CVDgvAjMdaM_LX10txGb1GDquvp0R-IiszOHSY23xw1qRcCit1YcAxSgB4P3HKa4wGs=s0)

There’s one variant of FAB menu

link

Copy link Link copied

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| FAB menu | -- | Available |

link

Copy link Link copied

Configurations
--------------

link

Copy link Link copied

![Image 3: 3 color configurations of FAB menus.](https://lh3.googleusercontent.com/ysJ9Ea896_EYwed_YofScZMv_HuE8BH4IJVkWyw4v2Xw-KInaEtXmOyWaaQNTTAZw0oLB9neXbgOnHTv2rPWRCii81v_hwh0ZkDiyQp2seY=w40)

![Image 4: 3 color configurations of FAB menus.](https://lh3.googleusercontent.com/ysJ9Ea896_EYwed_YofScZMv_HuE8BH4IJVkWyw4v2Xw-KInaEtXmOyWaaQNTTAZw0oLB9neXbgOnHTv2rPWRCii81v_hwh0ZkDiyQp2seY=s0)

3 color sets:

1.   Primary
2.   Secondary
3.   Tertiary

link

Copy link Link copied

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Color | Primary set, secondary set, tertiary set | -- | Available |

link

Copy link Link copied

Tokens & specs
--------------

link

Copy link Link copied

Use the table's menu to switch token sets. The FAB menu has a common token set and six color sets, three for each element (close button and menu item). [Learn about design tokens](https://m3.material.io/m3/pages/design-tokens/overview/)

link

Copy link Link copied

Close

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

![Image 5: 2 elements of a FAB menu.](https://lh3.googleusercontent.com/CsC2u7L3QL6svcrFzmZM2foCzJxzUjF93lwZuZ-oJW7RK-lKsp4Ei0iNdLiNhbFST2y9U34PClKaRDJVJK8dT582gl98nYYhiCGKAwXNSKO6=w40)

1.   Close button
2.   Menu item

link

Copy link Link copied

![Image 6: 5 FAB menus showing the range of 2–6 items.](https://lh3.googleusercontent.com/KIWWfbv6JG0LIK8rzUSHcalH5BrNbW8_o8_U3uLqVkUDcdZNw4VS_nwoQ33DaomQXt95s6R_EY49aEQsWTQhxxDn2aYrDvU4ZSv4_arxasPc=w40)

The FAB menu can have up to six items

link

Copy link Link copied

Color
-----

Color values are implemented through design tokens. For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value. [Learn more about design tokens](https://m3.material.io/m3/pages/design-tokens/overview)

link

Copy link Link copied

![Image 7: 12 colors of the FAB menu.](https://lh3.googleusercontent.com/tZxH6WCjbJBIqPlpd4_nt_npacUlh9WWyrIqJWs6Z1BCdGKbGFPt_BaW0CrG9HHNVQzBFYxxGU4hYm8LnEeWldCP9dezTNn3BwRy0uvJR2FoEw=w40)

1.   On primary container
2.   Primary container
3.   On primary
4.   Primary
5.   On secondary container
6.   Secondary container
7.   On secondary
8.   Secondary
9.   On tertiary container
10.   Tertiary container
11.   On tertiary
12.   Tertiary

link

Copy link Link copied

link

Copy link Link copied

### Close button

link

Copy link Link copied

![Image 8: 4 states of the FAB menu close button.](https://lh3.googleusercontent.com/IBxWcDPavbWf55MsedxQZnCouJM3OZfbOudsfZQNrILcXhsyU_EI9iIEZ1UeKo-BwB7btsT0_0ZApQFHjZA4TOMjuOaY7TDtozX-qV09ssI=w40)

Close button states in light and dark theme:

1.   Enabled
2.   Hovered
3.   Focused
4.   Pressed

link

Copy link Link copied

### Menu item

link

Copy link Link copied

![Image 9: 4 states of the FAB menu items.](https://lh3.googleusercontent.com/GHST3WLAtYjpsKWjXfoTtSy1pybwjIFPYgrw1GBjynLRHHSxmZWT-t8VhnSMGbOvYWG0O65po5ceeOVrqt5KKtMzyxazm1PLFiTj4KMgg-CB=w40)

Menu item states in light and dark theme:

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

FAB menu items share the same measurements as the medium button Buttons let people take action and make choices with one tap. [More on buttons](https://m3.material.io/m3/pages/common-buttons/overview) specs.

The close button should always be 56dp.

![Image 10: FAB menu size measurements.](https://lh3.googleusercontent.com/6K5OibGh_d83LTRduhambKrHPD8JMVCHm19eHlen8e58fVWnoLyh8wWGZyLrdCPSO8Q3m01icndNcp7uuA0LLzeHzKWk60mGzGS3wrlB78o=w40)

FAB menu size measurements

link

Copy link Link copied

The FAB menu animates from the top trailing edge of the FAB to ensure a smooth animation.

![Image 11: FAB on a mobile screen with 16dp margins annotated.](https://lh3.googleusercontent.com/WhBYTHZseZ9EfjdiU3CqPLeEC36wFENc3fV_9h5eR9T5ze6ooQya6w3-f1JWj7bBOkJnQHFL3LpbcmG_N1zDZC9RT3dkok2EOHrbxNP5-rQ=w40)

The FAB should always have 16dp margins

![Image 12: FAB menu opened from a FAB has matching margins of 16dp.](https://lh3.googleusercontent.com/HWYLNxfsd_aBEZRMazrMRxUthRgVqeA8_evmV1IZrkKg878uq7DK0dg5EZaR8q7n-QP_kLrEaYALuBpmKtQjnBiVXhjfz_1-yYZw-CG0MTQ=w40)

The close button and FAB share the top trailing corner as an anchor and appear in the same place

link

Copy link Link copied

Larger FABs will place the FAB menu slightly higher, with larger margins underneath.

![Image 13: Medium FAB on a mobile screen with 16dp margins annotated.](https://lh3.googleusercontent.com/gce3Kgv0OcZSOCiWq672oYOzAE9YJhGCC0oGLAcdxJ59BPnVhlV3HdjJPyrHiJy1LgUNnQkTKyOc9d6e2N7EL7hyrzOoMq8kRrAZwtFYUDJz=w40)

The medium FAB placement has 16dp margins

![Image 14: FAB menu opened from the medium FAB has a 40dp margin from bottom of screen.](https://lh3.googleusercontent.com/kfovl3xRwL77xd7_XYJlFsLMybMdv16Nd0U9T5f87iZTyW3lo8gU72nkr81ZLumjSbxXIYnkvJX7ea84B8WmUtmukv4fhG1Wppp4IGnOgENn=w40)

The close button is placed higher to align with the top of the medium FAB

link

Copy link Link copied

![Image 15: Large FAB on a mobile screen with 16dp margins annotated.](https://lh3.googleusercontent.com/_9hh4PDq9vnfiJ2AAOX8VKeIFe9De47Av_acmKjjFbTkWQOGjZTLOqGY5cWqLsxkDLWjG4bgquVe81njJP9pL12nQlj_F7iNMl7KTugTGLWP=w40)

The large FAB placement has 16dp margins

![Image 16: FAB menu opened from the large FAB has a 56dp margin from bottom of screen.](https://lh3.googleusercontent.com/zGkr1v4xtHihId5hAGO-4ESfqwzsweXE2xqXba2w8m0zl9Hswn3RWimV53apAvslPo7y0G2yrUchBqCB8sR1_96IAzSaJyALM8gE8GshfO85=w40)

The close button is placed higher to align with the top of the large FAB

link

Copy link Link copied
