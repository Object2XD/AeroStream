Title: Canonical layouts – Material Design 3

URL Source: http://m3.material.io/foundations/layout/canonical-layouts

Published Time: Tue, 01 Jan 1980 00:00:01 GMT

Markdown Content:
Canonical layouts are designs for common screen layouts across all window size classes

On this page

*   [Resources](https://m3.material.io/)
*   [Takeaways](https://m3.material.io/)
*   [Layouts](https://m3.material.io/)

link

Copy link Link copied

**Use the three canonical layouts as starting points for organizing common elements in an app**.
Each layout considers common use cases and components to address expectations and user needs for how apps adapt across window class sizes and breakpoints.

link

Copy link Link copied

Resources
---------

link

Copy link Link copied

| Type | Resource | Status |
| --- | --- | --- |
| Implementation | [MDC-Android – Canonical layouts](https://github.com/android/user-interface-samples/tree/main/CanonicalLayouts) | Available |
|  | [](https://github.com/orgs/flutter/projects/45)[Flutter –](https://pub.dev/packages/flutter_adaptive_scaffold)[Adaptive scaffold](https://pub.dev/packages/flutter_adaptive_scaffold) | Available |
|  | [Jetpack Compose – Canonical layouts](https://developer.android.com/develop/ui/views/layout/canonical-layouts) | Available |

link

Copy link Link copied

Takeaways
---------

link

Copy link Link copied

*   There are three canonical layouts: list-detail, supporting pane, feed
*   Each canonical layout has configurations for compact, medium, and expanded window size classes

link

Copy link Link copied

Layouts
-------

link

Copy link Link copied

### [Feed](https://m3.material.io/m3/pages/canonical-layouts/feed)

Use a feed layout to arrange content elements like cards in a configurable grid for quick, convenient viewing of a large amount of content.

![Image 1: Feed layout of a news app's top stories. One large story fills the first pane, and multiple smaller stories and live events are on the second pane.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxydid0o-1.png?alt=media&token=55ae108a-f05d-4c08-ab1e-1fade8706194)

Example feed layout

link

Copy link Link copied

### [List-detail](https://m3.material.io/m3/pages/canonical-layouts/list-detail)

Use the list-detail layout to display explorable lists of items alongside each item’s supplementary information—the item detail. This layout divides the app window into two side-by-side panes.

![Image 2: List-detail layout of a messaging app. The first pane lists all conversations. The second pane is for messaging in the selected conversation.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxydjght-2.png?alt=media&token=b304c1d5-579c-40dc-8fec-22bde1b72781)

Example list-detail layout

link

Copy link Link copied

### [Supporting pane](https://m3.material.io/m3/pages/canonical-layouts/supporting-pane)

Use the supporting pane layout to organize app content into primary and secondary display areas. The primary display area occupies the majority of the app window (typically about two thirds) and contains the main content. The secondary display area is a panel that takes up the remainder of the app window and presents content that supports the main content.

![Image 3: Supporting pane layout of a video app. The large, primary pane has the video, title, and actions. The small, secondary pane has queued and recommended videos.](https://firebasestorage.googleapis.com/v0/b/design-spec/o/projects%2Fgoogle-material-3%2Fimages%2Flxydkkpk-3.png?alt=media&token=5c0b5f37-ee8e-43da-84a3-378abd1d3e04)

Example supporting pane layout

[Previous Applying layout: Pane layouts](https://m3.material.io/foundations/layout/applying-layout)[Up next Canonical layouts: List-detail](https://m3.material.io/foundations/layout/canonical-layouts/list-detail)

vertical_align_top
