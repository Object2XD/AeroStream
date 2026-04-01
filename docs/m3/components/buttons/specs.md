Title: Buttons – Material Design 3

URL Source: http://m3.material.io/components/buttons/specs

Markdown Content:
link

Copy link Link copied

Variants
--------

link

Copy link Link copied

![Image 1: Diagram comparing buttons with toggle buttons.](https://lh3.googleusercontent.com/aL3DQi0w3IY7RrzOTfarwNqsX5XCPMiDGzkIUr6qHdwOoAxu9_jKKtj826ErTjT1VMuT-0jcXnFDfwyW8FPHchPEr6YmTreDMSFhFLPBQrmK=w40)

![Image 2: Diagram comparing buttons with toggle buttons.](https://lh3.googleusercontent.com/aL3DQi0w3IY7RrzOTfarwNqsX5XCPMiDGzkIUr6qHdwOoAxu9_jKKtj826ErTjT1VMuT-0jcXnFDfwyW8FPHchPEr6YmTreDMSFhFLPBQrmK=s0)

1.   Default button

2.   Toggle button

link

Copy link Link copied

| Variants | M3 | M3 Expressive |
| --- | --- | --- |
| Default | Available | Available |
| Toggle (selection) | -- | Available |

link

Copy link Link copied

Configurations
--------------

link

Copy link Link copied

![Image 3: Diagram showing configurations of buttons.](https://lh3.googleusercontent.com/bdblUB_QVH5kKnklBiiVlf9Dfthpn80V_W4WBfItgmm5y17ft7FXqpZIh7xultL_P7Qi9eLP9QDmfekSnWOWZGTlCpPt9EyzYlKwoNjf4w5R=w40)

![Image 4: Diagram showing configurations of buttons.](https://lh3.googleusercontent.com/bdblUB_QVH5kKnklBiiVlf9Dfthpn80V_W4WBfItgmm5y17ft7FXqpZIh7xultL_P7Qi9eLP9QDmfekSnWOWZGTlCpPt9EyzYlKwoNjf4w5R=s0)

1.   Size

2.   Shape

3.   Color

4.   Small button padding

link

Copy link Link copied

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Size | Small (default) | Available | Available |
| XS, M, L, XL | -- | Available |
| Shape | Round (default) | Available | Available |
| Square | -- | Available |
| Color | Elevated, filled (default), tonal, outlined, standard | Available | Available |
| Small button padding | 24dp | Available | Not recommended. Use 16dp |
| 16dp | -- | Available |

link

Copy link Link copied

Tokens & specs
--------------

Use the table's menu to select a token set. Button token sets are separated into common tokens, color, and size. [View baseline tokens](https://m3.material.io/m3/pages/common-buttons/specs#c305d304-a6c0-466a-a48c-8d0718a29ae2)

link

Copy link Link copied

Close

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

![Image 5: Diagram labeling 3 parts of a button.](https://lh3.googleusercontent.com/vVI1dXiEpkfp0fUhsnQ_pO8UcdtvWvVpAyQ3kZpslYAkObypS1kuGDoJ3fDcVd0Uat8A5xTrAjiCDeHw8gkVIHaPsnG2mWBCYxgEM5MMwGJf=w40)

1.   Container

2.   Label text

3.   Icon (optional)

link

Copy link Link copied

Color
-----

link

Copy link Link copied

Color values are implemented through design tokens Design tokens are the building blocks of all UI elements. The same tokens are used in designs, tools, and code. [More on tokens](https://m3.material.io/m3/pages/design-tokens/overview). For designers, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value.

*   There are five built-in button color styles: elevated, filled, tonal, outlined, and text

*   The default and toggle buttons use different colors

*   Toggle buttons don’t use the text style

link

Copy link Link copied

link

Copy link Link copied

![Image 6: Diagram shows dark and light color schemes for buttons.](https://lh3.googleusercontent.com/WJ93jt7Wo2SqAeoEl3Igtaiz31qt6PDJAQEGgQja7iigSR7TutQCkN32h0YzKOnaEC1ilgJGYjFj1i7vVX3gCVvEMuQk4MM2coEuiNbyezs=w40)

A. Elevated, B. Filled, C. Tonal, D. Outlined, E. Text

1.   Default

2.   Toggle: unselected

3.   Toggle: selected

link

Copy link Link copied

|  | 1. Default | 2. Toggle unselected | 3. Toggle selected |
| --- | --- | --- | --- |
| Elevated container Elevated icon & label | Surface container low Primary | Surface container low Primary | Primary On primary |
| Filled container Filled icon & label | Primary On primary | Surface container On surface variant | Primary On primary |
| Tonal container Tonal icon & label | Secondary container On secondary container | Secondary container On secondary container | Secondary On secondary |
| Outlined container Outlined icon & label | Outline variant (outline) On surface variant | Outline variant (outline) On surface variant | Inverse surface Inverse on surface |
| Text icon & label | Primary | -- | -- |

link

Copy link Link copied

States
------

link

Copy link Link copied

States States show the interaction status of a component or UI element. [More on states](https://m3.material.io/m3/pages/interaction-states/overview) are visual representations used to communicate the status of a component or interactive element.

link

Copy link Link copied

### Elevated button states

The elevated button style has an elevation of 1 by default and has no elevation when disabled.

link

Copy link Link copied

#### Default

link

Copy link Link copied

![Image 7: Elevated button states.](https://lh3.googleusercontent.com/k3KL_ghDviZ5fS2RvT0syvaePH29s86o5P0jE8LI6lFibKmdKnksaSN6lu2V-l-M_oJwnYgUklArsWfgnJIM7LdR1_hvcQNhpuawRaWpdyle=w40)

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

#### Toggle

link

Copy link Link copied

![Image 8: Toggle elevated button states.](https://lh3.googleusercontent.com/rvb5iQsP5fQ4x1Y8XXPVRYiQbpR96rc7TZ2L4jh6g2vUGhJ-eAAvhRCUg73TULYZhpDX9Px86LJ9SoLOOSlxfOwdvEfd51BXbsnXlNaHRKWi=w40)

A. Unselected, B. Selected

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

### Filled button states

link

Copy link Link copied

#### Default

link

Copy link Link copied

![Image 9: Filled button states.](https://lh3.googleusercontent.com/gyZ9rwGehmJUfgjq-BCWsP_HDS721DJTGFdkiiG-WQg79ySqKFUDQhwu0kz6s5AkAafWrc3cwbk5gAm8VJm0EP-fzi5Ji4RpDnUoEtFRFf4=w40)

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

#### Toggle

link

Copy link Link copied

![Image 10: Toggle filled button states.](https://lh3.googleusercontent.com/k-czt2XcdxC4BDdPtCvt06Ha0RJq7m2EzilHni13-eY0lalc8OYzyvurYhUJ5s_5CfyrBwN5Jq7407y7Kkii0OWHnaukL8O--VnF2DhY14eU=w40)

A. Unselected, B. Selected

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

### Tonal button states

link

Copy link Link copied

#### Default

link

Copy link Link copied

![Image 11: Tonal button states.](https://lh3.googleusercontent.com/--GyrKMzdXH697yW1JYJRU-29ZFA3rvrAoqb6E3i9Snc2JMMI-SZ8a6L9j8JA6Du-RMFzvIDO0y_ZV6LrlUBd5MRRJYy8o1Dy4vVYgT-hXQ=w40)

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

#### Toggle

link

Copy link Link copied

![Image 12: Toggle tonal button states.](https://lh3.googleusercontent.com/e2DkdnVIGe1kG0D1p9Jn0xNsBw15SNvPdAiduO3-Ignc7KICFjLA-Ecxy2n6o5IPtirv5oE_X0jMlcyd8MPwMcgsIzwAVRhEDyrkFThjoTU=w40)

A. Unselected, B. Selected

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

### Outlined button states

link

Copy link Link copied

The outlined button’s container fill is invisible at rest, but the opacity and state layers behave the same as other button styles when disabled, hovered, focused, or pressed.

link

Copy link Link copied

#### Default

link

Copy link Link copied

![Image 13: Outlined button states.](https://lh3.googleusercontent.com/mhc3SPkZyACY5TjcwGaGEvNSoZvVkdpfjf-l2-7sxbvUDROahw5M_g7P093GkOoimGqn34YEnLKVBMDAYCzc7W69UhQq6Jsm9sCQok2QxjfW=w40)

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

#### Toggle

link

Copy link Link copied

![Image 14: Toggle outlined button states.](https://lh3.googleusercontent.com/P6KyONzwpVV9sjgYN7ZdyOD4FoLpsdgaZp7j12m6Ya6-pV7IZniIHo_3mStHAzR-lHwvMqqx8-fwYkq3-3AI3KrlaPXr9k1iXVdeRE_ltjI5Hg=w40)

A. Unselected, B. Selected

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

### Text button style states

link

Copy link Link copied

The text button’s container is invisible at rest, but the opacity and state layers behave the same as other button styles when disabled, hovered, focused, or pressed. There is no toggle text button.

link

Copy link Link copied

![Image 15: Default text button style states.](https://lh3.googleusercontent.com/5SpJ9rRuJK-SMCI1434wzYB_RTXJ5wL_7IeY56p_NWxt5qEO_JSqFlaP1Isnd_8iUaThQDu_rdxS9K68fLvpK0hHZng_MfnLdTa1iBULlOV9=w40)

1.   Enabled
2.   Disabled
3.   Hovered
4.   Focused
5.   Pressed

link

Copy link Link copied

Shape morph
-----------

link

Copy link Link copied

### Pressed state

When pressed, buttons can morph to become more square. Both round and square buttons should have the same pressed shape.

The corner radius value differs for each button size. [See full button corner measurements](https://m3.material.io/m3/pages/common-buttons/specs#b1f39738-6f3a-409b-8f08-4cab6d78d756)

![Image 16: Shape changes of a button.](https://lh3.googleusercontent.com/8nBepkxLTh2-LZw41C57R3sB05HRK8eEhtPonnW84nLHJbq5RvM3hSQbRfeay0TYvDy2Zae4pn3s0PU3UVv8p4JZWoe3nduJScdjQwF1QCkUSw=w40)

A. Round button, B. Square button

1.   Enabled
2.   Hovered
3.   Pressed

link

Copy link Link copied

### When selected

In addition to changing shape when pressed, toggle buttons also change the resting shape from round (unselected) to square (selected).

If the resting unselected shape is square, the selected shape should be round.

![Image 17: Shape changes of a toggle button.](https://lh3.googleusercontent.com/_z5_ibNlIkEfNkcYLDj5UZ_UaH0EVzPp8OsyUDDLfHt9UQ9yS6PVp1ZjzslD85Gi4uUJdOLJYDJYBFtU7-jd-k5s4QXnINc4nuet00zk_iQ=w40)

A. Round button, B. Square button

1.   Enabled

2.   Hovered

3.   Pressed

4.   Selected

link

Copy link Link copied

Measurements
------------

link

Copy link Link copied

![Image 18: Diagram of measurements of all button sizes.](https://lh3.googleusercontent.com/U1HSZvJ64XZAVoKDD7c_aNskPPvKMw7T4dqs4dwruzlFAhdqAaS33FaIwqq5Gt_ba4S5kGnI0x-fmtZcL5rcT4vz0gOPi0TPra9yWf1P2mjd6Q=w40)

Padding and size measurements of each button size

1.   Extra small

2.   Small

3.   Medium

4.   Large

5.   Extra large

link

Copy link Link copied

### Target areas

link

Copy link Link copied

Extra small and small icon buttons must have a target size of 48x48dp or larger to be accessible.

![Image 19: Diagram of small button target areas.](https://lh3.googleusercontent.com/Kasep-SEdWUyUggfzteERh09ncJmgDUhHXT8siwlktcqKqL74LA66SSYlsR9uhuVcvbV7_DMoFknDNKAhP_n8ujKpAc522mekCDAaWMkVYUz-A=w40)

A. Extra small B. Small

1.   Round button
2.   Button with icon
3.   Square button

link

Copy link Link copied

### Corner sizes

link

Copy link Link copied

link

Copy link Link copied

|  | XS | S | M | L | XL |
| --- | --- | --- | --- | --- | --- |
| A. Round button | Full | Full | Full | Full | Full |
| B. Square button | 12dp | 12dp | 16dp | 28dp | 28dp |
| C. Pressed state | 8dp | 8dp | 12dp | 16dp | 16dp |

link

Copy link Link copied

Baseline tokens
---------------

link

Copy link Link copied

Use the table's menu to switch token sets. The baseline button token sets are deprecated, and organized by color.

link

Copy link Link copied

Close
