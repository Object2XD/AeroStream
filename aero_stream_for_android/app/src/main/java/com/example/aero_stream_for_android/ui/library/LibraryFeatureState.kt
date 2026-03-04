package com.example.aero_stream_for_android.ui.library

enum class LibrarySource {
    LocalFiles,
    SMB,
    Cache
}

enum class LibraryCategory {
    Songs,
    Albums,
    AlbumArtists,
    Artists,
    Genres,
    Years,
    Playlists
}

enum class LibrarySortKey {
    Name,
    AddedDate,
    LastPlayed,
    Year,
    Artist,
    Album,
    SongCount,
    CreatedAt
}

enum class SortOrder {
    Asc,
    Desc
}

data class LibrarySort(
    val key: LibrarySortKey = LibrarySortKey.Name,
    val order: SortOrder = SortOrder.Asc
)

data class LibraryFeatureState(
    val source: LibrarySource = LibrarySource.LocalFiles,
    val category: LibraryCategory = LibraryCategory.Songs,
    val sort: LibrarySort = LibrarySort()
)
