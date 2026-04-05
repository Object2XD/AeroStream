import 'mp4_box_header.dart';

const Set<String> desiredMp4MetadataItemTypes = <String>{
  '\u00a9nam',
  '\u00a9ART',
  '\u00a9alb',
  'aART',
  '\u00a9gen',
  '\u00a9day',
  'trkn',
  'disk',
};

class Mp4Layout {
  const Mp4Layout({
    required this.moovBox,
    required this.mvhdBox,
    required this.metaBox,
    required this.ilstBox,
    required this.metadataItemBoxes,
    required this.covrBox,
  });

  final Mp4BoxHeader moovBox;
  final Mp4BoxHeader? mvhdBox;
  final Mp4BoxHeader? metaBox;
  final Mp4BoxHeader? ilstBox;
  final List<Mp4BoxHeader> metadataItemBoxes;
  final Mp4BoxHeader? covrBox;

  bool get hasUsefulMetadata =>
      mvhdBox != null || metadataItemBoxes.isNotEmpty;
}
