package com.example.aero_stream_for_android.ui.library.content

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.example.aero_stream_for_android.ui.theme.AeroCompactUiTokens

@Composable
fun MediaArtwork(
    imageModel: Any?,
    placeholder: ImageVector,
    modifier: Modifier = Modifier,
    testTagPrefix: String? = null
) {
    val imageTag = if (testTagPrefix.isNullOrBlank()) "media_artwork_image" else "${testTagPrefix}_image"
    val placeholderTag = if (testTagPrefix.isNullOrBlank()) {
        "media_artwork_placeholder"
    } else {
        "${testTagPrefix}_placeholder"
    }

    Box(
        modifier = modifier
            .size(AeroCompactUiTokens.listArtworkSize)
            .clip(RoundedCornerShape(10.dp))
    ) {
        if (imageModel != null) {
            AsyncImage(
                model = imageModel,
                contentDescription = null,
                modifier = Modifier
                    .fillMaxSize()
                    .testTag(imageTag),
                contentScale = ContentScale.Crop
            )
        } else {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .background(MaterialTheme.colorScheme.surfaceVariant)
                    .testTag(placeholderTag),
                contentAlignment = Alignment.Center
            ) {
                Icon(placeholder, contentDescription = null)
            }
        }
    }
}
