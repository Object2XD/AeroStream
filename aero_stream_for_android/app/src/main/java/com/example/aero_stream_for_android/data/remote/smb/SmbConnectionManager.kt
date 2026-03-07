package com.example.aero_stream_for_android.data.remote.smb

import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.hierynomus.smbj.SMBClient
import com.hierynomus.smbj.SmbConfig as SmbJConfig
import com.hierynomus.smbj.auth.AuthenticationContext
import com.hierynomus.smbj.connection.Connection
import com.hierynomus.smbj.session.Session
import com.hierynomus.smbj.share.DiskShare
import android.util.Log
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.sync.Mutex
import kotlinx.coroutines.sync.withLock
import kotlinx.coroutines.withContext
import java.io.InputStream
import java.net.InetAddress
import java.net.UnknownHostException
import java.util.concurrent.ConcurrentHashMap
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

data class SmbConnectionTestResult(
    val success: Boolean,
    val summary: String,
    val detail: String
)

data class HostValidationResult(
    val isValid: Boolean,
    val isIpAddress: Boolean,
    val isLikelyShortLocalName: Boolean,
    val resolvedAddresses: List<String>,
    val message: String
)

/**
 * SMBサーバーへの接続を管理するシングルトン。
 * 接続プーリングと再接続を処理する。
 */
@Singleton
class SmbConnectionManager @Inject constructor() {

    companion object {
        private const val TAG = "SmbConnectionManager"
    }

    private val entries = ConcurrentHashMap<String, SmbConnectionEntry>()
    private val entriesMutex = Mutex()
    private val lifecycle = SmbConnectionLifecycle()

    /**
     * SMBサーバーに接続してDiskShareを返す。
     * 既に接続済みの場合はロックなしでキャッシュされた接続を返す。
     */
    suspend fun getShare(config: SmbConfig): DiskShare {
        val configKey = config.connectionKey()
        val entry = getOrCreateEntry(configKey)

        if (entry.currentConfig == config && lifecycle.isConnected(entry)) {
            entry.share?.let { return it }
        }

        return entry.mutex.withLock {
            withContext(Dispatchers.IO) {
                if (entry.currentConfig != config || !lifecycle.isConnected(entry)) {
                    lifecycle.disconnect(entry)
                    lifecycle.connect(entry, config)
                }
                entry.share ?: throw IllegalStateException("Failed to connect to SMB share")
            }
        }
    }

    private suspend fun getOrCreateEntry(key: String): SmbConnectionEntry {
        return entriesMutex.withLock {
            entries.getOrPut(key) { SmbConnectionEntry() }
        }
    }

    suspend fun validateHostTarget(host: String): HostValidationResult = withContext(Dispatchers.IO) {
        val trimmedHost = host.trim()
        if (trimmedHost.isBlank()) {
            return@withContext HostValidationResult(
                isValid = false,
                isIpAddress = false,
                isLikelyShortLocalName = false,
                resolvedAddresses = emptyList(),
                message = "ホスト名またはIPアドレスを入力してください。"
            )
        }

        if (isIpAddress(trimmedHost)) {
            return@withContext HostValidationResult(
                isValid = true,
                isIpAddress = true,
                isLikelyShortLocalName = false,
                resolvedAddresses = listOf(trimmedHost),
                message = "IPアドレス入力です。名前解決は不要です。"
            )
        }

        try {
            val resolvedAddresses = InetAddress.getAllByName(trimmedHost)
                .map { it.hostAddress ?: trimmedHost }
                .distinct()

            HostValidationResult(
                isValid = true,
                isIpAddress = false,
                isLikelyShortLocalName = false,
                resolvedAddresses = resolvedAddresses,
                message = "名前解決成功"
            )
        } catch (e: UnknownHostException) {
            HostValidationResult(
                isValid = false,
                isIpAddress = false,
                isLikelyShortLocalName = isLikelyShortLocalName(trimmedHost),
                resolvedAddresses = emptyList(),
                message = "この名前は端末のDNSでは解決できません。IPアドレス入力を推奨します。"
            )
        } catch (e: Exception) {
            HostValidationResult(
                isValid = false,
                isIpAddress = false,
                isLikelyShortLocalName = isLikelyShortLocalName(trimmedHost),
                resolvedAddresses = emptyList(),
                message = "名前解決の確認に失敗しました。現在のネットワーク状態または入力値を確認してください。"
            )
        }
    }

