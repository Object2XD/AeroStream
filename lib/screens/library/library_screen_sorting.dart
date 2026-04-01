import '../../models/library_models.dart';
import '../../models/track_item.dart';
import 'library_screen_types.dart';

List<T> _sortedCopy<T>(List<T> items, int Function(T a, T b) compare) {
  final sorted = [...items];
  sorted.sort(compare);
  return sorted;
}

List<LibraryAlbum> sortLibraryAlbums(
  List<LibraryAlbum> items,
  LibrarySortKey sortBy,
) {
  switch (sortBy) {
    case LibrarySortKey.artist:
      return _sortedCopy(items, (a, b) => a.artist.compareTo(b.artist));
    case LibrarySortKey.year:
      return _sortedCopy(items, (a, b) => b.year.compareTo(a.year));
    case LibrarySortKey.title:
    default:
      return _sortedCopy(items, (a, b) => a.title.compareTo(b.title));
  }
}

List<LibraryArtist> sortLibraryArtists(
  List<LibraryArtist> items,
  LibrarySortKey sortBy,
) {
  switch (sortBy) {
    case LibrarySortKey.songCount:
      return _sortedCopy(items, (a, b) => b.songCount.compareTo(a.songCount));
    case LibrarySortKey.name:
    default:
      return _sortedCopy(items, (a, b) => a.name.compareTo(b.name));
  }
}

List<LibraryAlbumArtist> sortLibraryAlbumArtists(
  List<LibraryAlbumArtist> items,
  LibrarySortKey sortBy,
) {
  switch (sortBy) {
    case LibrarySortKey.albumCount:
      return _sortedCopy(items, (a, b) => b.albumCount.compareTo(a.albumCount));
    case LibrarySortKey.name:
    default:
      return _sortedCopy(items, (a, b) => a.name.compareTo(b.name));
  }
}

List<LibraryGenre> sortLibraryGenres(
  List<LibraryGenre> items,
  LibrarySortKey sortBy,
) {
  switch (sortBy) {
    case LibrarySortKey.songCount:
      return _sortedCopy(items, (a, b) => b.songCount.compareTo(a.songCount));
    case LibrarySortKey.name:
    default:
      return _sortedCopy(items, (a, b) => a.name.compareTo(b.name));
  }
}

List<TrackItem> sortLibrarySongs(List<TrackItem> items, LibrarySortKey sortBy) {
  switch (sortBy) {
    case LibrarySortKey.artist:
      return _sortedCopy(items, (a, b) => a.artist.compareTo(b.artist));
    case LibrarySortKey.duration:
      return _sortedCopy(
        items,
        (a, b) => b.durationSeconds.compareTo(a.durationSeconds),
      );
    case LibrarySortKey.title:
    default:
      return _sortedCopy(items, (a, b) => a.title.compareTo(b.title));
  }
}
