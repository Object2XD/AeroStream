import 'dart:async';
import 'dart:convert';

import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

import '../../data/database/app_database.dart';
import '../../data/drive/drive_library_repository.dart';
import '../../data/drive/drive_stream_proxy.dart';
import '../../data/drive/drive_track_cache_service.dart';
import '../../models/track_item.dart';

class PlaybackSnapshot {
  const PlaybackSnapshot({
    required this.queue,
    required this.currentIndex,
    required this.positionSeconds,
    required this.isPlaying,
    required this.favoriteTrackIds,
  });

  final List<TrackItem> queue;
  final int currentIndex;
  final double positionSeconds;
  final bool isPlaying;
  final Set<int> favoriteTrackIds;

  TrackItem? get currentTrack =>
      currentIndex >= 0 && currentIndex < queue.length ? queue[currentIndex] : null;
}

class PlaybackRepository {
  PlaybackRepository({
    required AppDatabase database,
    required DriveLibraryRepository libraryRepository,
    required DriveStreamProxy driveStreamProxy,
    required DriveTrackCacheService trackCacheService,
  }) : _database = database,
       _libraryRepository = libraryRepository,
       _driveStreamProxy = driveStreamProxy,
       _trackCacheService = trackCacheService;

  final AppDatabase _database;
  final DriveLibraryRepository _libraryRepository;
  final DriveStreamProxy _driveStreamProxy;
  final DriveTrackCacheService _trackCacheService;

  final AudioPlayer _player = AudioPlayer();
  final StreamController<PlaybackSnapshot> _controller =
      StreamController<PlaybackSnapshot>.broadcast();

  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<int?>? _indexSubscription;
  StreamSubscription<PlayerState>? _playerStateSubscription;

  PlaybackSnapshot _snapshot = const PlaybackSnapshot(
    queue: <TrackItem>[],
    currentIndex: -1,
    positionSeconds: 0,
    isPlaying: false,
    favoriteTrackIds: <int>{},
  );
  int? _lastStartedTrackId;
  bool _initialized = false;

  Stream<PlaybackSnapshot> get stream => _controller.stream;

  PlaybackSnapshot get currentState => _snapshot;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    _initialized = true;
    await _driveStreamProxy.start();
    await _database.ensurePlaybackStateRow();
    await _restoreState();

    _positionSubscription = _player.positionStream.listen((_) => _publish());
    _indexSubscription = _player.currentIndexStream.listen((_) => _publish());
    _playerStateSubscription = _player.playerStateStream.listen((state) async {
      if (state.processingState == ProcessingState.completed &&
          (_player.currentIndex ?? -1) >= (_snapshot.queue.length - 1)) {
        await _player.pause();
      }
      _publish();
    });

