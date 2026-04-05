# AGENTS

## Verification Discipline

- Treat direct execution results as higher-confidence than architectural inference. When a claim can be validated by running the target path, measure first and explain second.
- Separate observations from hypotheses in status updates and final reports. Label uncertain reasoning as a hypothesis until it has been verified.
- Do not generalize from adjacent failures. A failure in one path or mode does not prove the same root cause in another path or mode.
- When debugging live behavior, validate the exact runtime path under discussion before concluding that auth, connectivity, persistence, or shared state is the blocker.
- If a result contradicts an earlier explanation, correct the explanation immediately and restate the current ground truth plainly.

## Benchmarking And Repro

- For benchmarks, report the measured output before interpreting it. Include the executed mode, target scope, success and failure counts, throughput, and the dominant failure reason.
- Distinguish clearly between “the benchmark harness works” and “the target workload succeeded”. Do not use harness readiness as a proxy for workload performance.
- Prefer end-to-end verification on the real execution path whenever the task is about runtime performance, connectivity, or externally visible behavior.
- If a benchmark or repro depends on a build artifact, refresh the artifact before drawing conclusions from its output.

## Spec Mapping

- Before changing logic based on a spec, identify the exact failing layer first. Do not assume that fixing an outer layer also fixes inner parsing, layout, state, or completion logic.
- Convert spec findings into explicit implementation checkpoints per layer. Write down which rule applies to discovery, traversal, completion, and output behavior before coding.
- Keep success criteria separate for different consumers of the same pipeline. Do not share one completion condition across paths with different goals unless the stricter condition is explicitly required.
- Add or update a regression that matches the failing real-world shape before treating the fix as complete. Synthetic tests should cover the observed failure mode, not just a nearby valid case.
- When a broad failure reason hides multiple stages, split it into stage-specific reasons before iterating further so later debugging starts from evidence instead of inference.

## Execution Model Changes

- When changing how work flows through a system, write down the current execution model and the target execution model before implementing. Name the source of work, the handoff points, the blocking points, the write boundary, and the terminal condition.
- Treat observability and behavior as separate deliverables. New labels, counters, telemetry, or stage names do not prove that the underlying execution model changed.
- When a request is about removing waiting, batching, barriers, or idle time, name the exact barrier being removed and verify that it is actually gone on the hot path. If the old barrier still exists anywhere relevant, report the result as partial.
- Define completion in runtime terms, not structural terms. A refactor is not complete because the code now contains stages, workers, queues, or helper types; it is complete only when the requested runtime behavior is observable.
- In progress and final reports for execution-model work, always separate:
  - what was implemented
  - what blocking or coordination points still remain
  - how current runtime behavior still differs from the requested behavior
- Do not use words like `done`, `complete`, or equivalent unless the requested runtime behavior has been verified end to end. If the work only added contracts, instrumentation, or internal structure, say that directly.
- Add at least one regression that proves the behavior change itself rather than just the new structure. Prefer tests that show work admission, handoff, overlap, blocking, refill, or completion timing on the real path under discussion.

## Performance Investigation Order

- For performance, lag, jank, throughput, scheduler, queue, rebuild, or telemetry problems, do not start by changing the easiest hotspot. Start by enumerating the plausible cause set first.
- Before implementing any fix, create a cause-candidate ledger. For each candidate, write down:
  - the candidate itself
  - why it could explain the observed symptom
  - what evidence currently supports it
  - what observation would disprove or weaken it
  - the expected impact if fixed
  - the implementation cost or blast radius
- Rank candidates by explanatory power and ease of proof first, and by implementation ease only after that. Do not pick a candidate just because it is local, simple, or convenient to edit.
- Design at least one discriminating experiment per high-priority candidate before changing code. The experiment must state:
  - what should be observed if this candidate is a primary cause
  - what should be observed if it is not
- Do not implement a fix until the candidate list exists and the selected candidate is the current top-ranked explanation for the symptom.
- Prefer one meaningful hypothesis cut per change. Avoid bundling multiple performance hypotheses into one patch when that would make the result impossible to attribute.
- Separate three claims in every performance report:
  - what code path or overhead source was changed
  - what symptom that path was suspected to affect
  - what symptom change has actually been demonstrated so far
- Do not claim that a symptom is improved, lighter, faster, or fixed unless that exact symptom has been shown to move in the expected direction. Code inspection, tests, and reduced churn in one path only prove that the path changed, not that the user-visible symptom is gone.
- If cause enumeration is incomplete, say that explicitly and continue the investigation. Do not skip the candidate-ranking step in order to make quick progress on an easy-to-edit area.

## Communication

- Do not fill evidence gaps with confident-sounding explanations. If the relevant path has not been measured yet, say that directly.
- When revising a conclusion, explain what was wrong in the earlier reasoning and what new evidence changed the conclusion.
