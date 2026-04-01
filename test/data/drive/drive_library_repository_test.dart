import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aero_stream/data/database/app_database.dart';
import 'package:aero_stream/data/drive/drive_library_repository.dart';
import 'package:aero_stream/data/drive/drive_scan_models.dart';

void main() {
  late AppDatabase database;
  late DriveLibraryRepository repository;

  setUp(() async {
    database = AppDatabase(NativeDatabase.memory());
    repository = DriveLibraryRepository(database);

    await database.setActiveAccount(
      SyncAccountsCompanion.insert(
        providerAccountId: 'account-1',
        email: 'listener@example.com',
        displayName: 'Listener',
        authKind: 'test',
        connectedAt: DateTime(2026, 3, 30),
        isActive: const Value(true),
      ),
    );
    final account = await database.getActiveAccount();
    await database.upsertRoot(
      SyncRootsCompanion.insert(
        accountId: account!.id,
        folderId: 'root-folder',
        folderName: 'Library',
        parentFolderId: const Value('root'),
        syncState: Value(DriveScanJobState.completed.value),
      ),
    );
    final root = await database.getRootByFolderId('root-folder');

    await database.upsertTrack(
      TracksCompanion.insert(
        rootId: root!.id,
        driveFileId: 'pending-track',
        fileName: 'pending.mp3',
        title: 'Pending Song',
        artist: '',
        album: '',
        albumArtist: '',
        genre: '',
        mimeType: 'audio/mpeg',
        metadataStatus: Value(TrackMetadataStatus.pending.value),
        artworkStatus: Value(TrackArtworkStatus.pending.value),
        indexStatus: Value(TrackIndexStatus.active.value),
      ),
    );
    await database.upsertTrack(
      TracksCompanion.insert(
        rootId: root.id,
        driveFileId: 'ready-track',
        fileName: 'ready.mp3',
        title: 'Ready Song',
        artist: 'Artist A',
        album: 'Album A',
        albumArtist: 'Artist A',
        genre: 'Electronic',
        mimeType: 'audio/mpeg',
        metadataStatus: Value(TrackMetadataStatus.ready.value),
        artworkStatus: Value(TrackArtworkStatus.ready.value),
        indexStatus: Value(TrackIndexStatus.active.value),
      ),
    );
    await database.upsertTrack(
      TracksCompanion.insert(
        rootId: root.id,
        driveFileId: 'removed-track',
        fileName: 'removed.mp3',
        title: 'Removed Song',
        artist: 'Artist B',
        album: 'Album B',
        albumArtist: 'Artist B',
        genre: 'Jazz',
        mimeType: 'audio/mpeg',
        metadataStatus: Value(TrackMetadataStatus.ready.value),
        artworkStatus: Value(TrackArtworkStatus.ready.value),
        indexStatus: Value(TrackIndexStatus.removed.value),
      ),
    );
  });

  tearDown(() async {
    await database.close();
  });

  test('songs include pending tracks but exclude removed tracks', () async {
    final songs = await repository.watchSongs().first;
    final titles = songs.map((track) => track.title).toList(growable: false);

    expect(titles, contains('Pending Song'));
    expect(titles, contains('Ready Song'));
    expect(titles, isNot(contains('Removed Song')));
  });

  test('aggregate tabs only include metadata-ready active tracks', () async {
    final albums = await repository.watchAlbums().first;
    final artists = await repository.watchArtists().first;
    final genres = await repository.watchGenres().first;

    expect(albums.map((album) => album.title), ['Album A']);
    expect(artists.map((artist) => artist.name), ['Artist A']);
    expect(genres.map((genre) => genre.name), ['Electronic']);
  });
}
