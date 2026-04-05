import 'package:aero_stream/core/providers/drive/drive_providers.dart';
import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/screens/info/google_drive/google_drive_settings_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'golden_test_harness.dart';

void main() {
  setUpAll(loadAeroFonts);

  const devices = <Device>[
    Device.phone,
    Device(name: 'desktop_wide', size: Size(1440, 1024)),
  ];

  testGoldens('Google Drive settings syncing state stays visually stable', (
    WidgetTester tester,
  ) async {
    final state = GoogleDriveState(
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
      scanProgress: const ScanProgress(
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
          googleDriveControllerProvider.overrideWith(
            () => _GoldenGoogleDriveController(state),
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
      'google_drive_settings_syncing',
      devices: devices,
    );
  });

  testGoldens(
    'Google Drive settings disconnected state stays visually stable',
    (WidgetTester tester) async {
      const state = GoogleDriveState(
        isConfigured: true,
        account: null,
        hasLinkedAccount: false,
        canAccessDrive: false,
        requiresReconnect: false,
        authErrorMessage: null,
        roots: <SyncRoot>[],
        cacheSizeBytes: 0,
        scanProgress: null,
        isMutating: false,
        configurationMessage: null,
        errorMessage: null,
      );

      await tester.pumpWidgetBuilder(
        ProviderScope(
          overrides: [
            googleDriveControllerProvider.overrideWith(
              () => _GoldenGoogleDriveController(state),
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

class _GoldenGoogleDriveController extends GoogleDriveController {
  _GoldenGoogleDriveController(this._state);

  final GoogleDriveState _state;

  @override
  Future<GoogleDriveState> build() async => _state;

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> addRoot(DriveFolderEntry folder) async {}

  @override
  Future<void> removeRoot(int rootId) async {}

  @override
  Future<void> enqueueSync() async {}

  @override
  Future<void> pauseSync(int jobId) async {}

  @override
  Future<void> resumeSync(int jobId) async {}

  @override
  Future<void> cancelSync(int jobId) async {}

  @override
  Future<void> clearCache() async {}

  @override
  Future<List<DriveFolderEntry>> listFolders({String parentId = 'root'}) async {
    return const <DriveFolderEntry>[];
  }

  @override
  Future<DriveFolderEntry> getFolder(String folderId) async {
    return const DriveFolderEntry(id: 'root', name: 'My Drive', parentId: null);
  }
}
