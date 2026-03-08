package com.example.aero_stream_for_android.ui.root

data class QuickReturnHeaderState(
    val totalHeaderHeightPx: Int = 0,
    val headerOffsetPx: Float = 0f
) {
    data class ScrollDeltaResult(
        val state: QuickReturnHeaderState,
        val consumedY: Float
    )

    val visibleHeaderHeightPx: Float
        get() = (totalHeaderHeightPx + headerOffsetPx).coerceIn(0f, totalHeaderHeightPx.toFloat())

    fun updateHeaderHeight(heightPx: Int): QuickReturnHeaderState {
        if (kotlin.math.abs(totalHeaderHeightPx - heightPx) <= 1) return this
        val newHeight = heightPx.coerceAtLeast(0)
        return copy(totalHeaderHeightPx = newHeight).clampOffset()
    }

    fun applyScrollDelta(deltaY: Float): QuickReturnHeaderState {
        return applyScrollDeltaWithConsumption(deltaY).state
    }

    fun applyScrollDeltaWithConsumption(deltaY: Float): ScrollDeltaResult {
        if (totalHeaderHeightPx <= 0) {
            return ScrollDeltaResult(
                state = copy(headerOffsetPx = 0f),
                consumedY = 0f
            )
        }

        val updatedState = copy(
            headerOffsetPx = (headerOffsetPx + deltaY).coerceIn(-totalHeaderHeightPx.toFloat(), 0f)
        )
        return ScrollDeltaResult(
            state = updatedState,
            consumedY = updatedState.headerOffsetPx - headerOffsetPx
        )
    }

    fun resetOffset(): QuickReturnHeaderState = copy(headerOffsetPx = 0f)

    fun clampOffset(): QuickReturnHeaderState {
        val minOffset = -totalHeaderHeightPx.toFloat()
        return copy(headerOffsetPx = headerOffsetPx.coerceIn(minOffset, 0f))
    }
}
