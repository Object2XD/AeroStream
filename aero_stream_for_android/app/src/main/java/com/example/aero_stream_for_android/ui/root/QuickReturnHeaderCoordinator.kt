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
    onDelta: (Float) -> Unit
): NestedScrollConnection {
    return remember(enabled, onDelta) {
        object : NestedScrollConnection {
            override fun onPreScroll(available: Offset, source: NestedScrollSource): Offset {
                if (enabled) {
                    onDelta(available.y)
                }
                return Offset.Zero
            }

            override fun onPostScroll(
                consumed: Offset,
                available: Offset,
                source: NestedScrollSource
            ): Offset {
                if (enabled && available.y != 0f) {
                    onDelta(available.y)
                }
                return Offset.Zero
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
