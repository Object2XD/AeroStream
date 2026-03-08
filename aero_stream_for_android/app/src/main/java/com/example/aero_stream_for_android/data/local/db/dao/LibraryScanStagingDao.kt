package com.example.aero_stream_for_android.data.local.db.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.aero_stream_for_android.data.local.db.entity.LibraryScanStagingSongEntity

@Dao
interface LibraryScanStagingDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSongs(songs: List<LibraryScanStagingSongEntity>)

    @Query("SELECT * FROM library_scan_staging_songs WHERE scanSessionId = :scanSessionId ORDER BY stagingId ASC")
    suspend fun getSongsBySession(scanSessionId: String): List<LibraryScanStagingSongEntity>

    @Query("DELETE FROM library_scan_staging_songs WHERE scanSessionId = :scanSessionId")
    suspend fun deleteBySession(scanSessionId: String)
}
