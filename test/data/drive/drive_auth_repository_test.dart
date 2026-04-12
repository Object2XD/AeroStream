import 'dart:io';

import 'package:aero_stream/core/config/drive_oauth_config.dart';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;

import 'test_drive_scan_logger.dart';

void main() {
  test('formats service-disabled Google API responses clearly', () {
    final response = http.Response('''
      {
        "error": {
          "code": 403,
          "message": "Google Drive API has not been used in project 123 before or it is disabled. Enable it by visiting https://console.developers.google.com/apis/api/drive.googleapis.com/overview?project=123 then retry.",
          "status": "PERMISSION_DENIED",
          "details": [
            {
              "@type": "type.googleapis.com/google.rpc.ErrorInfo",
              "reason": "SERVICE_DISABLED",
              "domain": "googleapis.com",
              "metadata": {
                "service": "drive.googleapis.com",
                "activationUrl": "https://console.developers.google.com/apis/api/drive.googleapis.com/overview?project=123"
              }
            }
          ]
        }
      }
      ''', 403);

    final exception = createGoogleApiException(
      context: 'Could not read Google Drive profile',
      response: response,
    );

    expect(
      exception.toString(),
      contains(
        'Google Drive API is not enabled for this Google Cloud project.',
      ),
    );
    expect(exception.toString(), isNot(contains('activationUrl')));
    expect(
      exception.toString(),
      contains(
        'https://console.developers.google.com/apis/api/drive.googleapis.com/overview?project=123',
      ),
    );
  });

  test('formats domain policy errors clearly', () {
    final response = http.Response('''
      {
        "error": {
          "code": 403,
          "message": "The domain administrators have disabled Drive apps.",
          "errors": [
            {
              "domain": "global",
              "reason": "domainPolicy",
              "message": "The domain administrators have disabled Drive apps."
            }
          ]
        }
      }
      ''', 403);

    final exception = createGoogleApiException(
      context: 'Could not read Google Drive profile',
      response: response,
    );

    expect(
      exception.toString(),
      'DriveAuthException(Your Google Workspace domain policy is blocking Drive access for this app.)',
    );
  });

  test(
    'desktop restoreSession clears corrupt secure storage instead of throwing',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final storage = _ThrowingSecureStorage(
        error: const FormatException('corrupt secure storage'),
      );
      final logger = RecordingDriveScanLogger();
      final repository = PlatformDriveAuthRepository(
        config: const DriveOAuthConfig(
          clientId: 'desktop-client-id',
          serverClientId: '',
          clientSecret: '',
        ),
        secureStorage: storage,
        logger: logger,
      );

      final profile = await repository.restoreSession();

      expect(profile, isNull);
      expect(storage.readCount, 1);
      expect(storage.deleteAllCount, 1);
      expect(logger.containsOperation('secure_storage_recovery'), isTrue);
    },
  );

  test(
    'desktop restoreSession logs session-missing recovery context',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final storage = _ThrowingSecureStorage(
        error: const FormatException('corrupt secure storage'),
      );
      final logger = RecordingDriveScanLogger();
      final repository = PlatformDriveAuthRepository(
        config: const DriveOAuthConfig(
          clientId: 'desktop-client-id',
          serverClientId: '',
          clientSecret: '',
        ),
        secureStorage: storage,
        logger: logger,
      );

      await repository.restoreSession();

      final lines = logger.joinedLines();
      expect(lines, contains('DriveAuth secure_storage_recovery'));
      expect(lines, contains('authKind="oauth_desktop"'));
    },
  );

  test(
    'desktop restoreSession treats secure storage file access errors as recoverable',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final storage = _ThrowingSecureStorage(
        error: FileSystemException(
          'file is in use',
          r'C:\Users\object2xd\AppData\Roaming\com.example\aero_stream\flutter_secure_storage.dat',
        ),
      );
      final repository = PlatformDriveAuthRepository(
        config: const DriveOAuthConfig(
          clientId: 'desktop-client-id',
          serverClientId: '',
          clientSecret: '',
        ),
        secureStorage: storage,
      );

      final profile = await repository.restoreSession();

      expect(profile, isNull);
      expect(storage.deleteAllCount, 1);
    },
  );

  test(
    'desktop restoreSession serializes concurrent recovery and clears once',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final storage = _CorruptThenClearedSecureStorage(
        error: const FormatException('corrupt secure storage'),
      );
      final repository = PlatformDriveAuthRepository(
        config: const DriveOAuthConfig(
          clientId: 'desktop-client-id',
          serverClientId: '',
          clientSecret: '',
        ),
        secureStorage: storage,
      );

      final profiles = await Future.wait([
        repository.restoreSession(),
        repository.restoreSession(),
      ]);

      expect(profiles, everyElement(isNull));
      expect(storage.deleteAllCount, 1);
    },
  );

  test(
    'desktop connect retries storage writes after clearing corrupted data',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final storage = _RetryableWriteSecureStorage(
        writeError: const FormatException('corrupt secure storage'),
      );
      final expectedProfile = const DriveAccountProfile(
        providerAccountId: 'drive-user-1',
        email: 'listener@example.com',
        displayName: 'Listener',
        authKind: 'oauth_desktop',
      );
      final repository = PlatformDriveAuthRepository(
        config: const DriveOAuthConfig(
          clientId: 'desktop-client-id',
          serverClientId: '',
          clientSecret: '',
        ),
        secureStorage: storage,
        desktopClientFactory: () async => oauth2.Client(
          oauth2.Credentials('access-token'),
          identifier: 'desktop-client-id',
        ),
        profileLoader: (_) async => expectedProfile,
      );

      final profile = await repository.connect();

      expect(profile.email, expectedProfile.email);
      expect(storage.deleteAllCount, 1);
      expect(storage.successfulWrites, 4);
    },
  );

  test(
    'desktop withClient invalidates runtime session on invalid_grant',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final storage = _MapSecureStorage(
        values: <String, String>{
          'drive.desktop.credentials': oauth2.Credentials(
            'access-token',
            refreshToken: 'refresh-token',
            tokenEndpoint: Uri.parse('https://oauth2.googleapis.com/token'),
          ).toJson(),
          'drive.desktop.profile.id': 'account-1',
          'drive.desktop.profile.email': 'listener@example.com',
          'drive.desktop.profile.name': 'Listener',
        },
      );
      var invalidationCount = 0;
      final repository = PlatformDriveAuthRepository(
        config: const DriveOAuthConfig(
          clientId: 'desktop-client-id',
          serverClientId: '',
          clientSecret: '',
        ),
        secureStorage: storage,
        onDesktopSessionInvalidated: () async {
          invalidationCount += 1;
        },
      );

      final profile = await repository.restoreSession();
      expect(profile, isNotNull);

      await expectLater(
        repository.withClient((_) async {
          throw oauth2.AuthorizationException(
            'invalid_grant',
            'Token has been expired or revoked.',
            null,
          );
        }),
        throwsA(isA<DriveAuthSessionExpiredException>()),
      );

      expect(invalidationCount, 1);
      expect(
        storage.deletedKeys,
        containsAll(<String>[
          'drive.desktop.credentials',
          'drive.desktop.profile.id',
          'drive.desktop.profile.email',
          'drive.desktop.profile.name',
        ]),
      );
      expect(storage.deleteAllCount, 0);
      await expectLater(
        repository.withClient((_) async => 'ok'),
        throwsA(isA<DriveAuthSessionExpiredException>()),
      );
    },
  );

  test(
    'desktop withClient keeps session for non invalid_grant auth failures',
    () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);

      final storage = _MapSecureStorage(
        values: <String, String>{
          'drive.desktop.credentials': oauth2.Credentials(
            'access-token',
            refreshToken: 'refresh-token',
            tokenEndpoint: Uri.parse('https://oauth2.googleapis.com/token'),
          ).toJson(),
          'drive.desktop.profile.id': 'account-1',
          'drive.desktop.profile.email': 'listener@example.com',
          'drive.desktop.profile.name': 'Listener',
        },
      );
      var invalidationCount = 0;
      final repository = PlatformDriveAuthRepository(
        config: const DriveOAuthConfig(
          clientId: 'desktop-client-id',
          serverClientId: '',
          clientSecret: '',
        ),
        secureStorage: storage,
        onDesktopSessionInvalidated: () async {
          invalidationCount += 1;
        },
      );

      await repository.restoreSession();

      final error = oauth2.AuthorizationException(
        'temporarily_unavailable',
        'Try again later.',
        null,
      );
      await expectLater(
        repository.withClient((_) async => throw error),
        throwsA(same(error)),
      );

      expect(invalidationCount, 0);
      expect(storage.deletedKeys, isEmpty);
      expect(storage.values['drive.desktop.credentials'], isNotNull);
    },
  );
}

