import 'package:aero_stream/core/providers/drive/drive_providers.dart';
import 'package:aero_stream/core/theme/app_theme.dart';
import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/drive_library_repository.dart';
import 'package:aero_stream/data/drive/drive_scan_runner.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:aero_stream/screens/info/google_drive/google_drive_settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'support/drive_test_helpers.dart';

void main() {
  group('formatCompactCount', () {
    test('formats compact values with K and M suffixes', () {
      expect(formatCompactCount(999), '999');
      expect(formatCompactCount(1200), '1.2K');
      expect(formatCompactCount(9400), '9.4K');
      expect(formatCompactCount(93046), '93K');
      expect(formatCompactCount(5247), '5.2K');
      expect(formatCompactCount(1250000), '1.2M');
      expect(formatCompactCount(6), '6');
    });
  });

  testWidgets(
    'Google Drive settings shows reconnect-required state without raw storage paths',
    (WidgetTester tester) async {
      final commands = _TestDriveCommands(
        buildWorkspaceState(
          canAccessDrive: false,
          requiresReconnect: true,
          authErrorMessage: driveSyncReconnectRequiredMessage,
          roots: [
            buildRoot(
              syncState: DriveScanJobState.failed.value,
              lastError:
                  r"PathAccessException: Cannot delete file, path = 'c:\users\object2xd\appdata\roaming\com.example\aero_stream\flutter_secure_storage.dat'",
            ),
          ],
        ),
      );

      await _pumpScreen(tester, commands);

      expect(find.text('Listener'), findsOneWidget);
      expect(find.byTooltip('Reconnect'), findsOneWidget);
      expect(
        find.textContaining(driveSyncReconnectRequiredMessage),
        findsWidgets,
      );
      expect(find.textContaining('flutter_secure_storage.dat'), findsNothing);
      expect(find.textContaining('PathAccessException'), findsNothing);

      final addFolderButton = tester.widget<IconButton>(
        _iconButtonWithTooltip('Add folder'),
      );
      final disconnectButton = tester.widget<IconButton>(
        _iconButtonWithTooltip('Disconnect'),
      );

      expect(addFolderButton.onPressed, isNull);
      expect(disconnectButton.onPressed, isNotNull);
    },
  );

  testWidgets(
    'Google Drive settings shows compact live sync metrics and icon-only controls',
    (WidgetTester tester) async {
      final commands = _TestDriveCommands(
        buildWorkspaceState(
          roots: [buildRoot()],
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
        ),
      );

      await _pumpScreen(tester, commands);

      expect(find.text('Extracting metadata'), findsOneWidget);
      expect(find.byTooltip('Indexed 93,046'), findsOneWidget);
      expect(find.byTooltip('Tags 5,247'), findsOneWidget);
      expect(find.byTooltip('Meta/s 12.4/s'), findsOneWidget);
      expect(find.byTooltip('Failed 6'), findsOneWidget);
      expect(find.text('93K'), findsOneWidget);
      expect(find.text('5.2K'), findsOneWidget);
      expect(find.text('12.4/s'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
      expect(find.text('Artwork 73 ready so far.'), findsOneWidget);
      expect(find.text('Pipeline'), findsNothing);
      expect(find.text('Extract Meta'), findsNothing);

      final pauseButton = tester.widget<IconButton>(
        _iconButtonWithTooltip('Pause sync'),
      );
      final resumeButton = tester.widget<IconButton>(
        _iconButtonWithTooltip('Resume sync'),
      );
      final cancelButton = tester.widget<IconButton>(
        _iconButtonWithTooltip('Cancel sync'),
      );

      expect(pauseButton.onPressed, isNotNull);
      expect(resumeButton.onPressed, isNull);
      expect(cancelButton.onPressed, isNotNull);
    },
  );

  testWidgets(
    'Google Drive settings shows 0.0 Meta/s while a running sync is stalled',
    (WidgetTester tester) async {
      final commands = _TestDriveCommands(
        buildWorkspaceState(
          roots: [buildRoot()],
          syncProgress: const DriveSyncProgress(
            jobId: 42,
            phase: 'metadata_enrichment',
            state: 'running',
            indexedCount: 93046,
            metadataReadyCount: 5247,
            artworkReadyCount: 73,
            failedCount: 0,
            itemsPerSecond: 0.0,
          ),
        ),
      );

      await _pumpScreen(tester, commands);

      expect(find.byTooltip('Meta/s 0.0/s'), findsOneWidget);
      expect(find.text('0.0/s'), findsOneWidget);
    },
  );

  testWidgets('Google Drive settings hides speed metric while sync is paused', (
    WidgetTester tester,
  ) async {
    final commands = _TestDriveCommands(
      buildWorkspaceState(
        roots: [buildRoot(syncState: DriveScanJobState.paused.value)],
        syncProgress: const DriveSyncProgress(
          jobId: 42,
          phase: 'metadata_enrichment',
          state: 'paused',
          indexedCount: 93046,
          metadataReadyCount: 5247,
          artworkReadyCount: 73,
          failedCount: 0,
          itemsPerSecond: 12.4,
        ),
      ),
    );

    await _pumpScreen(tester, commands);

    expect(find.byTooltip('Meta/s 12.4/s'), findsNothing);
    expect(find.text('12.4/s'), findsNothing);
  });

  testWidgets(
    'Google Drive settings still hides a stalled speed metric while sync is paused',
    (WidgetTester tester) async {
      final commands = _TestDriveCommands(
        buildWorkspaceState(
          roots: [buildRoot(syncState: DriveScanJobState.paused.value)],
          syncProgress: const DriveSyncProgress(
            jobId: 42,
            phase: 'metadata_enrichment',
            state: 'paused',
            indexedCount: 93046,
            metadataReadyCount: 5247,
            artworkReadyCount: 73,
            failedCount: 0,
            itemsPerSecond: 0.0,
          ),
        ),
      );

      await _pumpScreen(tester, commands);

      expect(find.byTooltip('Meta/s 0.0/s'), findsNothing);
      expect(find.text('0.0/s'), findsNothing);
    },
  );

  testWidgets(
    'Google Drive settings shows disconnected empty state with connect action',
    (WidgetTester tester) async {
      final commands = _TestDriveCommands(
        buildWorkspaceState(
          hasLinkedAccount: false,
          canAccessDrive: false,
          account: null,
          roots: const [],
        ),
      );

      await _pumpScreen(tester, commands);

      expect(find.text('Connect your library'), findsOneWidget);
      expect(find.byTooltip('Connect account'), findsOneWidget);
      expect(
        find.textContaining('No folders are selected yet.'),
        findsOneWidget,
      );

      final connectButton = tester.widget<IconButton>(
        _iconButtonWithTooltip('Connect account'),
      );
      expect(connectButton.onPressed, isNotNull);
    },
  );

  testWidgets(
    'folder picker follows navigation and confirms the selected folder',
    (WidgetTester tester) async {
      final commands = _TestDriveCommands(
        buildWorkspaceState(roots: const []),
        foldersByParent: <String, List<DriveFolderEntry>>{
          'root': const [
            DriveFolderEntry(id: 'music', name: 'Music', parentId: 'root'),
          ],
          'music': const [
            DriveFolderEntry(id: 'archive', name: 'Archive', parentId: 'music'),
          ],
        },
      );

      await _pumpScreen(tester, commands);

      final addFolderFinder = _iconButtonWithTooltip('Add folder');
      await tester.ensureVisible(addFolderFinder);
      await tester.pumpAndSettle();

      final addFolderButton = tester.widget<IconButton>(addFolderFinder);
      expect(addFolderButton.onPressed, isNotNull);

      await tester.tap(addFolderFinder);
      await tester.pumpAndSettle();

      expect(find.text('Choose a sync folder'), findsOneWidget);
      expect(find.byTooltip('Use current folder'), findsOneWidget);

      await tester.tap(find.text('Music'));
      await tester.pumpAndSettle();

      expect(find.text('Current folder'), findsOneWidget);
      expect(find.text('Archive'), findsOneWidget);

      await tester.tap(_iconButtonWithTooltip('Use current folder'));
      await tester.pumpAndSettle();

      expect(commands.addedFolders, hasLength(1));
      expect(commands.addedFolders.single.name, 'Music');
      expect(find.text('Added "Music" to sync roots.'), findsOneWidget);
    },
  );
}

Future<void> _pumpScreen(
  WidgetTester tester,
  _TestDriveCommands commands,
) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        driveWorkspaceProvider.overrideWith(
          () => FixedDriveWorkspaceNotifier(commands.state),
        ),
        driveCommandsProvider.overrideWithValue(commands),
      ],
      child: MaterialApp(
        theme: buildAeroTheme(),
        home: const GoogleDriveSettingsScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _iconButtonWithTooltip(String tooltip) {
  return find.byWidgetPredicate(
    (widget) => widget is IconButton && widget.tooltip == tooltip,
  );
}

class _TestDriveCommands extends DriveCommands {
  factory _TestDriveCommands(
    DriveWorkspaceState state, {
    Map<String, List<DriveFolderEntry>> foldersByParent = const {},
  }) {
    final database = makeTestDatabase();
    final authRepository = NoOpDriveAuthRepository();
    return _TestDriveCommands._(
      state: state,
      database: database,
      foldersByParent: foldersByParent,
      authRepository: authRepository,
    );
  }

  _TestDriveCommands._({
    required this.state,
    required AppDatabase database,
    required this.foldersByParent,
    required DriveAuthRepository authRepository,
  }) : super(
         database: database,
         authRepository: authRepository,
         httpClient: DriveHttpClient(authRepository: authRepository),
         libraryRepository: DriveLibraryRepository(database),
         runner: RecordingDriveScanRunner(
           database: database,
           authRepository: authRepository,
         ),
         workspace: FixedDriveWorkspaceNotifier(state),
       );

  final DriveWorkspaceState state;
  final Map<String, List<DriveFolderEntry>> foldersByParent;
  final List<DriveFolderEntry> addedFolders = <DriveFolderEntry>[];

  @override
  Future<void> connect() async {}

  @override
  Future<void> disconnect() async {}

  @override
  Future<void> addRoot(DriveFolderEntry folder) async {
    addedFolders.add(folder);
  }

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
    return foldersByParent[parentId] ?? const <DriveFolderEntry>[];
  }

  @override
  Future<DriveFolderEntry> getFolder(String folderId) async {
    for (final folders in foldersByParent.values) {
      for (final folder in folders) {
        if (folder.id == folderId) {
          return folder;
        }
      }
    }
    return const DriveFolderEntry(id: 'root', name: 'My Drive', parentId: null);
  }
}
