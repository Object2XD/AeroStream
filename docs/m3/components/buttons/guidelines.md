Title: Buttons – Material Design 3

URL Source: http://m3.material.io/components/buttons/guidelines

Markdown Content:
Buttons prompt most actions in a UI

Close

On this page

*   [Usage](https://m3.material.io/)
*   [Toggle buttons](https://m3.material.io/)
*   [Anatomy](https://m3.material.io/)
*   [Color styles](https://m3.material.io/)
*   [Adaptive design](https://m3.material.io/)

link

Copy link Link copied

![Image 1: Buttons in various shapes and sizes.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gjevop-1.png?alt=media&token=bc9f68db-d7d1-4ed9-bb58-6d9b443f6998)

Buttons and icon buttons come in many shapes, styles, and sizes

link

Copy link Link copied

Usage
-----

link

Copy link Link copied

Buttons communicate actions that people can take. They are typically placed throughout the UI, in places like:

*   Dialogs Dialogs provide important prompts in a user flow. [More on dialogs](https://m3.material.io/m3/pages/dialogs/overview)

*   Modal windows
*   Forms
*   Cards Cards display content and actions about a single subject [More on cards](https://m3.material.io/m3/pages/cards/overview)
*   Toolbars Toolbars display frequently used actions relevant to the current page [More on toolbars](https://m3.material.io/m3/pages/tooltips/overview)

They can also be placed within standard button groups Standard button groups add interactions between adjacent buttons when they're pressed. [More on button groups](https://m3.material.io/m3/pages/button-groups/overview).

Use visually-prominent filled buttons for the most important actions

link

Copy link Link copied

Buttons are just one option for representing actions in a product and shouldn’t be overused. Too many buttons on a screen can disrupt the visual hierarchy.

Consider placing additional actions in a navigation rail Navigation rails let people switch between UI views on mid-sized devices [More on navigation rail](https://m3.material.io/m3/pages/navigation-rail/overview), set of chips Chips help people enter information, make selections, filter content, or trigger actions. [More on chips](https://m3.material.io/m3/pages/chips/overview), text links, or icon buttons Icon buttons help people take minor actions with one tap. [More on icon buttons](https://m3.material.io/m3/pages/icon-buttons/overview).

![Image 2: 1 button placed on bottom right of screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gjl9h3-3.png?alt=media&token=089a7158-a011-4852-bbc1-a608dcba04d7)

check Do 
Use buttons for discrete actions

![Image 3: 3 buttons set side by side on bottom of screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gjm7we-4.png?alt=media&token=3c4c7650-83c0-4de0-aa00-84646b12bb0a)

close Don’t 
Don’t clutter your UI with too many buttons. Consider presenting low-priority actions in overflow menus or as icon buttons.

link

Copy link Link copied

![Image 4: Filled button on menu screen.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gjnyrv-5.png?alt=media&token=024e3271-e607-4718-ae8e-93e08d20cca1)

check Do 
A button container’s width is dynamically set to fit its label text

![Image 5: Filled button as wide as layout grid.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gjovh5-7.png?alt=media&token=32769a41-d8ed-43b2-a934-ef07a3f42ea2)

check Do 
Button container width can be responsive, which allows it to stretch horizontally

![Image 6: Filled button with label text overflowing the container. ](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gjpmov-6.png?alt=media&token=5e07ed7b-3d72-480d-aefd-e964adac3024)

close Don’t 
A button container’s width shouldn’t be narrower than its label text

link

Copy link Link copied

![Image 7: Diagram of button styles and toggle behaviors.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gjromg-8.png?alt=media&token=568873b8-70ad-4f00-95a0-91f0f11f5ccc)

There are five button styles, in order of emphasis:

1.   Elevated button

2.   Filled button

3.   Filled tonal button

4.   Outlined button
5.   Text button

Buttons have default and toggle behaviors:

A. Default button

B. Toggle (unselected)

C. Toggle (selected)

link

Copy link Link copied

A button group Button groups organize buttons and add interactions between them. [More on button groups](https://m3.material.io/m3/pages/button-groups/overview) is a collection of buttons that relate to each other and can respond to one another. Both buttons and icon buttons can be used inside a button group.

In some cases, there are primary and secondary actions within a button group. Buttons with primary actions should have a higher visual emphasis through size, color, or shape.

[More on button groups](https://m3.material.io/m3/pages/button-groups/overview)

![Image 8: Audio app with play, next, and back buttons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm3t81e1q-9.png?alt=media&token=e2b715eb-67a4-43b8-91c6-9636566aa8e5)

Different sized buttons in a button group help emphasize the main action from secondary actions

link

Copy link Link copied

Toggle buttons
--------------

link

Copy link Link copied

Toggle buttons should be used for binary selections, such as **Save** or **Favorite**. When toggle buttons are pressed, they can change color, shape, and labels.

Toggle buttons should use an outlined icon when unselected, and a filled version of the icon when selected. If a filled version doesn’t exist, increase the weight instead.

By default, toggle buttons change from round to square when selected.

Use toggle buttons for binary actions

link

Copy link Link copied

If the label changes on selected or unselected states, be mindful of the character count. Changing the label significantly is disruptive to the user and the page layout.

![Image 9: Toggleable “start” and “reset” buttons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm5xpelfc-40.png?alt=media&token=76b5fdbf-51a4-4bf7-a7fa-18a8344c5223)

check Do 
When using toggleable buttons, keep the label character count a similar length for both states

![Image 10: Toggleable “start” and “reset back to beginning” buttons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm5xpfhkc-41.png?alt=media&token=70674385-cf93-4d45-8f25-f41c7550f2e0)

close Don’t 
The label length shouldn’t change dramatically to be longer or shorter

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

![Image 11: 3 parts of a button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gjxqph-10.png?alt=media&token=bc755cbb-a219-477d-a91d-b3ce2c5a1434)

1.   Label text
2.   Container
3.   Icon (optional)

link

Copy link Link copied

### Label text

Label text is the most important element of a button. It describes the action that will occur if someone taps a button. It should be very brief, ideally 1–3 words.

Use sentence case, which only capitalizes the first word and proper nouns. This allows the text to distinguish proper nouns, for example: **Book with Flights**, not **BOOK WITH FLIGHTS**.

Don’t truncate or wrap label text. It should always be fully visible on a single line.

![Image 12: Button with label text “See all recipes.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gk8677-11.png?alt=media&token=d2f72e60-bab0-4a59-94d4-f1efeef061ce)

check Do 
Use sentence case for button label text, capitalizing the first word and proper nouns

![Image 13: Button with wrapped label.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gk8se0-12.png?alt=media&token=0c5de78d-eddc-4689-a877-64dde564a592)

close Don’t 
Don’t wrap text. For maximum legibility, label text should remain on a single line.

link

Copy link Link copied

Buttons with the **outlined** and **text** color style depend on the colors to be recognizable from other text and elements. Use caution when putting these buttons next to visually similar elements, such as chips or large text.

![Image 14: Chips next to an outlined button, highlighting their similarities.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gkb7by-13.png?alt=media&token=df8f8d15-6611-4468-a602-6729ae041553)

exclamation Caution 
The outlined button style is very similar to chips. Consider using a filled or tonal button instead.

link

Copy link Link copied

### Container

Button containers hold the label text and optional icon. Buttons with the **text** color style have a visible container only when hovered, focused, or pressed.

Buttons with a round shape have containers with fully rounded corners.

![Image 15: Round button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gkdq21-14.png?alt=media&token=0e9f70da-da9b-4bad-bfd2-f18734eae074)

Round buttons have containers with fully rounded corners

link

Copy link Link copied

Square buttons have containers with more subtle rounding that changes based on button size.

![Image 16: Square buttons with different radii.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gksq9w-15.png?alt=media&token=a66161dd-6f69-44db-97ec-8a6cfeed0192)

Square button have square containers and change radius as the button size changes

link

Copy link Link copied

![Image 17: Button with the label text “Edit playlist” within the container.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gkuacg-16.png?alt=media&token=212c260e-0c11-465b-91c6-dd6be48b5ad6)

check Do 
A button’s width dynamically adjusts to the label text

![Image 18: Button with text larger than its container.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gkv1ay-17.png?alt=media&token=3ea9e4e3-a13f-4541-a358-ad28c22b8b1b)

close Don’t 
Avoid setting a fixed width smaller than the label text

link

Copy link Link copied

### Icon (optional)

Icons visually communicate the button’s action and help draw attention. They should be placed on the leading side of the button, before the label text.

![Image 19: Filled button with the icon to the left of the label in a left-to-right language.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gky6ia-18.png?alt=media&token=5c0ec87d-81e5-4295-b113-51672dab7734)

check Do 
Place the icon to the left of the label in buttons with text in left-to-right languages

![Image 20: Filled button with the icon to the right of the label in a right-to-left language.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gkyyny-19.png?alt=media&token=51e26964-7305-4dce-afa5-0b541dad4cd9)

check Do 
Place the icon to the right of the label in buttons with text in right-to-left languages

link

Copy link Link copied

![Image 21: Button with shopping cart icon and text label “Add to cart”.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gl0vn9-20.png?alt=media&token=616419d9-b098-4c01-8d5c-b25b932e01d9)

check Do 
Use icons that clearly communicate their meaning

![Image 22: Button with Plus icon vertically above the text label “Add to watch list”.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gl28ks-21.png?alt=media&token=2407e30c-2180-459a-a2a2-0e071810ab22)

close Don’t 
Don’t vertically align an icon and text in the center of a button

![Image 23: Button with two icons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gl3vbi-23.png?alt=media&token=3c2472a5-a4c1-443f-a2bf-24bc4d68a692)

close Don’t 
Don’t use two icons in the same button

link

Copy link Link copied

Color styles
------------

link

Copy link Link copied

### Elevated style

link

Copy link Link copied

The **elevated** button style is the same as the tonal button, but with a shadow.

To avoid overusing shadows, use the elevated style only when absolutely necessary, such as when the button requires visual separation from a visually prominent background.

![Image 24: Elevated button on a scrim background.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gm51od-24.png?alt=media&token=af14e4f0-a5a6-4b07-bc2b-0bf30523a412)

Elevated buttons provide separation from a visually prominent background

link

Copy link Link copied

Buttons at higher elevations typically have more emphasis in a design, and should be used sparingly. For high emphasis, consider the filled style instead.

![Image 25: Elevated button in a shopping experience.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmah4jer3-25.png?alt=media&token=6bb135a0-9d8e-43dd-b7a9-6b4a83fd6bb9)

exclamation Caution 
Higher elevation increases the emphasis of a button

link

Copy link Link copied

### Filled style

link

Copy link Link copied

The **filled** button style has the most visual impact after the FAB Floating action buttons (FABs) help people take primary actions. [More on FABs](https://m3.material.io/m3/pages/fab/overview), and should be used for important, final actions that complete a flow, like **Save**, **Join now**, or **Confirm**.

![Image 26: Filled button reading “Make payment.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gleigh-26.png?alt=media&token=f6c42433-0e5d-4d96-b76e-58abe238f037)

Filled buttons have high visual impact when used for important actions

link

Copy link Link copied

Since they have such strong emphasis, the filled style should be used sparingly, ideally for only one action on a page.

In some cases, filled buttons can use tertiary colors.

![Image 27: Filled “pause” button in a music app.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmah4doid-27.png?alt=media&token=53a41e3c-5173-4493-8549-676680214b84)

Filled buttons can be responsive to the layout grid and help emphasize main actions

link

Copy link Link copied

### Tonal style

link

Copy link Link copied

The **tonal** button style is useful in contexts where a lower-priority button requires slightly more emphasis than an outline would give, such as **Next** in an onboarding flow. Tonal buttons use the secondary color mapping.

![Image 28: Shopping app with 2 tonal-style filled buttons.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmah4i06x-28.png?alt=media&token=282186b4-5cc1-42f7-a452-e67bb4045219)

The tonal style has less emphasis than filled or emphasis

link

Copy link Link copied

### Outlined style

link

Copy link Link copied

The **outlined** style is ideal for medium-emphasis buttons which contain actions that are important, but aren’t the primary action in a product.

Outlined buttons pair well with filled buttons to indicate alternative, secondary actions.

![Image 29: Outlined buttons for less important actions, including a back button and a button that reads “Next movie.”](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0glqjfo-29.png?alt=media&token=6a2bcb89-a879-4618-98b2-f132ed77fe44)

Outlined buttons contain less important supporting actions

link

Copy link Link copied

Outlined buttons display a stroke around the button container, and have no fill by default.
They should be placed on simple backgrounds, not visually prominent backgrounds such as images or videos.

![Image 30: Outlined button for “add to cart” in shopping app.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmah4la12-30.png?alt=media&token=3125469c-37e9-499e-aa27-2c4271d62ac1)

Outlined buttons display a stroke around the button container

link

Copy link Link copied

![Image 31: Outlined button labeled Add to calendar on a pink/purple background.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmah4nkn4-31.png?alt=media&token=1ade5dd3-9e53-426c-8b31-0c01e54f8454)

check Do 
Outlined buttons can be used on backgrounds with a color gradient

![Image 32: 2 photos, each with an outlined button with a custom fill.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fmah4nyin-33.png?alt=media&token=6e65c32c-ed73-419c-9d9d-3ea352a2ceb5)

exclamation Caution 
Use caution when placing outlined buttons on top of images. Customizing the button to have a contrasting container fill can help ensure legibility of label text. Or, use a filled button instead.

link

Copy link Link copied

### Text style

link

Copy link Link copied

The text button style should be used for the lowest priority actions, especially when presenting multiple options.

They should be placed on simple backgrounds, not visually prominent backgrounds such as images or videos. The container isn’t visible until someone interacts with the button.

Don’t underline the text button. Use hyperlinked body text instead to emphasize links. [More on hyperlinks](https://m3.material.io/m3/pages/typography/applying-type#24856f70-f759-45df-a06c-92018f286083)

![Image 33: Example calendar screen with 2 text buttons and 1 split button.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gm6pw1-34.png?alt=media&token=c46e7804-81f6-4ec3-a3d8-d8d19faed11b)

Use text buttons for the lowest priority actions

link

Copy link Link copied

Text buttons are often placed within components such as cards Cards display content and actions about a single subject. [More on cards](https://m3.material.io/m3/pages/cards/overview), dialogs Dialogs provide important prompts in a user flow. [More on dialogs](https://m3.material.io/m3/pages/dialogs/overview), and snackbars Snackbars show short updates about app processes at the bottom of the screen. [More on snackbars](https://m3.material.io/m3/pages/snackbar/overview). Since text buttons don’t have a visible container in their default state States show the interaction status of a component or UI element. [More on states](https://m3.material.io/m3/pages/interaction-states/overview), they don’t distract from nearby content.

However, since there’s no container, the label text color must always be recognizable from non-button text and elements.

![Image 34:  Text button labeled “Retry” in a snackbar.](https://lh3.googleusercontent.com/H36_SqjFfm4TS18z76cMTxMxIcg13xZ3eU6NI0yINuEomwQg4nT6Cm4VyJzI18WY1GjuwDJ1eOb2PIo5WY-HytGnJ3ST8utqjPz7KDPy8A=w40)

Text button in a snackbar

![Image 35: Text button labeled “View album” on an album cover background.](https://lh3.googleusercontent.com/X87REmjcVSL1zhGYVxWM17HfYYmx1viKw2trkix5gpytY-uQkrtsTzdlJCtb3H7kLliyFR7S5DUkXUZKmAWDVWmo9KRCfpdpnV7f5UtE9eV_=w40)

Text button against an image background

link

Copy link Link copied

In cards, text buttons help maintain an emphasis on card content.

![Image 36: Text button labeled “Learn more” in an information card about sourdough bread.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwp1tvqz-33.png?alt=media&token=15f63d9f-e6a2-430d-bf26-f469a627f359)

Text button in a card

link

Copy link Link copied

Dialogs use text buttons because the absence of a container helps unify the action with the dialog text.

Align text buttons to the trailing edge of dialogs, on the right for left-to-right languages and on the left for right-to-left languages.

![Image 37: 2 text buttons labeled “Cancel” and “Subscribe” aligned to the lower right side of a dialog.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwp1uawi-34.png?alt=media&token=e0f8a3c9-c9fc-4d94-bf96-07db1feaa1f5)

Text buttons in a dialog

link

Copy link Link copied

Adaptive design
---------------

link

Copy link Link copied

### Resizing

link

Copy link Link copied

When scaling layouts for large screen devices, buttons can adapt their visual presentation, size, alignment, and arrangement to fit different contexts and user needs.

link

Copy link Link copied

Choose the best button position based on screen size.

![Image 38: Flights app in compact screen with buttons below flight information.](https://lh3.googleusercontent.com/3KW8V16JAsM6Cftkf-BuF1NgPsqnPwsCbkaPR578JISH1whoSSSiUJqVOye4wObutCg-f2WVHfIQXnmkmiw4k_ByGfl3O-MprLgThuwmITQ=w40)

Filled buttons are end-aligned below flight information in a compact window

link

Copy link Link copied

![Image 39: Flights app in large screen with buttons to the left of flight information.](https://lh3.googleusercontent.com/6tk1fDAXbtRkIkd797NYOAVCfBrhOkWByXKAZ28KPaxvlPlUaK-n7v16EwYERfQV_5KxDRSn4D78Cz-rnO2QilJaunxsa8X8Q6MExjBCijgB=w40)

Filled buttons are start-aligned beside flight information in a large window

link

Copy link Link copied

The icon and label text in a button stay centered and grouped as the button's width changes.

![Image 40: 2 buttons with horizontally centered text labels.](https://lh3.googleusercontent.com/zNJswsz2xhLFG6fewuWbTQrjT-0HKkv1BSSQCzxrtBXBUxvS8M8REWEraIYu83ydMC01PsWINNAAvOfJ8cTT_QK9CnmcKpp1qlT9PDF6EaX9DQ=w40)

check Do 
Keep the icon and label text grouped and centered

![Image 41: 1 button with centered text label, 1 button with icon and label aligned to opposite edges.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gmzxhh-46.png?alt=media&token=b91d80aa-1a8c-4b29-8d8b-5282f8f3251d)

close Don’t 
Don't ungroup the icon and label text or let them anchor to opposite sides of the button

link

Copy link Link copied

Buttons can be customized to change size and scaling behavior across different window sizes Window size classes are opinionated breakpoints where layouts need to change to optimize for available space, device conventions, and ergonomics. [More on window size classes](https://m3.material.io/m3/pages/applying-layout/window-size-classes).

To avoid creating very long buttons in large windows, constrain button width or place buttons beside other elements.

![Image 42: Button width is over-stretched with screen width.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gn1q8h-47.png?alt=media&token=647e1fe7-a661-4c34-8771-07099ff4758a)

close Don’t 
Don’t allow the button to stretch in a way that creates long, flat buttons with very little content inside

link

Copy link Link copied

### Presentation

link

Copy link Link copied

The size and placement of buttons can change as parent containers, such as cards, adapt for larger screens.

Keep items, including buttons, in the same order between large and small screens to provide a consistent experience for screen readers and keyboard navigation.

![Image 43: 2 buttons scaling to accommodate different device sizes.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Fm0gn2wej-48.png?alt=media&token=765e8d57-6e78-4cc8-8877-0cd32b3b9d39)

Buttons can move in the layout, but elements should remain in the same order
