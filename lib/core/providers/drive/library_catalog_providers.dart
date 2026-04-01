import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';

import '../../../data/drive/library_catalog_repository.dart';
import '../../../models/library_models.dart';
import '../../../models/track_item.dart';
import '../runtime_mode_provider.dart';
import 'drive_providers.dart';

class LibraryPageState<T> {
  const LibraryPageState({
    required this.loadedPrefix,
    required this.totalCount,
    required this.nextCursor,
    required this.hasMore,
    required this.isLoadingMore,
    required this.isRefreshing,
    required this.revision,
  });

  final List<T> loadedPrefix;
  final int totalCount;
  final LibraryCursor? nextCursor;
  final bool hasMore;
  final bool isLoadingMore;
  final bool isRefreshing;
  final int revision;

  List<T> get items => loadedPrefix;
  int get loadedCount => loadedPrefix.length;

  T? itemAt(int index) {
    if (index < 0 || index >= loadedPrefix.length) {
      return null;
    }
    return loadedPrefix[index];
  }

  factory LibraryPageState.fromPage(LibraryPage<T> page) {
    return LibraryPageState<T>(
      loadedPrefix: page.items,
      totalCount: page.totalCount,
      nextCursor: page.nextCursor,
      hasMore: page.hasMore,
      isLoadingMore: false,
      isRefreshing: false,
      revision: page.revision,
    );
  }

  LibraryPageState<T> copyWith({
    List<T>? loadedPrefix,
    int? totalCount,
    LibraryCursor? Function()? nextCursor,
    bool? hasMore,
    bool? isLoadingMore,
    bool? isRefreshing,
    int? revision,
  }) {
    return LibraryPageState<T>(
      loadedPrefix: loadedPrefix ?? this.loadedPrefix,
      totalCount: totalCount ?? this.totalCount,
      nextCursor: nextCursor == null ? this.nextCursor : nextCursor(),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      revision: revision ?? this.revision,
    );
  }
}

final libraryCatalogRepositoryProvider = Provider<LibraryCatalogRepository>((
  ref,
) {
  if (ref.watch(useMockAppDataProvider)) {
    return const MockLibraryCatalogRepository();
  }
  return DatabaseLibraryCatalogRepository(ref.watch(appDatabaseProvider));
});

final libraryProjectionStatusProvider =
    StreamProvider<LibraryProjectionStatusSnapshot>((ref) {
      final repository = ref.watch(libraryCatalogRepositoryProvider);
      unawaited(repository.ensureProjectionBackfillStarted());
      return repository.watchProjectionStatus();
    });

final libraryRevisionProvider = StreamProvider<int>((ref) {
  return ref.watch(libraryCatalogRepositoryProvider).watchLibraryRevision();
});

final libraryCountsProvider = StreamProvider<LibraryCounts>((ref) {
  return ref.watch(libraryCatalogRepositoryProvider).watchLibraryCounts();
});

