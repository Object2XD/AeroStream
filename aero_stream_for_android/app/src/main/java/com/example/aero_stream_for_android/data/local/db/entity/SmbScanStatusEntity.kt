package com.example.aero_stream_for_android.data.local.db.entity

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "smb_scan_status")
data class SmbScanStatusEntity(
    @PrimaryKey
    val smbConfigId: String,
    val lastStartedAt: Long? = null,
    val lastSuccessfulScanAt: Long? = null,
    val lastCompletedAt: Long? = null,
    val lastResult: String = "IDLE",
    val lastMessage: String = ""
)
