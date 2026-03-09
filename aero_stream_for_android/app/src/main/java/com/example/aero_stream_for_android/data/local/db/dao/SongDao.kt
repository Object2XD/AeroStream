package com.example.aero_stream_for_android.data.local.db.dao

import androidx.room.*
import com.example.aero_stream_for_android.data.local.db.entity.SongEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface SongDao {

    @Query("SELECT * FROM songs ORDER BY title ASC")
    fun getAllSongs(): Flow<List<SongEntity>>

    @Query("SELECT * FROM songs WHERE source = :source ORDER BY title ASC")
    fun getSongsBySource(source: String): Flow<List<SongEntity>>

    @Query("SELECT * FROM songs WHERE source = :source")
    suspend fun getSongsBySourceList(source: String): List<SongEntity>

    @Query("SELECT * FROM songs WHERE source = 'SMB' AND isCached = 1 ORDER BY title ASC")
    fun getCachedSmbSongs(): Flow<List<SongEntity>>

    @Query(
        """
        SELECT * FROM songs
        WHERE album = :album AND albumArtist = :albumArtist
        ORDER BY trackNumber ASC, title ASC
        """
    )
    fun getSongsByAlbum(album: String, albumArtist: String): Flow<List<SongEntity>>

    @Query(
        """
        SELECT * FROM songs
        WHERE album = :album AND albumArtist = :albumArtist AND source = :source
        ORDER BY trackNumber ASC, title ASC
        """
    )
    fun getSongsByAlbumAndSource(
        album: String,
        albumArtist: String,
        source: String
    ): Flow<List<SongEntity>>

    @Query(
        """
        SELECT * FROM songs
        WHERE album = :album
          AND albumArtist = :albumArtist
          AND source = :source
          AND smbConfigId = :smbConfigId
        ORDER BY trackNumber ASC, title ASC
        """
    )
    fun getSongsByAlbumSourceAndSmbConfig(
        album: String,
        albumArtist: String,
        source: String,
        smbConfigId: String
    ): Flow<List<SongEntity>>

    @Query(
        """
        SELECT * FROM songs
        WHERE artist = :artist
          AND source = :source
        ORDER BY album ASC, trackNumber ASC, title ASC
        """
    )
    fun getSongsByArtistAndSource(artist: String, source: String): Flow<List<SongEntity>>

    @Query(
        """
        SELECT * FROM songs
        WHERE artist = :artist
          AND source = :source
          AND smbConfigId = :smbConfigId
        ORDER BY album ASC, trackNumber ASC, title ASC
        """
    )
    fun getSongsByArtistSourceAndSmbConfig(
        artist: String,
        source: String,
        smbConfigId: String
    ): Flow<List<SongEntity>>

    @Query(
        "SELECT * FROM songs WHERE source = :source AND smbConfigId = :smbConfigId ORDER BY title ASC"
    )
    fun getSongsBySourceAndSmbConfig(source: String, smbConfigId: String): Flow<List<SongEntity>>

    @Query(
        """
        SELECT * FROM songs
        WHERE source = :source AND smbConfigId = :smbConfigId AND smbLibraryBucket IN (:buckets)
        ORDER BY title ASC
        """
    )
    fun getSongsBySourceSmbConfigAndBuckets(
        source: String,
        smbConfigId: String,
        buckets: List<String>
    ): Flow<List<SongEntity>>

    @Query("SELECT * FROM songs WHERE id = :id")
    suspend fun getSongById(id: Long): SongEntity?

    @Query(
        """
        SELECT * FROM songs 
        WHERE title LIKE '%' || :query || '%' 
        OR artist LIKE '%' || :query || '%'
        OR album LIKE '%' || :query || '%'
        ORDER BY title ASC
        """
    )
    fun searchSongs(query: String): Flow<List<SongEntity>>

    @Query("SELECT * FROM songs WHERE lastPlayedAt IS NOT NULL ORDER BY lastPlayedAt DESC LIMIT :limit")
    fun getRecentlyPlayed(limit: Int = 20): Flow<List<SongEntity>>

    @Query("SELECT * FROM songs ORDER BY playCount DESC LIMIT :limit")
    fun getMostPlayed(limit: Int = 20): Flow<List<SongEntity>>

    @Query(
        """
        SELECT album,
               albumArtist,
               MIN(albumArtUri) as albumArtUri,
               COUNT(*) as count,
               SUM(CASE WHEN isCached = 1 THEN 1 ELSE 0 END) as cachedCount
        FROM songs
        GROUP BY album, albumArtist
        ORDER BY album ASC
        """
    )
    fun getAlbums(): Flow<List<AlbumInfo>>

    @Query(
        """
        SELECT album,
               albumArtist,
               MIN(albumArtUri) as albumArtUri,
               COUNT(*) as count,
               SUM(CASE WHEN isCached = 1 THEN 1 ELSE 0 END) as cachedCount
        FROM songs
        WHERE source = :source
        GROUP BY album, albumArtist
        ORDER BY album ASC
        """
    )
    fun getAlbumsBySource(source: String): Flow<List<AlbumInfo>>

    @Query(
        """
        SELECT album,
               albumArtist,
               MIN(albumArtUri) as albumArtUri,
               COUNT(*) as count,
               SUM(CASE WHEN isCached = 1 THEN 1 ELSE 0 END) as cachedCount
        FROM songs
        WHERE source = :source AND smbConfigId = :smbConfigId
        GROUP BY album, albumArtist
        ORDER BY album ASC
        """
    )
    fun getAlbumsBySourceAndSmbConfig(source: String, smbConfigId: String): Flow<List<AlbumInfo>>

    @Query(
        """
        SELECT album,
               albumArtist,
               MIN(albumArtUri) as albumArtUri,
               COUNT(*) as count,
               SUM(CASE WHEN isCached = 1 THEN 1 ELSE 0 END) as cachedCount
        FROM songs
        WHERE source = :source AND smbConfigId = :smbConfigId AND smbLibraryBucket IN (:buckets)
        GROUP BY album, albumArtist
        Order by album ASC
        """
    )
    fun getAlbumsBySourceSmbConfigAndBuckets(
        source: String,
        smbConfigId: String,
        buckets: List<String>
    ): Flow<List<AlbumInfo>>

    @Query("SELECT DISTINCT artist, COUNT(*) as songCount FROM songs GROUP BY artist ORDER BY artist ASC")
    fun getArtists(): Flow<List<ArtistInfo>>

    @Query(
        """
        SELECT artist, COUNT(*) as songCount
        FROM songs
        WHERE source = :source
        GROUP BY artist
        ORDER BY artist ASC
        """
    )
    fun getArtistsBySource(source: String): Flow<List<ArtistInfo>>

    @Query(
        """
        SELECT artist, COUNT(*) as songCount
        FROM songs
        WHERE source = :source AND smbConfigId = :smbConfigId
        GROUP BY artist
        ORDER BY artist ASC
        """
    )
    fun getArtistsBySourceAndSmbConfig(source: String, smbConfigId: String): Flow<List<ArtistInfo>>

    @Query(
        """
        SELECT artist, COUNT(*) as songCount
        FROM songs
        WHERE source = :source AND smbConfigId = :smbConfigId AND smbLibraryBucket IN (:buckets)
        GROUP BY artist
        ORDER BY artist ASC
        """
    )
    fun getArtistsBySourceSmbConfigAndBuckets(
        source: String,
        smbConfigId: String,
        buckets: List<String>
    ): Flow<List<ArtistInfo>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSong(song: SongEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSongs(songs: List<SongEntity>)

    @Update
    suspend fun updateSong(song: SongEntity)

    @Delete
    suspend fun deleteSong(song: SongEntity)

    @Query("DELETE FROM songs")
    fun clearAllSongs()

    @Query("DELETE FROM songs WHERE source = :source")
    suspend fun deleteAllBySource(source: String)

    @Query("DELETE FROM songs WHERE source = :source AND smbConfigId = :smbConfigId")
    suspend fun deleteAllBySourceAndSmbConfig(source: String, smbConfigId: String)

    @Query(
        """
        DELETE FROM songs
        WHERE source = :source AND smbConfigId = :smbConfigId AND smbLibraryBucket IN (:buckets)
        """
    )
    suspend fun deleteBySourceSmbConfigAndBuckets(source: String, smbConfigId: String, buckets: List<String>)

    @Query("DELETE FROM songs WHERE source = :source AND smbConfigId = :smbConfigId AND smbLibraryBucket IS NULL")
    suspend fun deleteLegacySmbLibraryRows(source: String, smbConfigId: String)

    @Query("SELECT smbPath, smbLastWriteTime, fileSize FROM songs WHERE source = :source AND smbConfigId = :smbConfigId AND smbPath IS NOT NULL")
    suspend fun getSmbSyncInfoList(source: String, smbConfigId: String): List<SmbSyncInfoProjection>

    @Query("DELETE FROM songs WHERE source = :source AND smbConfigId = :smbConfigId AND smbPath IN (:paths)")
    suspend fun deleteSongsBySmbPaths(source: String, smbConfigId: String, paths: List<String>)

    /**
     * SMBライブラリのスキャン結果をアトミックに置換する。
     * レガシー行削除 → 対象バケットの既存行削除 → 新規挿入を1トランザクションで実行。
     */
    @Transaction
    suspend fun replaceSmbLibrarySongs(
        source: String,
        smbConfigId: String,
        buckets: List<String>,
        songs: List<SongEntity>
    ) {
        deleteLegacySmbLibraryRows(source, smbConfigId)
        deleteBySourceSmbConfigAndBuckets(source, smbConfigId, buckets)
        insertSongs(songs)
    }

    @Query("SELECT MAX(sourceUpdatedAt) FROM songs WHERE source = :source AND smbConfigId = :smbConfigId")
    fun getLastSourceUpdatedAt(source: String, smbConfigId: String): Flow<Long?>

    @Query("UPDATE songs SET lastPlayedAt = :timestamp, playCount = playCount + 1 WHERE id = :songId")
    suspend fun updatePlayStats(songId: Long, timestamp: Long = System.currentTimeMillis())

    @Query("UPDATE songs SET cacheLastPlayedAt = :timestamp WHERE id = :songId AND isCached = 1")
    suspend fun updateCacheLastPlayedAt(songId: Long, timestamp: Long = System.currentTimeMillis())

    @Query(
        """
        UPDATE songs
        SET isCached = 1,
            cachedAt = :timestamp,
            localPath = :localPath
        WHERE id = :songId
        """
    )
    suspend fun markSongCachedById(songId: Long, localPath: String, timestamp: Long): Int

    @Query(
        """
        UPDATE songs
        SET isCached = 1,
            cachedAt = :timestamp,
            localPath = :localPath
        WHERE smbPath = :smbPath
        """
    )
    suspend fun markSongCachedBySmbPath(smbPath: String, localPath: String, timestamp: Long): Int

    @Query(
        """
        UPDATE songs
        SET isCached = 1,
            cachedAt = :timestamp,
            localPath = :localPath
        WHERE smbPath = :smbPath
          AND smbConfigId = :smbConfigId
        """
    )
    suspend fun markSongCachedBySmbPathAndConfigId(
        smbPath: String,
        smbConfigId: String,
        localPath: String,
        timestamp: Long
    ): Int

    @Query(
        """
        UPDATE songs
        SET isCached = 0,
            cachedAt = NULL,
            cacheLastPlayedAt = NULL,
            localPath = NULL
        WHERE smbPath = :smbPath
        """
    )
    suspend fun clearCacheBySmbPath(smbPath: String)

    @Query(
        """
        UPDATE songs
        SET isCached = 0,
            cachedAt = NULL,
            cacheLastPlayedAt = NULL,
            localPath = NULL
        WHERE smbPath = :smbPath
          AND smbConfigId = :smbConfigId
        """
    )
    suspend fun clearCacheBySmbPathAndConfigId(smbPath: String, smbConfigId: String)

    @Query(
        """
        SELECT id, smbPath, smbConfigId, localPath, cachedAt, cacheLastPlayedAt
        FROM songs
        WHERE source = 'SMB'
          AND isCached = 1
          AND COALESCE(cacheLastPlayedAt, cachedAt) IS NOT NULL
          AND COALESCE(cacheLastPlayedAt, cachedAt) < :threshold
        """
    )
    suspend fun getCachedSongsForCleanup(threshold: Long): List<CachedSongRecord>

    @Query("SELECT * FROM songs WHERE localPath = :path LIMIT 1")
    suspend fun getSongByLocalPath(path: String): SongEntity?

    @Query("SELECT * FROM songs WHERE smbPath = :path LIMIT 1")
    suspend fun getSongBySmbPath(path: String): SongEntity?

    @Query("SELECT * FROM songs WHERE smbPath = :path AND smbConfigId = :smbConfigId LIMIT 1")
    suspend fun getSongBySmbPathAndConfigId(path: String, smbConfigId: String): SongEntity?

    @Query(
        "SELECT * FROM songs WHERE source = :source AND smbConfigId = :smbConfigId"
    )
    suspend fun getSongsBySourceAndSmbConfigList(source: String, smbConfigId: String): List<SongEntity>
}

/**
 * アルバム情報のプロジェクション。
 */
data class AlbumInfo(
    val album: String,
    val albumArtist: String,
    val albumArtUri: String?,
    val count: Int,
    val cachedCount: Int
)

/**
 * アーティスト情報のプロジェクション。
 */
data class ArtistInfo(
    val artist: String,
    val songCount: Int
)

data class CachedSongRecord(
    val id: Long,
    val smbPath: String?,
    val smbConfigId: String?,
    val localPath: String?,
    val cachedAt: Long?,
    val cacheLastPlayedAt: Long?
)

data class SmbSyncInfoProjection(
    val smbPath: String,
    val smbLastWriteTime: Long,
    val fileSize: Long
)
