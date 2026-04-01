import 'dart:async';
import 'dart:io';

import 'package:path/path.dart' as p;

import '../database/app_database.dart';
import 'drive_http_client.dart';

class DriveStreamProxy {
  DriveStreamProxy({
    required AppDatabase database,
    required DriveHttpClient driveHttpClient,
  }) : _database = database,
       _driveHttpClient = driveHttpClient;

  final AppDatabase _database;
  final DriveHttpClient _driveHttpClient;

  HttpServer? _server;
  Uri? _baseUri;

  Future<void> start() async {
    if (_server != null) {
      return;
    }

    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server = server;
    _baseUri = Uri.parse('http://127.0.0.1:${server.port}');
    unawaited(server.forEach(_handleRequest));
  }

  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
    _baseUri = null;
  }

  Uri trackUri(int trackId) {
    final baseUri = _baseUri;
    if (baseUri == null) {
      throw StateError('DriveStreamProxy.start() must be called first.');
    }

    return baseUri.replace(path: '/tracks/$trackId/stream');
  }

  Future<void> _handleRequest(HttpRequest request) async {
    try {
      final segments = request.uri.pathSegments;
      if (segments.length != 3 ||
          segments[0] != 'tracks' ||
          segments[2] != 'stream') {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final trackId = int.tryParse(segments[1]);
      if (trackId == null) {
        request.response.statusCode = HttpStatus.badRequest;
        await request.response.close();
        return;
      }

      final track = await _database.getTrackById(trackId);
      if (track == null) {
        request.response.statusCode = HttpStatus.notFound;
        await request.response.close();
        return;
      }

      final cachePath = track.cachePath;
      if (cachePath != null && cachePath.isNotEmpty) {
        final cachedFile = File(cachePath);
        if (await cachedFile.exists()) {
          await _serveLocalFile(request, track, cachedFile);
          return;
        }
      }

      await _proxyRemoteStream(request, track);
    } catch (_) {
      request.response.statusCode = HttpStatus.internalServerError;
      await request.response.close();
    }
  }

  Future<void> _serveLocalFile(
    HttpRequest request,
    Track track,
    File cachedFile,
  ) async {
    final fileLength = await cachedFile.length();
    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
    if (rangeHeader == null || rangeHeader.isEmpty) {
      request.response.headers.contentType = ContentType.parse(
        _contentTypeForMime(track.mimeType),
      );
      request.response.headers.contentLength = fileLength;
      await cachedFile.openRead().pipe(request.response);
      return;
    }

    final byteRange = _parseRange(rangeHeader, fileLength);
    if (byteRange == null) {
      request.response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
      await request.response.close();
      return;
    }

    request.response.statusCode = HttpStatus.partialContent;
    request.response.headers.contentType = ContentType.parse(
      _contentTypeForMime(track.mimeType),
    );
    request.response.headers.set(
      HttpHeaders.contentRangeHeader,
      'bytes ${byteRange.start}-${byteRange.end}/$fileLength',
    );
    request.response.headers.contentLength =
        byteRange.end - byteRange.start + 1;
    await cachedFile
        .openRead(byteRange.start, byteRange.end + 1)
        .pipe(request.response);
  }

  Future<void> _proxyRemoteStream(HttpRequest request, Track track) async {
    final rangeHeader = request.headers.value(HttpHeaders.rangeHeader);
    final remoteResponse = await _driveHttpClient.downloadFile(
      fileId: track.driveFileId,
      resourceKey: track.resourceKey,
      rangeHeader: rangeHeader,
    );

    request.response.statusCode = remoteResponse.statusCode;
    remoteResponse.headers.forEach((key, value) {
      if (key.toLowerCase() == 'transfer-encoding') {
        return;
      }
      request.response.headers.set(key, value);
    });

    await remoteResponse.stream.pipe(request.response);
  }

  _ByteRange? _parseRange(String header, int fileLength) {
    final match = RegExp(r'bytes=(\d*)-(\d*)').firstMatch(header);
    if (match == null) {
      return null;
    }

    final startText = match.group(1);
    final endText = match.group(2);
    int start = int.tryParse(startText ?? '') ?? 0;
    int end = int.tryParse(endText ?? '') ?? (fileLength - 1);

    if (start < 0 || end >= fileLength || start > end) {
      return null;
    }

    return _ByteRange(start: start, end: end);
  }

  String _contentTypeForMime(String mimeType) {
    if (mimeType.isNotEmpty) {
      return mimeType;
    }
    return switch (p.extension(mimeType).toLowerCase()) {
      '.flac' => 'audio/flac',
      '.m4a' => 'audio/mp4',
      '.ogg' => 'audio/ogg',
      '.opus' => 'audio/opus',
      '.wav' => 'audio/wav',
      _ => 'audio/mpeg',
    };
  }
}

class _ByteRange {
  const _ByteRange({
    required this.start,
    required this.end,
  });

  final int start;
  final int end;
}
