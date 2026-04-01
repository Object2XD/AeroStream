import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PlaybackOverlayLayoutSpec {
  const PlaybackOverlayLayoutSpec({
    required this.contentMaxWidth,
    required this.contentPadding,
    this.verticalSpacing = 0,
    this.artworkSize = 0,
  });

  final double contentMaxWidth;
  final EdgeInsets contentPadding;
  final double verticalSpacing;
  final double artworkSize;

  factory PlaybackOverlayLayoutSpec.player(BoxConstraints constraints) {
    final horizontalPadding = constraints.maxWidth >= 840 ? 32.0 : 24.0;
    final verticalSpacing = constraints.maxHeight >= 760 ? 24.0 : 16.0;
    final artCandidate = math.min(
      constraints.maxWidth - (horizontalPadding * 2),
      constraints.maxHeight * 0.42,
    );

    return PlaybackOverlayLayoutSpec(
      contentMaxWidth: constraints.maxWidth >= 840 ? 520.0 : double.infinity,
      contentPadding: EdgeInsets.fromLTRB(
        horizontalPadding,
        12,
        horizontalPadding,
        20,
      ),
      verticalSpacing: verticalSpacing,
      artworkSize: math.min(artCandidate, 420.0),
    );
  }

  factory PlaybackOverlayLayoutSpec.queue(BoxConstraints constraints) {
    final horizontalPadding = constraints.maxWidth >= 840 ? 32.0 : 16.0;

    return PlaybackOverlayLayoutSpec(
      contentMaxWidth: constraints.maxWidth >= 840 ? 560.0 : double.infinity,
      contentPadding: EdgeInsets.fromLTRB(
        horizontalPadding,
        8,
        horizontalPadding,
        16,
      ),
    );
  }
}

class PlaybackOverlayScaffold extends StatelessWidget {
  const PlaybackOverlayScaffold({
    super.key,
    required this.decoration,
    required this.specBuilder,
    required this.childBuilder,
  });

  final Decoration decoration;
  final PlaybackOverlayLayoutSpec Function(BoxConstraints constraints)
  specBuilder;
  final Widget Function(
    BuildContext context,
    PlaybackOverlayLayoutSpec layoutSpec,
  )
  childBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Container(
        decoration: decoration,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layoutSpec = specBuilder(constraints);

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: layoutSpec.contentMaxWidth,
                  ),
                  child: Padding(
                    padding: layoutSpec.contentPadding,
                    child: childBuilder(context, layoutSpec),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

void closePlaybackOverlay(
  BuildContext context, {
  required String fallbackRoute,
}) {
  if (Navigator.of(context).canPop()) {
    context.pop();
    return;
  }

  context.go(fallbackRoute);
}

void showPlaybackOverlayPlaceholder(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
