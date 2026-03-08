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
private const val METADATA_FULL_DOWNLOAD_MAX_BYTES = 100 * 1024 * 1024L // 100MB

internal class SmbMetadataExtractor(
    private val context: Context,
    private val loggerTag: String
) {
    suspend fun extractSongMetadata(
        config: SmbConfig,
        fileInfo: SmbFileInfo,
        openFileStream: suspend (SmbConfig, String) -> InputStream,
        toSong: (SmbFileInfo) -> Song
    ): ScanMetadataResult {
        val fallbackSong = toSong(fileInfo).copy(
            smbConfigId = config.id,
            sourceUpdatedAt = System.currentTimeMillis(),
            metadataState = SongMetadataState.FALLBACK
        )
        val tempFile = File.createTempFile("smb_meta_", ".${fileInfo.extension}", context.cacheDir)

        return try {
            if (fileInfo.size > METADATA_FULL_DOWNLOAD_MAX_BYTES) {
                Log.d(
                    loggerTag,
                    "File too large for metadata extraction (${fileInfo.size} bytes), using fallback: ${fileInfo.path}"
                )
                return ScanMetadataResult.Fallback(fallbackSong)
            }

            openFileStream(config, fileInfo.path).use { input ->
                FileOutputStream(tempFile).use { output ->
                    val buffer = ByteArray(8192)
                    var totalBytesRead = 0L
                    while (totalBytesRead < METADATA_PARTIAL_READ_BYTES) {
                        val bytesRead = input.read(
                            buffer,
                            0,
                            minOf(buffer.size.toLong(), METADATA_PARTIAL_READ_BYTES - totalBytesRead).toInt()
                        )
                        if (bytesRead == -1) break
                        output.write(buffer, 0, bytesRead)
                        totalBytesRead += bytesRead
                    }
                }
            }

            val retriever = MediaMetadataRetriever()
            try {
                retriever.setDataSource(tempFile.absolutePath)

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
                    saveArtwork(config.id, fileInfo.path, bytes)
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
        } catch (e: CancellationException) {
            throw e
        } catch (e: Exception) {
            Log.w(loggerTag, "Metadata extraction failed for ${fileInfo.path}, using fallback", e)
            ScanMetadataResult.Fallback(fallbackSong)
        } finally {
            tempFile.delete()
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
