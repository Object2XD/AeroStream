import '../../models/library_models.dart';
import 'library_screen_types.dart';

final Map<LibraryTab, LibraryTabSection> libraryTabSections = {
  LibraryTab.albums: const LibraryTabSection(
    defaultSort: LibrarySortKey.title,
    sortOptions: [
      LibrarySortKey.title,
      LibrarySortKey.artist,
      LibrarySortKey.year,
    ],
    supportsViewToggle: true,
  ),
  LibraryTab.artists: const LibraryTabSection(
    defaultSort: LibrarySortKey.name,
    sortOptions: [LibrarySortKey.name, LibrarySortKey.songCount],
    supportsViewToggle: true,
  ),
  LibraryTab.albumArtists: const LibraryTabSection(
    defaultSort: LibrarySortKey.name,
    sortOptions: [LibrarySortKey.name, LibrarySortKey.albumCount],
    supportsViewToggle: true,
  ),
  LibraryTab.genres: const LibraryTabSection(
    defaultSort: LibrarySortKey.name,
    sortOptions: [LibrarySortKey.name, LibrarySortKey.songCount],
    supportsViewToggle: true,
  ),
  LibraryTab.songs: const LibraryTabSection(
    defaultSort: LibrarySortKey.title,
    sortOptions: [
      LibrarySortKey.title,
      LibrarySortKey.artist,
      LibrarySortKey.duration,
    ],
    supportsViewToggle: false,
  ),
};

Map<LibraryTab, LibrarySortKey> createInitialLibrarySortKeys() {
  return {
    for (final entry in libraryTabSections.entries)
      entry.key: entry.value.defaultSort,
  };
}
