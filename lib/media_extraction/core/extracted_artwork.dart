import 'dart:typed_data';

class ExtractedArtwork {
  const ExtractedArtwork({required this.bytes, required this.mimeType});

  final Uint8List bytes;
  final String mimeType;
}
