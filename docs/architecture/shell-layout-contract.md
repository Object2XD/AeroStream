# Shell Layout Contract

## Ownership

- `AeroShellScaffold` is the only owner of bottom navigation and the mini player.
- Branch router shells must render `AeroShellScaffold` with `padBodyForBottomChrome: false`.
- Branch shells own chrome layout. The page viewport ends at the top edge of the mini player.
- Routed pages do not re-inject chrome height into their padding. Pages only own small aesthetic trailing spacing.

## Page Rules

- Routed pages should use `AeroPageScaffold` or an equivalent page-only `Scaffold`.
- Routed pages must not calculate bottom chrome height or apply chrome-aware bottom inset.
- Branch screens must not carry shell mode flags such as `showShellChrome`; shell ownership belongs to the router, not the page.
- Page-level scroll padding owns the final trailing spacing for a screen.
- Section widgets must not add a second bottom spacer when the page scroll view already owns the trailing space.

## Testing Rules

- Keep standalone shell-hosted layout tests to protect page-level layout contracts in isolation.
- Keep route-level layout tests to protect the real `AeroStreamApp -> router -> branch shell -> page` path.
- Narrow desktop `512x923` is a permanent regression fixture for shell layout checks.
- Narrow desktop `471x913` is a permanent regression fixture for routed scroll-gap checks.

## Current Regression Coverage

- `test/library_viewport_height_test.dart` protects shell-hosted standalone page layout.
- `test/library_routed_viewport_height_regression_test.dart` protects the routed `Library` path.
- `test/library_routed_scroll_gap_regression_test.dart` protects the routed `Library` grid from trailing blank space at scroll end.
- `test/album_detail_screen_test.dart` protects routed `AlbumDetail` viewport behavior.
- `test/info_routed_viewport_height_test.dart` protects routed `Info` detail viewport behavior.

## Review Checklist

- Shell owns chrome, page owns spacing.
- Routed pages must not call chrome-height helpers.
- Scrollable trailing spacing must have a single owner: either the page scroll view or an inner section, never both.
- When a shell-managed route is added or edited, verify both a standalone test and a route-level test cover the layout.

## Recorded Regression

- `Library > Albums` routed grid on `471x913` regressed by stacking page bottom inset and section bottom padding, leaving a `194px` blank gap above the mini player at scroll end.
- The fix is to keep chrome height inside `AeroShellScaffold` only and use fixed aesthetic spacing in the page/section layer.
