import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'main entrypoint stays app-only and benchmark uses dedicated target',
    () {
      final appMain = File('lib/main.dart').readAsStringSync();
      final benchmarkMain = File(
        'lib/drive_benchmark_main.dart',
      ).readAsStringSync();

      expect(
        appMain,
        contains('runApp(const ProviderScope(child: AeroStreamApp()))'),
      );
      expect(appMain, isNot(contains('runDriveBenchmarkCli')));
      expect(appMain, isNot(contains('drive_live_benchmark_runner')));

      expect(benchmarkMain, contains('runDriveBenchmarkCli'));
      expect(benchmarkMain, contains('drive_live_benchmark_runner.dart'));
    },
  );
}
