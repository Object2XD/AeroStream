package com.example.aero_stream_for_android.data.remote.smb

import com.example.aero_stream_for_android.domain.model.SmbConfig
import com.hierynomus.msdtyp.AccessMask
import com.hierynomus.msfscc.FileAttributes
import com.hierynomus.mssmb2.SMB2CreateDisposition
import com.hierynomus.mssmb2.SMB2ShareAccess
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
import java.net.ConnectException
import java.net.SocketTimeoutException
import java.net.UnknownHostException
import java.util.EnumSet
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

    private data class ConnectionEntry(
        var client: SMBClient? = null,
        var connection: Connection? = null,
        var session: Session? = null,
        @Volatile var share: DiskShare? = null,
        @Volatile var currentConfig: SmbConfig? = null,
        val mutex: Mutex = Mutex()
    )

    private val entries = ConcurrentHashMap<String, ConnectionEntry>()
    private val entriesMutex = Mutex()

    /**
     * SMBサーバーに接続してDiskShareを返す。
     * 既に接続済みの場合はロックなしでキャッシュされた接続を返す。
     */
    suspend fun getShare(config: SmbConfig): DiskShare {
        val configKey = config.connectionKey()
        val entry = getOrCreateEntry(configKey)

        if (entry.currentConfig == config && isConnected(entry)) {
            entry.share?.let { return it }
        }

        return entry.mutex.withLock {
            withContext(Dispatchers.IO) {
                if (entry.currentConfig != config || !isConnected(entry)) {
                    disconnectEntry(entry)
                    connect(entry, config)
                }
                entry.share ?: throw IllegalStateException("Failed to connect to SMB share")
            }
        }
    }

    private suspend fun getOrCreateEntry(key: String): ConnectionEntry {
        return entriesMutex.withLock {
            entries.getOrPut(key) { ConnectionEntry() }
        }
    }

    private fun connect(entry: ConnectionEntry, config: SmbConfig) {
        val smbConfig = SmbJConfig.builder()
            .withTimeout(30, TimeUnit.SECONDS)
            .withReadTimeout(60, TimeUnit.SECONDS)
            .withWriteTimeout(60, TimeUnit.SECONDS)
            .withSoTimeout(30, TimeUnit.SECONDS)
            .build()

        entry.client = SMBClient(smbConfig)
        entry.connection = entry.client!!.connect(config.hostname, config.port)

        val authContext = if (config.username.isNotBlank()) {
            AuthenticationContext(
                config.username,
                config.password.toCharArray(),
                config.domain.ifBlank { null }
            )
        } else {
            AuthenticationContext.guest()
        }

        entry.session = entry.connection!!.authenticate(authContext)
        entry.share = entry.session!!.connectShare(config.shareName) as DiskShare
        entry.currentConfig = config
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
        val reason = classifyFailureReason(throwable)
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
        return entries.values.any { isConnected(it) }
    }

    fun isConnected(config: SmbConfig): Boolean {
        val entry = entries[config.connectionKey()] ?: return false
        return isConnected(entry)
    }

    private fun isConnected(entry: ConnectionEntry): Boolean {
        return try {
            entry.connection?.isConnected == true &&
                entry.session != null &&
                entry.share != null &&
                isShareHealthy(entry.share)
        } catch (e: Exception) {
            false
        }
    }

    /**
     * shareが実際に利用可能かを軽量に確認する。
     */
    private fun isShareHealthy(share: DiskShare?): Boolean {
        return try {
            share?.isConnected == true
        } catch (e: Exception) {
            false
        }
    }

    /**
     * 接続が壊れている場合にリセットして再接続する。
     * リトライ前に呼び出すことで、壊れたコネクションを回復させる。
     */
    suspend fun resetIfBroken(config: SmbConfig) {
        val entry = getOrCreateEntry(config.connectionKey())
        if (!isConnected(entry)) {
            Log.w(TAG, "resetIfBroken: 接続が壊れているため再接続します")
            entry.mutex.withLock {
                withContext(Dispatchers.IO) {
                    disconnectEntry(entry)
                    connect(entry, config)
                }
            }
        }
    }

    suspend fun disconnect(configId: String) {
        val entry = entriesMutex.withLock {
            entries.remove(configId)
        } ?: return
        withContext(Dispatchers.IO) {
            disconnectEntry(entry)
        }
    }

    suspend fun disconnectAll() {
        val snapshot = entriesMutex.withLock {
            entries.toMap().also { entries.clear() }
        }
        withContext(Dispatchers.IO) {
            snapshot.values.forEach { entry ->
                disconnectEntry(entry)
            }
        }
    }

    suspend fun disconnect() = disconnectAll()

    private fun disconnectEntry(entry: ConnectionEntry) {
        try {
            entry.share?.close()
            entry.session?.close()
            entry.connection?.close()
            entry.client?.close()
        } catch (e: Exception) {
            // Ignore disconnect errors
        } finally {
            entry.share = null
            entry.session = null
            entry.connection = null
            entry.client = null
            entry.currentConfig = null
        }
    }

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

    private fun classifyFailureReason(throwable: Throwable): String {
        val root = generateSequence(throwable) { it.cause }.last()
        val messageChain = generateSequence(throwable) { it.cause }
            .mapNotNull { it.message }
            .joinToString(" -> ")

        return when {
            root is UnknownHostException || messageChain.contains("UnknownHost", ignoreCase = true) ->
                "この端末のDNSではホスト名を解決できません。短いローカル機器名は動作しないことがあります。IPアドレス、またはDNSで解決できる完全修飾ホスト名を使用してください。"

            root is ConnectException || messageChain.contains("Connection refused", ignoreCase = true) ->
                "ホストには到達しましたが、ポート接続が拒否されました。ホスト、ポート、SMBサービスの起動状態を確認してください。"

            root is SocketTimeoutException || messageChain.contains("timed out", ignoreCase = true) ->
                "タイムアウトしました。ホスト到達性、ポート、VPNやファイアウォール設定を確認してください。"

            messageChain.contains("STATUS_LOGON_FAILURE", ignoreCase = true) ||
                messageChain.contains("logon failure", ignoreCase = true) ->
                "ユーザー名またはパスワードが正しくありません。"

            messageChain.contains("STATUS_ACCESS_DENIED", ignoreCase = true) ||
                messageChain.contains("access denied", ignoreCase = true) ->
                "アクセスが拒否されました。権限または認証情報を確認してください。"

            messageChain.contains("STATUS_BAD_NETWORK_NAME", ignoreCase = true) ||
                messageChain.contains("bad network name", ignoreCase = true) ->
                "共有名が見つかりません。共有名のスペルを確認してください。"

            messageChain.contains("STATUS_OBJECT_PATH_NOT_FOUND", ignoreCase = true) ->
                "開始フォルダまたは指定パスが見つかりません。"

            messageChain.contains("STATUS_OBJECT_NAME_NOT_FOUND", ignoreCase = true) ->
                "開始フォルダが見つかりません。共有名の下の相対パスを確認してください。"

            messageChain.contains("STATUS_OBJECT_PATH_SYNTAX_BAD", ignoreCase = true) ->
                "開始フォルダの形式が正しくありません。共有名の下の相対パスを指定してください。"

            messageChain.contains("STATUS_NOT_SUPPORTED", ignoreCase = true) ->
                "サーバー側の SMB 設定がこの接続方法を受け付けていません。"

            messageChain.isNotBlank() ->
                "${root::class.simpleName}: $messageChain"

            else ->
                root::class.simpleName ?: "不明なエラー"
        }
    }

    private fun isUnknownHostFailure(throwable: Throwable): Boolean {
        val root = generateSequence(throwable) { it.cause }.last()
        val messageChain = generateSequence(throwable) { it.cause }
            .mapNotNull { it.message }
            .joinToString(" -> ")
        return root is UnknownHostException || messageChain.contains("UnknownHost", ignoreCase = true)
    }

    private fun isLikelyShortLocalName(host: String): Boolean {
        return host.isNotBlank() &&
            !host.contains('.') &&
            host.length <= 63 &&
            host.all { it.isLetterOrDigit() || it == '-' || it == '_' }
    }

    private fun isIpAddress(host: String): Boolean {
        val ipv4 = Regex("""^(\d{1,3}\.){3}\d{1,3}$""")
        return ipv4.matches(host) || host.contains(':')
    }
}
