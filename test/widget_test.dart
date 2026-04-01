import 'package:aero_stream/app.dart';
import 'package:aero_stream/core/notifications/local_notification_service.dart';
import 'package:aero_stream/core/permissions/notification_permission_state.dart';
import 'package:aero_stream/core/permissions/permission_service.dart';
import 'package:aero_stream/core/providers/cover_image_mode_provider.dart';
import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/core/providers/service_providers.dart';
import 'package:aero_stream/widgets/mini_player_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('AeroStream routes across shell branches and info details', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          coverImageModeProvider.overrideWith(
            (ref) => CoverImageMode.placeholder,
          ),
          useMockAppDataProvider.overrideWith((ref) => true),
          playbackTickerEnabledProvider.overrideWith((ref) => false),
          notificationServiceProvider.overrideWithValue(
            NoOpLocalNotificationService(),
          ),
          permissionServiceProvider.overrideWithValue(
            const NoOpPermissionService(
              NotificationPermissionState.notRequired,
            ),
          ),
        ],
        child: const AeroStreamApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Music'), findsOneWidget);
    expect(find.text('NOW PLAYING'), findsOneWidget);
    expect(find.text('Recently Played'), findsOneWidget);
    expect(find.text('Your Playlists'), findsOneWidget);
    expect(find.byType(MiniPlayerBar), findsOneWidget);

    await tester.tap(find.byType(MiniPlayerBar));
    await tester.pumpAndSettle();

    expect(find.text('Up Next'), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(MiniPlayerBar), findsNothing);

    await tester.tap(find.byIcon(Icons.pause_rounded));
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);

    await tester.tap(find.text('Up Next'));
    await tester.pumpAndSettle();

    expect(find.text('Queue'), findsOneWidget);
    expect(find.text('QUEUE (5)'), findsOneWidget);

    await tester.tap(find.text('Vinyl Memories'));
    await tester.pumpAndSettle();

    expect(find.text('Vinyl Memories'), findsOneWidget);
    expect(find.text('Up Next'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.keyboard_arrow_down_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Info'));
    await tester.pumpAndSettle();

    expect(find.text('Information'), findsOneWidget);
    expect(find.text('Your Stats'), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Version 1.0.0'), findsOneWidget);

    await tester.tap(find.text('Total Listening Time'));
    await tester.pumpAndSettle();

    expect(find.text('Listening Time'), findsOneWidget);
    expect(find.text('Most Played Artists'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Information'), findsOneWidget);

    await tester.tap(find.text('Songs Played'));
    await tester.pumpAndSettle();

    expect(find.text('Songs Played'), findsWidgets);
    expect(find.text('Most Played Songs'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Information'), findsOneWidget);

    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();

    expect(find.text('Library'), findsWidgets);
    expect(find.text('Albums'), findsOneWidget);
    expect(find.text('Neon Nights'), findsOneWidget);

    await tester.tap(find.text('Playlists'));
    await tester.pumpAndSettle();

    expect(find.text('Playlists'), findsWidgets);
    expect(
      find.text('Playlist management is queued up for the next pass.'),
      findsOneWidget,
    );
  });
}