    _publish();
  }

  Future<void> dispose() async {
    await _positionSubscription?.cancel();
    await _indexSubscription?.cancel();
    await _playerStateSubscription?.cancel();
    await _player.dispose();
    await _controller.close();
    await _driveStreamProxy.stop();
  }

  Future<void> togglePlayPause() async {
    await initialize();

    if (_snapshot.queue.isEmpty) {
      return;
    }

    if (_player.playing) {
      await _player.pause();
      return;
    }

    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero, index: _player.currentIndex);
    }
    await _player.play();
  }

  Future<void> seekTo(double seconds) async {
    await initialize();
    await _player.seek(Duration(milliseconds: (seconds * 1000).round()));
  }

  Future<void> playTrack(TrackItem track, {List<TrackItem>? queue}) async {
    await initialize();

    final resolvedQueue = queue ?? _snapshot.queue;
    if (resolvedQueue.isEmpty) {
      await _setQueue([track], initialIndex: 0);
      return;
    }

    final index = resolvedQueue.indexWhere((item) => item.id == track.id);
    if (index >= 0) {
      await _setQueue(resolvedQueue, initialIndex: index);
      return;
    }

    final updatedQueue = <TrackItem>[
      track,
      ...resolvedQueue.where((item) => item.id != track.id),
    ];
    await _setQueue(updatedQueue, initialIndex: 0);
  }

  Future<void> playNext() async {
    await initialize();
    if (_snapshot.queue.isEmpty) {
      return;
    }

    if ((_player.currentIndex ?? -1) >= _snapshot.queue.length - 1) {
      final currentTrack = _snapshot.currentTrack;
      if (currentTrack != null) {
        await _player.seek(
          Duration(seconds: currentTrack.durationSeconds),
          index: _player.currentIndex,
        );
      }
      await _player.pause();
      return;
    }

    await _player.seekToNext();
    await _player.play();
  }

  Future<void> playPrevious() async {
    await initialize();
    if (_snapshot.queue.isEmpty) {
      return;
    }

    if (_player.position > const Duration(seconds: 3) ||
        (_player.currentIndex ?? 0) == 0) {
      await _player.seek(Duration.zero, index: _player.currentIndex);
      return;
    }

    await _player.seekToPrevious();
    await _player.play();
  }

  Future<void> playFromQueueIndex(int index) async {
    await initialize();
    if (index < 0 || index >= _snapshot.queue.length) {
      return;
    }

    await _player.seek(Duration.zero, index: index);
    await _player.play();
  }

  Future<void> toggleFavorite() async {
    final currentTrack = _snapshot.currentTrack;
    if (currentTrack == null) {
      return;
    }

    final updatedFavorites = Set<int>.from(_snapshot.favoriteTrackIds);
    if (!updatedFavorites.add(currentTrack.id)) {
      updatedFavorites.remove(currentTrack.id);
    }
    await _database.setFavorite(
      currentTrack.id,
      updatedFavorites.contains(currentTrack.id),
    );
    _snapshot = PlaybackSnapshot(
      queue: _snapshot.queue,
      currentIndex: _snapshot.currentIndex,
      positionSeconds: _snapshot.positionSeconds,
      isPlaying: _snapshot.isPlaying,
      favoriteTrackIds: updatedFavorites,
    );
    _controller.add(_snapshot);
  }

  Future<void> _setQueue(
    List<TrackItem> queue, {
    required int initialIndex,
    int initialPositionMs = 0,
    bool autoPlay = true,
  }) async {
    final audioSources = <AudioSource>[
      for (final track in queue)
        AudioSource.uri(
          _driveStreamProxy.trackUri(track.id),
          tag: MediaItem(
            id: track.id.toString(),
            title: track.title,
            album: track.album,
            artist: track.artist,
            artUri: track.imageUrl.isEmpty ? null : Uri.tryParse(track.imageUrl),
          ),
        ),
    ];

    await _player.setAudioSources(
      audioSources,
      initialIndex: queue.isEmpty ? null : initialIndex.clamp(0, queue.length - 1),
      initialPosition: Duration(milliseconds: initialPositionMs),
    );

    final favorites = await _favoriteIdsForQueue(queue);
    _snapshot = PlaybackSnapshot(
      queue: queue,
      currentIndex: queue.isEmpty ? -1 : initialIndex.clamp(0, queue.length - 1),
      positionSeconds: initialPositionMs / 1000,
      isPlaying: autoPlay,
      favoriteTrackIds: favorites,
    );

    if (autoPlay) {
      await _player.play();
    } else {
      await _player.pause();
    }

    _publish();
  }

  Future<void> _restoreState() async {
    final playbackState = await _database.getPlaybackState();
    if (playbackState == null) {
      return;
    }

    final queueIds =
        (jsonDecode(playbackState.queueTrackIdsJson) as List<dynamic>)
            .map((value) => value as int)
            .toList(growable: false);
    final queue = await _libraryRepository.getTrackItemsByIds(queueIds);
    if (queue.isEmpty) {
      return;
    }

    await _setQueue(
      queue,
      initialIndex: playbackState.currentIndex < 0
          ? 0
          : playbackState.currentIndex,
      initialPositionMs: playbackState.positionMs,
      autoPlay: playbackState.isPlaying,
    );
  }

  Future<Set<int>> _favoriteIdsForQueue(List<TrackItem> queue) async {
    if (queue.isEmpty) {
      return const <int>{};
    }

    final queueIds = queue.map((track) => track.id).toList(growable: false);
    final queueRows = await (_database.select(_database.tracks)
          ..where((table) => table.id.isIn(queueIds)))
        .get();
    final favoriteRows = queueRows.where((row) => row.isFavorite);
    return favoriteRows.map((row) => row.id).toSet();
  }

  void _publish() {
    final queue = _snapshot.queue;
    final currentIndex = queue.isEmpty ? -1 : (_player.currentIndex ?? 0);
    final snapshot = PlaybackSnapshot(
      queue: queue,
      currentIndex: currentIndex < 0 || currentIndex >= queue.length
          ? (queue.isEmpty ? -1 : 0)
          : currentIndex,
      positionSeconds: _player.position.inMilliseconds / 1000,
      isPlaying: _player.playing,
      favoriteTrackIds: _snapshot.favoriteTrackIds,
    );
    _snapshot = snapshot;
    _controller.add(snapshot);
    unawaited(_persistSnapshot(snapshot));
    _handleTrackStarted(snapshot.currentTrack);
  }

  Future<void> _persistSnapshot(PlaybackSnapshot snapshot) async {
    await _database.savePlaybackState(
      queueTrackIds: snapshot.queue.map((track) => track.id).toList(growable: false),
      currentTrackIdValue: snapshot.currentTrack?.id,
      currentIndexValue: snapshot.currentIndex,
      positionMsValue: (snapshot.positionSeconds * 1000).round(),
      isPlayingValue: snapshot.isPlaying,
    );
  }

  void _handleTrackStarted(TrackItem? track) {
    if (track == null || _lastStartedTrackId == track.id) {
      return;
    }

    _lastStartedTrackId = track.id;
    unawaited(
      _database.recordPlay(trackId: track.id, incrementPlayCount: true),
    );
    unawaited(_warmCacheForTrack(track.id));
  }

  Future<void> _warmCacheForTrack(int trackId) async {
    final row = await _database.getTrackById(trackId);
    if (row == null) {
      return;
    }

    await _trackCacheService.ensureCachedTrackFile(row);
  }
}
