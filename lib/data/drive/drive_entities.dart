enum DriveAuthSessionState {
  ready('ready'),
  reauthRequired('reauth_required');

  const DriveAuthSessionState(this.value);

  final String value;
}

const driveAuthReconnectRequiredMessage =
    'Google Drive session needs to be reconnected on this device.';
const driveSyncReconnectRequiredMessage =
    'Reconnect Google Drive to continue syncing.';

class DriveAccountProfile {
  const DriveAccountProfile({
    required this.providerAccountId,
    required this.email,
    required this.displayName,
    required this.authKind,
  });

  final String providerAccountId;
  final String email;
  final String displayName;
  final String authKind;
}

class DriveFolderEntry {
  const DriveFolderEntry({
    required this.id,
    required this.name,
    required this.parentId,
  });

  final String id;
  final String name;
  final String? parentId;
}

class DriveFileEntry {
  const DriveFileEntry({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.modifiedTime,
    required this.resourceKey,
    required this.sizeBytes,
    required this.md5Checksum,
  });

  final String id;
  final String name;
  final String mimeType;
  final DateTime? modifiedTime;
  final String? resourceKey;
  final int? sizeBytes;
  final String? md5Checksum;
}

class DriveObjectEntry {
  const DriveObjectEntry({
    required this.id,
    required this.name,
    required this.mimeType,
    required this.modifiedTime,
    required this.resourceKey,
    required this.sizeBytes,
    required this.md5Checksum,
    required this.parentIds,
  });

  final String id;
  final String name;
  final String mimeType;
  final DateTime? modifiedTime;
  final String? resourceKey;
  final int? sizeBytes;
  final String? md5Checksum;
  final List<String> parentIds;

  bool get isFolder => mimeType == 'application/vnd.google-apps.folder';
}

class DriveFolderPage {
  const DriveFolderPage({required this.items, required this.nextPageToken});

  final List<DriveObjectEntry> items;
  final String? nextPageToken;
}

class DriveChangeEntry {
  const DriveChangeEntry({
    required this.fileId,
    required this.isRemoved,
    required this.file,
  });

  final String fileId;
  final bool isRemoved;
  final DriveObjectEntry? file;
}

class DriveChangePage {
  const DriveChangePage({
    required this.changes,
    required this.nextPageToken,
    required this.newStartPageToken,
  });

  final List<DriveChangeEntry> changes;
  final String? nextPageToken;
  final String? newStartPageToken;
}

class DriveAudioMetadata {
  const DriveAudioMetadata({
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArtist,
    required this.genre,
    required this.year,
    required this.trackNumber,
    required this.discNumber,
    required this.durationMs,
    required this.artworkUri,
  });

  final String title;
  final String artist;
  final String album;
  final String albumArtist;
  final String genre;
  final int? year;
  final int trackNumber;
  final int discNumber;
  final int durationMs;
  final String? artworkUri;
}
