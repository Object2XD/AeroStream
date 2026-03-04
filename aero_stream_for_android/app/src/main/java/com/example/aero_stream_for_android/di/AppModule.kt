package com.example.aero_stream_for_android.di

import android.content.Context
import com.example.aero_stream_for_android.data.local.mediastore.LocalMediaDataSource
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object AppModule {

    @Provides
    @Singleton
    fun provideLocalMediaDataSource(@ApplicationContext context: Context): LocalMediaDataSource {
        return LocalMediaDataSource(context)
    }
}
