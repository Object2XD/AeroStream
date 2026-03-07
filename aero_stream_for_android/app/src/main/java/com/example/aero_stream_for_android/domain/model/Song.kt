package com.example.aero_stream_for_android.domain.model

import android.net.Uri

/**
 * 楽曲のドメインモデル。
 * 全ての再生ソース（Local / SMB / Download）で共通して使用される。
 */
data class Song(
    val id: Long,
    val title: String,
    val artist: String,
    val albumArtist: String = "",
    val album: String,
    val duration: Long,
    val albumArtUri: Uri? = null,
    val source: MusicSource,
    /** SMBサーバー上のファイルパス（SMB/Downloadソースの場合） */
    val smbPath: String? = null,
    /** 複数SMB設定を識別するID */
    val smbConfigId: String? = null,
    /** SMBライブラリの直下サブフォルダ単位を識別するID */
    val smbLibraryBucket: String? = null,
    /** ローカルファイルパス（Local/Downloadソースの場合） */
    val localPath: String? = null,
    /** コンテンツURI（Local ソースの場合、MediaStore URI） */
    val contentUri: Uri? = null,
    /** トラック番号 */
    val trackNumber: Int = 0,
    /** ファイルサイズ（バイト） */
    val fileSize: Long = 0L,
    /** MIMEタイプ */
    val mimeType: String? = null,
    /** SMBファイルの最終書き込み時刻（エポックミリ秒） */
    val smbLastWriteTime: Long = 0L,
    /** ローカルキャッシュ済みか */
    val isCached: Boolean = false,
    /** キャッシュ完了時刻 */
    val cachedAt: Long? = null,
    /** キャッシュ音源の最終再生時刻 */
    val cacheLastPlayedAt: Long? = null,
    /** ソースの最終更新時刻 */
    val sourceUpdatedAt: Long? = null,
    /** 最終再生日時 */
    val lastPlayedAt: Long? = null,
    /** 再生回数 */
    val playCount: Int = 0
)
