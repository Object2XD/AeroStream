import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:oauth2/oauth2.dart' as oauth2;
import 'package:url_launcher/url_launcher.dart';

import '../../core/config/drive_oauth_config.dart';
import 'drive_entities.dart';
import 'drive_scan_logger.dart';

class DriveAuthException implements Exception {
  const DriveAuthException(this.message);

  final String message;

  @override
  String toString() => 'DriveAuthException($message)';
}

DriveAuthException createGoogleApiException({
  required String context,
  required http.Response response,
}) {
  final responseBody = response.body;
  String? apiMessage;
  String? reason;
  String? activationUrl;

  try {
    final decoded = jsonDecode(responseBody);
    if (decoded is Map<String, dynamic>) {
      final error = decoded['error'];
      if (error is Map<String, dynamic>) {
        apiMessage = error['message'] as String?;

        final errors = error['errors'];
        if (errors is List) {
          for (final rawEntry in errors) {
            if (rawEntry is! Map<String, dynamic>) {
              continue;
            }
            reason ??= rawEntry['reason'] as String?;
            apiMessage ??= rawEntry['message'] as String?;
            activationUrl ??= rawEntry['extendedHelp'] as String?;
          }
        }

        final details = error['details'];
        if (details is List) {
          for (final rawDetail in details) {
            if (rawDetail is! Map<String, dynamic>) {
              continue;
            }
            reason ??= rawDetail['reason'] as String?;
            final metadata = rawDetail['metadata'];
            if (metadata is Map<String, dynamic>) {
              activationUrl ??= metadata['activationUrl'] as String?;
            }
          }
        }
      }
    }
  } catch (_) {
    // Fall through to the generic response handling below.
  }

  final normalizedMessage = apiMessage?.trim();
  final normalizedReason = reason?.trim();
  if (normalizedReason == 'SERVICE_DISABLED' ||
      normalizedReason == 'accessNotConfigured' ||
      (normalizedMessage != null &&
          normalizedMessage.contains('has not been used in project')) ||
      (normalizedMessage != null &&
          normalizedMessage.contains('is disabled'))) {
    final activationHint = activationUrl == null || activationUrl.isEmpty
        ? ''
        : ' Enable it here: $activationUrl';
    return DriveAuthException(
      'Google Drive API is not enabled for this Google Cloud project.$activationHint',
    );
  }

  if (normalizedReason == 'domainPolicy') {
    return const DriveAuthException(
      'Your Google Workspace domain policy is blocking Drive access for this app.',
    );
  }

  if (normalizedMessage != null && normalizedMessage.isNotEmpty) {
    return DriveAuthException(
      '$context (${response.statusCode}): $normalizedMessage',
    );
  }

  return DriveAuthException('$context (${response.statusCode}).');
}

abstract class DriveAuthRepository {
  bool get isConfigured;
  String? get configurationMessage;

  Future<DriveAccountProfile?> restoreSession();

  Future<DriveAccountProfile> connect();

  Future<void> disconnect();

  Future<T> withClient<T>(Future<T> Function(http.Client client) action);
}

class PlatformDriveAuthRepository implements DriveAuthRepository {
  PlatformDriveAuthRepository({
    required this.config,
    required FlutterSecureStorage secureStorage,
    DriveScanLogger logger = const NoOpDriveScanLogger(),
    Future<oauth2.Client> Function()? desktopClientFactory,
    Future<DriveAccountProfile> Function(http.Client client)? profileLoader,
  }) : _secureStorage = secureStorage,
       _logger = logger,
       _desktopClientFactory = desktopClientFactory,
       _profileLoader = profileLoader;

