package com.example.aero_stream_for_android.data.repository

import android.net.Uri
import com.example.aero_stream_for_android.data.local.db.dao.AlbumInfo
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.local.db.entity.SongEntity
import com.example.aero_stream_for_android.data.local.mediastore.LocalMediaDataSource
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.Album
import com.example.aero_stream_for_android.domain.model.Artist
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class MusicRepository @Inject constructor(
    private val songDao: SongDao,
    private val localMediaDataSource: LocalMediaDataSource
) {
    /**
     * 全楽曲を監視する（全ソース統合）。
     */
    fun getAllSongs(): Flow<List<Song>> = songDao.getAllSongs().map { entities ->
        entities.map { it.toDomain() }
    }

    /**
     * ソース別の楽曲を監視する。
     */
    fun getSongsBySource(source: MusicSource): Flow<List<Song>> =
        songDao.getSongsBySource(source.name).map { entities ->
            entities.map { it.toDomain() }
        }

    fun getCachedSmbSongs(): Flow<List<Song>> =
        songDao.getCachedSmbSongs().map { entities ->
            entities.map { it.toDomain() }
        }

    fun getSongsByAlbum(album: String, albumArtist: String): Flow<List<Song>> =
        songDao.getSongsByAlbum(album, albumArtist).map { entities ->
            entities.map { it.toDomain() }
        }

    fun getSongsByAlbumAndSource(
        album: String,
        albumArtist: String,
        source: MusicSource
    ): Flow<List<Song>> =
        songDao.getSongsByAlbumAndSource(album, albumArtist, source.name).map { entities ->
            entities.map { it.toDomain() }
        }

    fun getSongsByAlbumSourceAndSmbConfig(
        album: String,
        albumArtist: String,
        source: MusicSource,
        smbConfigId: String
    ): Flow<List<Song>> =
        songDao.getSongsByAlbumSourceAndSmbConfig(
            album = album,
            albumArtist = albumArtist,
            source = source.name,
            smbConfigId = smbConfigId
        ).map { entities ->
            entities.map { it.toDomain() }
        }

    fun getSongsBySourceAndSmbConfig(source: MusicSource, smbConfigId: String): Flow<List<Song>> =
        songDao.getSongsBySourceAndSmbConfig(source.name, smbConfigId).map { entities ->
            entities.map { it.toDomain() }
        }

    fun getSongsBySourceSmbConfigAndBuckets(
        source: MusicSource,
        smbConfigId: String,
        buckets: List<String>
    ): Flow<List<Song>> =
        songDao.getSongsBySourceSmbConfigAndBuckets(source.name, smbConfigId, buckets).map { entities ->
            entities.map { it.toDomain() }
        }

    /**
     * 楽曲を検索する。
     */
    fun searchSongs(query: String): Flow<List<Song>> =
        songDao.searchSongs(query).map { entities ->
            entities.map { it.toDomain() }
        }

    /**
     * 最近再生した楽曲を取得する。
     */
    fun getRecentlyPlayed(limit: Int = 20): Flow<List<Song>> =
        songDao.getRecentlyPlayed(limit).map { entities ->
            entities.map { it.toDomain() }
        }

    /**
     * よく再生する楽曲を取得する。
     */
    fun getMostPlayed(limit: Int = 20): Flow<List<Song>> =
        songDao.getMostPlayed(limit).map { entities ->
            entities.map { it.toDomain() }
        }

    /**
     * アルバム一覧を取得する。
     */
    fun getAlbums(): Flow<List<Album>> =
        songDao.getAlbums().map { albumInfos ->
            albumInfos.mapIndexed { index, info ->
                info.toAlbum(index)
            }
        }

    fun getAlbumsBySource(source: MusicSource): Flow<List<Album>> =
        songDao.getAlbumsBySource(source.name).map { albumInfos ->
            albumInfos.mapIndexed { index, info ->
                info.toAlbum(index)
            }
        }

    fun getAlbumsBySourceAndSmbConfig(source: MusicSource, smbConfigId: String): Flow<List<Album>> =
        songDao.getAlbumsBySourceAndSmbConfig(source.name, smbConfigId).map { albumInfos ->
            albumInfos.mapIndexed { index, info ->
                info.toAlbum(index)
            }
        }

    fun getAlbumsBySourceSmbConfigAndBuckets(
        source: MusicSource,
        smbConfigId: String,
        buckets: List<String>
    ): Flow<List<Album>> =
        songDao.getAlbumsBySourceSmbConfigAndBuckets(source.name, smbConfigId, buckets).map { albumInfos ->
            albumInfos.mapIndexed { index, info ->
                info.toAlbum(index)
            }
        }

    /**
     * アーティスト一覧を取得する。
     */
    fun getArtists(): Flow<List<Artist>> =
        songDao.getArtists().map { artistInfos ->
            artistInfos.mapIndexed { index, info ->
                Artist(
                    id = index.toLong(),
                    name = info.artist,
                    songCount = info.songCount
                )
            }
        }

    fun getArtistsBySource(source: MusicSource): Flow<List<Artist>> =
        songDao.getArtistsBySource(source.name).map { artistInfos ->
            artistInfos.mapIndexed { index, info ->
                Artist(
                    id = index.toLong(),
                    name = info.artist,
                    songCount = info.songCount
                )
            }
        }

    fun getArtistsBySourceAndSmbConfig(source: MusicSource, smbConfigId: String): Flow<List<Artist>> =
        songDao.getArtistsBySourceAndSmbConfig(source.name, smbConfigId).map { artistInfos ->
            artistInfos.mapIndexed { index, info ->
                Artist(
                    id = index.toLong(),
                    name = info.artist,
                    songCount = info.songCount
                )
            }
        }

    fun getArtistsBySourceSmbConfigAndBuckets(
        source: MusicSource,
        smbConfigId: String,
        buckets: List<String>
    ): Flow<List<Artist>> =
        songDao.getArtistsBySourceSmbConfigAndBuckets(source.name, smbConfigId, buckets).map { artistInfos ->
            artistInfos.mapIndexed { index, info ->
                Artist(
                    id = index.toLong(),
                    name = info.artist,
                    songCount = info.songCount
                )
            }
        }

    /**
     * ローカルストレージの楽曲をスキャンしてDBに保存する。
     */
    suspend fun refreshLocalMusic() {
        val localSongs = localMediaDataSource.scanLocalMusic()
        songDao.deleteAllBySource(MusicSource.LOCAL.name)
        songDao.insertSongs(localSongs.map { it.toEntity() })
    }

    /**
     * 楽曲の再生統計を更新する。
     */
    suspend fun updatePlayStats(songId: Long) {
        val now = System.currentTimeMillis()
        songDao.updatePlayStats(songId, now)
        songDao.updateCacheLastPlayedAt(songId, now)
    }

    /**
     * IDで楽曲を取得する。
     */
    suspend fun getSongById(id: Long): Song? {
        return songDao.getSongById(id)?.toDomain()
    }

    /**
     * 楽曲を保存する。
     */
    suspend fun insertSong(song: Song): Long {
        return songDao.insertSong(song.toEntity())
    }

    /**
     * 楽曲リストを保存する。
     */
    suspend fun insertSongs(songs: List<Song>) {
        songDao.insertSongs(songs.map { it.toEntity() })
    }

    // --- Mapping ---

    private fun SongEntity.toDomain(): Song = Song(
        id = id,
        title = title,
        artist = artist,
        albumArtist = albumArtist,
        album = album,
        duration = duration,
        albumArtUri = albumArtUri?.let { Uri.parse(it) },
        source = MusicSource.valueOf(source),
        smbPath = smbPath,
        smbConfigId = smbConfigId,
        smbLibraryBucket = smbLibraryBucket,
        localPath = localPath,
        contentUri = contentUri?.let { Uri.parse(it) },
        trackNumber = trackNumber,
        fileSize = fileSize,
        mimeType = mimeType,
        smbLastWriteTime = smbLastWriteTime,
        isCached = isCached,
        cachedAt = cachedAt,
        cacheLastPlayedAt = cacheLastPlayedAt,
        sourceUpdatedAt = sourceUpdatedAt,
        lastPlayedAt = lastPlayedAt,
        playCount = playCount
    )

    private fun Song.toEntity(): SongEntity = SongEntity(
        id = id,
        title = title,
        artist = artist,
        albumArtist = albumArtist,
        album = album,
        duration = duration,
        albumArtUri = albumArtUri?.toString(),
        source = source.name,
        smbPath = smbPath,
        smbConfigId = smbConfigId,
        smbLibraryBucket = smbLibraryBucket,
        localPath = localPath,
        contentUri = contentUri?.toString(),
        trackNumber = trackNumber,
        fileSize = fileSize,
        mimeType = mimeType,
        smbLastWriteTime = smbLastWriteTime,
        isCached = isCached,
        cachedAt = cachedAt,
        cacheLastPlayedAt = cacheLastPlayedAt,
        lastPlayedAt = lastPlayedAt,
        playCount = playCount,
        sourceUpdatedAt = sourceUpdatedAt
    )

    private fun AlbumInfo.toAlbum(index: Int): Album {
        val total = count
        val cached = cachedCount
        return Album(
            id = index.toLong(),
            name = album,
            artist = albumArtist,
            albumArtist = albumArtist,
            albumArtUri = albumArtUri?.let { Uri.parse(it) },
            songCount = total,
            cachedSongCount = cached,
            isFullyCached = total > 0 && cached >= total
        )
    }
}
