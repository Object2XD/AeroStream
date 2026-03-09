package com.example.aero_stream_for_android.data.local.db.dao

import androidx.room.*
import com.example.aero_stream_for_android.data.local.db.entity.DownloadEntity
import kotlinx.coroutines.flow.Flow

@Dao
interface DownloadDao {

    @Query("SELECT * FROM downloads ORDER BY createdAt DESC")
    fun getAllDownloads(): Flow<List<DownloadEntity>>

    @Query("SELECT * FROM downloads WHERE state = :state ORDER BY createdAt DESC")
    fun getDownloadsByState(state: String): Flow<List<DownloadEntity>>

    @Query("SELECT * FROM downloads WHERE songId = :songId LIMIT 1")
    suspend fun getDownloadBySongId(songId: Long): DownloadEntity?

    @Query("SELECT * FROM downloads WHERE smbPath = :smbPath LIMIT 1")
    suspend fun getDownloadBySmbPath(smbPath: String): DownloadEntity?

    @Query("SELECT * FROM downloads WHERE id = :id")
    suspend fun getDownloadById(id: Long): DownloadEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertDownload(download: DownloadEntity): Long

    @Update
    suspend fun updateDownload(download: DownloadEntity)

    @Delete
    suspend fun deleteDownload(download: DownloadEntity)

    @Query("DELETE FROM downloads")
    fun clearAllDownloads()

    @Query("DELETE FROM downloads WHERE smbPath = :smbPath")
    suspend fun deleteBySmbPath(smbPath: String)

    @Query("SELECT id FROM downloads")
    suspend fun getAllDownloadIds(): List<Long>

    @Query("UPDATE downloads SET state = :state, downloadedBytes = :bytes, fileSize = :fileSize WHERE id = :id")
    suspend fun updateProgress(id: Long, state: String, bytes: Long, fileSize: Long)

    @Query("UPDATE downloads SET state = :state, completedAt = :completedAt, localCachePath = :localPath WHERE id = :id")
    suspend fun markCompleted(id: Long, state: String = "COMPLETED", completedAt: Long = System.currentTimeMillis(), localPath: String)

    @Query("UPDATE downloads SET state = :state, errorMessage = :error WHERE id = :id")
    suspend fun markFailed(id: Long, state: String = "FAILED", error: String?)

    @Query("SELECT COUNT(*) FROM downloads WHERE state = 'COMPLETED'")
    fun getCompletedCount(): Flow<Int>
}
