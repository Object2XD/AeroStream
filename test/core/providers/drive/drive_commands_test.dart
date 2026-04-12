import 'package:aero_stream/core/providers/drive/drive_providers.dart';
import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../support/drive_test_helpers.dart';

void main() {
  test(
    'commands block drive entrypoints with a reconnect-required message',
    () async {
      final database = makeTestDatabase();
      addTearDown(database.close);

      await database.setActiveAccount(
        SyncAccountsCompanion.insert(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'oauth_desktop',
          connectedAt: DateTime(2026, 3, 31),
          authSessionState: Value(DriveAuthSessionState.reauthRequired.value),
          authSessionError: const Value(driveAuthReconnectRequiredMessage),
        ),
      );

      final authRepository = FakeDriveAuthRepository(
        restoreSessionResult: null,
      );
      final runner = RecordingDriveScanRunner(
        database: database,
        authRepository: authRepository,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          driveAuthRepositoryProvider.overrideWithValue(authRepository),
          driveScanRunnerProvider.overrideWithValue(runner),
        ],
      );
      addTearDown(container.dispose);

      await container.read(driveWorkspaceProvider.future);
      final commands = container.read(driveCommandsProvider);

      await expectLater(
        commands.listFolders(),
        throwsA(
          isA<DriveAuthException>().having(
            (error) => error.message,
            'message',
            driveAuthReconnectRequiredMessage,
          ),
        ),
      );
      await expectLater(
        commands.addRoot(
          const DriveFolderEntry(
            id: 'new-root',
            name: 'New Root',
            parentId: 'root',
          ),
        ),
        throwsA(
          isA<DriveAuthException>().having(
            (error) => error.message,
            'message',
            driveAuthReconnectRequiredMessage,
          ),
        ),
      );

      await commands.enqueueSync();
      await Future<void>.delayed(Duration.zero);

      final state = container.read(driveWorkspaceProvider).value!;
      expect(state.errorMessage, driveAuthReconnectRequiredMessage);
      expect(runner.enqueueCallCount, 0);
    },
  );

  test(
    'commands mark reconnect required when listFolders hits runtime auth expiry',
    () async {
      final database = makeTestDatabase();
      addTearDown(database.close);

      await database.setActiveAccount(
        SyncAccountsCompanion.insert(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'oauth_desktop',
          connectedAt: DateTime(2026, 3, 31),
          authSessionState: Value(DriveAuthSessionState.ready.value),
          authSessionError: const Value(null),
        ),
      );

      final authRepository = FakeDriveAuthRepository(
        restoreSessionResult: const DriveAccountProfile(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'oauth_desktop',
        ),
      );
      final runner = RecordingDriveScanRunner(
        database: database,
        authRepository: authRepository,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          driveAuthRepositoryProvider.overrideWithValue(authRepository),
          driveHttpClientProvider.overrideWithValue(
            ExpiredSessionDriveHttpClient(),
          ),
          driveScanRunnerProvider.overrideWithValue(runner),
        ],
      );
      addTearDown(container.dispose);

      await container.read(driveWorkspaceProvider.future);
      final commands = container.read(driveCommandsProvider);

      await expectLater(
        commands.listFolders(),
        throwsA(
          isA<DriveAuthException>().having(
            (error) => error.message,
            'message',
            driveAuthReconnectRequiredMessage,
          ),
        ),
      );

      final state = container.read(driveWorkspaceProvider).value!;
      final account = (await database.getActiveAccount())!;
      expect(state.requiresReconnect, isTrue);
      expect(state.canAccessDrive, isFalse);
      expect(state.errorMessage, driveAuthReconnectRequiredMessage);
      expect(
        account.authSessionState,
        DriveAuthSessionState.reauthRequired.value,
      );
    },
  );

  test(
    'commands mark reconnect required when addRoot hits runtime auth expiry',
    () async {
      final database = makeTestDatabase();
      addTearDown(database.close);

      await database.setActiveAccount(
        SyncAccountsCompanion.insert(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'oauth_desktop',
          connectedAt: DateTime(2026, 3, 31),
          authSessionState: Value(DriveAuthSessionState.ready.value),
          authSessionError: const Value(null),
        ),
      );
      final account = (await database.getActiveAccount())!;
      await database.upsertRoot(
        SyncRootsCompanion.insert(
          accountId: account.id,
          folderId: 'existing-root',
          folderName: 'Existing Root',
          parentFolderId: const Value('parent-folder'),
        ),
      );

      final authRepository = FakeDriveAuthRepository(
        restoreSessionResult: const DriveAccountProfile(
          providerAccountId: 'drive-account',
          email: 'listener@example.com',
          displayName: 'Listener',
          authKind: 'oauth_desktop',
        ),
      );
      final runner = RecordingDriveScanRunner(
        database: database,
        authRepository: authRepository,
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          driveAuthRepositoryProvider.overrideWithValue(authRepository),
          driveHttpClientProvider.overrideWithValue(
            ExpiredSessionDriveHttpClient(),
          ),
          driveScanRunnerProvider.overrideWithValue(runner),
        ],
      );
      addTearDown(container.dispose);

      await container.read(driveWorkspaceProvider.future);
      final commands = container.read(driveCommandsProvider);

      await expectLater(
        commands.addRoot(
          const DriveFolderEntry(
            id: 'new-root',
            name: 'New Root',
            parentId: 'root',
          ),
        ),
        throwsA(
          isA<DriveAuthException>().having(
            (error) => error.message,
            'message',
            driveAuthReconnectRequiredMessage,
          ),
        ),
      );

      final state = container.read(driveWorkspaceProvider).value!;
      expect(state.requiresReconnect, isTrue);
      expect(state.errorMessage, driveAuthReconnectRequiredMessage);
    },
  );

  test('commands reject an already-added folder before syncing', () async {
    final database = makeTestDatabase();
    addTearDown(database.close);

    await database.setActiveAccount(
      SyncAccountsCompanion.insert(
        providerAccountId: 'drive-account',
        email: 'listener@example.com',
        displayName: 'Listener',
        authKind: 'oauth_desktop',
        connectedAt: DateTime(2026, 3, 31),
        authSessionState: Value(DriveAuthSessionState.ready.value),
        authSessionError: const Value(null),
      ),
    );
    final account = (await database.getActiveAccount())!;
    await database.upsertRoot(
      SyncRootsCompanion.insert(
        accountId: account.id,
        folderId: 'existing-root',
        folderName: 'Existing Root',
      ),
    );

    final authRepository = FakeDriveAuthRepository(
      restoreSessionResult: const DriveAccountProfile(
        providerAccountId: 'drive-account',
        email: 'listener@example.com',
        displayName: 'Listener',
        authKind: 'oauth_desktop',
      ),
    );
    final runner = RecordingDriveScanRunner(
      database: database,
      authRepository: authRepository,
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        driveAuthRepositoryProvider.overrideWithValue(authRepository),
        driveScanRunnerProvider.overrideWithValue(runner),
      ],
    );
    addTearDown(container.dispose);

    await container.read(driveWorkspaceProvider.future);
    final commands = container.read(driveCommandsProvider);

    await expectLater(
      commands.addRoot(
        const DriveFolderEntry(
          id: 'existing-root',
          name: 'Existing Root',
          parentId: 'root',
        ),
      ),
      throwsA(
        isA<DriveAuthException>().having(
          (error) => error.message,
          'message',
          'This folder is already added.',
        ),
      ),
    );
  });

  test('commands cancel the active job before removing a root', () async {
    final database = makeTestDatabase();
    addTearDown(database.close);

    await database.setActiveAccount(
      SyncAccountsCompanion.insert(
        providerAccountId: 'drive-account',
        email: 'listener@example.com',
        displayName: 'Listener',
        authKind: 'oauth_desktop',
        connectedAt: DateTime(2026, 3, 31),
        authSessionState: Value(DriveAuthSessionState.ready.value),
        authSessionError: const Value(null),
      ),
    );
    final account = (await database.getActiveAccount())!;
    await database.upsertRoot(
      SyncRootsCompanion.insert(
        accountId: account.id,
        folderId: 'folder-1',
        folderName: 'Music',
        activeJobId: const Value(42),
      ),
    );
    final root = (await database.getRootByFolderId('folder-1'))!;

    final authRepository = FakeDriveAuthRepository(restoreSessionResult: null);
    final runner = RecordingDriveScanRunner(
      database: database,
      authRepository: authRepository,
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        driveAuthRepositoryProvider.overrideWithValue(authRepository),
        driveScanRunnerProvider.overrideWithValue(runner),
      ],
    );
    addTearDown(container.dispose);

    final commands = container.read(driveCommandsProvider);
    await commands.removeRoot(root.id);

    expect(runner.canceledJobIds, [42]);
    expect(await database.getRootById(root.id), isNull);
  });
}
