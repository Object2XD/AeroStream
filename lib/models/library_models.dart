import 'dart:convert';

enum LibraryTab {
  albums('Albums'),
  artists('Artists'),
  albumArtists('Album Artists'),
  genres('Genres'),
  songs('Songs');

  const LibraryTab(this.label);

  final String label;

  bool get supportsViewToggle => this != LibraryTab.songs;
}

enum LibraryViewMode { grid, list }

class LibraryAlbum {
  const LibraryAlbum({
    required this.id,
    required this.title,
    required this.artist,
    required this.year,
    required this.imageUrl,
  });

  final String id;
  final String title;
  final String artist;
  final int year;
  final String imageUrl;

  String get subtitle => year > 0 ? '$artist • $year' : artist;
}

class LibraryArtist {
  const LibraryArtist({
    required this.id,
    required this.name,
    required this.songCount,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final int songCount;
  final String imageUrl;

  String get subtitle => '$songCount songs';
}

class LibraryAlbumArtist {
  const LibraryAlbumArtist({
    required this.id,
    required this.name,
    required this.albumCount,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final int albumCount;
  final String imageUrl;

  String get subtitle => '$albumCount albums';
}

class LibraryGenre {
  const LibraryGenre({
    required this.id,
    required this.name,
    required this.songCount,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final int songCount;
  final String imageUrl;

  String get subtitle => '$songCount songs';
}

enum LibrarySongSort { title, artist, duration }

enum LibraryAlbumSort { title, artist, year }

enum LibraryArtistSort { name, songCount }

enum LibraryAlbumArtistSort { name, albumCount }

enum LibraryGenreSort { name, songCount }

enum LibraryProjectionBackfillState { pending, running, ready, failed }

class LibraryCursor {
  const LibraryCursor(this.value);

  final String value;
}

class LibraryPage<T> {
  const LibraryPage({
    required this.items,
    required this.totalCount,
    required this.nextCursor,
    required this.hasMore,
    required this.revision,
  });

  final List<T> items;
  final int totalCount;
  final LibraryCursor? nextCursor;
  final bool hasMore;
  final int revision;
}

class LibrarySlice<T> {
  const LibrarySlice({
    required this.offset,
    required this.items,
    required this.totalCount,
    required this.revision,
  });

  final int offset;
  final List<T> items;
  final int totalCount;
  final int revision;
}

class LibraryCounts {
  const LibraryCounts({
    required this.trackCount,
    required this.albumCount,
    required this.artistCount,
    required this.albumArtistCount,
    required this.genreCount,
  });

  final int trackCount;
  final int albumCount;
  final int artistCount;
  final int albumArtistCount;
  final int genreCount;
}

class LibraryProjectionStatusSnapshot {
  const LibraryProjectionStatusSnapshot({
    required this.state,
    required this.revision,
    this.errorMessage,
  });

  final LibraryProjectionBackfillState state;
  final int revision;
  final String? errorMessage;

  bool get isReady => state == LibraryProjectionBackfillState.ready;
  bool get isOptimizing =>
      state == LibraryProjectionBackfillState.pending ||
      state == LibraryProjectionBackfillState.running;
}

class DecodedAlbumRouteKey {
  const DecodedAlbumRouteKey({required this.albumArtist, required this.album});

  final String albumArtist;
  final String album;
}

String albumRouteKey({required String albumArtist, required String album}) {
  return Uri.encodeComponent(
    jsonEncode(<String, String>{'albumArtist': albumArtist, 'album': album}),
  );
}

DecodedAlbumRouteKey? decodeAlbumRouteKey(String value) {
  try {
    final decoded =
        jsonDecode(Uri.decodeComponent(value)) as Map<String, dynamic>;
    final albumArtist = decoded['albumArtist'] as String?;
    final album = decoded['album'] as String?;
    if (albumArtist == null || album == null) {
      return null;
    }
    return DecodedAlbumRouteKey(albumArtist: albumArtist, album: album);
  } catch (_) {
    return null;
  }
}
