Title: Dynamic color - Material Design 3

URL Source: http://m3.material.io/styles/color/dynamic/user-generated-source

Markdown Content:
### Use Material color roles in new design files

**First, get the color roles by creating a new theme with the Material Theme Builder**

1.   Open your Figma file. Select the **Resources** button in the Figma toolbar
2.   Find the [Material Theme Builder plugin](https://www.figma.com/community/plugin/1034969338659738588/material-theme-builder) and select **Run**. This will open a plugin dialog showing the default color scheme, including Core colors and Extended colors.
3.   Open the plugin's **Settings** (gear icon at lower right of dialog) and select the checkboxes for both **New theme color diagram** and **Generate State Layers**. This will create a handy visualization of your branded color scheme and also generate state layers essential for designing interactions. [Learn more about state layers](https://m3.material.io/m3/pages/interaction-states/state-layers)
4.   Navigate out of settings
5.   Open the Current Theme dropdown at the top of the dialog and select **+ ADD NEW THEME**
6.   Give your theme a short name (this name will become the prefix of your color roles in Figma)
7.   Select **ADD THEME**
8.   With **Custom** selected, select **Primary**. This opens a dialog prompting you to select a custom source color.
9.   Enter the Hex value for a color and hit **Apply**. This will generate a full color scheme.
10.   With the Current Theme dropdown at the top of the dialog, select your theme
11.   Select the frames or components in your file and then hit **Swap** in the bottom right of the dialog. This will automatically update the colors for any M3 Design Kit components.

### Apply color roles to an existing file or M3 Design Kit components

**First, get the color roles into your file**

1.   Copy your preferred scheme's color diagram from your [Material Theme Builder](https://www.figma.com/community/plugin/1034969338659738588/material-theme-builder) file and paste it into your file (this makes the color roles available in the Design panel on the right of the screen as part of your local styles)

**Swap colors in M3 Design Kit components for your preferred colors**

1.   Select the **Resources** button in the Figma toolbar.
2.   Find the [Material Theme Builder plugin](https://www.figma.com/community/plugin/1034969338659738588/material-theme-builder) and select **Run**. This will open a plugin dialog showing the default color scheme, including Core colors and Extended colors.
3.   In the Current Theme dropdown at the top of the dialog, select your color scheme
4.   Select the frames or M3 Design Kit components in your file that need a color update and then hit **Swap** in the bottom right of the dialog. This will automatically update their colors from baseline colors to your selected scheme colors

**Then, update any remaining non-color-role-based colors**

1.   Manually change any hex values or non-color-role-based color styles by selecting all and looking through the Selection colors in the Design panel on the right of the screen
2.   Any colors that don't start with your selected scheme name need to be replaced with a corresponding color role
3.   Hover on a non-color-role-based color row in the Design panel and select the **Style** icon (four dots). This opens a selection dialog.
4.   Search for your scheme name to see the color roles
5.   Select the color-role-based color that most closely matches that color's use case (see [Color roles](https://m3.material.io/m3/pages/color-roles) for more information on what color to use where) and select **Use style** to apply it to the selected objects
6.   Repeat until all non-color-role-based colors in the file have been replaced with color roles

### Try out how your designs will look with dynamic color

1.   Select the **Resources** button in the Figma toolbar.
2.   Find the [Material Theme Builder plugin](https://www.figma.com/community/plugin/1034969338659738588/material-theme-builder) and select **Run**. This will open a plugin dialog showing the default color scheme, including Core colors and Extended colors.
3.   Select Dynamic
4.   Add an image, or select the **Shuffle** icon to get a random source color
5.   Select the frames or components in your file that you want to see with dynamic color and then hit **Swap** in the bottom right of the dialog. This will automatically update their colors to the user-generated dynamic colors.
6.   Repeat with a range of colors to get a sense of how your product will appear across different users' devices

**Need to make adjustments to the scheme? Check out [Advanced customizations](https://m3.material.io/m3/pages/advanced/overview)**
