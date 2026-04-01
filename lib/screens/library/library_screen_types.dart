enum LibrarySortKey {
  title('Title'),
  artist('Artist'),
  year('Year'),
  name('Name'),
  songCount('Song Count'),
  albumCount('Album Count'),
  duration('Duration');

  const LibrarySortKey(this.label);

  final String label;
}

class LibraryTabSection {
  const LibraryTabSection({
    required this.defaultSort,
    required this.sortOptions,
    required this.supportsViewToggle,
  });

  final LibrarySortKey defaultSort;
  final List<LibrarySortKey> sortOptions;
  final bool supportsViewToggle;
}
