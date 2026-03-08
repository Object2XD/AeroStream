package com.example.aero_stream_for_android.data.local.db.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.aero_stream_for_android.data.local.db.entity.SmbScanStagingSongEntity

@Dao
interface SmbScanStagingDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertSongs(songs: List<SmbScanStagingSongEntity>)

    @Query("SELECT * FROM smb_scan_staging_songs WHERE scanSessionId = :scanSessionId ORDER BY stagingId ASC")
    suspend fun getSongsBySession(scanSessionId: String): List<SmbScanStagingSongEntity>

    @Query("DELETE FROM smb_scan_staging_songs WHERE scanSessionId = :scanSessionId")
    suspend fun deleteBySession(scanSessionId: String)
}
