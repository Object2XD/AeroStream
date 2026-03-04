package com.example.aero_stream_for_android.domain.model

/**
 * プレイリストのドメインモデル。
 */
data class Playlist(
    val id: Long = 0,
    val name: String,
    val songs: List<Song> = emptyList(),
    val createdAt: Long = System.currentTimeMillis(),
    val updatedAt: Long = System.currentTimeMillis()
) {
    val songCount: Int get() = songs.size
    val totalDuration: Long get() = songs.sumOf { it.duration }
}
