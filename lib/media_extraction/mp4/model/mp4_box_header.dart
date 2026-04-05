class Mp4BoxHeader {
  const Mp4BoxHeader({
    required this.offset,
    required this.size,
    required this.headerSize,
    required this.type,
    this.usesExtendedSize = false,
    this.extendsToEof = false,
  });

  final int offset;
  final int size;
  final int headerSize;
  final String type;
  final bool usesExtendedSize;
  final bool extendsToEof;

  int get dataOffset => offset + headerSize;
  int get end => offset + size;
}
