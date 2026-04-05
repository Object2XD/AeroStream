import 'dart:typed_data';

import 'package:aero_stream/data/drive/drive_auth_repository.dart';
import 'package:aero_stream/data/drive/drive_download_debug_meter.dart';
import 'package:aero_stream/data/drive/drive_entities.dart';
import 'package:aero_stream/data/drive/drive_http_client.dart';
import 'package:aero_stream/data/drive/extraction/drive_byte_range_reader.dart';
import 'package:aero_stream/media_extraction/core/byte_range.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('DriveDownloadDebugMeter separates requested and unique bytes', () {
    final meter = DriveDownloadDebugMeter();
    final context = DriveDownloadDebugContext(
      meter: meter,
      component: DriveDownloadDebugComponent.metadata,
      driveFileId: 'file-1',
      jobId: 1,
      taskId: 10,
    );

    meter.beginSession(context);
    meter.recordRequestedRange(context, ByteRange(0, 10));
    meter.recordRequestedRange(context, ByteRange(5, 15));
    meter.recordDownloadedBytes(context, 10);
    meter.recordDownloadedBytes(context, 5);

    final summary = meter.snapshot(context);
    expect(summary.requestCount, 2);
    expect(summary.requestedBytes, 20);
    expect(summary.uniqueRequestedBytes, 15);
    expect(summary.downloadedBytes, 15);
  });

  test('DriveByteRangeReader tracks debug meter in exact mode', () async {
    final bytes = Uint8List.fromList(List<int>.generate(100, (i) => i));
    final client = _ByteDriveHttpClient({'file-2': bytes});
    final meter = DriveDownloadDebugMeter();
    final context = DriveDownloadDebugContext(
      meter: meter,
      component: DriveDownloadDebugComponent.metadata,
      driveFileId: 'file-2',
      jobId: 1,
      taskId: 11,
    );
    final reader = DriveByteRangeReader(
      driveHttpClient: client,
      driveFileId: 'file-2',
      resourceKey: null,
      fileSize: bytes.length,
      fetchPolicy: DriveByteRangeFetchPolicy.exact,
      debugContext: context,
    );

    final read = await reader.read(ByteRange(10, 20));

    expect(read.length, 10);
    final summary = meter.snapshot(context);
    expect(summary.requestCount, 1);
    expect(summary.requestedBytes, 10);
    expect(summary.uniqueRequestedBytes, 10);
    expect(summary.downloadedBytes, 10);
  });

  test('DriveByteRangeReader avoids extra debug counts on cache hit', () async {
    final bytes = Uint8List.fromList(List<int>.generate(100, (i) => i));
    final client = _ByteDriveHttpClient({'file-3': bytes});
    final meter = DriveDownloadDebugMeter();
    final context = DriveDownloadDebugContext(
      meter: meter,
      component: DriveDownloadDebugComponent.artwork,
      driveFileId: 'file-3',
      jobId: 2,
      taskId: 12,
    );
    final reader = DriveByteRangeReader(
      driveHttpClient: client,
      driveFileId: 'file-3',
      resourceKey: null,
      fileSize: bytes.length,
      fetchPolicy: DriveByteRangeFetchPolicy.minimumWindow,
      debugContext: context,
    );

    await reader.read(ByteRange(10, 20));
    await reader.read(ByteRange(15, 18));

    final summary = meter.snapshot(context);
    expect(summary.requestCount, 1);
    expect(summary.requestedBytes, 90);
    expect(summary.uniqueRequestedBytes, 90);
    expect(summary.downloadedBytes, 90);
  });

  test('DriveByteRangeReader enforces request budget', () async {
    final bytes = Uint8List.fromList(List<int>.generate(100, (i) => i));
    final client = _ByteDriveHttpClient({'file-4': bytes});
    final reader = DriveByteRangeReader(
      driveHttpClient: client,
      driveFileId: 'file-4',
      resourceKey: null,
      fileSize: bytes.length,
      fetchPolicy: DriveByteRangeFetchPolicy.exact,
      readBudget: const DriveRangeReadBudget(maxRequestCount: 1),
    );

    await reader.read(ByteRange(0, 5));
    await expectLater(
      () => reader.read(ByteRange(10, 15)),
      throwsA(isA<DriveRangeBudgetExceeded>()),
    );
  });
}

class _ByteDriveHttpClient extends DriveHttpClient {
  _ByteDriveHttpClient(this.bytesByFileId)
    : super(authRepository: _FakeAuthRepository());

  final Map<String, Uint8List> bytesByFileId;

  @override
  Future<Uint8List> downloadBytes({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    final bytes = bytesByFileId[fileId];
    if (bytes == null) {
      throw StateError('Missing bytes for $fileId');
    }
    if (rangeHeader == null || rangeHeader.isEmpty) {
      return bytes;
    }
    final match = RegExp(r'^bytes=(\d+)-(\d+)$').firstMatch(rangeHeader);
    if (match == null) {
      throw StateError('Unsupported range header: $rangeHeader');
    }
    final start = int.parse(match.group(1)!);
    final inclusiveEnd = int.parse(match.group(2)!);
    final end = inclusiveEnd >= bytes.length ? bytes.length : inclusiveEnd + 1;
    if (start >= end) {
      return Uint8List(0);
    }
    return Uint8List.fromList(bytes.sublist(start, end));
  }
}

class _FakeAuthRepository implements DriveAuthRepository {
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
    throw UnimplementedError();
  }
}
