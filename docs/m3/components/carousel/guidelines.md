Title: Carousel – Material Design 3

URL Source: http://m3.material.io/components/carousel/guidelines

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
link

Copy link Link copied

![Image 1: Carousel items adapting dynamically to device size by shrinking and reducing in number.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwusb1kq-1.png?alt=media&token=31e0f0e5-44dc-40dc-88a3-810d49d9d32a)

Carousel items adapt dynamically based on window size

link

Copy link Link copied

Usage
-----

link

Copy link Link copied

Carousels display a scrollable list of items. Carousel items emphasize visuals, but can also contain brief text that adapts to the item size.

There are four carousel layouts:

*   Multi-browse The multi-browse carousel layout shows at least one large, medium, and small carousel item at a time. 
*   Uncontained The uncontained carousel layout show items that scroll to the edge of the container. 
*   Hero The hero carousel layout shows at least one large and one small item at a time. 
*   Full-screen The full-screen carousel layout shows one edge-to-edge large item at a time and scrolls vertically. 

All of these layouts can be centered, though center-aligned hero The center-aligned hero carousel layout shows at least one large and two small items at a time. The large item is centered.  is the most common centered carousel.

Carousels can scroll in two ways:

*   **Default**: Standard scrolling. Recommended for uncontained layouts.
*   **Snap-scrolling**: Scrolled items snap to the carousel's layout. Recommended for multi-browse, hero, and full-screen layouts

![Image 2: Contained carousel with a large, medium, and small item. Text is hidden on the small item.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwusbuoo-2.png?alt=media&token=fe9b4940-fc2b-453f-b10c-1eb4f1bb5250)

A carousel can contain different sized items

link

Copy link Link copied

Choose the best carousel layout for your product. Some layouts are more visual-focused, while others are more customizable.

link

Copy link Link copied

