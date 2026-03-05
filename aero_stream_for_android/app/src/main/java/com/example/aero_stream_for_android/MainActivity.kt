package com.example.aero_stream_for_android

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.runtime.SideEffect
import androidx.compose.runtime.getValue
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.hilt.navigation.compose.hiltViewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.example.aero_stream_for_android.ui.root.RootShell
import com.example.aero_stream_for_android.ui.theme.AppThemeViewModel
import com.example.aero_stream_for_android.ui.theme.AeroStreamTheme
import dagger.hilt.android.AndroidEntryPoint

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            val themeViewModel: AppThemeViewModel = hiltViewModel()
            val themeMode by themeViewModel.themeMode.collectAsStateWithLifecycle()
            val systemDarkTheme = isSystemInDarkTheme()
            val darkTheme = when (themeMode) {
                "dark" -> true
                "light" -> false
                else -> systemDarkTheme
            }

            SideEffect {
                val lightScrim = Color.White.toArgb()
                val darkScrim = Color.Black.toArgb()
                val statusBarStyle = if (darkTheme) {
                    SystemBarStyle.dark(darkScrim)
                } else {
                    SystemBarStyle.auto(lightScrim, darkScrim)
                }
                val navigationBarStyle = if (darkTheme) {
                    SystemBarStyle.dark(darkScrim)
                } else {
                    SystemBarStyle.auto(lightScrim, darkScrim)
                }
                this@MainActivity.enableEdgeToEdge(
                    statusBarStyle = statusBarStyle,
                    navigationBarStyle = navigationBarStyle
                )
            }

            AeroStreamTheme(darkTheme = darkTheme) {
                RootShell()
            }
        }
    }
}
