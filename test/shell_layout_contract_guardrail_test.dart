import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('shell-managed pages do not reference bottom chrome helpers', () {
    const guardedFiles = <String>[
      'lib/widgets/aero_page_scaffold.dart',
      'lib/screens/library_screen.dart',
      'lib/screens/library/album_detail_screen.dart',
    ];

    for (final path in guardedFiles) {
      final source = File(path).readAsStringSync();

      expect(
        source.contains('aeroBottomChromeHeight('),
        isFalse,
        reason:
            'Expected $path to stay page-only and avoid direct bottom chrome '
            'height reads.',
      );
      expect(
        source.contains('aeroBodyBottomInset('),
        isFalse,
        reason:
            'Expected $path to avoid chrome-aware bottom inset helpers so '
            'shell and page spacing ownership stay separated.',
      );
    }
  });
}
