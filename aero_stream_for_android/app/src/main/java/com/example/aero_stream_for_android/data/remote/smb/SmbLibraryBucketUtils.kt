package com.example.aero_stream_for_android.data.remote.smb

const val ROOT_BUCKET_ID = "__root__"

data class SmbLibraryBucket(
    val id: String,
    val displayName: String,
    val shareRelativePath: String,
    val containsDirectFiles: Boolean = false
)

fun deriveSmbLibraryBucket(rootPath: String, smbPath: String): String? {
    val relativePath = stripSmbRootPrefix(rootPath, smbPath)
    if (relativePath.isBlank()) return ROOT_BUCKET_ID
    val firstSegment = relativePath.substringBefore('\\', "")
    return firstSegment.ifBlank { ROOT_BUCKET_ID }
}

fun bucketDisplayName(bucketId: String): String =
    if (bucketId == ROOT_BUCKET_ID) "ルート直下のファイル" else bucketId
