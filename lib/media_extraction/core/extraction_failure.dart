class ExtractionFailure implements Exception {
  const ExtractionFailure(
    this.reason, {
    required this.fileName,
    required this.mimeType,
    this.details = const <String, Object?>{},
    this.cause,
  });

  final String reason;
  final String fileName;
  final String mimeType;
  final Map<String, Object?> details;
  final Object? cause;

  @override
  String toString() => 'ExtractionFailure($reason)';
}
