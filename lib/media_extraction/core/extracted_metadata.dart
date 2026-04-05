class ExtractedMetadata {
  const ExtractedMetadata({
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.trackNumber,
    this.discNumber,
    this.durationMs,
  });

  final String? title;
  final String? artist;
  final String? album;
  final String? albumArtist;
  final String? genre;
  final int? year;
  final int? trackNumber;
  final int? discNumber;
  final int? durationMs;

  bool get hasAnyData =>
      title != null ||
      artist != null ||
      album != null ||
      albumArtist != null ||
      genre != null ||
      year != null ||
      trackNumber != null ||
      discNumber != null ||
      durationMs != null;

  ExtractedMetadata merge(ExtractedMetadata other) {
    return ExtractedMetadata(
      title: title ?? other.title,
      artist: artist ?? other.artist,
      album: album ?? other.album,
      albumArtist: albumArtist ?? other.albumArtist,
      genre: genre ?? other.genre,
      year: year ?? other.year,
      trackNumber: trackNumber ?? other.trackNumber,
      discNumber: discNumber ?? other.discNumber,
      durationMs: durationMs ?? other.durationMs,
    );
  }
}
