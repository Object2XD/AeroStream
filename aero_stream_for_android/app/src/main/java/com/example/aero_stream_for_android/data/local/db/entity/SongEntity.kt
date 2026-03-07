package com.example.aero_stream_for_android.data.local.db.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * 楽曲のRoomエンティティ。
 * ローカル / SMB / ダウンロード全ソースのメタデータをキャッシュする。
 */
@Entity(tableName = "songs")
data class SongEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    val title: String,
    val artist: String,
    val albumArtist: String = "",
    val album: String,
    val duration: Long,
    val albumArtUri: String? = null,
    val source: String, // LOCAL, SMB, DOWNLOAD
    val smbPath: String? = null,
    val smbConfigId: String? = null,
    val smbLibraryBucket: String? = null,
    val localPath: String? = null,
    val contentUri: String? = null,
    val trackNumber: Int = 0,
    val fileSize: Long = 0L,
    val mimeType: String? = null,
    val smbLastWriteTime: Long = 0L,
    val isCached: Boolean = false,
    val cachedAt: Long? = null,
    val cacheLastPlayedAt: Long? = null,
    val lastPlayedAt: Long? = null,
    val playCount: Int = 0,
    val sourceUpdatedAt: Long? = null,
    val addedAt: Long = System.currentTimeMillis()
)
