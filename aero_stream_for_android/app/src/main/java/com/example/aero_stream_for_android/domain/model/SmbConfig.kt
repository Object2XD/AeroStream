package com.example.aero_stream_for_android.domain.model

/**
 * SMBサーバー接続設定。
 */
data class SmbConfig(
    val id: String = "",
    val displayName: String = "",
    val hostname: String = "",
    val port: Int = 445,
    val shareName: String = "",
    val rootPath: String = "",
    val username: String = "",
    val password: String = "",
    val domain: String = ""
) {
    val isConfigured: Boolean
        get() = hostname.isNotBlank() && shareName.isNotBlank()
}
