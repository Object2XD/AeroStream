import 'package:aero_stream/core/providers/drive/drive_providers.dart';
import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/drive_library_repository.dart';
import 'package:aero_stream/screens/info/google_drive/google_drive_settings_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'golden_test_harness.dart';
import '../support/drive_test_helpers.dart';

void main() {
  setUpAll(loadAeroFonts);

  const devices = <Device>[
    Device.phone,
    Device(name: 'desktop_wide', size: Size(1440, 1024)),
  ];

  testGoldens('Google Drive settings syncing state stays visually stable', (
    WidgetTester tester,
  ) async {
    final state = DriveWorkspaceState(
      isConfigured: true,
      account: const DriveAccountProfile(
        providerAccountId: 'drive-account',
        email: 'listener@example.com',
        displayName: 'Listener',
        authKind: 'oauth_desktop',
      ),
      hasLinkedAccount: true,
      canAccessDrive: true,
      requiresReconnect: false,
      authErrorMessage: null,
      roots: const [
        SyncRoot(
          id: 1,
          accountId: 1,
          folderId: 'folder-1',
          folderName: 'google_play_music',
          parentFolderId: null,
          syncState: 'running',
          lastSyncedAt: null,
          lastError: null,
          activeJobId: null,
          indexedCount: 93046,
          metadataReadyCount: 5247,
          artworkReadyCount: 73,
          failedCount: 0,
        ),
      ],
      cacheSizeBytes: 0,
      syncProgress: const DriveSyncProgress(
        jobId: 42,
        phase: 'metadata_enrichment',
        state: 'running',
        indexedCount: 93046,
        metadataReadyCount: 5247,
        artworkReadyCount: 73,
        failedCount: 6,
        itemsPerSecond: 12.4,
      ),
      isMutating: false,
      configurationMessage: null,
      errorMessage: null,
    );

    await tester.pumpWidgetBuilder(
      ProviderScope(
        overrides: [
          driveWorkspaceProvider.overrideWith(
            () => FixedDriveWorkspaceNotifier(state),
          ),
          driveCommandsProvider.overrideWithValue(_GoldenDriveCommands(state)),
        ],
        child: wrapWithShell(
          const GoogleDriveSettingsScreen(),
          currentNavIndex: 3,
        ),
      ),
      wrapper: buildGoldenApp,
    );
    await tester.pumpAndSettle();

    await multiScreenGolden(
      tester,
      'google_drive_settings_syncing',
      devices: devices,
    );
  });

  testGoldens(
    'Google Drive settings disconnected state stays visually stable',
    (WidgetTester tester) async {
      const state = DriveWorkspaceState(
        isConfigured: true,
        account: null,
        hasLinkedAccount: false,
        canAccessDrive: false,
        requiresReconnect: false,
        authErrorMessage: null,
        roots: <SyncRoot>[],
        cacheSizeBytes: 0,
        syncProgress: null,
        isMutating: false,
        configurationMessage: null,
        errorMessage: null,
      );

      await tester.pumpWidgetBuilder(
        ProviderScope(
          overrides: [
            driveWorkspaceProvider.overrideWith(
              () => FixedDriveWorkspaceNotifier(state),
            ),
            driveCommandsProvider.overrideWithValue(
              _GoldenDriveCommands(state),
            ),
          ],
          child: wrapWithShell(
            const GoogleDriveSettingsScreen(),
            currentNavIndex: 3,
          ),
        ),
        wrapper: buildGoldenApp,
      );
      await tester.pumpAndSettle();

      await multiScreenGolden(
        tester,
        'google_drive_settings_disconnected',
        devices: devices,
      );
    },
  );
}

class _GoldenDriveCommands extends DriveCommands {
  _GoldenDriveCommands(DriveWorkspaceState state)
    : super(
        database: makeTestDatabase(),
        authRepository: NoOpDriveAuthRepository(),
        httpClient: DriveHttpClient(authRepository: NoOpDriveAuthRepository()),
        libraryRepository: DriveLibraryRepository(makeTestDatabase()),
        runner: RecordingDriveScanRunner(
          database: makeTestDatabase(),
          authRepository: NoOpDriveAuthRepository(),
        ),
        workspace: FixedDriveWorkspaceNotifier(state),
      );

  @override
  Future<void> connect() async {}
}
