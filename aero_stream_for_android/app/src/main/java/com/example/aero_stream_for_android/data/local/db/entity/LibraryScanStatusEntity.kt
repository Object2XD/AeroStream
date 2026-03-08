package com.example.aero_stream_for_android.data.local.db.entity

import androidx.room.Entity

@Entity(
    tableName = "library_scan_status",
    primaryKeys = ["sourceType", "sourceConfigId"]
)
data class LibraryScanStatusEntity(
    val sourceType: String,
    val sourceConfigId: String,
    val lastStartedAt: Long? = null,
    val lastSuccessfulScanAt: Long? = null,
    val lastCompletedAt: Long? = null,
    val lastResult: String = "IDLE",
    val lastMessage: String = ""
)
