import 'dart:io';

import 'package:flutter/widgets.dart';

import 'data/drive/benchmark/drive_live_benchmark_runner.dart';

Future<void> main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  exit(await runDriveBenchmarkCli(args));
}
