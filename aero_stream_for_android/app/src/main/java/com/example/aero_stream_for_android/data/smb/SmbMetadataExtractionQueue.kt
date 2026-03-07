package com.example.aero_stream_for_android.data.smb

import android.content.Context
import android.util.Log
import com.example.aero_stream_for_android.data.local.db.dao.SongDao
import com.example.aero_stream_for_android.data.remote.smb.SmbFileInfo
import com.example.aero_stream_for_android.data.remote.smb.SmbMediaDataSource
import com.example.aero_stream_for_android.data.remote.smb.SmbMetadataExtractor
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.domain.model.Song
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.channels.Channel
import kotlinx.coroutines.isActive
import kotlinx.coroutines.launch
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class SmbMetadataExtractionQueue @Inject constructor(
    @ApplicationContext private val context: Context,
    private val songDao: SongDao,
    private val smbMediaDataSource: SmbMediaDataSource
) {
    private val scope = CoroutineScope(SupervisorJob() + Dispatchers.IO)
    private val metadataExtractor = SmbMetadataExtractor(context, "SmbExtractionQueue")
    
    // LIFO queue implementation to prioritize newest requests
    private val queueMutex = Mutex()
    private val pendingRequests = mutableListOf<Request>()
    private val processingPaths = mutableSetOf<String>()
    
    // Channel to wake up workers
    private val workChannel = Channel<Unit>(Channel.UNLIMITED)
    
    private val workerCount = 2 // Limit concurrent extractions
    
    init {
        // Start workers
        repeat(workerCount) {
            scope.launch {
                workerLoop()
            }
        }
    }
    
    fun enqueueExtraction(config: SmbConfig, song: Song) {
        if (song.smbPath == null || song.duration > 0L) {
            // Already has metadata or not an SMB song
            return
        }
        
        scope.launch {
            queueMutex.withLock {
                // Remove existing request for the same path to prevent duplicates and effectively push it to the end (highest priority)
                pendingRequests.removeAll { it.song.smbPath == song.smbPath }
                
                if (!processingPaths.contains(song.smbPath)) {
                    pendingRequests.add(Request(config, song))
                    workChannel.trySend(Unit)
                }
            }
        }
    }
    
    private suspend fun workerLoop() {
        for (signal in workChannel) {
            if (!scope.isActive) break
            
            val request = queueMutex.withLock {
                if (pendingRequests.isNotEmpty()) {
                    // LIFO: take the last item (newest request)
                    val req = pendingRequests.removeAt(pendingRequests.lastIndex)
                    processingPaths.add(req.song.smbPath!!)
                    req
                } else {
                    null
                }
            }
            
            if (request != null) {
                try {
                    processRequest(request)
                } catch (e: Exception) {
                    Log.e("SmbExtractionQueue", "Error extracting metadata for ${request.song.smbPath}", e)
                } finally {
                    queueMutex.withLock {
                        processingPaths.remove(request.song.smbPath!!)
                    }
                }
            }
        }
    }
    
    private suspend fun processRequest(request: Request) {
        val path = request.song.smbPath ?: return
        val configId = request.config.id
        
        // Double check if metadata was already extracted
        val existingEntity = songDao.getSongBySmbPath(path)
        if (existingEntity == null || existingEntity.duration > 0L) {
            return
        }
        val fileInfo = SmbFileInfo(
            name = path.substringAfterLast('\\'),
            path = path,
            size = request.song.fileSize,
            lastWriteTime = request.song.smbLastWriteTime,
            isDirectory = false,
            extension = path.substringAfterLast('.', "").lowercase()
        )
        
        val result = metadataExtractor.extractSongMetadata(
            config = request.config,
            fileInfo = fileInfo,
            openFileStream = { cfg, filePath -> smbMediaDataSource.openFileStream(cfg, filePath) },
            toSong = { _ -> request.song }
        )
        
        if (result is MetadataResult.Success || result is MetadataResult.Fallback) {
            val updatedSong = when (result) {
                is MetadataResult.Success -> result.song
                is MetadataResult.Fallback -> result.song
                else -> request.song
            }
            
            // Only update the database if we actually gained some new metadata
            if (updatedSong.duration > 0L || updatedSong.albumArtUri != null) {
                Log.d("SmbExtractionQueue", "Updating metadata in DB for: $path")
                songDao.updateSong(updatedSong.toEntity())
            }
        }
    }
    
    // Mapping extension to avoid exposing internal entities everywhere if possible
    private fun Song.toEntity(): com.example.aero_stream_for_android.data.local.db.entity.SongEntity {
        return com.example.aero_stream_for_android.data.local.db.entity.SongEntity(
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
            lastPlayedAt = lastPlayedAt,
            playCount = playCount,
            sourceUpdatedAt = sourceUpdatedAt
        )
    }
    
    private data class Request(
        val config: SmbConfig,
        val song: Song
    )
}
