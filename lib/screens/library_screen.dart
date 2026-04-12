import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../app_routes.dart';
import '../core/providers/drive/drive_providers.dart';
import '../core/providers/drive/library_catalog_providers.dart';
import '../core/providers/mini_player_controller.dart';
import '../models/library_models.dart';
import '../models/track_item.dart';
import '../widgets/feature_placeholder_view.dart';
import '../widgets/library_media_views.dart';
import '../widgets/media_list_row.dart';
import 'library/library_screen_content.dart';
import 'library/library_screen_sections.dart';
import 'library/library_screen_types.dart';

const double _kLibraryBottomSpacing = 24.0;
const double _kLibraryMaxWidth = 640.0;

class LibraryScreen extends HookConsumerWidget {
  const LibraryScreen({
    super.key,
    this.initialTab = LibraryTab.albums,
    this.initialViewMode = LibraryViewMode.grid,
  });

  final LibraryTab initialTab;
  final LibraryViewMode initialViewMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth > (_kLibraryMaxWidth + 32)
        ? (screenWidth - _kLibraryMaxWidth) / 2
        : 16.0;

    final tabController = useTabController(
      initialLength: LibraryTab.values.length,
      initialIndex: initialTab.index,
    );
    useListenable(tabController);

    final scrollControllers = useMemoized(
      () => {for (final tab in LibraryTab.values) tab: ScrollController()},
    );
    useEffect(() {
      return () {
        for (final controller in scrollControllers.values) {
          controller.dispose();
        }
      };
    }, [scrollControllers]);

    final currentTab = LibraryTab.values[tabController.index];
    final currentSection = libraryTabSections[currentTab]!;
    final currentScrollController = scrollControllers[currentTab]!;
    final viewMode = useState(initialViewMode);
    final sortByByCategory = useState(createInitialLibrarySortKeys());
    final currentSortKey =
        sortByByCategory.value[currentTab] ?? currentSection.defaultSort;
    final previousTabRef = useRef(currentTab);
    final previousSortRef = useRef(currentSortKey);

    final driveState = ref.watch(driveWorkspaceProvider);
    final countsValue = ref.watch(libraryCountsProvider);
    final projectionStatusValue = ref.watch(libraryProjectionStatusProvider);
    final revisionValue = ref.watch(libraryRevisionProvider);
    final projectionStatus = projectionStatusValue.asData?.value;
    final revision =
        revisionValue.asData?.value ?? projectionStatus?.revision ?? 0;

