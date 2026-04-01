import 'dart:async';
import 'dart:math' as math;

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../data/mock_media.dart';
import '../../data/playback/playback_repository.dart';
import '../../models/track_item.dart';
import 'drive/drive_providers.dart';
import 'runtime_mode_provider.dart';

export 'runtime_mode_provider.dart';

final playbackTickerEnabledProvider = Provider<bool>((ref) => true);

class MiniPlayerState {
  const MiniPlayerState({
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

  bool get hasTrack => currentIndex >= 0 && currentIndex < queue.length;
  TrackItem? get currentTrack => hasTrack ? queue[currentIndex] : null;
  double get currentDurationSeconds =>
      currentTrack?.durationSeconds.toDouble() ?? 0;
  double get progress => currentDurationSeconds == 0
      ? 0
      : (positionSeconds / currentDurationSeconds).clamp(0.0, 1.0).toDouble();
  bool get isFavorite =>
      currentTrack != null && favoriteTrackIds.contains(currentTrack!.id);
  String get elapsedLabel => formatTrackTimestamp(positionSeconds);
  String get durationLabel => currentTrack?.durationLabel ?? '0:00';
  int get upNextCount => hasTrack
      ? math.max(queue.length - currentIndex - 1, 0)
      : 0;
  TrackItem? get nextTrack =>
      hasTrack && currentIndex + 1 < queue.length ? queue[currentIndex + 1] : null;

  MiniPlayerState copyWith({
    List<TrackItem>? queue,
    int? currentIndex,
    double? positionSeconds,
    bool? isPlaying,
    Set<int>? favoriteTrackIds,
  }) {
    return MiniPlayerState(
      queue: queue ?? this.queue,
      currentIndex: currentIndex ?? this.currentIndex,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      isPlaying: isPlaying ?? this.isPlaying,
      favoriteTrackIds: favoriteTrackIds ?? this.favoriteTrackIds,
    );
  }

  factory MiniPlayerState.fromPlayback(PlaybackSnapshot snapshot) {
    return MiniPlayerState(
      queue: snapshot.queue,
      currentIndex: snapshot.currentIndex,
      positionSeconds: snapshot.positionSeconds,
      isPlaying: snapshot.isPlaying,
      favoriteTrackIds: snapshot.favoriteTrackIds,
    );
  }
}

class MiniPlayerController extends Notifier<MiniPlayerState> {
  StreamSubscription<PlaybackSnapshot>? _subscription;

  PlaybackRepository get _playbackRepository =>
      ref.read(playbackRepositoryProvider);
  bool get _isMockMode => ref.read(useMockAppDataProvider);

  @override
  MiniPlayerState build() {
    if (ref.watch(useMockAppDataProvider)) {
      return MiniPlayerState(
        queue: playbackQueue,
        currentIndex: 0,
        positionSeconds: 0,
        isPlaying: true,
        favoriteTrackIds: const <int>{},
      );
    }

    final repository = _playbackRepository;
    unawaited(repository.initialize());

    _subscription ??= repository.stream.listen((snapshot) {
      state = MiniPlayerState.fromPlayback(snapshot);
    });
    ref.onDispose(() => _subscription?.cancel());

    return MiniPlayerState.fromPlayback(repository.currentState);
  }

  void togglePlayPause() {
    if (_isMockMode) {
      state = state.copyWith(isPlaying: !state.isPlaying);
      return;
    }
    unawaited(_playbackRepository.togglePlayPause());
  }

  void seekTo(double seconds) {
    if (_isMockMode) {
      final duration = state.currentDurationSeconds;
      final clampedSeconds = duration <= 0
          ? math.max(seconds, 0).toDouble()
          : seconds.clamp(0, duration).toDouble();
      state = state.copyWith(positionSeconds: clampedSeconds);
      return;
    }
    unawaited(_playbackRepository.seekTo(seconds));
  }

  void playTrack(TrackItem track, {List<TrackItem>? queue}) {
    if (_isMockMode) {
      final resolvedQueue = queue ?? state.queue;
      if (resolvedQueue.isEmpty) {
        state = state.copyWith(
          queue: [track],
          currentIndex: 0,
          positionSeconds: 0,
          isPlaying: true,
        );
        return;
      }

      final index = resolvedQueue.indexWhere((item) => item.id == track.id);
      if (index >= 0) {
        state = state.copyWith(
          queue: resolvedQueue,
          currentIndex: index,
          positionSeconds: 0,
          isPlaying: true,
        );
        return;
      }

      state = state.copyWith(
        queue: <TrackItem>[
          track,
          ...resolvedQueue.where((item) => item.id != track.id),
        ],
        currentIndex: 0,
        positionSeconds: 0,
        isPlaying: true,
      );
      return;
    }
    unawaited(_playbackRepository.playTrack(track, queue: queue));
  }

  void playNext() {
    if (_isMockMode) {
      if (!state.hasTrack) {
        return;
      }
      if (state.currentIndex >= state.queue.length - 1) {
        state = state.copyWith(
          positionSeconds: state.currentDurationSeconds,
          isPlaying: false,
        );
        return;
      }
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
        positionSeconds: 0,
        isPlaying: true,
      );
      return;
    }
    unawaited(_playbackRepository.playNext());
  }

  void playPrevious() {
    if (_isMockMode) {
      if (!state.hasTrack) {
        return;
      }
      if (state.positionSeconds > 3 || state.currentIndex == 0) {
        state = state.copyWith(positionSeconds: 0);
        return;
      }
      state = state.copyWith(
        currentIndex: state.currentIndex - 1,
        positionSeconds: 0,
        isPlaying: true,
      );
      return;
    }
    unawaited(_playbackRepository.playPrevious());
  }

  void toggleFavorite() {
    if (_isMockMode) {
      final currentTrack = state.currentTrack;
      if (currentTrack == null) {
        return;
      }
      final favoriteTrackIds = Set<int>.from(state.favoriteTrackIds);
      if (!favoriteTrackIds.add(currentTrack.id)) {
        favoriteTrackIds.remove(currentTrack.id);
      }
      state = state.copyWith(favoriteTrackIds: favoriteTrackIds);
      return;
    }
    unawaited(_playbackRepository.toggleFavorite());
  }

  void playFromQueueIndex(int index) {
    if (_isMockMode) {
      if (index < 0 || index >= state.queue.length) {
        return;
      }
      state = state.copyWith(
        currentIndex: index,
        positionSeconds: 0,
        isPlaying: true,
      );
      return;
    }
    unawaited(_playbackRepository.playFromQueueIndex(index));
  }
}

final miniPlayerControllerProvider =
    NotifierProvider<MiniPlayerController, MiniPlayerState>(
      MiniPlayerController.new,
    );
