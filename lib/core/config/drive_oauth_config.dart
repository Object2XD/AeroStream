import 'dart:convert';

import 'package:flutter/foundation.dart';

class DriveOAuthConfig {
  const DriveOAuthConfig({
    required this.clientId,
    required this.serverClientId,
    required this.clientSecret,
  });

  final String clientId;
  final String serverClientId;
  final String clientSecret;

  static const scopes = <String>[
    'https://www.googleapis.com/auth/drive.readonly',
  ];

  factory DriveOAuthConfig.fromEnvironment() {
    const envConfig = DriveOAuthConfig(
      clientId: String.fromEnvironment('AERO_DRIVE_GOOGLE_CLIENT_ID'),
      serverClientId: String.fromEnvironment(
        'AERO_DRIVE_GOOGLE_SERVER_CLIENT_ID',
      ),
      clientSecret: String.fromEnvironment('AERO_DRIVE_GOOGLE_CLIENT_SECRET'),
    );
    const rawOAuthJson = String.fromEnvironment('AERO_DRIVE_GOOGLE_OAUTH_JSON');
    final parsedConfig = DriveOAuthConfig.tryParseDownloadedClientJson(
      rawOAuthJson,
    );
    if (parsedConfig == null) {
      return envConfig;
    }

    return DriveOAuthConfig(
      clientId: parsedConfig.clientId.isNotEmpty
          ? parsedConfig.clientId
          : envConfig.clientId,
      serverClientId: parsedConfig.serverClientId.isNotEmpty
          ? parsedConfig.serverClientId
          : envConfig.serverClientId,
      clientSecret: parsedConfig.clientSecret.isNotEmpty
          ? parsedConfig.clientSecret
          : envConfig.clientSecret,
    );
  }

  static DriveOAuthConfig? tryParseDownloadedClientJson(String rawJson) {
    if (rawJson.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      final nestedConfig = decoded['installed'] ?? decoded['web'] ?? decoded;
      if (nestedConfig is! Map<String, dynamic>) {
        return null;
      }

      final clientId =
          nestedConfig['client_id'] as String? ??
          nestedConfig['clientId'] as String? ??
          '';
      if (clientId.isEmpty) {
        return null;
      }

      return DriveOAuthConfig(
        clientId: clientId,
        serverClientId:
            nestedConfig['server_client_id'] as String? ??
            nestedConfig['serverClientId'] as String? ??
            '',
        clientSecret:
            nestedConfig['client_secret'] as String? ??
            nestedConfig['clientSecret'] as String? ??
            '',
      );
    } catch (_) {
      return null;
    }
  }

  bool get requiresClientIdForCurrentPlatform {
    if (kIsWeb) {
      return false;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return true;
    }

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return true;
    }

    return false;
  }

  bool get isConfiguredForCurrentPlatform {
    if (kIsWeb) {
      return false;
    }

    if (!requiresClientIdForCurrentPlatform) {
      return true;
    }

    return clientId.isNotEmpty;
  }

  String? get configurationMessage {
    if (kIsWeb) {
      return 'Google Drive sync is not available on web.';
    }

    if (isConfiguredForCurrentPlatform) {
      return null;
    }

    if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux) {
      return 'Google Drive is not configured in this desktop build. Re-run Flutter with --dart-define-from-file=build_config/google_drive_oauth.env.json or use tool/build_windows_with_google_oauth.ps1.';
    }

    return 'Set AERO_DRIVE_GOOGLE_OAUTH_JSON or AERO_DRIVE_GOOGLE_CLIENT_ID for this platform before connecting Google Drive.';
  }
}
