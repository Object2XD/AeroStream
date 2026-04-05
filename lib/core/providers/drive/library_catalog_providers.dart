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
    required this.pageSize,
    required this.pagesByOffset,
    required this.loadingOffsets,
    required this.totalCount,
    required this.isRefreshing,
    required this.revision,
  });

  final int pageSize;
  final Map<int, List<T>> pagesByOffset;
  final Set<int> loadingOffsets;
  final int totalCount;
  final bool isRefreshing;
  final int revision;

  int pageOffsetForIndex(int index) => (index ~/ pageSize) * pageSize;

  T? itemAt(int index) {
    if (index < 0 || index >= totalCount) {
      return null;
    }
    final pageOffset = pageOffsetForIndex(index);
    final page = pagesByOffset[pageOffset];
    if (page == null) {
      return null;
    }

    final pageIndex = index - pageOffset;
    if (pageIndex < 0 || pageIndex >= page.length) {
      return null;
    }
    return page[pageIndex];
  }

  bool hasPageAtOffset(int offset) => pagesByOffset.containsKey(offset);

  bool isPageLoading(int offset) => loadingOffsets.contains(offset);

  factory LibraryPageState.fromSlice({
    required LibrarySlice<T> slice,
    required int pageSize,
  }) {
    final pagesByOffset = <int, List<T>>{};
    if (slice.items.isNotEmpty) {
      pagesByOffset[slice.offset] = slice.items;
    }
    return LibraryPageState<T>(
      pageSize: pageSize,
      pagesByOffset: pagesByOffset,
      loadingOffsets: const <int>{},
      totalCount: slice.totalCount,
      isRefreshing: false,
      revision: slice.revision,
    );
  }

  LibraryPageState<T> copyWith({
    int? pageSize,
    Map<int, List<T>>? pagesByOffset,
    Set<int>? loadingOffsets,
    int? totalCount,
    bool? isRefreshing,
    int? revision,
  }) {
    return LibraryPageState<T>(
      pageSize: pageSize ?? this.pageSize,
      pagesByOffset: pagesByOffset ?? this.pagesByOffset,
      loadingOffsets: loadingOffsets ?? this.loadingOffsets,
      totalCount: totalCount ?? this.totalCount,
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
  int _generation = 0;
  final Set<int> _scheduledOffsets = <int>{};

  Future<LibrarySlice<T>> fetchSlice({
    required SortT sort,
    required int offset,
    required int limit,
  });

  void scheduleEnsureIndexLoaded(int index) {
    final current = state.asData?.value;
    if (current == null ||
        current.isRefreshing ||
        index < 0 ||
        index >= current.totalCount) {
      return;
    }

    final pageOffset = current.pageOffsetForIndex(index);
    if (!current.hasPageAtOffset(pageOffset)) {
      _schedulePageLoad(pageOffset);
      return;
    }

    _prefetchAdjacentPages(current, pageOffset);
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
    final generation = ++_generation;
    if (current == null || !refreshing) {
      state = const AsyncLoading();
    } else {
      state = AsyncData(current.copyWith(isRefreshing: true));
    }

    try {
      final slice = await fetchSlice(sort: sort, offset: 0, limit: pageSize);
      if (generation != _generation) {
        return;
      }

      final nextState = LibraryPageState<T>.fromSlice(
        slice: slice,
        pageSize: pageSize,
      );
      state = AsyncData(nextState);
      _prefetchAdjacentPages(nextState, 0);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> _loadPageAtOffset(int offset, {bool prefetch = false}) async {
    final current = state.asData?.value;
    if (current == null ||
        current.isRefreshing ||
        offset < 0 ||
        offset >= current.totalCount ||
        current.hasPageAtOffset(offset) ||
        current.isPageLoading(offset)) {
      return;
    }

    final generation = _generation;
    final loadingOffsets = Set<int>.from(current.loadingOffsets)..add(offset);
    state = AsyncData(current.copyWith(loadingOffsets: loadingOffsets));

    try {
      final slice = await fetchSlice(
        sort: sort,
        offset: offset,
        limit: pageSize,
      );
      if (generation != _generation) {
        return;
      }

      final latest = state.asData?.value;
      if (latest == null) {
        return;
      }

      final nextPagesByOffset = Map<int, List<T>>.from(latest.pagesByOffset)
        ..[slice.offset] = slice.items;
      final nextLoadingOffsets = Set<int>.from(latest.loadingOffsets)
        ..remove(offset);
      final nextState = latest.copyWith(
        pagesByOffset: nextPagesByOffset,
        loadingOffsets: nextLoadingOffsets,
        totalCount: slice.totalCount,
        revision: slice.revision,
        isRefreshing: false,
      );
      state = AsyncData(nextState);

      if (!prefetch) {
        _prefetchAdjacentPages(nextState, slice.offset);
      }
    } catch (error, stackTrace) {
      if (generation != _generation) {
        return;
      }

      final latest = state.asData?.value;
      if (latest == null) {
        state = AsyncError(error, stackTrace);
        return;
      }

      final nextLoadingOffsets = Set<int>.from(latest.loadingOffsets)
        ..remove(offset);
      state = AsyncData(
        latest.copyWith(
          loadingOffsets: nextLoadingOffsets,
          isRefreshing: false,
        ),
      );
    }
  }

  void _prefetchAdjacentPages(LibraryPageState<T> current, int centerOffset) {
    for (final offset in <int>[
      centerOffset - pageSize,
      centerOffset + pageSize,
    ]) {
      if (offset < 0 || offset >= current.totalCount) {
        continue;
      }
      _schedulePageLoad(offset, prefetch: true);
    }
  }

  void _schedulePageLoad(int offset, {bool prefetch = false}) {
    final current = state.asData?.value;
    if (current == null ||
        offset < 0 ||
        offset >= current.totalCount ||
        current.hasPageAtOffset(offset) ||
        current.isPageLoading(offset) ||
        !_scheduledOffsets.add(offset)) {
      return;
    }

    unawaited(
      Future<void>.delayed(Duration.zero, () async {
        _scheduledOffsets.remove(offset);
        await _loadPageAtOffset(offset, prefetch: prefetch);
      }),
    );
  }
}

class LibrarySongsController
    extends _LibraryPageController<TrackItem, LibrarySongSort> {
  LibrarySongsController({required super.repository, required super.sort})
    : super(pageSize: 100);

  @override
  Future<LibrarySlice<TrackItem>> fetchSlice({
    required LibrarySongSort sort,
    required int offset,
    required int limit,
  }) {
    return repository.fetchSongsSlice(sort: sort, offset: offset, limit: limit);
  }
}

class LibraryAlbumsController
    extends _LibraryPageController<LibraryAlbum, LibraryAlbumSort> {
  LibraryAlbumsController({required super.repository, required super.sort})
    : super(pageSize: 80);

  @override
  Future<LibrarySlice<LibraryAlbum>> fetchSlice({
    required LibraryAlbumSort sort,
    required int offset,
    required int limit,
  }) {
    return repository.fetchAlbumsSlice(
      sort: sort,
      offset: offset,
      limit: limit,
    );
  }
}

class LibraryArtistsController
    extends _LibraryPageController<LibraryArtist, LibraryArtistSort> {
  LibraryArtistsController({required super.repository, required super.sort})
    : super(pageSize: 80);

  @override
  Future<LibrarySlice<LibraryArtist>> fetchSlice({
    required LibraryArtistSort sort,
    required int offset,
    required int limit,
  }) {
    return repository.fetchArtistsSlice(
      sort: sort,
      offset: offset,
      limit: limit,
    );
  }
}

class LibraryAlbumArtistsController
    extends _LibraryPageController<LibraryAlbumArtist, LibraryAlbumArtistSort> {
  LibraryAlbumArtistsController({
    required super.repository,
    required super.sort,
  }) : super(pageSize: 80);

  @override
  Future<LibrarySlice<LibraryAlbumArtist>> fetchSlice({
    required LibraryAlbumArtistSort sort,
    required int offset,
    required int limit,
  }) {
    return repository.fetchAlbumArtistsSlice(
      sort: sort,
      offset: offset,
      limit: limit,
    );
  }
}

class LibraryGenresController
    extends _LibraryPageController<LibraryGenre, LibraryGenreSort> {
  LibraryGenresController({required super.repository, required super.sort})
    : super(pageSize: 80);

  @override
  Future<LibrarySlice<LibraryGenre>> fetchSlice({
    required LibraryGenreSort sort,
    required int offset,
    required int limit,
  }) {
    return repository.fetchGenresSlice(
      sort: sort,
      offset: offset,
      limit: limit,
    );
  }
}

final librarySongsControllerProvider =
    StateNotifierProvider.family<
      LibrarySongsController,
      AsyncValue<LibraryPageState<TrackItem>>,
      LibrarySongSort
    >((ref, sort) {
      return LibrarySongsController(
        repository: ref.watch(libraryCatalogRepositoryProvider),
        sort: sort,
      );
    });

final libraryAlbumsControllerProvider =
    StateNotifierProvider.family<
      LibraryAlbumsController,
      AsyncValue<LibraryPageState<LibraryAlbum>>,
      LibraryAlbumSort
    >((ref, sort) {
      return LibraryAlbumsController(
        repository: ref.watch(libraryCatalogRepositoryProvider),
        sort: sort,
      );
    });

final libraryArtistsControllerProvider =
    StateNotifierProvider.family<
      LibraryArtistsController,
      AsyncValue<LibraryPageState<LibraryArtist>>,
      LibraryArtistSort
    >((ref, sort) {
      return LibraryArtistsController(
        repository: ref.watch(libraryCatalogRepositoryProvider),
        sort: sort,
      );
    });

final libraryAlbumArtistsControllerProvider =
    StateNotifierProvider.family<
      LibraryAlbumArtistsController,
      AsyncValue<LibraryPageState<LibraryAlbumArtist>>,
      LibraryAlbumArtistSort
    >((ref, sort) {
      return LibraryAlbumArtistsController(
        repository: ref.watch(libraryCatalogRepositoryProvider),
        sort: sort,
      );
    });

final libraryGenresControllerProvider =
    StateNotifierProvider.family<
      LibraryGenresController,
      AsyncValue<LibraryPageState<LibraryGenre>>,
      LibraryGenreSort
    >((ref, sort) {
      return LibraryGenresController(
        repository: ref.watch(libraryCatalogRepositoryProvider),
        sort: sort,
      );
    });
