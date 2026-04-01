import 'package:aero_stream/screens/home_screen.dart';
import 'package:aero_stream/screens/info/information_screen.dart';
import 'package:aero_stream/screens/info/listening_time_screen.dart';
import 'package:aero_stream/screens/info/songs_played_screen.dart';
import 'package:aero_stream/models/library_models.dart';
import 'package:aero_stream/screens/library/album_detail_screen.dart';
import 'package:aero_stream/screens/library_screen.dart';
import 'package:aero_stream/screens/player/player_screen.dart';
import 'package:aero_stream/screens/player/queue_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

import 'golden_test_harness.dart';

void main() {
  setUpAll(loadAeroFonts);

  const devices = <Device>[Device.phone, Device.tabletPortrait];
  const infoDevices = <Device>[
    Device.phone,
    Device.tabletPortrait,
    Device(name: 'desktop_wide', size: Size(1440, 1024)),
  ];

  testGoldens('Home screen stays visually stable', (WidgetTester tester) async {
    await tester.pumpWidgetBuilder(
      wrapWithShell(const HomeScreen(), currentNavIndex: 0),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(tester, 'home_screen', devices: devices);
  });

  testGoldens('Information screen stays visually stable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidgetBuilder(
      wrapWithShell(const InformationScreen(), currentNavIndex: 3),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(tester, 'information_screen', devices: infoDevices);
  });

  testGoldens('Listening Time screen stays visually stable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidgetBuilder(
      wrapWithShell(const ListeningTimeScreen(), currentNavIndex: 3),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(tester, 'listening_time_screen', devices: devices);
  });

  testGoldens('Songs Played screen stays visually stable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidgetBuilder(
      wrapWithShell(const SongsPlayedScreen(), currentNavIndex: 3),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(tester, 'songs_played_screen', devices: devices);
  });

  testGoldens('Player screen stays visually stable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidgetBuilder(
      const PlayerScreen(),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(tester, 'player_screen', devices: devices);
  });

  testGoldens('Queue screen stays visually stable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidgetBuilder(
      const QueueScreen(),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(tester, 'queue_screen', devices: devices);
  });

  testGoldens('Library albums stay visually stable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidgetBuilder(
      wrapWithShell(const LibraryScreen(), currentNavIndex: 1),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(tester, 'library_screen_albums', devices: devices);
  });

  testGoldens('Library albums list stays visually stable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidgetBuilder(
      wrapWithShell(
        const LibraryScreen(initialViewMode: LibraryViewMode.list),
        currentNavIndex: 1,
      ),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(
      tester,
      'library_screen_albums_list',
      devices: devices,
    );
  });

  testGoldens('Library songs stay visually stable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidgetBuilder(
      wrapWithShell(
        const LibraryScreen(initialTab: LibraryTab.songs),
        currentNavIndex: 1,
      ),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(
      tester,
      'library_screen_songs',
      devices: const [Device.phone],
    );
  });

  testGoldens('Album detail screen stays visually stable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidgetBuilder(
      wrapWithShell(const AlbumDetailScreen(albumId: '1'), currentNavIndex: 1),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(tester, 'album_detail_screen', devices: devices);
  });
}