class _ThrowingSecureStorage extends FlutterSecureStorage {
  _ThrowingSecureStorage({required this.error});

  final Object error;
  int readCount = 0;
  int deleteAllCount = 0;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    readCount += 1;
    throw error;
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    deleteAllCount += 1;
  }
}

class _CorruptThenClearedSecureStorage extends FlutterSecureStorage {
  _CorruptThenClearedSecureStorage({required this.error});

  final Object error;
  bool _cleared = false;
  int deleteAllCount = 0;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (!_cleared) {
      throw error;
    }
    return null;
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    deleteAllCount += 1;
    _cleared = true;
  }
}

class _RetryableWriteSecureStorage extends FlutterSecureStorage {
  _RetryableWriteSecureStorage({required this.writeError});

  final Object writeError;
  final Map<String, String> values = <String, String>{};
  bool _hasThrownWriteError = false;
  int deleteAllCount = 0;
  int successfulWrites = 0;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return values[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (!_hasThrownWriteError) {
      _hasThrownWriteError = true;
      throw writeError;
    }
    if (value != null) {
      values[key] = value;
      successfulWrites += 1;
    }
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    deleteAllCount += 1;
    values.clear();
  }
}

class _MapSecureStorage extends FlutterSecureStorage {
  _MapSecureStorage({Map<String, String>? values})
    : values = values ?? <String, String>{};

  final Map<String, String> values;
  final List<String> deletedKeys = <String>[];
  int deleteAllCount = 0;

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    return values[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      values.remove(key);
      return;
    }
    values[key] = value;
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    deletedKeys.add(key);
    values.remove(key);
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    deleteAllCount += 1;
    values.clear();
  }
}
