import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import 'drive_auth_repository.dart';
import 'drive_entities.dart';
import 'drive_scan_logger.dart';

class DriveHttpClient {
  const DriveHttpClient({
    required DriveAuthRepository authRepository,
    DriveScanLogger logger = const NoOpDriveScanLogger(),
  }) : _authRepository = authRepository,
       _logger = logger;

  final DriveAuthRepository _authRepository;
  final DriveScanLogger _logger;

  static const folderMimeType = 'application/vnd.google-apps.folder';
  static const _apiBase = 'https://www.googleapis.com/drive/v3';

  Future<List<DriveFolderEntry>> listFolders({String parentId = 'root'}) async {
    final folders = <DriveFolderEntry>[];
    String? nextPageToken;

    do {
      final page = await listFolderPage(
        parentId: parentId,
        pageToken: nextPageToken,
        pageSize: 1000,
      );
      folders.addAll(
        page.items
            .where((entry) => entry.isFolder)
            .map(
              (entry) => DriveFolderEntry(
                id: entry.id,
                name: entry.name,
                parentId: entry.parentIds.isEmpty
                    ? null
                    : entry.parentIds.first,
              ),
            ),
      );
      nextPageToken = page.nextPageToken;
    } while (nextPageToken != null);

    return folders;
  }

