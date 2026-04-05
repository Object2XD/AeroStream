import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('metadata pipeline hot path does not call full fetch APIs', () async {
    final stageExecutor = File(
      'lib/data/drive/metadata_pipeline_stage_executor.dart',
    );
    final runtime = File('lib/data/drive/metadata_pipeline_runtime.dart');

    final stageExecutorSource = await stageExecutor.readAsString();
    final runtimeSource = await runtime.readAsString();

    expect(stageExecutorSource.contains('fetchFullBytes('), isFalse);
    expect(stageExecutorSource.contains('fetchFullBytesWithDebug('), isFalse);
    expect(runtimeSource.contains('fetchFullBytes('), isFalse);
    expect(runtimeSource.contains('fetchFullBytesWithDebug('), isFalse);
  });
}
