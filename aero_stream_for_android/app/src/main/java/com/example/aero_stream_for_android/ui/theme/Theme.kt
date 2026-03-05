package com.example.aero_stream_for_android.ui.theme

import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext

private val DarkColorScheme = darkColorScheme(
    primary = PrimaryDark,
    onPrimary = OnPrimaryDark,
    primaryContainer = DarkSurface3,
    onPrimaryContainer = White,
    secondary = SecondaryDark,
    onSecondary = OnPrimaryDark,
    secondaryContainer = DarkSurface2,
    onSecondaryContainer = White,
    tertiary = TertiaryDark,
    onTertiary = White,
    background = Black,
    onBackground = White,
    surface = DarkSurface,
    onSurface = White,
    surfaceVariant = DarkSurfaceVariant,
    onSurfaceVariant = LightGray,
    outline = DarkGray,
    inverseSurface = White,
    inverseOnSurface = Black,
    inversePrimary = PrimaryLight,
    error = Color(0xFFCF6679),
    onError = Black
)

private val LightColorScheme = lightColorScheme(
    primary = PrimaryLight,
    onPrimary = OnPrimaryLight,
    primaryContainer = Color(0xFFE8E8E8),
    onPrimaryContainer = PrimaryLight,
    secondary = SecondaryLight,
    onSecondary = White,
    secondaryContainer = Color(0xFFF0F0F0),
    onSecondaryContainer = PrimaryLight,
    tertiary = TertiaryLight,
    onTertiary = White,
    background = White,
    onBackground = PrimaryLight,
    surface = Color(0xFFFAFAFA),
    onSurface = PrimaryLight,
    surfaceVariant = Color(0xFFE8E8E8),
    onSurfaceVariant = SecondaryLight,
    outline = Color(0xFFBDBDBD),
    inverseSurface = PrimaryLight,
    inverseOnSurface = White,
    inversePrimary = PrimaryDark
)

@Composable
fun AeroStreamTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = false, // デフォルトはYTM風カスタムカラー
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = Typography,
        content = content
    )
}
