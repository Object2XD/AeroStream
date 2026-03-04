package com.example.aero_stream_for_android.data.smb

import com.example.aero_stream_for_android.domain.model.Song

enum class SmbScanStage(val label: String) {
    IDLE("待機中"),
    CONNECTING("接続中"),
    LISTING("一覧を取得中"),
    ANALYZING("音楽を解析中"),
    SAVING("保存中"),
    COMPLETED("更新完了"),
    FAILED("更新失敗"),
    CANCELLED("更新をキャンセルしました")
}

data class SmbScanProgress(
    val isRunning: Boolean = false,
    val stage: SmbScanStage = SmbScanStage.IDLE,
    val scannedCount: Int = 0,
    val failedCount: Int = 0,
    val skippedDirectories: Int = 0,
    val totalCount: Int = 0,
    val message: String = "",
    val smbConfigId: String? = null
)

data class ScanProgressEvent(
    val stage: SmbScanStage,
    val scannedCount: Int = 0,
    val failedCount: Int = 0,
    val skippedDirectories: Int = 0,
    val totalCount: Int = 0,
    val currentPath: String? = null
)

/**
 * メタデータ抽出結果。
 */
sealed class MetadataResult {
    /** メタデータ取得成功 */
    data class Success(val song: Song) : MetadataResult()
    /** メタデータ取得失敗だがファイル名からフォールバック */
    data class Fallback(val song: Song) : MetadataResult()
    /** 完全に失敗（曲を追加しない） */
    data object Error : MetadataResult()
}

/**
 * バケット単位のスキャン結果。
 */
data class BucketScanResult(
    val songs: List<Song>,
    val failedCount: Int,
    val skippedDirectories: Int
)

/**
 * スキャン中の累積状態を管理する。
 */
data class ScanAccumulator(
    val results: MutableList<Song> = mutableListOf(),
    var failedCount: Int = 0,
    var skippedDirectories: Int = 0,
    val skippedPaths: MutableList<String> = mutableListOf()
)
