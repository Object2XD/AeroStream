Title: FAB – Material Design 3

URL Source: http://m3.material.io/components/floating-action-button/specs

Markdown Content:
link

Copy link Link copied

Variants
--------

link

Copy link Link copied

![Image 1: An icon on the container of a FAB, medium FAB, and large FAB.](https://lh3.googleusercontent.com/CdTXXgPJ5XavoUEXtTKTczb0ENYt1VwreirVIJMyIYnwI6gFCYn1S4LCQyptGlF6EzKq9xL2hzPOQKv2RdKrhf6kTIj5vkcNY2u-VuQRqghs=w40)

![Image 2: An icon on the container of a FAB, medium FAB, and large FAB.](https://lh3.googleusercontent.com/CdTXXgPJ5XavoUEXtTKTczb0ENYt1VwreirVIJMyIYnwI6gFCYn1S4LCQyptGlF6EzKq9xL2hzPOQKv2RdKrhf6kTIj5vkcNY2u-VuQRqghs=s0)

1.   FAB
2.   Medium FAB
3.   Large FAB

link

Copy link Link copied

link

Copy link Link copied

![Image 3: An icon on the container of a small FAB.](https://lh3.googleusercontent.com/LVMfvx2rKsoVM1_1Pq9CQ8o0dDyfSQtfCxYgle_57GhDKX0oDkNepZr0yvyqmoI6mL-0QfWWfFkmVJV5RwLbJVGJ4YGXZBTcT9JW2-IPRQNpVg=w40)

![Image 4: An icon on the container of a small FAB.](https://lh3.googleusercontent.com/LVMfvx2rKsoVM1_1Pq9CQ8o0dDyfSQtfCxYgle_57GhDKX0oDkNepZr0yvyqmoI6mL-0QfWWfFkmVJV5RwLbJVGJ4YGXZBTcT9JW2-IPRQNpVg=s0)

1. Small FAB

link

Copy link Link copied

| Variant | M3 | M3 Expressive |
| --- | --- | --- |
| FAB | Available | Available |
| Medium FAB | -- | Available |
| Large FAB | Available | Available |
| Small FAB | Available | Not recommended. Use a larger size. |

link

Copy link Link copied

Configurations
--------------

link

Copy link Link copied

In the expressive update, the **primary**, **secondary**, and **tertiary** set colors were renamed to **primary container**, **secondary container**, and **tertiary container**to match the actual color roles used. New primary, secondary, and tertiary color styles were created to match the corresponding color roles. [View details in the color styles section](https://m3.material.io/m3/pages/fab/specs#67e71ec7-b520-405a-aa06-2decfa0b92a3)

link

Copy link Link copied

| Category | Configuration | M3 | M3 Expressive |
| --- | --- | --- | --- |
| Color | Primary container, secondary container, tertiary container | Available as primary, secondary, tertiary | Available |
| Primary. secondary, tertiary | -- | Available |

link

Copy link Link copied

link

Copy link Link copied

Close

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

![Image 5: 2 elements of the FAB.](https://lh3.googleusercontent.com/ANFTHcXuJZA9FSSl3I315pOU3UzwgUh_BZgfudPuvatQY4tLh2hREtb6ESAQZulQZBDe8iHcqQ548uZe2aJd2UGGv-8q2XXCBeGLdERRlXs=w40)

1. Container

2. Icon

link

Copy link Link copied

Color
-----

Color values are implemented through design tokens. For design, this means working with color values that correspond with tokens. In implementation, a color value will be a token that references a value.[Learn more about design tokens](https://m3.material.io/m3/pages/design-tokens)

link

Copy link Link copied

### Color styles

FABs can use several combinations of **color** and **on-color** styles, such as **primary** and **on-primary**. The following color mappings provide the same legibility and functionality, so the color mapping you use depends on style alone.

link

Copy link Link copied

![Image 6: 6 FAB color styles in light and dark themes. Each style has 2 color roles, 1 for the container and icon.](https://lh3.googleusercontent.com/ZwUAoGfKU_nKPy45dUL885gk5_UbUfDoN2lY0oreRhS7vnkY12iBhnT3a1Fm1LydwMZVkqFYkQhYjVbGHx_hHsPwlmEm2KWwSQ75kOOKSkCsEA=w40)

1.   Primary container & On primary container (default)
2.   Secondary container & On secondary container
3.   Tertiary container & On tertiary container
4.   Primary & On primary
5.   Secondary & On secondary
6.   Tertiary & On tertiary

link

Copy link Link copied

### Baseline color styles

link

Copy link Link copied

Surface FAB color styles are still available, but no longer recommended.

link

Copy link Link copied

![Image 7: Baseline FAB style in all 3 sizes.](https://lh3.googleusercontent.com/Yt-382N_6b_TEqwyVAFZY_PG3zCmejVTFm6-tfbkUGpTqwgeECy2CNFH8n0bV1Spc6qU-ruc9l-Qja0_LpTeeYatxSxOi7qyzjF5tSeeXuEU=w40)

1.   Surface FABs

link

Copy link Link copied

States
------

States are visual representations used to communicate the status of a component or interactive element.
When using a non-default color mapping for FABs, make sure the state layer color is the same as the icon color. For example, the state layer color for the **primary** color style should be md.sys.color.primary.

link

Copy link Link copied

![Image 8: 4 states of a FAB shown in light and dark themes.](https://lh3.googleusercontent.com/zCVGIf6lxv-ExBpOFiRo9G2yv-hIzjqPkEG0HKniNMzlBuWcEI8tXSvAndc3RL7Q0OOG56i6xP36k1rP1E-Fz92l4TGPZlkzdbNCF67rj2M=w40)

1.   Enabled
2.   Hovered (8% state layer) - elevation 4
3.   Focused (10% state layer)
4.   Pressed (10% state layer)

link

Copy link Link copied

Measurements
------------

link

Copy link Link copied

### FAB

link

Copy link Link copied

![Image 9: FAB size measurements.](https://lh3.googleusercontent.com/bY4SJyZCamFkqUakHco1-HsHBRJ55wn7zAWPhJCBlE9W4aA7wFnRywl8NSl_e7oToqU6JODtUnjeguVn7BJd5irT8DYnHQmq1lQKEvgN3g3Q=w40)

FAB size measurements

![Image 10: FAB padding measurements.](https://lh3.googleusercontent.com/beevX-JBo5BT5oaSR6WnfIvvspxwDFUOsGg0TBWuDEAgjCYevFNjOhNnz6om1Pbxkal9dwoBR5HwAeyyn7LB8z1N-NrDjH_F9ZcxN_lEL60=w40)

FAB padding measurements

link

Copy link Link copied

### Medium FAB

link

Copy link Link copied

![Image 11: Medium FAB size measurements.](https://lh3.googleusercontent.com/l-yip97Leh5bLumalSFuxS1DEMG6p3xJlXkUCTioixjvr0uXlzTaKK85zQzLnZPpgD9E72Zajd1yO9VMW1FKpSUVCWXbP5XIxIz6dUiubWALJw=w40)

Medium FAB size measurements

![Image 12: Medium FAB padding measurements.](https://lh3.googleusercontent.com/qQZXXxZh9x9LRJyZI_2tblBDG7aMd-Rx3HQVX-ssihAGa-xSIGuOA2FZNPKeHgfbI-q19SD0IIUCT-xnLHk4Q-P2KSb-KnSm95tRPJQs2rKx=w40)

Medium FAB padding measurements

link

Copy link Link copied

### Large FAB

link

Copy link Link copied

![Image 13: Large FAB size measurements.](https://lh3.googleusercontent.com/_1q2AqUdfZfCbC9aKRbQaXHO48GA5OSdH6ywXyyosvlIznXjrr0Wx-WM9xomavwT1qj6RA42qG01crP9I7GQPJ92BWnvJqijQ01UxjQKKcgS=w40)

Large FAB size measurements

![Image 14: Large FAB padding measurements.](https://lh3.googleusercontent.com/PsH6GvakYnsKOw9X05rxaShBXItlCIc3qS-LGjmdITmzFgAnhxdiyhzUEM34i8B0MGtZoBoDdXE7eA1hYAFqcWEqFyipPBdhE0TirWp_HMWxTA=w40)

Large FAB padding measurements

link

Copy link Link copied

Baseline tokens & specs
-----------------------

link

Copy link Link copied

Use the table's menu to select a token set. This only includes baseline tokens, including small and surface FABs. It doesn't include large or regular FABs, since those are still currently used.

link

Copy link Link copied

Close
