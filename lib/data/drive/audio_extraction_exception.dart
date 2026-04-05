class DriveRangedExtractionException implements Exception {
  const DriveRangedExtractionException(
    this.reason, {
    required this.fileName,
    required this.mimeType,
    this.cause,
  });

  final String reason;
  final String fileName;
  final String mimeType;
  final Object? cause;

  @override
  String toString() => 'DriveRangedExtractionException($reason)';
}
