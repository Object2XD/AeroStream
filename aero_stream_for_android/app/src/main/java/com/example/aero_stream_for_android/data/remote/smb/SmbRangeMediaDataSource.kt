package com.example.aero_stream_for_android.data.remote.smb

import android.media.MediaDataSource
import java.io.Closeable

interface SmbRandomAccessReader : Closeable {
    fun readAt(position: Long, buffer: ByteArray, offset: Int, size: Int): Int
}

class SmbRangeMediaDataSource(
    private val reader: SmbRandomAccessReader,
    private val size: Long
) : MediaDataSource() {
    override fun readAt(position: Long, buffer: ByteArray, offset: Int, size: Int): Int {
        if (position < 0 || position >= this.size) return -1
        if (size <= 0) return 0
        val readableSize = minOf(size.toLong(), this.size - position).toInt()
        if (readableSize <= 0) return -1
        return reader.readAt(position, buffer, offset, readableSize)
    }

    override fun getSize(): Long = size

    override fun close() {
        reader.close()
    }
}