abstract class _LibraryPageController<T, SortT>
    extends StateNotifier<AsyncValue<LibraryPageState<T>>> {
  _LibraryPageController({
    required this.repository,
    required this.sort,
    required this.pageSize,
  }) : super(const AsyncLoading()) {
    unawaited(_loadInitial());
  }

  final LibraryCatalogRepository repository;
  final SortT sort;
  final int pageSize;
  bool _loadMoreScheduled = false;

  Future<LibraryPage<T>> fetchPage({
    required SortT sort,
    required int limit,
    LibraryCursor? cursor,
  });

  Future<void> loadMore() async {
    final current = state.asData?.value;
    if (current == null ||
        current.isLoadingMore ||
        current.isRefreshing ||
        !current.hasMore ||
        current.nextCursor == null) {
      return;
    }

    state = AsyncData(current.copyWith(isLoadingMore: true));
    try {
      final page = await fetchPage(
        sort: sort,
        limit: pageSize,
        cursor: current.nextCursor,
      );
      state = AsyncData(
        LibraryPageState<T>(
          loadedPrefix: [...current.loadedPrefix, ...page.items],
          totalCount: page.totalCount,
          nextCursor: page.nextCursor,
          hasMore: page.hasMore,
          isLoadingMore: false,
          isRefreshing: false,
          revision: page.revision,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  void scheduleLoadMoreIfNeeded(
    int index, {
    int prefetchThreshold = 12,
  }) {
    final current = state.asData?.value;
    if (current == null ||
        current.isLoadingMore ||
        current.isRefreshing ||
        !current.hasMore ||
        current.nextCursor == null ||
        index < current.loadedCount - prefetchThreshold ||
        _loadMoreScheduled) {
      return;
    }

    _loadMoreScheduled = true;
    unawaited(
      Future<void>.delayed(Duration.zero, () async {
        _loadMoreScheduled = false;
        await loadMore();
      }),
    );
  }

  Future<void> refreshIfStale(int revision) async {
    final current = state.asData?.value;
    if (current == null || current.revision != revision) {
      await refresh();
    }
  }

  Future<void> refresh() => _loadInitial(refreshing: true);

  Future<void> _loadInitial({bool refreshing = false}) async {
    final current = state.asData?.value;
    if (current == null || !refreshing) {
      state = const AsyncLoading();
    } else {
      state = AsyncData(current.copyWith(isRefreshing: true));
    }

    try {
      final page = await fetchPage(sort: sort, limit: pageSize);
      state = AsyncData(LibraryPageState<T>.fromPage(page));
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }
}

class LibrarySongsController
    extends _LibraryPageController<TrackItem, LibrarySongSort> {
  LibrarySongsController({
    required super.repository,
    required super.sort,
  }) : super(pageSize: 100);

  @override
  Future<LibraryPage<TrackItem>> fetchPage({
    required LibrarySongSort sort,
    required int limit,
    LibraryCursor? cursor,
  }) {
    return repository.fetchSongsPage(sort: sort, cursor: cursor, limit: limit);
  }
}

class LibraryAlbumsController
    extends _LibraryPageController<LibraryAlbum, LibraryAlbumSort> {
  LibraryAlbumsController({
    required super.repository,
    required super.sort,
  }) : super(pageSize: 80);

  @override
  Future<LibraryPage<LibraryAlbum>> fetchPage({
    required LibraryAlbumSort sort,
    required int limit,
    LibraryCursor? cursor,
  }) {
    return repository.fetchAlbumsPage(sort: sort, cursor: cursor, limit: limit);
  }
}

class LibraryArtistsController
    extends _LibraryPageController<LibraryArtist, LibraryArtistSort> {
  LibraryArtistsController({
    required super.repository,
    required super.sort,
  }) : super(pageSize: 80);

  @override
  Future<LibraryPage<LibraryArtist>> fetchPage({
    required LibraryArtistSort sort,
    required int limit,
    LibraryCursor? cursor,
  }) {
    return repository.fetchArtistsPage(sort: sort, cursor: cursor, limit: limit);
  }
}

class LibraryAlbumArtistsController
    extends _LibraryPageController<LibraryAlbumArtist, LibraryAlbumArtistSort> {
  LibraryAlbumArtistsController({
    required super.repository,
    required super.sort,
  }) : super(pageSize: 80);

  @override
  Future<LibraryPage<LibraryAlbumArtist>> fetchPage({
    required LibraryAlbumArtistSort sort,
    required int limit,
    LibraryCursor? cursor,
  }) {
    return repository.fetchAlbumArtistsPage(
      sort: sort,
      cursor: cursor,
      limit: limit,
    );
  }
}

class LibraryGenresController
    extends _LibraryPageController<LibraryGenre, LibraryGenreSort> {
  LibraryGenresController({
    required super.repository,
    required super.sort,
  }) : super(pageSize: 80);

  @override
  Future<LibraryPage<LibraryGenre>> fetchPage({
    required LibraryGenreSort sort,
    required int limit,
    LibraryCursor? cursor,
  }) {
    return repository.fetchGenresPage(sort: sort, cursor: cursor, limit: limit);
  }
}

final librarySongsControllerProvider = StateNotifierProvider.family<
  LibrarySongsController,
  AsyncValue<LibraryPageState<TrackItem>>,
  LibrarySongSort
>((ref, sort) {
  return LibrarySongsController(
    repository: ref.watch(libraryCatalogRepositoryProvider),
    sort: sort,
  );
});

final libraryAlbumsControllerProvider = StateNotifierProvider.family<
  LibraryAlbumsController,
  AsyncValue<LibraryPageState<LibraryAlbum>>,
  LibraryAlbumSort
>((ref, sort) {
  return LibraryAlbumsController(
    repository: ref.watch(libraryCatalogRepositoryProvider),
    sort: sort,
  );
});

final libraryArtistsControllerProvider = StateNotifierProvider.family<
  LibraryArtistsController,
  AsyncValue<LibraryPageState<LibraryArtist>>,
  LibraryArtistSort
>((ref, sort) {
  return LibraryArtistsController(
    repository: ref.watch(libraryCatalogRepositoryProvider),
    sort: sort,
  );
});

final libraryAlbumArtistsControllerProvider = StateNotifierProvider.family<
  LibraryAlbumArtistsController,
  AsyncValue<LibraryPageState<LibraryAlbumArtist>>,
  LibraryAlbumArtistSort
>((ref, sort) {
  return LibraryAlbumArtistsController(
    repository: ref.watch(libraryCatalogRepositoryProvider),
    sort: sort,
  );
});

final libraryGenresControllerProvider = StateNotifierProvider.family<
  LibraryGenresController,
  AsyncValue<LibraryPageState<LibraryGenre>>,
  LibraryGenreSort
>((ref, sort) {
  return LibraryGenresController(
    repository: ref.watch(libraryCatalogRepositoryProvider),
    sort: sort,
  );
});
