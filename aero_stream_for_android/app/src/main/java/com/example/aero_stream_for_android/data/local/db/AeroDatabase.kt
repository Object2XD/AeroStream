package com.example.aero_stream_for_android.data.local.db

import androidx.room.Database
import androidx.room.migration.Migration
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import com.example.aero_stream_for_android.data.local.db.dao.DownloadDao
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStagingDao
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStatusDao
import com.example.aero_stream_for_android.data.local.db.dao.PlaylistDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.local.db.entity.DownloadEntity
import com.example.aero_stream_for_android.data.local.db.entity.LibraryScanStagingSongEntity
import com.example.aero_stream_for_android.data.local.db.entity.LibraryScanStatusEntity
import com.example.aero_stream_for_android.data.local.db.entity.PlaylistEntity
import com.example.aero_stream_for_android.data.local.db.entity.PlaylistSongCrossRef
import com.example.aero_stream_for_android.data.local.db.entity.SongEntity

@Database(
    entities = [
        SongEntity::class,
        LibraryScanStagingSongEntity::class,
        LibraryScanStatusEntity::class,
        PlaylistEntity::class,
        PlaylistSongCrossRef::class,
        DownloadEntity::class
    ],
    version = 9,
    exportSchema = false
)
abstract class AeroDatabase : RoomDatabase() {
    abstract fun songDao(): SongDao
    abstract fun libraryScanStagingDao(): LibraryScanStagingDao
    abstract fun libraryScanStatusDao(): LibraryScanStatusDao
    abstract fun playlistDao(): PlaylistDao
    abstract fun downloadDao(): DownloadDao

