package com.example.aero_stream_for_android.di

import com.example.aero_stream_for_android.data.remote.smb.SmbConnectionManager
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideSmbConnectionManager(): SmbConnectionManager {
        return SmbConnectionManager()
    }
}
