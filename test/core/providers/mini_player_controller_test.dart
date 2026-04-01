import 'package:aero_stream/core/providers/mini_player_controller.dart';
import 'package:aero_stream/data/mock_media.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  ProviderContainer buildContainer() {
    final container = ProviderContainer(
      overrides: [
        useMockAppDataProvider.overrideWith((ref) => true),
        playbackTickerEnabledProvider.overrideWith((ref) => false),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test(
    'seek updates the current progress and next/previous navigate the queue',
    () {
      final container = buildContainer();
      final controller = container.read(miniPlayerControllerProvider.notifier);

      controller.seekTo(150);
      expect(container.read(miniPlayerControllerProvider).positionSeconds, 150);

      controller.playNext();
      expect(container.read(miniPlayerControllerProvider).currentTrack!.id, 2);
      expect(container.read(miniPlayerControllerProvider).positionSeconds, 0);

      controller.playPrevious();
      expect(container.read(miniPlayerControllerProvider).currentTrack!.id, 1);
      expect(container.read(miniPlayerControllerProvider).positionSeconds, 0);
    },
  );

  test('playTrack swaps queue context and starts the tapped item', () {
    final container = buildContainer();
    final controller = container.read(miniPlayerControllerProvider.notifier);

    controller.playTrack(recentTracks[3], queue: recentTracks);

    final state = container.read(miniPlayerControllerProvider);
    expect(state.currentTrack!.id, recentTracks[3].id);
    expect(state.currentIndex, 3);
    expect(state.isPlaying, isTrue);
  });

  test(
    'queue end stops playback and favorite toggle follows the current track',
    () {
      final container = buildContainer();
      final controller = container.read(miniPlayerControllerProvider.notifier);

      controller.playTrack(recentTracks.last, queue: recentTracks);
      controller.playNext();

      final stoppedState = container.read(miniPlayerControllerProvider);
      expect(stoppedState.currentTrack!.id, recentTracks.last.id);
      expect(stoppedState.isPlaying, isFalse);
      expect(
        stoppedState.positionSeconds,
        recentTracks.last.durationSeconds.toDouble(),
      );

      controller.toggleFavorite();
      expect(container.read(miniPlayerControllerProvider).isFavorite, isTrue);
    },
  );
}
