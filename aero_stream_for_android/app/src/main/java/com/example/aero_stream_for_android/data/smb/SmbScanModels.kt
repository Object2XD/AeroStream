package com.example.aero_stream_for_android.data.smb

import com.example.aero_stream_for_android.data.scan.LibraryScanProgress
import com.example.aero_stream_for_android.data.scan.LibraryScanStage
import com.example.aero_stream_for_android.data.scan.LibraryStoredScanResult
import com.example.aero_stream_for_android.data.scan.ScanMetadataResult
import com.example.aero_stream_for_android.data.scan.ScanProgressEvent
import com.example.aero_stream_for_android.domain.model.Song

typealias SmbScanStage = LibraryScanStage
typealias SmbStoredScanResult = LibraryStoredScanResult
typealias SmbScanProgress = LibraryScanProgress
typealias ScanProgressEvent = com.example.aero_stream_for_android.data.scan.ScanProgressEvent
typealias MetadataResult = ScanMetadataResult

data class BucketScanResult(
    val songs: List<Song>,
    val failedCount: Int,
    val skippedDirectories: Int
)

data class ScanAccumulator(
    val results: MutableList<Song> = mutableListOf(),
    var failedCount: Int = 0,
    var skippedDirectories: Int = 0,
    val skippedPaths: MutableList<String> = mutableListOf()
)
