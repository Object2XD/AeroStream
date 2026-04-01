class TrackItem {
  const TrackItem({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.durationSeconds,
    required this.imageUrl,
  });

  final int id;
  final String title;
  final String artist;
  final String album;
  final int durationSeconds;
  final String imageUrl;

  String get durationLabel => formatTrackTimestamp(durationSeconds.toDouble());
}

String formatTrackTimestamp(double seconds) {
  final safeSeconds = seconds.isFinite ? seconds.clamp(0, 359999).round() : 0;
  final hours = safeSeconds ~/ 3600;
  final minutes = (safeSeconds % 3600) ~/ 60;
  final remainderSeconds = safeSeconds % 60;

  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:${remainderSeconds.toString().padLeft(2, '0')}';
  }

  return '$minutes:${remainderSeconds.toString().padLeft(2, '0')}';
}

String formatQueueDuration(Iterable<TrackItem> tracks) {
  final totalSeconds = tracks.fold<int>(
    0,
    (sum, track) => sum + track.durationSeconds,
  );
  final hours = totalSeconds ~/ 3600;
  final minutes = (totalSeconds % 3600) ~/ 60;

  if (hours > 0) {
    return '$hours hr $minutes min';
  }

  return '$minutes min';
}
