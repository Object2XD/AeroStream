class AudioObjectDescriptor {
  const AudioObjectDescriptor({
    required this.objectId,
    required this.fileName,
    required this.mimeType,
    required this.sizeBytes,
  });

  final String objectId;
  final String fileName;
  final String mimeType;
  final int? sizeBytes;

  bool get hasKnownSize => sizeBytes != null && sizeBytes! > 0;
}