    companion object {
        val MIGRATION_1_2 = object : Migration(1, 2) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE songs ADD COLUMN smbConfigId TEXT")
                database.execSQL("ALTER TABLE songs ADD COLUMN sourceUpdatedAt INTEGER")
            }
        }

        val MIGRATION_2_3 = object : Migration(2, 3) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE songs ADD COLUMN smbLibraryBucket TEXT")
            }
        }

        val MIGRATION_3_4 = object : Migration(3, 4) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE songs ADD COLUMN albumArtist TEXT NOT NULL DEFAULT ''")
            }
        }

        val MIGRATION_4_5 = object : Migration(4, 5) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE songs ADD COLUMN smbLastWriteTime INTEGER NOT NULL DEFAULT 0")
            }
        }

        val MIGRATION_5_6 = object : Migration(5, 6) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE songs ADD COLUMN isCached INTEGER NOT NULL DEFAULT 0")
                database.execSQL("ALTER TABLE songs ADD COLUMN cachedAt INTEGER")
                database.execSQL("ALTER TABLE songs ADD COLUMN cacheLastPlayedAt INTEGER")
                database.execSQL(
                    """
                    UPDATE songs
                    SET source = 'SMB',
                        isCached = 1,
                        cachedAt = COALESCE(sourceUpdatedAt, addedAt)
                    WHERE source = 'DOWNLOAD' AND smbPath IS NOT NULL
                    """
                )
            }
        }

        val MIGRATION_6_7 = object : Migration(6, 7) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE songs ADD COLUMN metadataState TEXT NOT NULL DEFAULT 'UNSCANNED'")
                database.execSQL(
                    """
                    UPDATE songs
                    SET metadataState = CASE
                        WHEN source = 'SMB' AND duration = 0 AND albumArtUri IS NULL THEN 'FALLBACK'
                        ELSE 'COMPLETE'
                    END
                    """
                )
                database.execSQL(
                    """
                    CREATE TABLE IF NOT EXISTS smb_scan_staging_songs (
                        stagingId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                        scanSessionId TEXT NOT NULL,
                        songId INTEGER NOT NULL,
                        title TEXT NOT NULL,
                        artist TEXT NOT NULL,
                        albumArtist TEXT NOT NULL,
                        album TEXT NOT NULL,
                        duration INTEGER NOT NULL,
                        albumArtUri TEXT,
                        source TEXT NOT NULL,
                        smbPath TEXT,
                        smbConfigId TEXT,
                        smbLibraryBucket TEXT,
                        localPath TEXT,
                        contentUri TEXT,
                        trackNumber INTEGER NOT NULL,
                        fileSize INTEGER NOT NULL,
                        mimeType TEXT,
                        smbLastWriteTime INTEGER NOT NULL,
                        isCached INTEGER NOT NULL,
                        cachedAt INTEGER,
                        cacheLastPlayedAt INTEGER,
                        sourceUpdatedAt INTEGER,
                        metadataState TEXT NOT NULL,
                        lastPlayedAt INTEGER,
                        playCount INTEGER NOT NULL,
                        addedAt INTEGER NOT NULL
                    )
                    """
                )
                database.execSQL(
                    "CREATE INDEX IF NOT EXISTS index_smb_scan_staging_songs_scanSessionId ON smb_scan_staging_songs(scanSessionId)"
                )
                database.execSQL(
                    "CREATE INDEX IF NOT EXISTS index_smb_scan_staging_songs_scanSessionId_smbPath ON smb_scan_staging_songs(scanSessionId, smbPath)"
                )
                database.execSQL(
                    """
                    CREATE TABLE IF NOT EXISTS smb_scan_status (
                        smbConfigId TEXT NOT NULL PRIMARY KEY,
                        lastStartedAt INTEGER,
                        lastSuccessfulScanAt INTEGER,
                        lastCompletedAt INTEGER,
                        lastResult TEXT NOT NULL,
                        lastMessage TEXT NOT NULL
                    )
                    """
                )
            }
        }

        val MIGRATION_7_8 = object : Migration(7, 8) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL(
                    """
                    CREATE TABLE IF NOT EXISTS library_scan_staging_songs (
                        stagingId INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
                        scanSessionId TEXT NOT NULL,
                        scanSource TEXT NOT NULL,
                        scanSourceConfigId TEXT NOT NULL,
                        songId INTEGER NOT NULL,
                        title TEXT NOT NULL,
                        artist TEXT NOT NULL,
                        albumArtist TEXT NOT NULL,
                        album TEXT NOT NULL,
                        duration INTEGER NOT NULL,
                        albumArtUri TEXT,
                        source TEXT NOT NULL,
                        smbPath TEXT,
                        smbConfigId TEXT,
                        smbLibraryBucket TEXT,
                        localPath TEXT,
                        contentUri TEXT,
                        trackNumber INTEGER NOT NULL,
                        fileSize INTEGER NOT NULL,
                        mimeType TEXT,
                        smbLastWriteTime INTEGER NOT NULL,
                        isCached INTEGER NOT NULL,
                        cachedAt INTEGER,
                        cacheLastPlayedAt INTEGER,
                        sourceUpdatedAt INTEGER,
                        metadataState TEXT NOT NULL,
                        lastPlayedAt INTEGER,
                        playCount INTEGER NOT NULL,
                        addedAt INTEGER NOT NULL
                    )
                    """
                )
                database.execSQL(
                    "CREATE INDEX IF NOT EXISTS index_library_scan_staging_songs_scanSessionId ON library_scan_staging_songs(scanSessionId)"
                )
                database.execSQL(
                    "CREATE INDEX IF NOT EXISTS index_library_scan_staging_songs_scanSource_scanSourceConfigId ON library_scan_staging_songs(scanSource, scanSourceConfigId)"
                )
                database.execSQL(
                    """
                    INSERT INTO library_scan_staging_songs (
                        scanSessionId, scanSource, scanSourceConfigId, songId, title, artist, albumArtist,
                        album, duration, albumArtUri, source, smbPath, smbConfigId, smbLibraryBucket,
                        localPath, contentUri, trackNumber, fileSize, mimeType, smbLastWriteTime,
                        isCached, cachedAt, cacheLastPlayedAt, sourceUpdatedAt, metadataState,
                        lastPlayedAt, playCount, addedAt
                    )
                    SELECT
                        scanSessionId,
                        source,
                        COALESCE(smbConfigId, source),
                        songId, title, artist, albumArtist, album, duration, albumArtUri, source,
                        smbPath, smbConfigId, smbLibraryBucket, localPath, contentUri, trackNumber,
                        fileSize, mimeType, smbLastWriteTime, isCached, cachedAt, cacheLastPlayedAt,
                        sourceUpdatedAt, metadataState, lastPlayedAt, playCount, addedAt
                    FROM smb_scan_staging_songs
                    """
                )
                database.execSQL(
                    """
                    CREATE TABLE IF NOT EXISTS library_scan_status (
                        sourceType TEXT NOT NULL,
                        sourceConfigId TEXT NOT NULL,
                        lastStartedAt INTEGER,
                        lastSuccessfulScanAt INTEGER,
                        lastCompletedAt INTEGER,
                        lastResult TEXT NOT NULL,
                        lastMessage TEXT NOT NULL,
                        PRIMARY KEY(sourceType, sourceConfigId)
                    )
                    """
                )
                database.execSQL(
                    """
                    INSERT INTO library_scan_status (
                        sourceType, sourceConfigId, lastStartedAt, lastSuccessfulScanAt,
                        lastCompletedAt, lastResult, lastMessage
                    )
                    SELECT
                        'SMB',
                        smbConfigId,
                        lastStartedAt,
                        lastSuccessfulScanAt,
                        lastCompletedAt,
                        lastResult,
                        lastMessage
                    FROM smb_scan_status
                    """
                )
            }
        }

        val MIGRATION_8_9 = object : Migration(8, 9) {
            override fun migrate(database: SupportSQLiteDatabase) {
                database.execSQL("ALTER TABLE downloads ADD COLUMN smbConfigId TEXT")
            }
        }
    }
}
