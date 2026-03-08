package com.example.aero_stream_for_android.data.local.db.entity

import androidx.room.Entity
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "library_scan_staging_songs",
    indices = [
        Index(value = ["scanSessionId"]),
        Index(value = ["scanSource", "scanSourceConfigId"])
    ]
)
data class LibraryScanStagingSongEntity(
    @PrimaryKey(autoGenerate = true)
    val stagingId: Long = 0,
    val scanSessionId: String,
    val scanSource: String,
    val scanSourceConfigId: String,
    val songId: Long = 0,
    val title: String,
    val artist: String,
    val albumArtist: String = "",
    val album: String,
    val duration: Long,
    val albumArtUri: String? = null,
    val source: String,
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
    val sourceUpdatedAt: Long? = null,
    val metadataState: String = "UNSCANNED",
    val lastPlayedAt: Long? = null,
    val playCount: Int = 0,
    val addedAt: Long = System.currentTimeMillis()
)