  final DriveOAuthConfig config;
  final FlutterSecureStorage _secureStorage;
  final DriveScanLogger _logger;
  final Future<oauth2.Client> Function()? _desktopClientFactory;
  final Future<DriveAccountProfile> Function(http.Client client)?
  _profileLoader;

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  static const _desktopCredentialsKey = 'drive.desktop.credentials';
  static const _desktopProfileIdKey = 'drive.desktop.profile.id';
  static const _desktopProfileEmailKey = 'drive.desktop.profile.email';
  static const _desktopProfileNameKey = 'drive.desktop.profile.name';

  bool _googleSignInInitialized = false;
  GoogleSignInAccount? _currentGoogleUser;
  oauth2.Client? _desktopClient;
  Future<void> _desktopStorageSequence = Future<void>.value();

  @override
  bool get isConfigured => config.isConfiguredForCurrentPlatform;

  @override
  String? get configurationMessage => config.configurationMessage;

  bool get _usesGoogleSignIn {
    if (kIsWeb) {
      return false;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return true;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  @override
  Future<DriveAccountProfile?> restoreSession() async {
    if (!isConfigured) {
      _logger.warning(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'restore_session_skipped',
        message: configurationMessage ?? 'Google Drive is not configured.',
      );
      return null;
    }

    if (_usesGoogleSignIn) {
      await _ensureGoogleSignInInitialized();
      final account = await _googleSignIn.attemptLightweightAuthentication();
      if (account == null) {
        _logger.warning(
          prefix: 'DriveAuth',
          subsystem: 'auth',
          operation: 'session_missing',
          message: 'No Google Sign-In session was available to restore.',
        );
        return null;
      }

      final authorization = await account.authorizationClient
          .authorizationForScopes(DriveOAuthConfig.scopes);
      if (authorization == null) {
        _logger.warning(
          prefix: 'DriveAuth',
          subsystem: 'auth',
          operation: 'session_missing',
          message: 'Google Sign-In authorization is missing for Drive scopes.',
        );
        return null;
      }

      _currentGoogleUser = account;
      _logger.info(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'restore_session_success',
        details: <String, Object?>{
          'authKind': 'google_sign_in',
        },
      );
      return DriveAccountProfile(
        providerAccountId: account.id,
        email: account.email,
        displayName: account.displayName ?? account.email,
        authKind: 'google_sign_in',
      );
    }

    final credentialsJson = await _readDesktopSecureValue(
      _desktopCredentialsKey,
    );
    if (credentialsJson == null || credentialsJson.isEmpty) {
      _logger.warning(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'session_missing',
        details: const <String, Object?>{'authKind': 'oauth_desktop'},
        message: 'Desktop OAuth credentials are missing.',
      );
      return null;
    }

    final oauth2.Credentials credentials;
    try {
      credentials = oauth2.Credentials.fromJson(credentialsJson);
    } on FormatException catch (error) {
      await _clearCorruptedDesktopSession(error);
      return null;
    }
    _desktopClient = _buildDesktopClient(credentials);

    final profile = await _readStoredDesktopProfile();
    if (profile != null) {
      _logger.info(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'restore_session_success',
        details: const <String, Object?>{'authKind': 'oauth_desktop'},
      );
      return profile;
    }

    final fetchedProfile = await _fetchProfileWithClient(_desktopClient!);
    await _persistDesktopProfile(fetchedProfile, throwOnFailure: false);
    _logger.info(
      prefix: 'DriveAuth',
      subsystem: 'auth',
      operation: 'restore_session_success',
      details: const <String, Object?>{'authKind': 'oauth_desktop'},
    );
    return fetchedProfile;
  }

  @override
  Future<DriveAccountProfile> connect() async {
    if (!isConfigured) {
      _logger.error(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'connect_fail',
        message: configurationMessage ?? 'Google Drive is not configured.',
      );
      throw DriveAuthException(
        configurationMessage ?? 'Google Drive is not configured.',
      );
    }
    _logger.info(
      prefix: 'DriveAuth',
      subsystem: 'auth',
      operation: 'connect_start',
      details: <String, Object?>{
        'authKind': _usesGoogleSignIn ? 'google_sign_in' : 'oauth_desktop',
      },
    );

    if (_usesGoogleSignIn) {
      await _ensureGoogleSignInInitialized();

      final account = await _googleSignIn.authenticate(
        scopeHint: DriveOAuthConfig.scopes,
      );
      await account.authorizationClient.authorizeScopes(
        DriveOAuthConfig.scopes,
      );
      _currentGoogleUser = account;
      _logger.info(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'connect_success',
        details: const <String, Object?>{'authKind': 'google_sign_in'},
      );

      return DriveAccountProfile(
        providerAccountId: account.id,
        email: account.email,
        displayName: account.displayName ?? account.email,
        authKind: 'google_sign_in',
      );
    }

    final client =
        await (_desktopClientFactory?.call() ?? _createDesktopClient());
    _desktopClient?.close();
    _desktopClient = client;

    final profile = await _fetchProfileWithClient(client);
    await _persistDesktopCredentials(
      client.credentials.toJson(),
      throwOnFailure: false,
    );
    await _persistDesktopProfile(profile, throwOnFailure: false);
    _logger.info(
      prefix: 'DriveAuth',
      subsystem: 'auth',
      operation: 'connect_success',
      details: const <String, Object?>{'authKind': 'oauth_desktop'},
    );
    return profile;
  }

  @override
  Future<void> disconnect() async {
    if (_usesGoogleSignIn) {
      try {
        await _googleSignIn.disconnect();
      } catch (_) {
        await _googleSignIn.signOut();
      }
      _currentGoogleUser = null;
      _logger.info(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'disconnect_success',
        details: const <String, Object?>{'authKind': 'google_sign_in'},
      );
      return;
    }

    _desktopClient?.close();
    _desktopClient = null;
    try {
      await _withDesktopStorageLock(() => _secureStorage.deleteAll());
      _logger.info(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'disconnect_success',
        details: const <String, Object?>{'authKind': 'oauth_desktop'},
      );
    } catch (error) {
      if (_isRecoverableDesktopStorageError(error)) {
        _logger.error(
          prefix: 'DriveAuth',
          subsystem: 'auth',
          operation: 'disconnect_fail',
          details: const <String, Object?>{'authKind': 'oauth_desktop'},
          error: error,
        );
        throw const DriveAuthException(
          'Could not clear the saved Google Drive session on this device. Close other apps that may be using secure storage and try again.',
        );
      }
      rethrow;
    }
  }

  @override
  Future<T> withClient<T>(Future<T> Function(http.Client client) action) async {
    if (_usesGoogleSignIn) {
      await _ensureGoogleSignInInitialized();
      final user =
          _currentGoogleUser ??
          await _googleSignIn.attemptLightweightAuthentication();
      if (user == null) {
        _logger.warning(
          prefix: 'DriveAuth',
          subsystem: 'auth',
          operation: 'session_missing',
          details: const <String, Object?>{'authKind': 'google_sign_in'},
        );
        throw const DriveAuthException('Sign in to Google Drive first.');
      }
      _currentGoogleUser = user;

      final authorization =
          await user.authorizationClient.authorizationForScopes(
            DriveOAuthConfig.scopes,
          ) ??
          await user.authorizationClient.authorizeScopes(
            DriveOAuthConfig.scopes,
          );
      final client = authorization.authClient(scopes: DriveOAuthConfig.scopes);

      try {
        return await action(client);
      } catch (error, stackTrace) {
        _logger.error(
          prefix: 'DriveAuth',
          subsystem: 'auth',
          operation: 'client_action_fail',
          details: const <String, Object?>{'authKind': 'google_sign_in'},
          error: error,
          stackTrace: stackTrace,
        );
        rethrow;
      } finally {
        client.close();
      }
    }

    final client = _desktopClient ?? await _restoreDesktopClient();
    if (client == null) {
      _logger.warning(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'session_missing',
        details: const <String, Object?>{'authKind': 'oauth_desktop'},
        message: 'Desktop OAuth client is not available.',
      );
      throw const DriveAuthException('Google Drive is not connected.');
    }

    try {
      final result = await action(client);
      await _persistDesktopCredentials(
        client.credentials.toJson(),
        throwOnFailure: false,
      );
      return result;
    } catch (error, stackTrace) {
      _logger.error(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'client_action_fail',
        details: const <String, Object?>{'authKind': 'oauth_desktop'},
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _ensureGoogleSignInInitialized() async {
    if (_googleSignInInitialized) {
      return;
    }

    await _googleSignIn.initialize(
      clientId: config.clientId.isEmpty ? null : config.clientId,
      serverClientId: config.serverClientId.isEmpty
          ? null
          : config.serverClientId,
    );
    _googleSignInInitialized = true;
  }

  Future<oauth2.Client?> _restoreDesktopClient() async {
    final credentialsJson = await _readDesktopSecureValue(
      _desktopCredentialsKey,
    );
    if (credentialsJson == null || credentialsJson.isEmpty) {
      _logger.warning(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'session_missing',
        details: const <String, Object?>{'authKind': 'oauth_desktop'},
        message: 'Desktop OAuth credentials are missing during client restore.',
      );
      return null;
    }

    late final oauth2.Client client;
    try {
      client = _buildDesktopClient(
        oauth2.Credentials.fromJson(credentialsJson),
      );
    } on FormatException catch (error) {
      await _clearCorruptedDesktopSession(error);
      return null;
    }
    _desktopClient = client;
    _logger.info(
      prefix: 'DriveAuth',
      subsystem: 'auth',
      operation: 'desktop_client_restored',
    );
    return client;
  }

  Future<oauth2.Client> _createDesktopClient() async {
    final authorizationEndpoint = Uri.parse(
      'https://accounts.google.com/o/oauth2/v2/auth',
    );
    final tokenEndpoint = Uri.parse('https://oauth2.googleapis.com/token');

    final redirectServer = await HttpServer.bind(
      InternetAddress.loopbackIPv4,
      0,
    );
    final redirectUri = Uri.parse(
      'http://127.0.0.1:${redirectServer.port}/oauth2redirect',
    );

    final grant = oauth2.AuthorizationCodeGrant(
      config.clientId,
      authorizationEndpoint,
      tokenEndpoint,
      secret: config.clientSecret.isEmpty ? null : config.clientSecret,
    );

    final baseAuthorizationUrl = grant.getAuthorizationUrl(
      redirectUri,
      scopes: DriveOAuthConfig.scopes,
    );
    final authorizationUrl = baseAuthorizationUrl.replace(
      queryParameters: <String, String>{
        ...baseAuthorizationUrl.queryParameters,
        'access_type': 'offline',
        'prompt': 'consent',
      },
    );

    final opened = await launchUrl(
      authorizationUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!opened) {
      await redirectServer.close(force: true);
      throw const DriveAuthException(
        'Could not open the browser for Google authorization.',
      );
    }

    final responseUri = await _waitForDesktopRedirect(
      redirectServer,
      redirectUri,
    );
    await redirectServer.close(force: true);
    return grant.handleAuthorizationResponse(responseUri.queryParameters);
  }

  Future<Uri> _waitForDesktopRedirect(
    HttpServer server,
    Uri redirectUri,
  ) async {
    final completer = Completer<Uri>();

    late final StreamSubscription<HttpRequest> subscription;
    subscription = server.listen((request) async {
      final uri = request.uri.replace(
        scheme: redirectUri.scheme,
        host: redirectUri.host,
        port: redirectUri.port,
      );

      request.response
        ..statusCode = HttpStatus.ok
        ..headers.contentType = ContentType.html
        ..write(
          '<html><body style="font-family: sans-serif;"><h2>Google Drive connected</h2><p>You can close this window and return to Aero Stream.</p></body></html>',
        );
      await request.response.close();
      if (!completer.isCompleted) {
        completer.complete(uri);
      }
      await subscription.cancel();
    });

    return completer.future.timeout(
      const Duration(minutes: 3),
      onTimeout: () {
        throw const DriveAuthException(
          'Google authorization timed out before completion.',
        );
      },
    );
  }

  Future<DriveAccountProfile> _fetchProfileWithClient(
    http.Client client,
  ) async {
    final profileLoader = _profileLoader;
    if (profileLoader != null) {
      return profileLoader(client);
    }

    final response = await client.get(
      Uri.parse(
        'https://www.googleapis.com/drive/v3/about?fields=user(displayName,emailAddress,permissionId)',
      ),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw createGoogleApiException(
        context: 'Could not read Google Drive profile',
        response: response,
      );
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final user = (json['user'] as Map<String, dynamic>? ?? <String, dynamic>{});

    return DriveAccountProfile(
      providerAccountId:
          user['permissionId'] as String? ??
          user['emailAddress'] as String? ??
          'unknown',
      email: user['emailAddress'] as String? ?? 'unknown@example.com',
      displayName:
          user['displayName'] as String? ??
          user['emailAddress'] as String? ??
          'Google Drive',
      authKind: 'oauth_desktop',
    );
  }

  oauth2.Client _buildDesktopClient(oauth2.Credentials credentials) {
    return oauth2.Client(
      credentials,
      identifier: config.clientId,
      secret: config.clientSecret.isEmpty ? null : config.clientSecret,
      onCredentialsRefreshed: (refreshed) {
        unawaited(
          _persistDesktopCredentials(refreshed.toJson(), throwOnFailure: false),
        );
      },
    );
  }

  Future<void> _persistDesktopCredentials(
    String credentialsJson, {
    required bool throwOnFailure,
  }) {
    return _withDesktopStorageLock(
      () => _writeDesktopSecureValueLocked(
        _desktopCredentialsKey,
        credentialsJson,
        throwOnFailure: throwOnFailure,
      ),
    );
  }

  Future<void> _persistDesktopProfile(
    DriveAccountProfile profile, {
    required bool throwOnFailure,
  }) {
    return _withDesktopStorageLock(() async {
      await _writeDesktopSecureValueLocked(
        _desktopProfileIdKey,
        profile.providerAccountId,
        throwOnFailure: throwOnFailure,
      );
      await _writeDesktopSecureValueLocked(
        _desktopProfileEmailKey,
        profile.email,
        throwOnFailure: throwOnFailure,
      );
      await _writeDesktopSecureValueLocked(
        _desktopProfileNameKey,
        profile.displayName,
        throwOnFailure: throwOnFailure,
      );
    });
  }

  Future<DriveAccountProfile?> _readStoredDesktopProfile() async {
    final id = await _readDesktopSecureValue(_desktopProfileIdKey);
    if (id == null || id.isEmpty) {
      return null;
    }
    final email = await _readDesktopSecureValue(_desktopProfileEmailKey);
    if (email == null || email.isEmpty) {
      return null;
    }
    final name = await _readDesktopSecureValue(_desktopProfileNameKey);
    if (name == null || name.isEmpty) {
      return null;
    }

    return DriveAccountProfile(
      providerAccountId: id,
      email: email,
      displayName: name,
      authKind: 'oauth_desktop',
    );
  }

  Future<String?> _readDesktopSecureValue(String key) async {
    return _withDesktopStorageLock(() async {
      try {
        return await _secureStorage.read(key: key);
      } on FormatException catch (error) {
        _logger.warning(
          prefix: 'DriveAuth',
          subsystem: 'auth',
          operation: 'secure_storage_read_fail',
          details: <String, Object?>{'key': key},
          error: error,
        );
        await _clearCorruptedDesktopSessionLocked(error);
        return null;
      } on PlatformException catch (error) {
        if (_isRecoverableDesktopStorageError(error)) {
          _logger.warning(
            prefix: 'DriveAuth',
            subsystem: 'auth',
            operation: 'secure_storage_read_fail',
            details: <String, Object?>{'key': key},
            error: error,
          );
          await _clearCorruptedDesktopSessionLocked(error);
          return null;
        }
        rethrow;
      } catch (error) {
        if (_isRecoverableDesktopStorageError(error)) {
          _logger.warning(
            prefix: 'DriveAuth',
            subsystem: 'auth',
            operation: 'secure_storage_read_fail',
            details: <String, Object?>{'key': key},
            error: error,
          );
          await _clearCorruptedDesktopSessionLocked(error);
          return null;
        }
        rethrow;
      }
    });
  }

  Future<void> _clearCorruptedDesktopSession(Object error) async {
    await _withDesktopStorageLock(
      () => _clearCorruptedDesktopSessionLocked(error),
    );
  }

  Future<void> _writeDesktopSecureValueLocked(
    String key,
    String value, {
    required bool throwOnFailure,
  }) async {
    try {
      await _secureStorage.write(key: key, value: value);
      return;
    } catch (error, stackTrace) {
      if (!_isRecoverableDesktopStorageError(error)) {
        Error.throwWithStackTrace(error, stackTrace);
      }

      await _clearCorruptedDesktopSessionLocked(error);

      try {
        await _secureStorage.write(key: key, value: value);
      } catch (retryError, retryStackTrace) {
        if (throwOnFailure || !_isRecoverableDesktopStorageError(retryError)) {
          Error.throwWithStackTrace(retryError, retryStackTrace);
        }
        _logger.warning(
          prefix: 'DriveAuth',
          subsystem: 'auth',
          operation: 'secure_storage_write_retry_fail',
          details: <String, Object?>{'key': key},
          error: retryError,
          stackTrace: retryStackTrace,
        );
      }
    }
  }

  Future<void> _clearCorruptedDesktopSessionLocked(Object error) async {
    _logger.warning(
      prefix: 'DriveAuth',
      subsystem: 'auth',
      operation: 'secure_storage_recovery',
      details: const <String, Object?>{'authKind': 'oauth_desktop'},
      error: error,
    );
    _desktopClient?.close();
    _desktopClient = null;

    try {
      await _secureStorage.deleteAll();
    } catch (deleteError, deleteStackTrace) {
      if (!_isRecoverableDesktopStorageError(deleteError)) {
        Error.throwWithStackTrace(deleteError, deleteStackTrace);
      }
      _logger.warning(
        prefix: 'DriveAuth',
        subsystem: 'auth',
        operation: 'secure_storage_recovery_delete_fail',
        details: const <String, Object?>{'authKind': 'oauth_desktop'},
        error: deleteError,
        stackTrace: deleteStackTrace,
      );
    }
  }

  Future<T> _withDesktopStorageLock<T>(Future<T> Function() action) {
    final completer = Completer<T>();
    _desktopStorageSequence = _desktopStorageSequence.catchError((_) {}).then((
      _,
    ) async {
      try {
        completer.complete(await action());
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
    });
    return completer.future;
  }

  bool _isRecoverableDesktopStorageError(Object error) {
    if (error is FormatException || error is PlatformException) {
      return true;
    }
    if (error is FileSystemException) {
      final path = (error.path ?? '').toLowerCase();
      final message = error.toString().toLowerCase();
      return path.contains('flutter_secure_storage.dat') ||
          message.contains('flutter_secure_storage.dat');
    }
    final message = error.toString();
    return message.contains('CryptUnprotectData') ||
        message.contains('Failed to decrypt data') ||
        message.contains('Failed to parse JSON') ||
        message.contains('JSON is not an object.');
  }
}
