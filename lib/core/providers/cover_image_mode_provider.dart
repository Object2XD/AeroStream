import 'package:hooks_riverpod/hooks_riverpod.dart';

enum CoverImageMode { network, placeholder }

final coverImageModeProvider = Provider<CoverImageMode>((ref) {
  return CoverImageMode.network;
});