| Layout | Best used for |
| --- | --- |
| [Multi-browse](https://m3.material.io/m3/pages/carousel/guidelines#d95cefa4-53df-45e2-bbb2-3aeeecbe9639) | Browsing many visual items at once (like photos), dynamic designs |
| [Uncontained](https://m3.material.io/m3/pages/carousel/guidelines#96c5c157-fe5b-4ee3-a9b4-72bf8efab7e9) | Highly-customized or text-heavy carousels, stacked imaged and text, traditional carousel behavior |
| [Hero](https://m3.material.io/m3/pages/carousel/guidelines#5991f961-79aa-4955-b86e-3e15432108e6) | Spotlighting very large visual items (like a movie or featured app) |
| [Center-aligned hero](https://m3.material.io/m3/pages/carousel/guidelines#a9f8dcde-e5c5-464f-b488-d9ded9ae4a4a) | Centered, large visual items |
| [Full-screen](https://m3.material.io/m3/pages/carousel/guidelines#ae0f1566-a956-4c4b-b153-d50ee20c32e7) | Vertically-scrolling video or image feeds, immersive experiences |

link

Copy link Link copied

Carousel items must be fully visible on-screen (except for the uncontained layout The uncontained carousel layout show items that scroll to the edge of the container. ). When scrolled, items automatically change size and snap into place to maintain the same layout.

![Image 3: Multi-browse carousel with all images and text easily legible.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwuscosc-3-do.png?alt=media&token=ddae19a2-c2a5-4a4f-a57a-89ebf9924d44)

check Do 
Set the large carousel item size to ensure the images and text are easy to read and recognize

![Image 4: Multi-browse carousel with a very thin small item, making the image unrecognizable.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwusd3wu-3-don't.png?alt=media&token=9d93fc2f-8f36-44df-b19e-3b541f3dc539)

close Don’t 
Avoid setting carousel items so small that the image isn't recognizable

link

Copy link Link copied

### Accessibility requirements on scrolling pages

On vertically-scrolling pages, carousels require an accessible way to view all the items without horizontally scrolling. (This requirement doesn't apply to full-screen carousels The full-screen carousel layout shows one edge-to-edge large item at a time and scrolls vertically. .)

Material recommends adding a **Show all** button below the carousel, which opens a dedicated vertically-scrolling page of all carousel items.

If the carousel has a header, you can use an arrow icon button instead.

View the [accessibility tab](https://m3.material.io/m3/pages/carousel/accessibility) for more details and alternate solutions.

Make sure users can scroll vertically through all carousel items

link

Copy link Link copied

### Multi-browse

The multi-browse layout The multi-browse carousel layout shows at least one large, medium, and small carousel item at a time.  is best for browsing many items at once, like photos or event feeds. Snap-scrolling is recommended to ensure items are recognizable and consistently sized.

On larger screens, more large and medium items are visible in this layout.

Avoid using this layout if the carousel items need lots of text or have complicated imagery.

A multi-browse layout has different sized items within the carousel

link

Copy link Link copied

In compact windows, only show up to three carousel items if they have text.

If you need to show more than three items, make sure the images and content are easy to understand and recognize.

![Image 5: Carousel on a phone. 2 large, 1 medium, and 1 small item are fully visible but thin. The items don't have text.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwusga4v-6.png?alt=media&token=79689475-2747-4ee9-839c-b8c1eecba850)

exclamation Caution 
In compact windows, only show more than three items if the items are easy to understand and recognize

link

Copy link Link copied

### Uncontained

The uncontained layout The uncontained carousel layout show items that scroll to the edge of the container.  is most similar to a traditional carousel, where items are a single size and flow past the edge of the screen.

Both default scrolling and snap-scrolling work well with this layout.

Since items don't change size, this layout can be customized to show more text or other UI above or below each item without the text being masked or cropped.

Carousel items are all the same size in an uncontained layout

link

Copy link Link copied

### Uncontained multi-aspect ratio

The uncontained multi-aspect ratio 104 of 111 rows displayed The uncontained multi-aspect ratio layout shows carousel items of various widths.  carousel has the same layout as the uncontained carousel but contains items of various sizes.

Item widths can range anywhere between 9:16 for min width size to 16:9 for max width.

Only use this carousel layout if the items have various widths.

Carousel items are of various sizes in an uncontained multi-aspect ratio layout

link

Copy link Link copied

### Hero

The hero layout The hero carousel layout shows at least one large and one small item at a time.  is best for spotlighting content that needs more attention, like movie, shows, or other media thumbnails. It highlights one large image to focus on, while providing a sneak peek of what’s next.

On larger screens, more large items are visible.

Use snap-scrolling so users can easily cycle through items one at a time.

A hero carousel in compact windows should show one large item and one small item

link

Copy link Link copied

### Center-aligned hero

When the hero layout The hero carousel layout shows at least one large and one small item at a time.  is center-aligned, it adds an additional previewed item on the leading edge, making the large carousel item centered.

A centered hero carousel has two small carousel items, with a large item centered

link

Copy link Link copied

### Full-screen

The full-screen layout The full-screen carousel layout shows one edge-to-edge large item at a time and scrolls vertically.  is best used for immersive experiences like video articles, featured headlines, or items that are visually rich. It can contain text and other UI elements on top of the image.

This layout works best with content that is taller than it is wide, and scrolls vertically. It only works in portrait orientation in compact and medium windows. Don't use this layout in landscape orientation.

Use snap-scrolling for full-screen layouts. Don't use default scrolling.

Full-screen carousels fill the entire content area of the screen

link

Copy link Link copied

Anatomy
-------

link

Copy link Link copied

![Image 6: 4 elements of a carousel.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwushw0z-11.png?alt=media&token=0ec8f8d6-6910-47b8-af5e-aec914857c5e)

Multi-browse carousel (left) and hero carousel (right):

1.   Container
2.   Large carousel item
3.   Medium carousel item
4.   Small carousel item

link

Copy link Link copied

### Container

The carousel container holds all carousel items. The number of carousel items visible in the container can change based on the carousel layout Layout is the visual arrangement of elements on the screen. [More on layout](https://m3.material.io/m3/pages/understanding-layout/overview) and the window size class Window size classes are opinionated breakpoints where layouts need to change to optimize for available space, device conventions, and ergonomics. [More on window size classes](https://m3.material.io/m3/pages/applying-layout/window-size-classes).

![Image 7: An empty rectangle representing a carousel container.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwusikhn-12.png?alt=media&token=e53338c0-9e12-4500-a02a-6a3fa00a5be7)

The carousel container is a rectangle. It can be used in many ways and stretched to any size.

link

Copy link Link copied

### Carousel items

Carousel items hold content. A carousel item has no fixed width; it changes width depending on the window size or its position in the carousel's layout. There are three dynamic widths an item can be: **large**, **medium**, and **small**.

![Image 8: 3 sizes of carousel items.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwusj1ii-13.png?alt=media&token=a8d53996-8396-4e21-a972-c74335739543)

1.   Large carousel item
2.   Medium carousel item
3.   Small carousel item

link

Copy link Link copied

Large items have a max width that can be adjusted. This changes how all other large, medium, and small carousel items fit on screen. Large items must remain big enough to be easy to understand and recognize.

Medium items adjust width dynamically to the carousel size and available space.

Small items have a width range of 40–56dp.

![Image 9: 2 sizes of carousel items for hero layouts.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwusjjti-14.png?alt=media&token=405ab913-2f35-4d0e-aa46-07e957c4e947)

1.   Large item
2.   Small item

link

Copy link Link copied

When the large item's max width is narrow enough, more items can be shown on screen at once. In compact windows, this is only recommended for carousels with simple imagery.

![Image 10: 3 sizes of carousel items for multi-browse layouts. 2 large items are visible.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwuslefr-15.png?alt=media&token=93b132b6-bb28-4e57-9a57-f1c02ac20115)

1.   Large item
2.   Medium item
3.   Small item

link

Copy link Link copied

### Item text (optional)

Carousel items are primarily visual. Item text is optional and should be brief.

If your carousel items require a lot of text, consider using the **uncontained layout The uncontained carousel layout show items that scroll to the edge of the container.**, which can show more information, or use a series of cards Cards display content and actions about a single subject. [More on cards](https://m3.material.io/m3/pages/cards/overview) instead.

![Image 11: Contained carousel items with 5 lines of content: a title, a description, and a label.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwusmns4-16.png?alt=media&token=11d776e8-048f-4e1e-81d9-1a265271a7a6)

exclamation Caution 
Avoid exceeding two lines of text in carousel items in compact windows unless the background is simple, like a single color.

link

Copy link Link copied

Content within a carousel item can adapt dynamically based on the container and window size.

Text should always be understandable at each size. Consider adapting the text to use brief labels on smaller carousel items.

![Image 12: A carousel item at 3 different sizes to show  how text changes at each size.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwusqbrm-17.png?alt=media&token=bcc4c752-6b49-4820-960e-c22af7c9591b)

1.   Large carousel item with the full title and label text
2.   Medium carousel item hiding the title text
3.   Small carousel item abbreviating the label text

link

Copy link Link copied

Responsive layout
-----------------

link

Copy link Link copied

As the carousel container size increases, so do the number of carousel items visible at a time.

In compact window sizes Window widths smaller than 600dp, such as a phone in portrait orientation. [More on compact window size class](https://m3.material.io/m3/pages/applying-layout/compact), carousels can comfortably show up to three carousel items at once.

As the window size grows, more carousel items are added and scale in size.

Full-screen carousels The full-screen carousel layout shows one edge-to-edge large item at a time and scrolls vertically.  only ever show one item at once.

![Image 13: 8 carousel items visible at once on a tablet in landscape orientation.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwuso0q8-18.png?alt=media&token=1ca63117-b627-4361-afb1-6730a8ee93d3)

Carousels can show more items at once on larger screens

link

Copy link Link copied

Behavior
--------

link

Copy link Link copied

### Scrolling

Carousel items have a parallax effect when they're scrolled.

The **default** scrolling behavior doesn't snap items to a layout grid. They can stop anywhere in the container. Only use this for the uncontained layout The uncontained carousel layout show items that scroll to the edge of the container. .

The **snap-scrolling** behavior aligns carousel items to the layout grid after they're scrolled. Items snap to the grid when released. Use this for multi-browse The multi-browse carousel layout shows at least one large, medium, and small carousel item at a time. , hero The hero carousel layout shows at least one large and one small item at a time. , and full-screen layouts The full-screen carousel layout shows one edge-to-edge large item at a time and scrolls vertically. .

Carousel items with snap-scrolling maintain the same layout when released

link

Copy link Link copied

In full-screen layouts, make sure the carousel items snap to the edges of the carousel container. Avoid letting them scroll freely or stop halfway.

Full-screen layouts must use snap-scrolling.

![Image 14: Full-screen carousel with items stopping halfway off screen once scrolled.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flwuspl2g-20-don't.png?alt=media&token=71d2bacf-deaf-4fc7-84f2-7b8f5fd86747)

close Don’t 
Avoid scrolling freely on full-screen carousels
