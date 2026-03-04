package com.example.aero_stream_for_android.di

import com.example.aero_stream_for_android.player.AudioPlayer
import com.example.aero_stream_for_android.player.Media3AudioPlayer
import com.example.aero_stream_for_android.player.StandardAudioPlayer
import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class AudioModule {

    @Binds
    @Singleton
    @Named("media3")
    abstract fun bindMedia3Player(impl: Media3AudioPlayer): AudioPlayer

    @Binds
    @Singleton
    @Named("mediaPlayer")
    abstract fun bindStandardPlayer(impl: StandardAudioPlayer): AudioPlayer
}
