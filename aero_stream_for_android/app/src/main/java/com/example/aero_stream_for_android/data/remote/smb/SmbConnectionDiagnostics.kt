package com.example.aero_stream_for_android.data.remote.smb

import java.net.ConnectException
import java.net.SocketTimeoutException
import java.net.UnknownHostException

internal fun classifySmbFailureReason(throwable: Throwable): String {
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

internal fun isUnknownHostFailure(throwable: Throwable): Boolean {
    val root = generateSequence(throwable) { it.cause }.last()
    val messageChain = generateSequence(throwable) { it.cause }
        .mapNotNull { it.message }
        .joinToString(" -> ")
    return root is UnknownHostException || messageChain.contains("UnknownHost", ignoreCase = true)
}

internal fun isLikelyShortLocalName(host: String): Boolean {
    return host.isNotBlank() &&
        !host.contains('.') &&
        host.length <= 63 &&
        host.all { it.isLetterOrDigit() || it == '-' || it == '_' }
}

internal fun isIpAddress(host: String): Boolean {
    val ipv4 = Regex("""^(\d{1,3}\.){3}\d{1,3}$""")
    return ipv4.matches(host) || host.contains(':')
}
