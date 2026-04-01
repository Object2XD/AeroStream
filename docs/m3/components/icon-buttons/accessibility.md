Title: Icon buttons – Material Design 3

URL Source: http://m3.material.io/components/icon-buttons/accessibility

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
link

Copy link Link copied

Use cases
---------

link

Copy link Link copied

People should be able to do the following using assistive technology:

*   Understand meaning of the icon
*   Navigate to and activate an icon button
*   When applicable, a tooltip should be available to help describe the icon button's purpose

link

Copy link Link copied

Interaction & style
-------------------

link

Copy link Link copied

Ensure the icon has contrast of at least 3:1 with the surface or background.

![Image 1: Icon button with correct contrast ratio.](https://lh3.googleusercontent.com/sxEm_qQA7j39jtqbpiH6Lnec5G_ZIJs-b8cWfSYYldZIAEjGTT52yeEfaF8M1HLTZCe0_0zqKfBBPGW9s6i9C0qFg75AEtWXiQmEzv4VVEEozQ=s0)

check Do 
Icon buttons should have a 3:1 contrast ratio with the surface or background

![Image 2: Icon button with insufficient contrast ratio.](https://lh3.googleusercontent.com/FqCMh3l6_zJ396vQUK3U2--BcmNuXzVzQHPsd2a9kOXz6CjN4pE_mugSVMkSsZep6dHnnmhA-1_JIycaz0vxATA36JS_voTYg8Fc_zJDH_5f=s0)

close Don’t 
Avoid using colors with contrast below 3:1

link

Copy link Link copied

Keyboard navigation
-------------------

link

Copy link Link copied

| **Keys** | **Actions** |
| --- | --- |
| Tab | Focus lands on (non-disabled) icon button |
| Space or Enter | Activates the (non-disabled) icon button |

link

Copy link Link copied

Labeling elements
-----------------

link

Copy link Link copied

The accessibility label for icon buttons describes the action the button is executing, such as **Add to favorites**, **Bookmark**, or **Send message**.

![Image 3: Icon button label and role.](https://lh3.googleusercontent.com/Veran4xIuwOjaUK-TME0CkyE4D03sjgbC1O1fGyyeie01_pz6s0p7PoibSPSPzTNT7bmFKJy4kG40AnFtMviria4wR7kDBMlNQI6OuqqES8tBQ=w40)

![Image 4: Icon button label and role.](https://lh3.googleusercontent.com/Veran4xIuwOjaUK-TME0CkyE4D03sjgbC1O1fGyyeie01_pz6s0p7PoibSPSPzTNT7bmFKJy4kG40AnFtMviria4wR7kDBMlNQI6OuqqES8tBQ=s0)

The icon button label describes the action, such as Add to favorites for the heart icon

link

Copy link Link copied

Layout &density
---------------

link

Copy link Link copied

Groups of similar components can be nested together inside a component, or they can stand alone.

The target size of each icon button should be at least 48dp, even when nested.

![Image 5: Icon buttons with 48dp target sizes.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c1h7ba-4.png?alt=media&token=79849c70-99e3-4433-8616-05d06808a57b)

Icon buttons can be used within other components, such as an app bar

link

Copy link Link copied

### Avoid applying density by default

Don't apply density to icon buttons by default. This lowers their targets below the required 48x48 CSS pixels minimum size.

Provide density options that allow people to choose a higher density, such as selecting a denser layout or changing the theme. Controls for adjusting density must maintain a target size of at least 48x48 CSS pixels.

link

Copy link Link copied

Hover
-----

link

Copy link Link copied

On web, icon buttons should display a tooltip with an accessibility label.

![Image 6: “Heart” icon with "Add to favorites" tooltip on hover.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0c1j2b9-5.png?alt=media&token=244efcd1-5b55-496d-a4bb-9bc97593fbd9)

The tooltip label text should be clear and concise
