import 'package:aero_stream/data/mock_library.dart';
import 'package:aero_stream/models/library_models.dart';
import 'package:aero_stream/screens/library/library_screen_sections.dart';
import 'package:aero_stream/screens/library/library_screen_sorting.dart';
import 'package:aero_stream/screens/library/library_screen_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('libraryTabSections', () {
    test('exposes expected defaults and options for each tab', () {
      expect(createInitialLibrarySortKeys(), {
        LibraryTab.albums: LibrarySortKey.title,
        LibraryTab.artists: LibrarySortKey.name,
        LibraryTab.albumArtists: LibrarySortKey.name,
        LibraryTab.genres: LibrarySortKey.name,
        LibraryTab.songs: LibrarySortKey.title,
      });

      expect(libraryTabSections[LibraryTab.albums]!.sortOptions, const [
        LibrarySortKey.title,
        LibrarySortKey.artist,
        LibrarySortKey.year,
      ]);
      expect(libraryTabSections[LibraryTab.songs]!.sortOptions, const [
        LibrarySortKey.title,
        LibrarySortKey.artist,
        LibrarySortKey.duration,
      ]);
      expect(libraryTabSections[LibraryTab.songs]!.supportsViewToggle, isFalse);
      expect(libraryTabSections[LibraryTab.albums]!.supportsViewToggle, isTrue);
    });
  });

  group('library sorting helpers', () {
    test('sortLibraryAlbums keeps year sort descending', () {
      final sorted = sortLibraryAlbums(libraryAlbums, LibrarySortKey.year);

      expect(sorted.map((album) => album.id).toList(), ['1', '2', '3', '4']);
    });

    test('sortLibrarySongs keeps duration sort descending', () {
      final sorted = sortLibrarySongs(librarySongs, LibrarySortKey.duration);

      expect(sorted.map((song) => song.id).toList(), [104, 105, 102, 101, 103]);
    });
  });
}