    fun formatConnectionError(
        config: SmbConfig,
        stage: String,
        throwable: Throwable
    ): String {
        val reason = classifySmbFailureReason(throwable)
        val detail = buildString {
            appendLine("段階: $stage")
            appendLine("表示名: ${config.displayName.ifBlank { "SMB" }}")
            appendLine("ホスト: ${config.hostname}:${config.port}")
            appendLine(
                "解決結果: ${
                    if (isUnknownHostFailure(throwable)) {
                        "未解決"
                    } else {
                        "接続先の解決後に失敗"
                    }
                }"
            )
            appendLine("共有名: ${config.shareName}")
            if (config.rootPath.isNotBlank()) {
                appendLine("開始フォルダ: ${normalizeSmbRootPath(config.rootPath)}")
            }
            appendLine("ユーザー: ${config.username.ifBlank { "guest" }}")
            append("詳細: $reason")
        }
        return detail.trim()
    }

    fun isConnected(): Boolean {
        return entries.values.any { lifecycle.isConnected(it) }
    }

    fun isConnected(config: SmbConfig): Boolean {
        val entry = entries[config.connectionKey()] ?: return false
        return lifecycle.isConnected(entry)
    }

    /**
     * 接続が壊れている場合にリセットして再接続する。
     * リトライ前に呼び出すことで、壊れたコネクションを回復させる。
     */
    suspend fun resetIfBroken(config: SmbConfig) {
        val entry = getOrCreateEntry(config.connectionKey())
        if (!lifecycle.isConnected(entry)) {
            Log.w(TAG, "resetIfBroken: 接続が壊れているため再接続します")
            entry.mutex.withLock {
                withContext(Dispatchers.IO) {
                    lifecycle.disconnect(entry)
                    lifecycle.connect(entry, config)
                }
            }
        }
    }

    suspend fun disconnect(configId: String) {
        val entry = entriesMutex.withLock {
            entries.remove(configId)
        } ?: return
        withContext(Dispatchers.IO) {
            lifecycle.disconnect(entry)
        }
    }

    suspend fun disconnectAll() {
        val snapshot = entriesMutex.withLock {
            entries.toMap().also { entries.clear() }
        }
        withContext(Dispatchers.IO) {
            snapshot.values.forEach { entry ->
                lifecycle.disconnect(entry)
            }
        }
    }

    suspend fun disconnect() = disconnectAll()

    private fun SmbConfig.connectionKey(): String {
        return id.ifBlank { "$hostname:$port/$shareName" }
    }

    /**
     * 接続テスト。成功した場合はtrue。
     * シングルトンの接続を汚染しないよう、ローカル変数で接続を管理する。
     */
    suspend fun testConnection(config: SmbConfig): SmbConnectionTestResult = withContext(Dispatchers.IO) {
        var localClient: SMBClient? = null
        var localConnection: Connection? = null
        var localSession: Session? = null
        var localShare: DiskShare? = null

        try {
            if (!config.isConfigured) {
                return@withContext SmbConnectionTestResult(
                    success = false,
                    summary = "入力が不足しています",
                    detail = buildString {
                        appendLine("段階: 入力値確認")
                        appendLine("ホスト: ${config.hostname.ifBlank { "(未入力)" }}:${config.port}")
                        appendLine("共有名: ${config.shareName.ifBlank { "(未入力)" }}")
                        if (config.rootPath.isNotBlank()) {
                            appendLine("開始フォルダ: ${normalizeSmbRootPath(config.rootPath)}")
                        }
                        append("詳細: ホスト名または共有名が未入力です。")
                    }
                )
            }

            val hostValidation = validateHostTarget(config.hostname)
            if (!hostValidation.isValid) {
                return@withContext SmbConnectionTestResult(
                    success = false,
                    summary = "ホスト名を解決できませんでした",
                    detail = buildString {
                        appendLine("段階: ホスト名解決")
                        appendLine("表示名: ${config.displayName.ifBlank { "SMB" }}")
                        appendLine("ホスト: ${config.hostname}:${config.port}")
                        appendLine("解決結果: 未解決")
                        appendLine("共有名: ${config.shareName}")
                        if (config.rootPath.isNotBlank()) {
                            appendLine("開始フォルダ: ${normalizeSmbRootPath(config.rootPath)}")
                        }
                        appendLine("詳細: ${hostValidation.message}")
                        append(
                            "推奨: IPアドレスを入力するか、ルーター/DNS側で名前解決できる完全修飾ホスト名を使用してください。"
                        )
                    }
                )
            }

            val resolutionText = if (hostValidation.isIpAddress) {
                "IPアドレス指定"
            } else {
                hostValidation.resolvedAddresses.joinToString()
            }

            val smbConfig = SmbJConfig.builder()
                .withTimeout(30, TimeUnit.SECONDS)
                .withReadTimeout(60, TimeUnit.SECONDS)
                .withWriteTimeout(60, TimeUnit.SECONDS)
                .withSoTimeout(30, TimeUnit.SECONDS)
                .build()

            localClient = SMBClient(smbConfig)
            localConnection = try {
                localClient.connect(config.hostname, config.port)
            } catch (e: Exception) {
                return@withContext SmbConnectionTestResult(
                    success = false,
                    summary = if (isUnknownHostFailure(e)) {
                        "ホスト名を解決できませんでした"
                    } else {
                        "ホストへの接続に失敗しました"
                    },
                    detail = formatConnectionError(config, "TCP接続", e)
                )
            }

            val authContext = if (config.username.isNotBlank()) {
                AuthenticationContext(
                    config.username,
                    config.password.toCharArray(),
                    config.domain.ifBlank { null }
                )
            } else {
                AuthenticationContext.guest()
            }

            localSession = try {
                localConnection.authenticate(authContext)
            } catch (e: Exception) {
                return@withContext SmbConnectionTestResult(
                    success = false,
                    summary = "認証に失敗しました",
                    detail = formatConnectionError(config, "認証", e)
                )
            }

            localShare = try {
                localSession.connectShare(config.shareName) as DiskShare
            } catch (e: Exception) {
                return@withContext SmbConnectionTestResult(
                    success = false,
                    summary = "共有フォルダに接続できませんでした",
                    detail = formatConnectionError(config, "共有接続", e)
                )
            }

            val rootPath = normalizeSmbRootPath(config.rootPath)
            try {
                if (rootPath.isBlank()) {
                    localShare.list("")
                } else {
                    localShare.list(rootPath)
                }
            } catch (e: Exception) {
                return@withContext SmbConnectionTestResult(
                    success = false,
                    summary = if (rootPath.isBlank()) {
                        "共有フォルダの読み取りに失敗しました"
                    } else {
                        "開始フォルダが見つかりません"
                    },
                    detail = if (rootPath.isBlank()) {
                        formatConnectionError(config, "一覧取得", e)
                    } else {
                        buildString {
                            appendLine("段階: 開始フォルダ確認")
                            appendLine("表示名: ${config.displayName.ifBlank { "SMB" }}")
                            appendLine("ホスト: ${config.hostname}:${config.port}")
                            appendLine("共有名: ${config.shareName}")
                            appendLine("開始フォルダ: $rootPath")
                            append(
                                "詳細: 共有名への接続は成功しましたが、指定した開始フォルダにはアクセスできません。共有名の下の相対パスになっているか確認してください。"
                            )
                        }.trim()
                    }
                )
            }

            SmbConnectionTestResult(
                success = true,
                summary = "接続成功",
                detail = buildString {
                    appendLine("段階: ${if (rootPath.isBlank()) "ルート一覧取得" else "開始フォルダ確認"}")
                    appendLine("表示名: ${config.displayName.ifBlank { "SMB" }}")
                    appendLine("ホスト: ${config.hostname}:${config.port}")
                    appendLine("解決結果: $resolutionText")
                    appendLine("共有名: ${config.shareName}")
                    if (rootPath.isNotBlank()) {
                        appendLine("開始フォルダ: $rootPath")
                    }
                    append("状態: 接続と一覧取得に成功しました")
                }
            )
        } finally {
            // ローカル変数のみクリーンアップ。シングルトンの接続は破壊しない。
            try {
                localShare?.close()
                localSession?.close()
                localConnection?.close()
                localClient?.close()
            } catch (e: Exception) {
                // Ignore cleanup errors
            }
        }
    }
}
