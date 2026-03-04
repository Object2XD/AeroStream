package com.example.aero_stream_for_android.data.remote.smb

fun normalizeSmbRootPath(rootPath: String): String {
    val trimmed = rootPath.trim().replace('/', '\\')
    if (trimmed.isBlank()) return ""

    return trimmed
        .split('\\')
        .filter { it.isNotBlank() }
        .joinToString("\\")
}

fun resolveSmbShareRelativePath(rootPath: String, childPath: String): String {
    val normalizedRoot = normalizeSmbRootPath(rootPath)
    val normalizedChild = normalizeSmbRootPath(childPath)
    return when {
        normalizedRoot.isBlank() -> normalizedChild
        normalizedChild.isBlank() -> normalizedRoot
        else -> "$normalizedRoot\\$normalizedChild"
    }
}

fun stripSmbRootPrefix(rootPath: String, absoluteSharePath: String): String {
    val normalizedRoot = normalizeSmbRootPath(rootPath)
    val normalizedPath = normalizeSmbRootPath(absoluteSharePath)
    if (normalizedRoot.isBlank()) return normalizedPath
    return normalizedPath.removePrefix("$normalizedRoot\\").removePrefix(normalizedRoot)
}

fun validateSmbRootPathInput(rootPath: String): String? {
    val trimmed = rootPath.trim()
    if (trimmed.isBlank()) return null
    if (trimmed.startsWith("\\") || trimmed.startsWith("/")) {
        return "開始フォルダは共有名の下の相対パスで入力してください"
    }
    if (trimmed.contains("..")) {
        return "開始フォルダに .. は使用できません"
    }
    if (trimmed.contains(':')) {
        return "開始フォルダに絶対パスは指定できません"
    }

    val normalized = trimmed.replace('/', '\\')
    if (normalized.split('\\').any { it.isBlank() }) {
        return "開始フォルダに空のパス区切りは使用できません"
    }

    return null
}
