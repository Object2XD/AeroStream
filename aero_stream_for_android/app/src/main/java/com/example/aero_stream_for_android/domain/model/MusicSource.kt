package com.example.aero_stream_for_android.domain.model

/**
 * 楽曲の再生ソースを表す列挙型。
 * YouTube Music における「ライブラリ」「YouTube」「オフライン」に対応。
 */
enum class MusicSource {
    /** ローカルストレージ上の楽曲 */
    LOCAL,
    /** SMBサーバー上の楽曲（YouTube Music の YouTube 楽曲に相当） */
    SMB,
    /** SMBからダウンロード済みの楽曲（オフライン再生用） */
    DOWNLOAD
}
