import 'package:aero_stream/data/drive/metadata_pipeline_stage_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deferred entries are promoted in FIFO order before new admissions', () async {
    final queue = MetadataPipelineStageQueue<String>(watermark: 1);
    final admitted = <String>[];

    expect(queue.enqueue('first'), isTrue);
    expect(
      queue.enqueue('deferred-a', onAdmitted: () => admitted.add('deferred-a')),
      isFalse,
    );
    expect(
      queue.enqueue('deferred-b', onAdmitted: () => admitted.add('deferred-b')),
      isFalse,
    );

    expect(await queue.take(shouldStop: () => false), 'first');
    expect(await queue.take(shouldStop: () => false), 'deferred-a');

    expect(
      queue.enqueue('fresh-after-promotion', onAdmitted: () => admitted.add('fresh')),
      isFalse,
    );
    expect(await queue.take(shouldStop: () => false), 'deferred-b');
    expect(await queue.take(shouldStop: () => false), 'fresh-after-promotion');
    expect(admitted, ['deferred-a', 'deferred-b', 'fresh']);
  });

  test('take returns null on timeout when no item is admitted', () async {
    final queue = MetadataPipelineStageQueue<String>(watermark: 1);

    final result = await queue.take(
      shouldStop: () => false,
      timeout: const Duration(milliseconds: 20),
    );

    expect(result, isNull);
  });
}
