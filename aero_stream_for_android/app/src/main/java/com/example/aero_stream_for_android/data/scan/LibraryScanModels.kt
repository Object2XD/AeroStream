package com.example.aero_stream_for_android.data.scan

import com.example.aero_stream_for_android.domain.model.Song

enum class LibraryScanStage(val label: String) {
    IDLE("待機中"),
    CONNECTING("接続中"),
    LISTING("一覧を取得中"),
    EXTRACTING("メタデータを抽出中"),
    STAGING("ステージング中"),
    COMMITTING("反映中"),
    COMPLETED("更新完了"),
    FAILED("更新失敗"),
    CANCELLED("更新をキャンセルしました")
}

enum class LibraryStoredScanResult {
    IDLE,
    RUNNING,
    COMPLETED,
    FAILED,
    CANCELLED
}

data class LibraryScanProgress(
    val isRunning: Boolean = false,
    val stage: LibraryScanStage = LibraryScanStage.IDLE,
    val elapsedSec: Long = 0L,
    val processedCount: Int = 0,
    val scannedCount: Int = 0,
    val stagedCount: Int = 0,
    val failedCount: Int = 0,
    val skippedDirectories: Int = 0,
    val totalCount: Int = 0,
    val discoveryCompleted: Boolean = false,
    val progressPercent: Int? = null,
    val estimatedRemainingSec: Long? = null,
    val message: String = "",
    val sourceConfigId: String? = null
)

data class ScanProgressEvent(
    val stage: LibraryScanStage,
    val processedCount: Int = 0,
    val scannedCount: Int = 0,
    val stagedCount: Int = 0,
    val failedCount: Int = 0,
    val skippedDirectories: Int = 0,
    val totalCount: Int = 0,
    val discoveryCompleted: Boolean = false,
    val currentPath: String? = null
)

sealed class ScanMetadataResult {
    data class Success(val song: Song) : ScanMetadataResult()
    data class Fallback(val song: Song) : ScanMetadataResult()
    data object Error : ScanMetadataResult()
}
