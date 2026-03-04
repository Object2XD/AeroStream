package com.example.aero_stream_for_android.domain.model

import android.net.Uri

/**
 * アルバムのドメインモデル。
 */
data class Album(
    val id: Long,
    val name: String,
    val artist: String,
    val albumArtist: String = "",
    val albumArtUri: Uri? = null,
    val songCount: Int = 0,
    val year: Int? = null
)
