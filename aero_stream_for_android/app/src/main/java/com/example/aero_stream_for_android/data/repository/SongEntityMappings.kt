package com.example.aero_stream_for_android.data.repository

import android.net.Uri
import com.example.aero_stream_for_android.data.local.db.entity.SongEntity
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.SongMetadataState

fun SongEntity.toDomainSong(): Song = Song(
    id = id,
    title = title,
    artist = artist,
    albumArtist = albumArtist,
    album = album,
    duration = duration,
    albumArtUri = albumArtUri?.let { Uri.parse(it) },
    source = MusicSource.valueOf(source),
    smbPath = smbPath,
    smbConfigId = smbConfigId,
    smbLibraryBucket = smbLibraryBucket,
    localPath = localPath,
    contentUri = contentUri?.let { Uri.parse(it) },
    trackNumber = trackNumber,
    fileSize = fileSize,
    mimeType = mimeType,
    smbLastWriteTime = smbLastWriteTime,
    isCached = isCached,
    cachedAt = cachedAt,
    cacheLastPlayedAt = cacheLastPlayedAt,
    sourceUpdatedAt = sourceUpdatedAt,
    metadataState = runCatching { SongMetadataState.valueOf(metadataState) }
        .getOrDefault(SongMetadataState.UNSCANNED),
    lastPlayedAt = lastPlayedAt,
    playCount = playCount
)

fun Song.toSongEntity(): SongEntity = SongEntity(
    id = id,
    title = title,
    artist = artist,
    albumArtist = albumArtist,
    album = album,
    duration = duration,
    albumArtUri = albumArtUri?.toString(),
    source = source.name,
    smbPath = smbPath,
    smbConfigId = smbConfigId,
    smbLibraryBucket = smbLibraryBucket,
    localPath = localPath,
    contentUri = contentUri?.toString(),
    trackNumber = trackNumber,
    fileSize = fileSize,
    mimeType = mimeType,
    smbLastWriteTime = smbLastWriteTime,
    isCached = isCached,
    cachedAt = cachedAt,
    cacheLastPlayedAt = cacheLastPlayedAt,
    metadataState = metadataState.name,
    lastPlayedAt = lastPlayedAt,
    playCount = playCount,
    sourceUpdatedAt = sourceUpdatedAt
)
