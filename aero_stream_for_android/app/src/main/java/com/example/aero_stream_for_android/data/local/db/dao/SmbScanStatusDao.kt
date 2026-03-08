package com.example.aero_stream_for_android.data.local.db.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.aero_stream_for_android.data.local.db.entity.SmbScanStatusEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface SmbScanStatusDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(status: SmbScanStatusEntity)

    @Query("SELECT * FROM smb_scan_status WHERE smbConfigId = :smbConfigId LIMIT 1")
    suspend fun getStatus(smbConfigId: String): SmbScanStatusEntity?

    @Query("SELECT lastSuccessfulScanAt FROM smb_scan_status WHERE smbConfigId = :smbConfigId LIMIT 1")
    fun observeLastSuccessfulScanAt(smbConfigId: String): Flow<Long?>
}
