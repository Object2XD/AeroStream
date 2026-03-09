package com.example.aero_stream_for_android.di

import android.content.Context
import androidx.room.Room
import com.example.aero_stream_for_android.data.local.db.AeroDatabase
import com.example.aero_stream_for_android.data.local.db.dao.DownloadDao
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStagingDao
import com.example.aero_stream_for_android.data.local.db.dao.LibraryScanStatusDao
import com.example.aero_stream_for_android.data.local.db.dao.PlaylistDao
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideDatabase(@ApplicationContext context: Context): AeroDatabase {
        return Room.databaseBuilder(
            context,
            AeroDatabase::class.java,
            "aero_stream_db"
        )
            .addMigrations(AeroDatabase.MIGRATION_1_2)
            .addMigrations(AeroDatabase.MIGRATION_2_3)
            .addMigrations(AeroDatabase.MIGRATION_3_4)
            .addMigrations(AeroDatabase.MIGRATION_4_5)
            .addMigrations(AeroDatabase.MIGRATION_5_6)
            .addMigrations(AeroDatabase.MIGRATION_6_7)
            .addMigrations(AeroDatabase.MIGRATION_7_8)
            .addMigrations(AeroDatabase.MIGRATION_8_9)
            .build()
    }

    @Provides
    fun provideSongDao(db: AeroDatabase): SongDao = db.songDao()

    @Provides
    fun provideLibraryScanStagingDao(db: AeroDatabase): LibraryScanStagingDao = db.libraryScanStagingDao()

    @Provides
    fun provideLibraryScanStatusDao(db: AeroDatabase): LibraryScanStatusDao = db.libraryScanStatusDao()

    @Provides
    fun providePlaylistDao(db: AeroDatabase): PlaylistDao = db.playlistDao()

    @Provides
    fun provideDownloadDao(db: AeroDatabase): DownloadDao = db.downloadDao()
}
