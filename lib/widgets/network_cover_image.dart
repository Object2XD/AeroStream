import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'dart:io';

import '../core/providers/cover_image_mode_provider.dart';

class NetworkCoverImage extends ConsumerWidget {
  const NetworkCoverImage({
    super.key,
    required this.imageUrl,
    required this.width,
    required this.height,
    required this.borderRadius,
  });

  final String imageUrl;
  final double width;
  final double height;
  final double borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(coverImageModeProvider);

    if (mode == CoverImageMode.placeholder) {
      return _buildFallback(context);
    }

    final uri = Uri.tryParse(imageUrl);
    final isRemote = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https');
    final isFileUri = uri != null && uri.scheme == 'file';
    final filePath = isFileUri ? uri.toFilePath() : imageUrl;
    final isLocalFile = !isRemote && filePath.isNotEmpty;

    if (isLocalFile) {
      final file = File(filePath);
      if (!file.existsSync()) {
        return _buildFallback(context);
      }

      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.file(
          file,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildFallback(context),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildFallback(context);
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: width,
            height: height,
            color: Theme.of(context).colorScheme.surfaceContainer,
            alignment: Alignment.center,
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.music_note_rounded,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }
}
