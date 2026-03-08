package com.example.aero_stream_for_android.data.remote.smb

import android.content.Context
import android.media.MediaMetadataRetriever
import android.net.Uri
import android.util.Log
import com.example.aero_stream_for_android.data.scan.ScanMetadataResult
import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.SongMetadataState
import java.io.File
import java.io.FileOutputStream
import java.io.InputStream
import kotlin.coroutines.cancellation.CancellationException

private const val METADATA_PARTIAL_READ_BYTES = 2 * 1024 * 1024L // 2MB

internal class SmbMetadataExtractor(
    private val context: Context,
    private val loggerTag: String
) {
    private val rangeReadExtensions = setOf("mp3", "m4a", "flac", "wav")

    suspend fun extractSongMetadata(
        config: SmbConfig,
        fileInfo: SmbFileInfo,
        openFileStream: suspend (SmbConfig, String) -> InputStream,
        openRandomAccessReader: suspend (SmbConfig, String) -> SmbRandomAccessReader,
        toSong: (SmbFileInfo) -> Song
    ): ScanMetadataResult {
        val fallbackSong = toSong(fileInfo).copy(
            smbConfigId = config.id,
            sourceUpdatedAt = System.currentTimeMillis(),
            metadataState = SongMetadataState.FALLBACK
        )
        return try {
            if (fileInfo.extension.lowercase() in rangeReadExtensions) {
                runCatching {
                    val reader = openRandomAccessReader(config, fileInfo.path)
                    val mediaDataSource = SmbRangeMediaDataSource(reader = reader, size = fileInfo.size)
                    try {
                        return parseWithRetriever(
                            fallbackSong = fallbackSong,
                            configId = config.id,
                            smbPath = fileInfo.path
                        ) { retriever ->
                            retriever.setDataSource(mediaDataSource)
                        }
                    } finally {
                        runCatching { mediaDataSource.close() }
                    }
                }.onFailure { firstError ->
                    Log.w(
                        loggerTag,
                        "Range metadata extraction failed, retrying with full fetch: ${fileInfo.path}",
                        firstError
                    )
                }
                return parseFromTempFile(
                    config = config,
                    fileInfo = fileInfo,
                    fallbackSong = fallbackSong,
                    openFileStream = openFileStream,
                    readLimitBytes = null
                )
            }

            parseFromTempFile(
                config = config,
                fileInfo = fileInfo,
                fallbackSong = fallbackSong,
                openFileStream = openFileStream,
                readLimitBytes = METADATA_PARTIAL_READ_BYTES
            )
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.w(loggerTag, "Metadata extraction failed for ${fileInfo.path}, using fallback", e)
            ScanMetadataResult.Fallback(fallbackSong)
        }
    }

    private suspend fun parseFromTempFile(
        config: SmbConfig,
        fileInfo: SmbFileInfo,
        fallbackSong: Song,
        openFileStream: suspend (SmbConfig, String) -> InputStream,
        readLimitBytes: Long?
    ): ScanMetadataResult {
        val tempFile = File.createTempFile("smb_meta_", ".${fileInfo.extension}", context.cacheDir)
        return try {
            openFileStream(config, fileInfo.path).use { input ->
                FileOutputStream(tempFile).use { output ->
                    val buffer = ByteArray(8192)
                    var totalBytesRead = 0L
                    while (true) {
                        val size = when {
                            readLimitBytes == null -> buffer.size
                            totalBytesRead >= readLimitBytes -> break
                            else -> minOf(buffer.size.toLong(), readLimitBytes - totalBytesRead).toInt()
                        }
                        val bytesRead = input.read(buffer, 0, size)
                        if (bytesRead == -1) break
                        output.write(buffer, 0, bytesRead)
                        totalBytesRead += bytesRead
                    }
                }
            }

            parseWithRetriever(
                fallbackSong = fallbackSong,
                configId = config.id,
                smbPath = fileInfo.path
            ) { retriever ->
                retriever.setDataSource(tempFile.absolutePath)
            }
        } finally {
            tempFile.delete()
        }
    }

    private fun parseWithRetriever(
        fallbackSong: Song,
        configId: String,
        smbPath: String,
        setDataSource: (MediaMetadataRetriever) -> Unit
    ): ScanMetadataResult {
        val retriever = MediaMetadataRetriever()
        return try {
            setDataSource(retriever)

            val title = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
                ?.takeIf { it.isNotBlank() }
                ?: fallbackSong.title
            val artist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
                ?.takeIf { it.isNotBlank() }
                ?: fallbackSong.artist
            val albumArtist = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUMARTIST)
                ?.takeIf { it.isNotBlank() }
                ?: artist
            val album = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ALBUM)
                ?.takeIf { it.isNotBlank() }
                ?: fallbackSong.album
            val duration = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_DURATION)
                ?.toLongOrNull()
                ?: 0L
            val trackNumber = retriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_CD_TRACK_NUMBER)
                ?.substringBefore('/')
                ?.toIntOrNull()
                ?: 0
            val artUri = retriever.embeddedPicture?.let { bytes ->
                saveArtwork(configId, smbPath, bytes)
            }

            ScanMetadataResult.Success(
                fallbackSong.copy(
                    title = title,
                    artist = artist,
                    albumArtist = albumArtist,
                    album = album,
                    duration = duration,
                    trackNumber = trackNumber,
                    albumArtUri = artUri,
                    metadataState = SongMetadataState.COMPLETE
                )
            )
        } finally {
            runCatching { retriever.release() }
        }
    }

    private fun saveArtwork(smbConfigId: String, smbPath: String, bytes: ByteArray): Uri {
        val artworkDir = File(context.cacheDir, "smb_artwork${File.separator}$smbConfigId").apply {
            mkdirs()
        }
        val artworkFile = File(artworkDir, "${smbPath.hashCode()}.jpg")
        artworkFile.writeBytes(bytes)
        return Uri.fromFile(artworkFile)
    }
}
