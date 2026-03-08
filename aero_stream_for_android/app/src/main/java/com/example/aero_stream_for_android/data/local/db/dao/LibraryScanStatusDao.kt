package com.example.aero_stream_for_android.data.local.db.dao

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.aero_stream_for_android.data.local.db.entity.LibraryScanStatusEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface LibraryScanStatusDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun upsert(status: LibraryScanStatusEntity)

    @Query(
        """
        SELECT * FROM library_scan_status
        WHERE sourceType = :sourceType AND sourceConfigId = :sourceConfigId
        LIMIT 1
        """
    )
    suspend fun getStatus(sourceType: String, sourceConfigId: String): LibraryScanStatusEntity?

    @Query(
        """
        SELECT lastSuccessfulScanAt FROM library_scan_status
        WHERE sourceType = :sourceType AND sourceConfigId = :sourceConfigId
        LIMIT 1
        """
    )
    fun observeLastSuccessfulScanAt(sourceType: String, sourceConfigId: String): Flow<Long?>
}
