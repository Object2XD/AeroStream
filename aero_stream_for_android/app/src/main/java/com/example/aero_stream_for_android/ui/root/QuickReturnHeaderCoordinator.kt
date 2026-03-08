package com.example.aero_stream_for_android.ui.root

import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.input.nestedscroll.NestedScrollConnection
import androidx.compose.ui.input.nestedscroll.NestedScrollSource
import androidx.compose.ui.input.nestedscroll.nestedScroll
import androidx.compose.ui.unit.Velocity

@Composable
fun rememberQuickReturnNestedScrollConnection(
    enabled: Boolean,
    onScrollDelta: (Float) -> Float
): NestedScrollConnection {
    return remember(enabled, onScrollDelta) {
        object : NestedScrollConnection {
            override fun onPreScroll(available: Offset, source: NestedScrollSource): Offset {
                if (!enabled || available.y == 0f) return Offset.Zero
                val consumedY = onScrollDelta(available.y)
                return Offset(x = 0f, y = consumedY)
            }

            override fun onPostScroll(
                consumed: Offset,
                available: Offset,
                source: NestedScrollSource
            ): Offset {
                if (!enabled || available.y == 0f) return Offset.Zero
                val consumedY = onScrollDelta(available.y)
                return Offset(x = 0f, y = consumedY)
            }

            override suspend fun onPreFling(available: Velocity): Velocity = Velocity.Zero

            override suspend fun onPostFling(consumed: Velocity, available: Velocity): Velocity =
                Velocity.Zero
        }
    }
}

fun Modifier.quickReturnNestedScroll(
    enabled: Boolean,
    connection: NestedScrollConnection
): Modifier {
    return if (enabled) nestedScroll(connection) else this
}
