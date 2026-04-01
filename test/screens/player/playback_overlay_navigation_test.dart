import 'package:aero_stream/app_routes.dart';
import 'package:aero_stream/core/providers/cover_image_mode_provider.dart';
import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/core/theme/app_theme.dart';
import 'package:aero_stream/screens/player/player_screen.dart';
import 'package:aero_stream/screens/player/queue_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('Player and Queue close buttons honor fallback routes', (
    WidgetTester tester,
  ) async {
    Future<void> pumpOverlayRoute({
      required String initialLocation,
      required Widget playerChild,
      required Widget queueChild,
    }) async {
      final router = GoRouter(
        initialLocation: initialLocation,
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('HOME ROUTE'))),
          ),
          GoRoute(
            path: AppRoutes.player,
            builder: (context, state) => playerChild,
          ),
          GoRoute(
            path: AppRoutes.queue,
            builder: (context, state) => queueChild,
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            coverImageModeProvider.overrideWith(
              (ref) => CoverImageMode.placeholder,
            ),
            useMockAppDataProvider.overrideWith((ref) => true),
            playbackTickerEnabledProvider.overrideWith((ref) => false),
          ],
          child: MaterialApp.router(
            theme: buildAeroTheme(),
            routerConfig: router,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await pumpOverlayRoute(
      initialLocation: AppRoutes.player,
      playerChild: const PlayerScreen(),
      queueChild: const Scaffold(body: SizedBox.shrink()),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();
    expect(find.text('HOME ROUTE'), findsOneWidget);

    await pumpOverlayRoute(
      initialLocation: AppRoutes.queue,
      playerChild: const Scaffold(body: Center(child: Text('PLAYER ROUTE'))),
      queueChild: const QueueScreen(),
    );

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();
    expect(find.text('PLAYER ROUTE'), findsOneWidget);
  });
}
