import 'package:aero_stream/core/config/drive_oauth_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses downloaded Google desktop OAuth JSON', () {
    const rawJson = '''
{
  "installed": {
    "client_id": "desktop-client-id.apps.googleusercontent.com",
    "project_id": "aero-stream",
    "auth_uri": "https://accounts.google.com/o/oauth2/auth",
    "token_uri": "https://oauth2.googleapis.com/token",
    "client_secret": "desktop-secret",
    "redirect_uris": [
      "http://localhost"
    ]
  }
}
''';

    final config = DriveOAuthConfig.tryParseDownloadedClientJson(rawJson);

    expect(config, isNotNull);
    expect(config!.clientId, 'desktop-client-id.apps.googleusercontent.com');
    expect(config.clientSecret, 'desktop-secret');
    expect(config.serverClientId, isEmpty);
  });

  test('returns null for invalid OAuth JSON', () {
    final config = DriveOAuthConfig.tryParseDownloadedClientJson('{"foo":"bar"}');

    expect(config, isNull);
  });
}
