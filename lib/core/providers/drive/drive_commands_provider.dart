import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'drive_commands.dart';
import 'drive_dependency_providers.dart';
import 'drive_workspace_provider.dart';

final driveCommandsProvider = Provider<DriveCommands>((ref) {
  return DriveCommands(
    database: ref.read(appDatabaseProvider),
    authRepository: ref.read(driveAuthRepositoryProvider),
    httpClient: ref.read(driveHttpClientProvider),
    libraryRepository: ref.read(driveLibraryRepositoryProvider),
    runner: ref.read(driveScanRunnerProvider),
    workspace: ref.read(driveWorkspaceProvider.notifier),
  );
});