    useEffect(() {
      final previousTab = previousTabRef.value;
      final previousSort = previousSortRef.value;
      if (previousTab == currentTab && previousSort != currentSortKey) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (currentScrollController.hasClients) {
            currentScrollController.jumpTo(0);
          }
        });
      }
      previousTabRef.value = currentTab;
      previousSortRef.value = currentSortKey;
      return null;
    }, [currentTab, currentSortKey, currentScrollController]);

    void showMessage(String message) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
    }

    Future<void> openSong(TrackItem track) async {
      try {
        final queue = await ref
            .read(libraryCatalogRepositoryProvider)
            .fetchAllSongs(sort: _songSortForKey(currentSortKey));
        if (!context.mounted) {
          return;
        }
        ref
            .read(miniPlayerControllerProvider.notifier)
            .playTrack(track, queue: queue);
        if (!context.mounted) {
          return;
        }
        context.push(AppRoutes.player);
      } catch (error) {
        showMessage(error.toString());
      }
    }

    void openAlbum(LibraryAlbum album) {
      context.push(AppRoutes.libraryAlbumDetail(album.id));
    }

    final songsValue = currentTab == LibraryTab.songs
        ? ref.watch(
            librarySongsControllerProvider(_songSortForKey(currentSortKey)),
          )
        : null;
    final albumsValue = currentTab == LibraryTab.albums
        ? ref.watch(
            libraryAlbumsControllerProvider(_albumSortForKey(currentSortKey)),
          )
        : null;
    final artistsValue = currentTab == LibraryTab.artists
        ? ref.watch(
            libraryArtistsControllerProvider(_artistSortForKey(currentSortKey)),
          )
        : null;
    final albumArtistsValue = currentTab == LibraryTab.albumArtists
        ? ref.watch(
            libraryAlbumArtistsControllerProvider(
              _albumArtistSortForKey(currentSortKey),
            ),
          )
        : null;
    final genresValue = currentTab == LibraryTab.genres
        ? ref.watch(
            libraryGenresControllerProvider(_genreSortForKey(currentSortKey)),
          )
        : null;

    final currentPageValue = switch (currentTab) {
      LibraryTab.songs => songsValue,
      LibraryTab.albums => albumsValue,
      LibraryTab.artists => artistsValue,
      LibraryTab.albumArtists => albumArtistsValue,
      LibraryTab.genres => genresValue,
    };

    useEffect(() {
      Future.microtask(() async {
        switch (currentTab) {
          case LibraryTab.songs:
            await ref
                .read(
                  librarySongsControllerProvider(
                    _songSortForKey(currentSortKey),
                  ).notifier,
                )
                .refreshIfStale(revision);
            break;
          case LibraryTab.albums:
            await ref
                .read(
                  libraryAlbumsControllerProvider(
                    _albumSortForKey(currentSortKey),
                  ).notifier,
                )
                .refreshIfStale(revision);
            break;
          case LibraryTab.artists:
            await ref
                .read(
                  libraryArtistsControllerProvider(
                    _artistSortForKey(currentSortKey),
                  ).notifier,
                )
                .refreshIfStale(revision);
            break;
          case LibraryTab.albumArtists:
            await ref
                .read(
                  libraryAlbumArtistsControllerProvider(
                    _albumArtistSortForKey(currentSortKey),
                  ).notifier,
                )
                .refreshIfStale(revision);
            break;
          case LibraryTab.genres:
            await ref
                .read(
                  libraryGenresControllerProvider(
                    _genreSortForKey(currentSortKey),
                  ).notifier,
                )
                .refreshIfStale(revision);
            break;
        }
      });
      return null;
    }, [currentTab, currentSortKey, revision, projectionStatus?.state]);

    final trackCount = countsValue.asData?.value.trackCount ?? 0;
    final showProjectionStatus =
        currentTab != LibraryTab.songs &&
        projectionStatus != null &&
        !projectionStatus.isReady;

    final appBar = AppBar(
      toolbarHeight: 64,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      title: Text(
        'Library',
        style: theme.textTheme.headlineSmall?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      ),
      actions: [
        IconButton(
          key: const ValueKey('library-add-button'),
          onPressed: () => context.go(AppRoutes.info),
          tooltip: 'Manage Google Drive in Info',
          icon: const Icon(Icons.cloud_sync_rounded),
        ),
        const SizedBox(width: 4),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(48),
        child: Align(
          alignment: Alignment.centerLeft,
          child: TabBar(
            controller: tabController,
            isScrollable: true,
            dividerColor: theme.colorScheme.outlineVariant.withValues(
              alpha: 0.65,
            ),
            indicatorColor: theme.colorScheme.primary,
            indicatorWeight: 2,
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            labelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
            unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            tabs: [for (final tab in LibraryTab.values) Tab(text: tab.label)],
          ),
        ),
      ),
    );

    Widget body;
    if (countsValue.hasError) {
      body = FeaturePlaceholderView(
        icon: Icons.error_outline_rounded,
        eyebrow: 'LIBRARY',
        title: 'Could not load your music',
        description: countsValue.error.toString(),
      );
    } else if (countsValue.isLoading && !countsValue.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (trackCount == 0) {
      body = _LibraryEmptyState(
        isConnected: driveState.asData?.value.isConnected ?? false,
        configurationMessage: driveState.asData?.value.configurationMessage,
        onOpenInfo: () => context.go(AppRoutes.info),
      );
    } else if (currentPageValue?.hasError ?? false) {
      body = FeaturePlaceholderView(
        icon: Icons.error_outline_rounded,
        eyebrow: 'LIBRARY',
        title: 'Could not load your music',
        description: currentPageValue!.error.toString(),
      );
    } else if ((currentPageValue == null ||
            (currentPageValue.isLoading && !currentPageValue.hasValue)) &&
        !showProjectionStatus) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final slivers = _buildCurrentTabSlivers(
        context: context,
        currentTab: currentTab,
        currentSortKey: currentSortKey,
        currentSection: currentSection,
        viewMode: viewMode.value,
        horizontalPadding: horizontalPadding,
        trackCount: trackCount,
        projectionStatus: projectionStatus,
        songsState: songsValue?.asData?.value,
        albumsState: albumsValue?.asData?.value,
        artistsState: artistsValue?.asData?.value,
        albumArtistsState: albumArtistsValue?.asData?.value,
        genresState: genresValue?.asData?.value,
        onSortSelected: (nextSort) {
          sortByByCategory.value = {
            ...sortByByCategory.value,
            currentTab: nextSort,
          };
        },
        onViewModeChanged: (nextMode) => viewMode.value = nextMode,
        onOpenSong: openSong,
        onOpenAlbum: openAlbum,
        onShowMessage: showMessage,
        onItemBuilt: (index) {
          switch (currentTab) {
            case LibraryTab.songs:
              ref
                  .read(
                    librarySongsControllerProvider(
                      _songSortForKey(currentSortKey),
                    ).notifier,
                  )
                  .scheduleEnsureIndexLoaded(index);
              break;
            case LibraryTab.albums:
              ref
                  .read(
                    libraryAlbumsControllerProvider(
                      _albumSortForKey(currentSortKey),
                    ).notifier,
                  )
                  .scheduleEnsureIndexLoaded(index);
              break;
            case LibraryTab.artists:
              ref
                  .read(
                    libraryArtistsControllerProvider(
                      _artistSortForKey(currentSortKey),
                    ).notifier,
                  )
                  .scheduleEnsureIndexLoaded(index);
              break;
            case LibraryTab.albumArtists:
              ref
                  .read(
                    libraryAlbumArtistsControllerProvider(
                      _albumArtistSortForKey(currentSortKey),
                    ).notifier,
                  )
                  .scheduleEnsureIndexLoaded(index);
              break;
            case LibraryTab.genres:
              ref
                  .read(
                    libraryGenresControllerProvider(
                      _genreSortForKey(currentSortKey),
                    ).notifier,
                  )
                  .scheduleEnsureIndexLoaded(index);
              break;
          }
        },
      );

      body = CustomScrollView(
        key: const ValueKey('library-scroll-view'),
        controller: currentScrollController,
        slivers: [
          for (final sliver in slivers) sliver,
          const SliverToBoxAdapter(
            child: SizedBox(height: _kLibraryBottomSpacing),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: appBar,
      body: body,
    );
  }
}

List<Widget> _buildCurrentTabSlivers({
  required BuildContext context,
  required LibraryTab currentTab,
  required LibrarySortKey currentSortKey,
  required LibraryTabSection currentSection,
  required LibraryViewMode viewMode,
  required double horizontalPadding,
  required int trackCount,
  required LibraryProjectionStatusSnapshot? projectionStatus,
  required LibraryPageState<TrackItem>? songsState,
  required LibraryPageState<LibraryAlbum>? albumsState,
  required LibraryPageState<LibraryArtist>? artistsState,
  required LibraryPageState<LibraryAlbumArtist>? albumArtistsState,
  required LibraryPageState<LibraryGenre>? genresState,
  required ValueChanged<LibrarySortKey> onSortSelected,
  required ValueChanged<LibraryViewMode> onViewModeChanged,
  required Future<void> Function(TrackItem track) onOpenSong,
  required void Function(LibraryAlbum album) onOpenAlbum,
  required void Function(String message) onShowMessage,
  required ValueChanged<int> onItemBuilt,
}) {
  final slivers = <Widget>[
    if (currentTab != LibraryTab.songs &&
        projectionStatus != null &&
        !projectionStatus.isReady) ...[
      SliverPadding(
        padding: EdgeInsets.fromLTRB(
          horizontalPadding,
          12,
          horizontalPadding,
          0,
        ),
        sliver: SliverToBoxAdapter(
          child: _LibraryProjectionStatusCard(status: projectionStatus),
        ),
      ),
      const SliverToBoxAdapter(child: SizedBox(height: 12)),
    ],
    SliverPadding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
      sliver: SliverToBoxAdapter(
        child: LibraryUtilityRow(
          key: const ValueKey('library-utility-row'),
          sortOptions: currentSection.sortOptions,
          currentSortKey: currentSortKey,
          showViewToggle: currentSection.supportsViewToggle,
          viewMode: viewMode,
          onSortSelected: onSortSelected,
          onViewModeChanged: onViewModeChanged,
        ),
      ),
    ),
    const SliverToBoxAdapter(child: SizedBox(height: 8)),
  ];

  switch (currentTab) {
    case LibraryTab.songs:
      slivers.add(
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          sliver: SliverLibraryMediaList(
            itemCount: songsState?.totalCount ?? 0,
            itemAt: (index) {
              final song = songsState?.itemAt(index);
              if (song == null) {
                return null;
              }
              return LibraryMediaItemData(
                id: 'song-${song.id}',
                title: song.title,
                subtitle: '${song.artist} • ${song.album}',
                imageUrl: song.imageUrl,
                onTap: () => unawaited(onOpenSong(song)),
                trailing: TrackRowTrailing(
                  durationLabel: song.durationLabel,
                  buttonKey: ValueKey('library-song-overflow-${song.id}'),
                  onMenuTap: () =>
                      onShowMessage('Song actions are coming soon.'),
                ),
              );
            },
            onItemBuilt: onItemBuilt,
          ),
        ),
      );
      break;
    case LibraryTab.albums:
      slivers.addAll(
        _collectionSlivers(
          horizontalPadding: horizontalPadding,
          viewMode: viewMode,
          itemCount: albumsState?.totalCount ?? 0,
          itemAt: (index) {
            final album = albumsState?.itemAt(index);
            if (album == null) {
              return null;
            }
            return LibraryMediaItemData(
              id: 'album-${album.id}',
              title: album.title,
              subtitle: album.subtitle,
              imageUrl: album.imageUrl,
              onTap: () => onOpenAlbum(album),
              trailing: LibraryOverflowButton(
                buttonKey: ValueKey('library-album-overflow-${album.id}'),
                onTap: () => onShowMessage('Album actions are coming soon.'),
              ),
            );
          },
          onItemBuilt: onItemBuilt,
        ),
      );
      if ((albumsState?.totalCount ?? 0) == 0 &&
          trackCount > 0 &&
          projectionStatus != null &&
          !projectionStatus.isReady) {
        slivers.add(
          _LibraryProjectionEmptyStateSliver(
            horizontalPadding: horizontalPadding,
            status: projectionStatus,
          ),
        );
      }
      break;
    case LibraryTab.artists:
      slivers.addAll(
        _collectionSlivers(
          horizontalPadding: horizontalPadding,
          viewMode: viewMode,
          itemCount: artistsState?.totalCount ?? 0,
          itemAt: (index) {
            final artist = artistsState?.itemAt(index);
            if (artist == null) {
              return null;
            }
            return LibraryMediaItemData(
              id: 'artist-${artist.id}',
              title: artist.name,
              subtitle: artist.subtitle,
              imageUrl: artist.imageUrl,
              onTap: () => onShowMessage('Artist details are coming soon.'),
            );
          },
          onItemBuilt: onItemBuilt,
        ),
      );
      if ((artistsState?.totalCount ?? 0) == 0 &&
          trackCount > 0 &&
          projectionStatus != null &&
          !projectionStatus.isReady) {
        slivers.add(
          _LibraryProjectionEmptyStateSliver(
            horizontalPadding: horizontalPadding,
            status: projectionStatus,
          ),
        );
      }
      break;
    case LibraryTab.albumArtists:
      slivers.addAll(
        _collectionSlivers(
          horizontalPadding: horizontalPadding,
          viewMode: viewMode,
          itemCount: albumArtistsState?.totalCount ?? 0,
          itemAt: (index) {
            final artist = albumArtistsState?.itemAt(index);
            if (artist == null) {
              return null;
            }
            return LibraryMediaItemData(
              id: 'album-artist-${artist.id}',
              title: artist.name,
              subtitle: artist.subtitle,
              imageUrl: artist.imageUrl,
              onTap: () =>
                  onShowMessage('Album artist details are coming soon.'),
            );
          },
          onItemBuilt: onItemBuilt,
        ),
      );
      if ((albumArtistsState?.totalCount ?? 0) == 0 &&
          trackCount > 0 &&
          projectionStatus != null &&
          !projectionStatus.isReady) {
        slivers.add(
          _LibraryProjectionEmptyStateSliver(
            horizontalPadding: horizontalPadding,
            status: projectionStatus,
          ),
        );
      }
      break;
    case LibraryTab.genres:
      slivers.addAll(
        _collectionSlivers(
          horizontalPadding: horizontalPadding,
          viewMode: viewMode,
          itemCount: genresState?.totalCount ?? 0,
          itemAt: (index) {
            final genre = genresState?.itemAt(index);
            if (genre == null) {
              return null;
            }
            return LibraryMediaItemData(
              id: 'genre-${genre.id}',
              title: genre.name,
              subtitle: genre.subtitle,
              imageUrl: genre.imageUrl,
              onTap: () => onShowMessage('Genre browsing is coming soon.'),
            );
          },
          onItemBuilt: onItemBuilt,
        ),
      );
      if ((genresState?.totalCount ?? 0) == 0 &&
          trackCount > 0 &&
          projectionStatus != null &&
          !projectionStatus.isReady) {
        slivers.add(
          _LibraryProjectionEmptyStateSliver(
            horizontalPadding: horizontalPadding,
            status: projectionStatus,
          ),
        );
      }
      break;
  }

  return slivers;
}

