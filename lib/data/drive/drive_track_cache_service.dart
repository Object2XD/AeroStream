import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../database/app_database.dart';
import 'drive_http_client.dart';

class DriveTrackCacheService {
  DriveTrackCacheService({
    required AppDatabase database,
    required DriveHttpClient driveHttpClient,
  }) : _database = database,
       _driveHttpClient = driveHttpClient;

  final AppDatabase _database;
  final DriveHttpClient _driveHttpClient;

  Future<File> ensureCachedTrackFile(Track track) async {
    final existingPath = track.cachePath;
    if (existingPath != null && existingPath.isNotEmpty) {
      final existingFile = File(existingPath);
      if (await existingFile.exists()) {
        return existingFile;
      }
    }

    final cacheDirectory = await _cacheDirectory();
    final extension = _fileExtension(
      track.fileName,
      fallbackMimeType: track.mimeType,
    );
    final targetFile = File(
      p.join(cacheDirectory.path, 'track-${track.id}$extension'),
    );
    final response = await _driveHttpClient.downloadFile(
      fileId: track.driveFileId,
      resourceKey: track.resourceKey,
    );

    final sink = targetFile.openWrite();
    await response.stream.pipe(sink);
    await _database.updateTrackCache(
      track.id,
      cachePathValue: targetFile.path,
      cacheStatusValue: 'cached',
    );
    return targetFile;
  }

  Future<void> removeCachedTrackFile(Track track) async {
    final cachePath = track.cachePath;
    if (cachePath == null || cachePath.isEmpty) {
      return;
    }

    final file = File(cachePath);
    if (await file.exists()) {
      await file.delete();
    }
    await _database.updateTrackCache(
      track.id,
      cachePathValue: null,
      cacheStatusValue: 'none',
    );
  }

  Future<void> removeCachedTrackFiles(Iterable<Track> tracks) async {
    final uniqueTracks = {
      for (final track in tracks) track.id: track,
    }.values.toList(growable: false);
    if (uniqueTracks.isEmpty) {
      return;
    }

    for (final track in uniqueTracks) {
      final cachePath = track.cachePath;
      if (cachePath == null || cachePath.isEmpty) {
        continue;
      }

      final file = File(cachePath);
      if (await file.exists()) {
        await file.delete();
      }
    }

    await _database.clearTrackCachesByIds(uniqueTracks.map((track) => track.id));
  }

  Future<Directory> _cacheDirectory() async {
    final directory = Directory(
      p.join((await getApplicationSupportDirectory()).path, 'track-cache'),
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  String _fileExtension(
    String fileName, {
    required String fallbackMimeType,
  }) {
    final fromName = p.extension(fileName);
    if (fromName.isNotEmpty) {
      return fromName;
    }

    return switch (fallbackMimeType) {
      'audio/flac' => '.flac',
      'audio/aac' => '.aac',
      'audio/ogg' => '.ogg',
      'audio/opus' => '.opus',
      'audio/wav' || 'audio/x-wav' => '.wav',
      'audio/mp4' || 'audio/x-m4a' => '.m4a',
      _ => '.mp3',
    };
  }
}
