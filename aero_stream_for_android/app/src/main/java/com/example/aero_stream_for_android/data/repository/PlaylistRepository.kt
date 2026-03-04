package com.example.aero_stream_for_android.data.repository

import com.example.aero_stream_for_android.data.local.db.dao.PlaylistDao
import com.example.aero_stream_for_android.data.local.db.entity.PlaylistEntity
import com.example.aero_stream_for_android.data.local.db.entity.PlaylistSongCrossRef
import com.example.aero_stream_for_android.domain.model.Playlist
import com.example.aero_stream_for_android.domain.model.Song
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class PlaylistRepository @Inject constructor(
    private val playlistDao: PlaylistDao,
    private val musicRepository: MusicRepository
) {
    /**
     * 全プレイリストを監視する。
     */
    fun getAllPlaylists(): Flow<List<Playlist>> =
        playlistDao.getAllPlaylistsWithSongs().map { list ->
            list.map { pws ->
                Playlist(
                    id = pws.playlist.id,
                    name = pws.playlist.name,
                    songs = emptyList(), // 軽量リスト用
                    createdAt = pws.playlist.createdAt,
                    updatedAt = pws.playlist.updatedAt
                )
            }
        }

    /**
     * プレイリストの詳細（楽曲付き）を取得する。
     */
    fun getPlaylistWithSongs(playlistId: Long): Flow<Playlist?> =
        playlistDao.getPlaylistWithSongs(playlistId).map { pws ->
            pws?.let {
                Playlist(
                    id = it.playlist.id,
                    name = it.playlist.name,
                    songs = it.songs.mapNotNull { entity ->
                        musicRepository.getSongById(entity.id)
                    },
                    createdAt = it.playlist.createdAt,
                    updatedAt = it.playlist.updatedAt
                )
            }
        }

    /**
     * プレイリストを作成する。
     */
    suspend fun createPlaylist(name: String): Long {
        return playlistDao.insertPlaylist(
            PlaylistEntity(name = name)
        )
    }

    /**
     * プレイリスト名を更新する。
     */
    suspend fun renamePlaylist(playlistId: Long, newName: String) {
        playlistDao.getPlaylistWithSongs(playlistId)
        // Simpler approach - just update with current timestamp
        playlistDao.updatePlaylist(
            PlaylistEntity(
                id = playlistId,
                name = newName,
                updatedAt = System.currentTimeMillis()
            )
        )
    }

    /**
     * プレイリストを削除する。
     */
    suspend fun deletePlaylist(playlistId: Long) {
        playlistDao.deletePlaylist(PlaylistEntity(id = playlistId, name = ""))
    }

    /**
     * プレイリストに楽曲を追加する。
     */
    suspend fun addSongToPlaylist(playlistId: Long, songId: Long) {
        val maxOrder = playlistDao.getMaxSortOrder(playlistId) ?: -1
        playlistDao.addSongToPlaylist(
            PlaylistSongCrossRef(
                playlistId = playlistId,
                songId = songId,
                sortOrder = maxOrder + 1
            )
        )
    }

    /**
     * プレイリストから楽曲を削除する。
     */
    suspend fun removeSongFromPlaylist(playlistId: Long, songId: Long) {
        playlistDao.removeSongFromPlaylist(
            PlaylistSongCrossRef(playlistId = playlistId, songId = songId)
        )
    }
}
