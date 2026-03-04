package com.example.aero_stream_for_android.data.local.db.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * プレイリストのRoomエンティティ。
 */
@Entity(tableName = "playlists")
data class PlaylistEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val name: String,
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
)
