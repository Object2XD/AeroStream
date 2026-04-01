import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app_routes.dart';
import '../core/providers/mini_player_controller.dart';
import 'bottom_nav_bar.dart';
import 'mini_player_bar.dart';

const double _miniPlayerInset = 8.0;
const double _miniPlayerHeight = 74.0;
const double _navBarHeight = 72.0;

double aeroBottomChromeHeight(BuildContext context) {
  final safeBottomInset = MediaQuery.paddingOf(context).bottom;
  return _miniPlayerHeight + _navBarHeight + safeBottomInset;
}

class AeroShellScaffold extends HookConsumerWidget {
  const AeroShellScaffold({
    super.key,
    required this.body,
    required this.currentNavIndex,
    this.appBar,
    this.padBodyForBottomChrome = true,
    this.bodyBottomPadding = 16,
  });

  final PreferredSizeWidget? appBar;
  final Widget body;
  final int currentNavIndex;
  final bool padBodyForBottomChrome;
  final double bodyBottomPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final miniPlayer = ref.watch(miniPlayerControllerProvider);
    final safeBottomInset = MediaQuery.paddingOf(context).bottom;
    final navigationLayerHeight = _navBarHeight + safeBottomInset;
    final hasMiniPlayer = miniPlayer.currentTrack != null;
    final bottomChromeHeight =
        (hasMiniPlayer ? _miniPlayerHeight : 0) + _navBarHeight + safeBottomInset;

    void handleNavSelected(int index) {
      if (index == currentNavIndex) {
        return;
      }

      context.go(AppRoutes.tabLocations[index]);
    }

    return Scaffold(
      extendBody: true,
      appBar: appBar,
      body: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: padBodyForBottomChrome
                ? bottomChromeHeight + bodyBottomPadding
                : 0,
          ),
          child: body,
        ),
      ),
      bottomNavigationBar: SizedBox(
        height: bottomChromeHeight,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SizedBox(
                height: navigationLayerHeight,
                child: ColoredBox(
                  color: theme.colorScheme.surfaceContainer,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: safeBottomInset,
                        child: SizedBox(
                          height: _navBarHeight,
                          child: BottomNavBar(
                            currentIndex: currentNavIndex,
                            onTap: handleNavSelected,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (hasMiniPlayer)
              Positioned(
                left: _miniPlayerInset,
                right: _miniPlayerInset,
                bottom: navigationLayerHeight,
                child: SizedBox(
                  height: _miniPlayerHeight,
                  child: MiniPlayerBar(
                    track: miniPlayer.currentTrack!,
                    progress: miniPlayer.progress,
                    isPlaying: miniPlayer.isPlaying,
                    onPlayPause: () => ref
                        .read(miniPlayerControllerProvider.notifier)
                        .togglePlayPause(),
                    onOpen: () => context.push(AppRoutes.player),
                    onNext: () => ref
                        .read(miniPlayerControllerProvider.notifier)
                        .playNext(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
