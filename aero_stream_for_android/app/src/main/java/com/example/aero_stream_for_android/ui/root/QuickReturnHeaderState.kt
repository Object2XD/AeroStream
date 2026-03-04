package com.example.aero_stream_for_android.ui.root

data class QuickReturnHeaderState(
    val totalHeaderHeightPx: Int = 0,
    val headerOffsetPx: Float = 0f
) {
    val visibleHeaderHeightPx: Float
        get() = (totalHeaderHeightPx + headerOffsetPx).coerceIn(0f, totalHeaderHeightPx.toFloat())

    fun updateHeaderHeight(heightPx: Int): QuickReturnHeaderState {
        if (kotlin.math.abs(totalHeaderHeightPx - heightPx) <= 1) return this
        val newHeight = heightPx.coerceAtLeast(0)
        return copy(totalHeaderHeightPx = newHeight).clampOffset()
    }

    fun applyScrollDelta(deltaY: Float): QuickReturnHeaderState {
        if (totalHeaderHeightPx <= 0) return copy(headerOffsetPx = 0f)
        return copy(
            headerOffsetPx = (headerOffsetPx + deltaY).coerceIn(-totalHeaderHeightPx.toFloat(), 0f)
        )
    }

    fun resetOffset(): QuickReturnHeaderState = copy(headerOffsetPx = 0f)

    fun clampOffset(): QuickReturnHeaderState {
        val minOffset = -totalHeaderHeightPx.toFloat()
        return copy(headerOffsetPx = headerOffsetPx.coerceIn(minOffset, 0f))
    }
}
