package com.example.aero_stream_for_android.data.remote.smb

import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.hierynomus.smbj.SMBClient
import com.hierynomus.smbj.SmbConfig as SmbJConfig
import com.hierynomus.smbj.auth.AuthenticationContext
import com.hierynomus.smbj.connection.Connection
import com.hierynomus.smbj.session.Session
import com.hierynomus.smbj.share.DiskShare
import java.util.concurrent.TimeUnit
import kotlinx.coroutines.sync.Mutex

internal data class SmbConnectionEntry(
    var client: SMBClient? = null,
    var connection: Connection? = null,
    var session: Session? = null,
    @Volatile var share: DiskShare? = null,
    @Volatile var currentConfig: SmbConfig? = null,
    val mutex: Mutex = Mutex()
)

internal class SmbConnectionLifecycle {
    fun connect(entry: SmbConnectionEntry, config: SmbConfig) {
        val smbConfig = SmbJConfig.builder()
            .withTimeout(30, TimeUnit.SECONDS)
            .withReadTimeout(60, TimeUnit.SECONDS)
            .withWriteTimeout(60, TimeUnit.SECONDS)
            .withSoTimeout(30, TimeUnit.SECONDS)
            .build()

        val client = SMBClient(smbConfig)
        val connection = client.connect(config.hostname, config.port)

        val authContext = if (config.username.isNotBlank()) {
            AuthenticationContext(
                config.username,
                config.password.toCharArray(),
                config.domain.ifBlank { null }
            )
        } else {
            AuthenticationContext.guest()
        }

        val session = connection.authenticate(authContext)
        val share = session.connectShare(config.shareName) as DiskShare

        entry.client = client
        entry.connection = connection
        entry.session = session
        entry.share = share
        entry.currentConfig = config
    }

    fun disconnect(entry: SmbConnectionEntry) {
        try {
            entry.share?.close()
            entry.session?.close()
            entry.connection?.close()
            entry.client?.close()
        } catch (_: Exception) {
            // Ignore disconnect errors
        } finally {
            entry.share = null
            entry.session = null
            entry.connection = null
            entry.client = null
            entry.currentConfig = null
        }
    }

    fun isConnected(entry: SmbConnectionEntry): Boolean {
        return try {
            entry.connection?.isConnected == true &&
                entry.session != null &&
                entry.share != null &&
                isShareHealthy(entry.share)
        } catch (_: Exception) {
            false
        }
    }

    private fun isShareHealthy(share: DiskShare?): Boolean {
        return try {
            share?.isConnected == true
        } catch (_: Exception) {
            false
        }
    }
}
