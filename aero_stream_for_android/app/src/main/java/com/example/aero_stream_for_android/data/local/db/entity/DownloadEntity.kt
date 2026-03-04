package com.example.aero_stream_for_android.data.local.db.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

/**
 * ダウンロード状態を管理するRoomエンティティ。
 * SMB楽曲のダウンロード進捗を追跡する。
 */
@Entity(tableName = "downloads")
data class DownloadEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Long = 0,
    /** 元のSongEntityのID */
    val songId: Long,
    /** SMBサーバー上のファイルパス */
    val smbPath: String,
    /** ローカルキャッシュパス */
    val localCachePath: String? = null,
    /** ダウンロード状態: PENDING, DOWNLOADING, COMPLETED, FAILED, PAUSED */
    val state: String = "PENDING",
    /** ファイル全体のサイズ（バイト） */
    val fileSize: Long = 0L,
    /** ダウンロード済みバイト数 */
    val downloadedBytes: Long = 0L,
    /** 作成日時 */
    val createdAt: Long = System.currentTimeMillis(),
    /** 完了日時 */
    val completedAt: Long? = null,
    /** エラーメッセージ */
    val errorMessage: String? = null
)

/**
 * ダウンロード状態の列挙。
 */
object DownloadState {
    const val PENDING = "PENDING"
    const val DOWNLOADING = "DOWNLOADING"
    const val COMPLETED = "COMPLETED"
    const val FAILED = "FAILED"
    const val PAUSED = "PAUSED"
}
