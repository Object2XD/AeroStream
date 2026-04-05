import 'dart:convert';
import 'dart:typed_data';

import 'package:charset/charset.dart';

String? decodeLegacySingleByteText(Uint8List bytes) {
  final primary = _sanitizeDecodedText(
    latin1.decode(bytes, allowInvalid: true),
  );
  final alternative = _tryDecodeShiftJis(bytes);
  return _pickPreferredLegacyText(primary: primary, alternative: alternative);
}

String? repairMisdecodedLegacyText(String? value) {
  final primary = _sanitizeDecodedText(value);
  if (primary == null) {
    return null;
  }

  List<int> bytes;
  try {
    bytes = latin1.encode(primary);
  } on ArgumentError {
    return primary;
  }

  final alternative = _tryDecodeShiftJis(Uint8List.fromList(bytes));
  return _pickPreferredLegacyText(primary: primary, alternative: alternative);
}

List<String> repairMisdecodedLegacyTexts(Iterable<String> values) {
  return values
      .map(repairMisdecodedLegacyText)
      .whereType<String>()
      .toList(growable: false);
}

String? _tryDecodeShiftJis(Uint8List bytes) {
  try {
    return _sanitizeDecodedText(
      const ShiftJISDecoder(allowMalformed: true).convert(bytes),
    );
  } catch (_) {
    return null;
  }
}

String? _pickPreferredLegacyText({
  required String? primary,
  required String? alternative,
}) {
  if (primary == null) {
    return alternative;
  }
  if (alternative == null || alternative == primary) {
    return primary;
  }

  final primaryQuality = _TextQuality.measure(primary);
  final alternativeQuality = _TextQuality.measure(alternative);
  final scoreDelta = alternativeQuality.score - primaryQuality.score;
  final alternativeJapanese =
      alternativeQuality.japaneseCount > 0 ||
      alternativeQuality.halfWidthKanaCount > 0;
  final primaryJapanese =
      primaryQuality.japaneseCount > 0 || primaryQuality.halfWidthKanaCount > 0;

  if (primaryQuality.looksBroken &&
      !alternativeQuality.looksBroken &&
      scoreDelta >= 4) {
    return alternative;
  }
  if (alternativeJapanese &&
      !primaryJapanese &&
      !alternativeQuality.looksBroken &&
      scoreDelta >= 8) {
    return alternative;
  }
  if (scoreDelta >= 18 && !alternativeQuality.looksBroken) {
    return alternative;
  }
  return primary;
}

String? _sanitizeDecodedText(String? value) {
  final trimmed = value?.replaceAll('\u0000', '').trim();
  return trimmed == null || trimmed.isEmpty ? null : trimmed;
}

class _TextQuality {
  const _TextQuality({
    required this.score,
    required this.controlCount,
    required this.replacementCount,
    required this.japaneseCount,
    required this.halfWidthKanaCount,
    required this.letterCount,
    required this.printableCount,
  });

  final int score;
  final int controlCount;
  final int replacementCount;
  final int japaneseCount;
  final int halfWidthKanaCount;
  final int letterCount;
  final int printableCount;

  bool get looksBroken {
    if (controlCount > 0 || replacementCount > 0) {
      return true;
    }
    if (printableCount == 0) {
      return true;
    }
    return letterCount == 0 && japaneseCount == 0 && halfWidthKanaCount == 0;
  }

  static _TextQuality measure(String text) {
    var score = 0;
    var controlCount = 0;
    var replacementCount = 0;
    var japaneseCount = 0;
    var halfWidthKanaCount = 0;
    var letterCount = 0;
    var printableCount = 0;

    for (final rune in text.runes) {
      if (_isWhitespace(rune)) {
        score += 1;
        printableCount += 1;
        continue;
      }
      if (_isDisallowedControl(rune)) {
        controlCount += 1;
        score -= 12;
        continue;
      }
      if (rune == 0xfffd) {
        replacementCount += 1;
        score -= 12;
        continue;
      }
      if (_isJapanese(rune)) {
        japaneseCount += 1;
        printableCount += 1;
        score += 8;
        continue;
      }
      if (_isHalfWidthKana(rune)) {
        halfWidthKanaCount += 1;
        printableCount += 1;
        score += 6;
        continue;
      }
      if (_isAsciiLetterOrDigit(rune)) {
        letterCount += 1;
        printableCount += 1;
        score += 4;
        continue;
      }
      if (_isLetterLike(rune)) {
        letterCount += 1;
        printableCount += 1;
        score += 4;
        continue;
      }
      if (_isCommonSymbol(rune)) {
        printableCount += 1;
        score += 2;
        continue;
      }
      if (_isPrintable(rune)) {
        printableCount += 1;
        continue;
      }
      score -= 4;
    }

    if ((japaneseCount > 0 || halfWidthKanaCount > 0) &&
        controlCount == 0 &&
        replacementCount == 0) {
      score += 12;
    }

    return _TextQuality(
      score: score,
      controlCount: controlCount,
      replacementCount: replacementCount,
      japaneseCount: japaneseCount,
      halfWidthKanaCount: halfWidthKanaCount,
      letterCount: letterCount,
      printableCount: printableCount,
    );
  }
}

bool _isWhitespace(int rune) =>
    rune == 0x09 || rune == 0x0a || rune == 0x0d || rune == 0x20;

bool _isDisallowedControl(int rune) =>
    (rune < 0x20 && !_isWhitespace(rune)) || (rune >= 0x7f && rune <= 0x9f);

bool _isPrintable(int rune) => rune >= 0x20 && rune != 0x7f;

bool _isAsciiLetterOrDigit(int rune) =>
    (rune >= 0x30 && rune <= 0x39) ||
    (rune >= 0x41 && rune <= 0x5a) ||
    (rune >= 0x61 && rune <= 0x7a);

bool _isLetterLike(int rune) {
  final char = String.fromCharCode(rune);
  return char.toLowerCase() != char.toUpperCase();
}

bool _isCommonSymbol(int rune) =>
    (rune >= 0x21 && rune <= 0x2f) ||
    (rune >= 0x3a && rune <= 0x40) ||
    (rune >= 0x5b && rune <= 0x60) ||
    (rune >= 0x7b && rune <= 0x7e) ||
    (rune >= 0x2010 && rune <= 0x2015) ||
    (rune >= 0x2018 && rune <= 0x201f);

bool _isJapanese(int rune) =>
    (rune >= 0x3040 && rune <= 0x309f) ||
    (rune >= 0x30a0 && rune <= 0x30ff) ||
    (rune >= 0x3400 && rune <= 0x4dbf) ||
    (rune >= 0x4e00 && rune <= 0x9fff);

bool _isHalfWidthKana(int rune) => rune >= 0xff65 && rune <= 0xff9f;
