package com.example.aero_stream_for_android.data.download

sealed interface DownloadStartResult {
    data class Started(val downloadId: Long, val retriedFromFailure: Boolean) : DownloadStartResult
    data class SkippedActive(val existingDownloadId: Long) : DownloadStartResult
    data class AlreadyCompleted(val existingDownloadId: Long) : DownloadStartResult
    data class ConfigResolutionFailed(val reason: String) : DownloadStartResult
}
