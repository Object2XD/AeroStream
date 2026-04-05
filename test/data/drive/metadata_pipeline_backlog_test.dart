import 'package:aero_stream/data/drive/metadata_pipeline_backlog.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('runtime tracker moves a task through metadata stages', () {
    final hub = MetadataPipelineTelemetryHub();
    const jobId = 501;
    addTearDown(() => hub.clearJob(jobId));

    final tracker = MetadataPipelineRuntimeTracker(jobId: jobId, hub: hub);
    tracker.seedTasks(const <int>[1]);
    expect(
      hub.snapshotForJob(jobId),
      const MetadataPipelineBacklog(
        fetch: MetadataPipelineStageBacklog(queuedCount: 1),
      ),
    );

    tracker.startStage(
      1,
      stage: MetadataPipelineStage.fetch,
      formatKey: 'm4a',
    );
    expect(
      hub.snapshotForJob(jobId),
      const MetadataPipelineBacklog(
        fetch: MetadataPipelineStageBacklog(runningCount: 1),
        activeFormatBreakdown: MetadataPipelineFormatBreakdown(m4aRunning: 1),
      ),
    );

    tracker.completeStage(1, stage: MetadataPipelineStage.fetch);
    tracker.queueStage(1, stage: MetadataPipelineStage.parse);
    tracker.startStage(1, stage: MetadataPipelineStage.parse, formatKey: 'm4a');
    tracker.completeStage(1, stage: MetadataPipelineStage.parse);
    tracker.queueStage(1, stage: MetadataPipelineStage.flush);
    tracker.startStage(1, stage: MetadataPipelineStage.flush, formatKey: 'm4a');
    tracker.completeStage(1, stage: MetadataPipelineStage.flush);

    expect(
      hub.snapshotForJob(jobId),
      const MetadataPipelineBacklog(
        fetch: MetadataPipelineStageBacklog(completedCount: 1),
        parse: MetadataPipelineStageBacklog(completedCount: 1),
        flush: MetadataPipelineStageBacklog(completedCount: 1),
      ),
    );
  });

  test('runtime tracker records stage failures and abandon', () {
    final hub = MetadataPipelineTelemetryHub();
    const jobId = 502;
    addTearDown(() => hub.clearJob(jobId));

    final tracker = MetadataPipelineRuntimeTracker(jobId: jobId, hub: hub);
    tracker.seedTasks(const <int>[1, 2]);
    tracker.abandonTask(2);
    tracker.startStage(
      1,
      stage: MetadataPipelineStage.fetch,
      formatKey: 'mp3',
    );
    tracker.failStage(1, stage: MetadataPipelineStage.fetch);
    tracker.queueStage(1, stage: MetadataPipelineStage.flush);
    tracker.startStage(1, stage: MetadataPipelineStage.flush, formatKey: 'mp3');
    tracker.completeStage(1, stage: MetadataPipelineStage.flush);

    expect(
      hub.snapshotForJob(jobId),
      const MetadataPipelineBacklog(
        fetch: MetadataPipelineStageBacklog(failedCount: 1),
        flush: MetadataPipelineStageBacklog(completedCount: 1),
      ),
    );
  });

  test('runtime tracker records blocked and unblocked stage transitions', () {
    final hub = MetadataPipelineTelemetryHub();
    const jobId = 503;
    addTearDown(() => hub.clearJob(jobId));

    final tracker = MetadataPipelineRuntimeTracker(jobId: jobId, hub: hub);
    tracker.queueStage(1, stage: MetadataPipelineStage.fetch, formatKey: 'm4a');
    tracker.markBlocked(1, MetadataPipelineStage.fetch);
    expect(
      hub.snapshotForJob(jobId),
      const MetadataPipelineBacklog(
        fetch: MetadataPipelineStageBacklog(blockedCount: 1),
      ),
    );

    tracker.unblockStage(1, MetadataPipelineStage.fetch);
    expect(
      hub.snapshotForJob(jobId),
      const MetadataPipelineBacklog(
        fetch: MetadataPipelineStageBacklog(queuedCount: 1),
      ),
    );
  });

  test('runtime tracker stores source queue backlog counts', () {
    final hub = MetadataPipelineTelemetryHub();
    const jobId = 504;
    addTearDown(() => hub.clearJob(jobId));

    final tracker = MetadataPipelineRuntimeTracker(jobId: jobId, hub: hub);
    tracker.setSourceBacklog(queuedCount: 9, runningCount: 3);

    expect(
      hub.snapshotForJob(jobId),
      const MetadataPipelineBacklog(
        sourceQueuedCount: 9,
        sourceRunningCount: 3,
      ),
    );
  });

  test('telemetry hub coalesces rapid runtime updates for watchers', () async {
    final hub = MetadataPipelineTelemetryHub(
      publishCadence: const Duration(milliseconds: 40),
    );
    const jobId = 505;
    addTearDown(() => hub.clearJob(jobId));

    final tracker = MetadataPipelineRuntimeTracker(jobId: jobId, hub: hub);
    final snapshots = <MetadataPipelineBacklog>[];
    final subscription = hub.watchJob(jobId).listen(snapshots.add);
    addTearDown(subscription.cancel);

    tracker.queueStage(1, stage: MetadataPipelineStage.fetch);
    tracker.startStage(
      1,
      stage: MetadataPipelineStage.fetch,
      formatKey: 'm4a',
    );
    tracker.completeStage(1, stage: MetadataPipelineStage.fetch);
    tracker.queueStage(1, stage: MetadataPipelineStage.parse);

    expect(snapshots, isEmpty);

    await Future<void>.delayed(const Duration(milliseconds: 60));

    expect(snapshots, hasLength(1));
    expect(
      snapshots.single,
      const MetadataPipelineBacklog(
        fetch: MetadataPipelineStageBacklog(completedCount: 1),
        parse: MetadataPipelineStageBacklog(queuedCount: 1),
      ),
    );
  });
}
