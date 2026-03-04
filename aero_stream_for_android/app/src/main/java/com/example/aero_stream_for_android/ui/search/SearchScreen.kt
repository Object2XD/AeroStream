package com.example.aero_stream_for_android.ui.search

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Clear
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.example.aero_stream_for_android.ui.components.SongListItem
import com.example.aero_stream_for_android.ui.player.PlayerViewModel
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SearchScreen(
    onNavigateToPlayer: () -> Unit = {},
    searchViewModel: SearchViewModel = hiltViewModel(),
    playerViewModel: PlayerViewModel = hiltViewModel()
) {
    val uiState by searchViewModel.uiState.collectAsState()
    val playerState by playerViewModel.playerState.collectAsState()

    Scaffold(
        topBar = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .background(MaterialTheme.colorScheme.background)
                    .padding(
                        start = AeroCompactUiTokens.screenHorizontalPadding,
                        end = AeroCompactUiTokens.screenHorizontalPadding,
                        top = AeroCompactUiTokens.headerTopPadding,
                        bottom = AeroCompactUiTokens.headerBottomPadding
                    )
            ) {
                OutlinedTextField(
                    value = uiState.query,
                    onValueChange = searchViewModel::onQueryChanged,
                    singleLine = true,
                    placeholder = { Text("曲名、アーティスト、アルバムを検索") },
                    leadingIcon = {
                        Icon(Icons.Default.Search, contentDescription = "Search")
                    },
                    trailingIcon = {
                        if (uiState.query.isNotEmpty()) {
                            IconButton(onClick = searchViewModel::clearSearch) {
                                Icon(Icons.Default.Clear, contentDescription = "Clear")
                            }
                        }
                    },
                    modifier = Modifier.fillMaxWidth(),
                    textStyle = AeroCompactUiTokens.rowSubtitleTextStyle()
                )
            }
        }
    ) { paddingValues ->
        if (uiState.isSearching) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentAlignment = Alignment.Center
            ) {
                CircularProgressIndicator()
            }
        } else if (uiState.results.isEmpty() && uiState.query.isNotEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .padding(32.dp),
                contentAlignment = Alignment.Center
            ) {
                Text(
                    text = "\"${uiState.query}\" に一致する結果はありません",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues),
                contentPadding = PaddingValues(bottom = 80.dp)
            ) {
                items(uiState.results) { song ->
                    SongListItem(
                        song = song,
                        onClick = {
                            playerViewModel.playQueue(uiState.results, uiState.results.indexOf(song))
                            onNavigateToPlayer()
                        },
                        isPlaying = playerState.currentSong?.id == song.id && playerState.isPlaying,
                        showDownloadIcon = true
                    )
                }
            }
        }
    }
}