List<Widget> _collectionSlivers({
  required double horizontalPadding,
  required LibraryViewMode viewMode,
  required int itemCount,
  required LibraryMediaItemData? Function(int index) itemAt,
  required ValueChanged<int> onItemBuilt,
}) {
  if (viewMode == LibraryViewMode.grid) {
    return [
      SliverPadding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
        sliver: SliverLibraryMediaGrid(
          itemCount: itemCount,
          itemAt: itemAt,
          onItemBuilt: onItemBuilt,
        ),
      ),
    ];
  }
  return [
    SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverLibraryMediaList(
        itemCount: itemCount,
        itemAt: itemAt,
        onItemBuilt: onItemBuilt,
      ),
    ),
  ];
}

class _LibraryEmptyState extends StatelessWidget {
  const _LibraryEmptyState({
    required this.isConnected,
    required this.configurationMessage,
    required this.onOpenInfo,
  });

  final bool isConnected;
  final String? configurationMessage;
  final VoidCallback onOpenInfo;

  @override
  Widget build(BuildContext context) {
    final title = isConnected
        ? 'No songs have been synced yet'
        : 'Connect Google Drive to build your library';
    final description =
        configurationMessage ??
        (isConnected
            ? 'Use the Google Drive settings in Info to add folders and start syncing.'
            : 'Aero Stream keeps connection and sync management in the Info tab.');

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _kLibraryMaxWidth),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            _kLibraryBottomSpacing,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FeaturePlaceholderView(
                icon: Icons.cloud_queue_rounded,
                eyebrow: 'LIBRARY',
                title: title,
                description: description,
              ),
              const SizedBox(height: 16),
              FilledButton.tonalIcon(
                onPressed: onOpenInfo,
                icon: const Icon(Icons.info_outline_rounded),
                label: const Text('Open Info'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LibraryProjectionStatusCard extends StatelessWidget {
  const _LibraryProjectionStatusCard({required this.status});

  final LibraryProjectionStatusSnapshot status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFailed = status.state == LibraryProjectionBackfillState.failed;
    final title = isFailed
        ? 'Optimization paused'
        : 'Library optimization in progress';
    final description = isFailed
        ? status.errorMessage == null
              ? 'Showing the items that are available so far. Retry optimization after the sync issue is resolved.'
              : 'Showing the items that are available so far. ${status.errorMessage}'
        : 'Showing items with finished metadata. More albums, artists, and genres will appear as optimization continues.';

    return Container(
      key: const ValueKey('library-projection-status-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isFailed
            ? theme.colorScheme.errorContainer
            : theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isFailed ? Icons.error_outline_rounded : Icons.tune_rounded,
            color: isFailed
                ? theme.colorScheme.onErrorContainer
                : theme.colorScheme.onSecondaryContainer,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: isFailed
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onSecondaryContainer,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isFailed
                        ? theme.colorScheme.onErrorContainer
                        : theme.colorScheme.onSecondaryContainer,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LibraryProjectionEmptyStateSliver extends StatelessWidget {
  const _LibraryProjectionEmptyStateSliver({
    required this.horizontalPadding,
    required this.status,
  });

  final double horizontalPadding;
  final LibraryProjectionStatusSnapshot status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFailed = status.state == LibraryProjectionBackfillState.failed;
    final title = isFailed
        ? 'No grouped results are available yet'
        : 'Preparing grouped results';
    final description = isFailed
        ? 'Optimization stopped before any albums, artists, or genres were ready to show.'
        : 'Aero Stream will show albums, artists, and genres here as soon as more tracks finish metadata processing.';

    return SliverPadding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 12, horizontalPadding, 0),
      sliver: SliverToBoxAdapter(
        child: Container(
          key: const ValueKey('library-projection-empty-state'),
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

LibrarySongSort _songSortForKey(LibrarySortKey key) {
  switch (key) {
    case LibrarySortKey.artist:
      return LibrarySongSort.artist;
    case LibrarySortKey.duration:
      return LibrarySongSort.duration;
    case LibrarySortKey.title:
    default:
      return LibrarySongSort.title;
  }
}

LibraryAlbumSort _albumSortForKey(LibrarySortKey key) {
  switch (key) {
    case LibrarySortKey.artist:
      return LibraryAlbumSort.artist;
    case LibrarySortKey.year:
      return LibraryAlbumSort.year;
    case LibrarySortKey.title:
    default:
      return LibraryAlbumSort.title;
  }
}

LibraryArtistSort _artistSortForKey(LibrarySortKey key) {
  switch (key) {
    case LibrarySortKey.songCount:
      return LibraryArtistSort.songCount;
    case LibrarySortKey.name:
    default:
      return LibraryArtistSort.name;
  }
}

LibraryAlbumArtistSort _albumArtistSortForKey(LibrarySortKey key) {
  switch (key) {
    case LibrarySortKey.albumCount:
      return LibraryAlbumArtistSort.albumCount;
    case LibrarySortKey.name:
    default:
      return LibraryAlbumArtistSort.name;
  }
}

LibraryGenreSort _genreSortForKey(LibrarySortKey key) {
  switch (key) {
    case LibrarySortKey.songCount:
      return LibraryGenreSort.songCount;
    case LibrarySortKey.name:
    default:
      return LibraryGenreSort.name;
  }
}
