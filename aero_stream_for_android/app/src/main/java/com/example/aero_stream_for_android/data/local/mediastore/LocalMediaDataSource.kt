package com.example.aero_stream_for_android.data.local.mediastore

import android.content.ContentUris
import android.content.Context
import android.net.Uri
import android.os.Build
import android.provider.MediaStore
import com.example.aero_stream_for_android.domain.model.MusicSource
import com.example.aero_stream_for_android.domain.model.Song
import com.example.aero_stream_for_android.domain.model.SongMetadataState
import dagger.hilt.android.qualifiers.ApplicationContext
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import javax.inject.Inject
import javax.inject.Singleton

/**
 * ローカルストレージからMediaStore APIを使って楽曲をスキャンするデータソース。
 */
@Singleton
class LocalMediaDataSource @Inject constructor(
    @ApplicationContext private val context: Context
) {
    companion object {
        private const val ALBUM_ART_URI = "content://media/external/audio/albumart"

        private val AUDIO_EXTENSIONS = setOf(
            "mp3", "m4a", "flac", "ogg", "wav", "aac", "wma", "opus"
        )
    }

    suspend fun queryAudioItems(): List<LocalMediaItem> = withContext(Dispatchers.IO) {
        val items = mutableListOf<LocalMediaItem>()

        val collection = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            MediaStore.Audio.Media.getContentUri(MediaStore.VOLUME_EXTERNAL)
        } else {
            MediaStore.Audio.Media.EXTERNAL_CONTENT_URI
        }

        val projection = arrayOf(
            MediaStore.Audio.Media._ID,
            MediaStore.Audio.Media.TITLE,
            MediaStore.Audio.Media.ARTIST,
            MediaStore.Audio.Media.ALBUM,
            MediaStore.Audio.Media.ALBUM_ID,
            MediaStore.Audio.Media.DURATION,
            MediaStore.Audio.Media.TRACK,
            MediaStore.Audio.Media.SIZE,
            MediaStore.Audio.Media.MIME_TYPE,
            MediaStore.Audio.Media.DATA,
            MediaStore.Audio.Media.DATE_MODIFIED
        )

        val selection = "${MediaStore.Audio.Media.IS_MUSIC} != 0"
        val sortOrder = "${MediaStore.Audio.Media.TITLE} ASC"

        context.contentResolver.query(
            collection,
            projection,
            selection,
            null,
            sortOrder
        )?.use { cursor ->
            val idColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media._ID)
            val titleColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TITLE)
            val artistColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ARTIST)
            val albumColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM)
            val albumIdColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.ALBUM_ID)
            val durationColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DURATION)
            val trackColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.TRACK)
            val sizeColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.SIZE)
            val mimeTypeColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.MIME_TYPE)
            val dataColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATA)
            val modifiedColumn = cursor.getColumnIndexOrThrow(MediaStore.Audio.Media.DATE_MODIFIED)

            while (cursor.moveToNext()) {
                val id = cursor.getLong(idColumn)
                val duration = cursor.getLong(durationColumn)

                // 1秒未満の音声ファイルはスキップ
                if (duration < 1000) continue

                val albumId = cursor.getLong(albumIdColumn)
                val albumArtUri = ContentUris.withAppendedId(Uri.parse(ALBUM_ART_URI), albumId)
                val contentUri = ContentUris.withAppendedId(
                    MediaStore.Audio.Media.EXTERNAL_CONTENT_URI,
                    id
                )
                val localPath = cursor.getString(dataColumn)
                val modifiedAt = cursor.getLong(modifiedColumn) * 1000L

                items.add(
                    LocalMediaItem(
                        mediaStoreId = id,
                        title = cursor.getString(titleColumn) ?: "Unknown",
                        artist = cursor.getString(artistColumn) ?: "Unknown Artist",
                        album = cursor.getString(albumColumn) ?: "Unknown Album",
                        albumArtUri = albumArtUri,
                        duration = duration,
                        trackNumber = cursor.getInt(trackColumn),
                        fileSize = cursor.getLong(sizeColumn),
                        mimeType = cursor.getString(mimeTypeColumn),
                        localPath = localPath,
                        contentUri = contentUri,
                        modifiedAt = modifiedAt
                    )
                )
            }
        }

        items
    }
}

data class LocalMediaItem(
    val mediaStoreId: Long,
    val title: String,
    val artist: String,
    val album: String,
    val albumArtUri: Uri?,
    val duration: Long,
    val trackNumber: Int,
    val fileSize: Long,
    val mimeType: String?,
    val localPath: String?,
    val contentUri: Uri,
    val modifiedAt: Long
) {
    val lookupKey: String
        get() = localPath ?: contentUri.toString()

    fun toSong(): Song = Song(
        id = mediaStoreId,
        title = title,
        artist = artist,
        album = album,
        duration = duration,
        albumArtUri = albumArtUri,
        source = MusicSource.LOCAL,
        localPath = localPath,
        contentUri = contentUri,
        trackNumber = trackNumber,
        fileSize = fileSize,
        mimeType = mimeType,
        sourceUpdatedAt = modifiedAt,
        metadataState = SongMetadataState.COMPLETE
    )
}
