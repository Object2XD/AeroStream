package com.example.aero_stream_for_android.data.local.db.entity

import androidx.room.Embedded
import androidx.room.Junction
import androidx.room.Relation

/**
 * プレイリストとその楽曲を結合したデータクラス。
 */
data class PlaylistWithSongs(
    @Embedded val playlist: PlaylistEntity,
    @Relation(
        parentColumn = "id",
        entityColumn = "id",
        associateBy = Junction(
            value = PlaylistSongCrossRef::class,
            parentColumn = "playlistId",
            entityColumn = "songId"
        )
    )
    val songs: List<SongEntity>
)
