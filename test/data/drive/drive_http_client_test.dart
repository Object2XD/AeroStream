import 'dart:convert';
import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'test_drive_scan_logger.dart';

void main() {
  test('DriveHttpClient redacts pageToken and resourceKey from failure logs', () async {
    final logger = RecordingDriveScanLogger();
    final client = _ScriptedClient((request) async {
      if (request.url.path.endsWith('/changes')) {
        return http.StreamedResponse(
          Stream<List<int>>.value(
            utf8.encode('{"error":{"message":"permission denied"}}'),
          ),
          403,
        );
      }
      return http.StreamedResponse(
        Stream<List<int>>.value(
          utf8.encode('{"error":{"message":"download denied"}}'),
        ),
        403,
      );
    });
    final httpClient = DriveHttpClient(
      authRepository: _ClientBackedAuthRepository(client),
      logger: logger,
    );

    await expectLater(
      () => httpClient.listChangesPage(pageToken: 'secret-page-token'),
      throwsA(isA<DriveAuthException>()),
    );
    await expectLater(
      () => httpClient.downloadBytes(
        fileId: 'track-1',
        resourceKey: 'secret-resource-key',
        rangeHeader: 'bytes=0-31',
      ),
      throwsA(isA<DriveAuthException>()),
    );

    final lines = logger.joinedLines();
    expect(lines, contains('statusCode=403'));
    expect(lines, contains('pageToken="present"'));
    expect(lines, isNot(contains('secret-page-token')));
    expect(lines, contains('resourceKey="redacted"'));
    expect(lines, isNot(contains('secret-resource-key')));
  });
}

class _ClientBackedAuthRepository implements DriveAuthRepository {
  _ClientBackedAuthRepository(this.client);

  final http.Client client;

  @override
  String? get configurationMessage => null;

  @override
  bool get isConfigured => true;

  @override
  Future<DriveAccountProfile> connect() {
    throw UnimplementedError();
  }

  @override
  Future<void> disconnect() async {}

  @override
  Future<DriveAccountProfile?> restoreSession() async => null;

  @override
  Future<T> withClient<T>(Future<T> Function(http.Client client) action) {
    return action(client);
  }
}

class _ScriptedClient extends http.BaseClient {
  _ScriptedClient(this.handler);

  final Future<http.StreamedResponse> Function(http.BaseRequest request) handler;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return handler(request);
  }
}