  Future<DriveFolderPage> listFolderPage({
    required String parentId,
    String? pageToken,
    int pageSize = 1000,
  }) async {
    final stopwatch = Stopwatch()..start();
    _logger.info(
      prefix: 'DriveHTTP',
      subsystem: 'http',
      operation: 'files_list_start',
      details: <String, Object?>{
        'parentId': parentId,
        'pageToken': pageToken,
        'pageSize': pageSize,
      },
    );
    final json = await _getJson(
      '/files',
      operation: 'files_list_request',
      queryParameters: <String, String>{
        'q': "'$parentId' in parents and trashed = false",
        'fields':
            'files(id,name,mimeType,modifiedTime,resourceKey,size,md5Checksum,parents),nextPageToken',
        'orderBy': 'folder,name_natural',
        'pageSize': '$pageSize',
        if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
      },
      details: <String, Object?>{
        'parentId': parentId,
        'pageToken': pageToken,
        'pageSize': pageSize,
      },
    );

    final items = (json['files'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(_mapObjectEntry)
        .toList(growable: false);
    _logger.info(
      prefix: 'DriveHTTP',
      subsystem: 'http',
      operation: 'files_list_success',
      context: DriveScanLogContext(elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{
        'parentId': parentId,
        'itemCount': items.length,
        'nextPageToken': json['nextPageToken'] as String?,
      },
    );

    return DriveFolderPage(
      items: items,
      nextPageToken: json['nextPageToken'] as String?,
    );
  }

  Future<List<DriveFileEntry>> listAudioFilesRecursively(
    String parentId,
  ) async {
    final queue = <String>[parentId];
    final results = <DriveFileEntry>[];

    while (queue.isNotEmpty) {
      final currentFolder = queue.removeLast();
      String? nextPageToken;
      do {
        final page = await listFolderPage(
          parentId: currentFolder,
          pageToken: nextPageToken,
          pageSize: 1000,
        );

        for (final entry in page.items) {
          if (entry.isFolder) {
            queue.add(entry.id);
            continue;
          }
          if (!_isAudioFile(name: entry.name, mimeType: entry.mimeType)) {
            continue;
          }
          results.add(
            DriveFileEntry(
              id: entry.id,
              name: entry.name,
              mimeType: entry.mimeType,
              modifiedTime: entry.modifiedTime,
              resourceKey: entry.resourceKey,
              sizeBytes: entry.sizeBytes,
              md5Checksum: entry.md5Checksum,
            ),
          );
        }

        nextPageToken = page.nextPageToken;
      } while (nextPageToken != null);
    }

    return results;
  }

  Future<Map<String, dynamic>> getFolderMetadata(String folderId) {
    return _getJson(
      '/files/$folderId',
      operation: 'folder_metadata_request',
      queryParameters: const <String, String>{'fields': 'id,name,parents'},
      details: <String, Object?>{'folderId': folderId},
    );
  }

  Future<String> getStartPageToken() async {
    final stopwatch = Stopwatch()..start();
    _logger.info(
      prefix: 'DriveHTTP',
      subsystem: 'http',
      operation: 'changes_start_page_token_start',
    );
    final json = await _getJson(
      '/changes/startPageToken',
      operation: 'changes_start_page_token_request',
    );
    final token = json['startPageToken'] as String?;
    if (token == null || token.isEmpty) {
      _logger.error(
        prefix: 'DriveHTTP',
        subsystem: 'http',
        operation: 'changes_start_page_token_missing',
        context: DriveScanLogContext(elapsedMs: stopwatch.elapsedMilliseconds),
        message: 'Drive changes start page token is missing.',
      );
      throw const DriveAuthException(
        'Drive changes start page token is missing.',
      );
    }
    _logger.info(
      prefix: 'DriveHTTP',
      subsystem: 'http',
      operation: 'changes_start_page_token_success',
      context: DriveScanLogContext(elapsedMs: stopwatch.elapsedMilliseconds),
      details: const <String, Object?>{'startPageToken': 'present'},
    );
    return token;
  }

  Future<DriveChangePage> listChangesPage({
    required String pageToken,
    int pageSize = 1000,
  }) async {
    final stopwatch = Stopwatch()..start();
    _logger.info(
      prefix: 'DriveHTTP',
      subsystem: 'http',
      operation: 'changes_list_start',
      details: <String, Object?>{'pageToken': pageToken, 'pageSize': pageSize},
    );
    final json = await _getJson(
      '/changes',
      operation: 'changes_list_request',
      queryParameters: <String, String>{
        'pageToken': pageToken,
        'pageSize': '$pageSize',
        'includeRemoved': 'true',
        'restrictToMyDrive': 'true',
        'supportsAllDrives': 'false',
        'spaces': 'drive',
        'fields':
            'changes(fileId,removed,file(id,name,mimeType,modifiedTime,resourceKey,size,md5Checksum,parents,trashed)),nextPageToken,newStartPageToken',
      },
      details: <String, Object?>{'pageToken': pageToken, 'pageSize': pageSize},
    );

    final changes = (json['changes'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map((entry) {
          final file = entry['file'] as Map<String, dynamic>?;
          return DriveChangeEntry(
            fileId: entry['fileId'] as String? ?? '',
            isRemoved: entry['removed'] as bool? ?? false,
            file: file == null ? null : _mapObjectEntry(file),
          );
        })
        .where((entry) => entry.fileId.isNotEmpty)
        .toList(growable: false);
    _logger.info(
      prefix: 'DriveHTTP',
      subsystem: 'http',
      operation: 'changes_list_success',
      context: DriveScanLogContext(elapsedMs: stopwatch.elapsedMilliseconds),
      details: <String, Object?>{
        'changeCount': changes.length,
        'nextPageToken': json['nextPageToken'] as String?,
        'newStartPageToken': json['newStartPageToken'] as String?,
      },
    );

    return DriveChangePage(
      changes: changes,
      nextPageToken: json['nextPageToken'] as String?,
      newStartPageToken: json['newStartPageToken'] as String?,
    );
  }

  Future<http.StreamedResponse> downloadFile({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    final stopwatch = Stopwatch()..start();
    try {
      final response = await _authRepository.withClient((client) async {
        final uri = Uri.parse('$_apiBase/files/$fileId').replace(
          queryParameters: <String, String>{
            'alt': 'media',
            if (resourceKey != null && resourceKey.isNotEmpty)
              'resourceKey': resourceKey,
          },
        );
        final request = http.Request('GET', uri);
        if (rangeHeader != null && rangeHeader.isNotEmpty) {
          request.headers[HttpHeaders.rangeHeader] = rangeHeader;
        }
        return client.send(request);
      });
      return response;
    } catch (error, stackTrace) {
      _logger.error(
        prefix: 'DriveHTTP',
        subsystem: 'http',
        operation: 'download_file_fail',
        context: DriveScanLogContext(
          driveFileId: fileId,
          elapsedMs: stopwatch.elapsedMilliseconds,
        ),
        details: <String, Object?>{
          'rangeHeader': rangeHeader,
          'resourceKey': resourceKey,
        },
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<Uint8List> downloadBytes({
    required String fileId,
    String? resourceKey,
    String? rangeHeader,
  }) async {
    final stopwatch = Stopwatch()..start();
    final response = await downloadFile(
      fileId: fileId,
      resourceKey: resourceKey,
      rangeHeader: rangeHeader,
    );
    if (response.statusCode != HttpStatus.ok &&
        response.statusCode != HttpStatus.partialContent) {
      final body = await response.stream.bytesToString();
      final exception = createGoogleApiException(
        context: 'Google Drive download failed',
        response: http.Response(body, response.statusCode),
      );
      _logger.error(
        prefix: 'DriveHTTP',
        subsystem: 'http',
        operation: 'download_bytes_fail',
        context: DriveScanLogContext(
          driveFileId: fileId,
          elapsedMs: stopwatch.elapsedMilliseconds,
        ),
        details: <String, Object?>{
          'statusCode': response.statusCode,
          'rangeHeader': rangeHeader,
          'resourceKey': resourceKey,
        },
        error: exception,
      );
      throw exception;
    }
    final builder = BytesBuilder(copy: false);
    await for (final chunk in response.stream) {
      builder.add(chunk);
    }
    final bytes = builder.takeBytes();
    return bytes;
  }

  Future<Map<String, dynamic>> _getJson(
    String path, {
    required String operation,
    Map<String, String>? queryParameters,
    Map<String, Object?> details = const <String, Object?>{},
  }) async {
    final stopwatch = Stopwatch()..start();
    _logger.info(
      prefix: 'DriveHTTP',
      subsystem: 'http',
      operation: operation,
      details: details,
    );
    try {
      final response = await _authRepository.withClient((client) async {
        return client.get(
          Uri.parse('$_apiBase$path').replace(queryParameters: queryParameters),
        );
      });

      if (response.statusCode != HttpStatus.ok) {
        final exception = createGoogleApiException(
          context: 'Google Drive request failed',
          response: response,
        );
        _logger.error(
          prefix: 'DriveHTTP',
          subsystem: 'http',
          operation: '${operation}_fail',
          context: DriveScanLogContext(
            elapsedMs: stopwatch.elapsedMilliseconds,
          ),
          details: <String, Object?>{
            ...details,
            'statusCode': response.statusCode,
          },
          error: exception,
        );
        throw exception;
      }

      _logger.info(
        prefix: 'DriveHTTP',
        subsystem: 'http',
        operation: '${operation}_success',
        context: DriveScanLogContext(elapsedMs: stopwatch.elapsedMilliseconds),
        details: <String, Object?>{
          ...details,
          'statusCode': response.statusCode,
        },
      );
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (error, stackTrace) {
      _logger.error(
        prefix: 'DriveHTTP',
        subsystem: 'http',
        operation: '${operation}_exception',
        context: DriveScanLogContext(elapsedMs: stopwatch.elapsedMilliseconds),
        details: details,
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  DriveObjectEntry _mapObjectEntry(Map<String, dynamic> entry) {
    return DriveObjectEntry(
      id: entry['id'] as String,
      name: entry['name'] as String? ?? 'Untitled',
      mimeType: entry['mimeType'] as String? ?? '',
      modifiedTime: DateTime.tryParse(entry['modifiedTime'] as String? ?? ''),
      resourceKey: entry['resourceKey'] as String?,
      sizeBytes: int.tryParse(entry['size']?.toString() ?? ''),
      md5Checksum: entry['md5Checksum'] as String?,
      parentIds: (entry['parents'] as List<dynamic>? ?? const [])
          .cast<String>(),
    );
  }

  bool _isAudioFile({required String name, required String mimeType}) {
    if (mimeType.startsWith('audio/')) {
      return true;
    }

    final lowerName = name.toLowerCase();
    return lowerName.endsWith('.mp3') ||
        lowerName.endsWith('.m4a') ||
        lowerName.endsWith('.aac') ||
        lowerName.endsWith('.flac') ||
        lowerName.endsWith('.ogg') ||
        lowerName.endsWith('.opus') ||
        lowerName.endsWith('.wav');
  }
}
