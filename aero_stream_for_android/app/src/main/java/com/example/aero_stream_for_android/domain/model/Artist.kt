package com.example.aero_stream_for_android.domain.model

/**
 * アーティストのドメインモデル。
 */
data class Artist(
    val id: Long,
    val name: String,
    val songCount: Int = 0,
    val albumCount: Int = 0
)
