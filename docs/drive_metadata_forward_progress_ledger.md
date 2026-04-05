# Drive Metadata Forward Progress Ledger

## Current Execution Model
- Source admission: queued `extract_tags` tasks are pulled from `scan_tasks` into the in-memory `fetchHead` queue.
- Handoff points: `fetchHead -> analyzeHead -> plan -> fetch -> parse -> flush`.
- Blocking points: each in-memory stage queue is bounded by a high watermark.
- Write boundary: DB writes happen in `flush`, plus runtime-stage heartbeats while tasks are active.
- Terminal condition: source backlog is zero and no runtime stage has queued/running/blocked work.

## Candidate Ledger

### 1. Queue coordination deadlock
- Why it fits: workers used to wait synchronously inside `_enqueueStage` / `_enqueueFlush` when the next bounded queue was full.
- Supporting evidence: synthetic repros showed `fetchHead/analyzeHead` blocked with no downstream progress under watermark `1`, and the retry path loops directly between those stages.
- Weakening observation: if workers can release the stage and the same hot path still freezes, this is not the primary cause.
- Expected impact if fixed: blocked upstream retry should eventually be re-admitted, downstream stages should resume, and the job should complete.
- Blast radius: local to metadata pipeline queue coordination.

### 2. Other coordination bug
- Why it fits: source refill, runtime-stage persistence, or flush batching could still hold work even after bounded-queue deadlock is removed.
- Supporting evidence: live UI and benchmark paths do not expose exactly the same blocked shape.
- Weakening observation: if the synthetic hot path completes once bounded queue waits are removed, this candidate loses priority.
- Expected impact if fixed: progress would recover without changing retry semantics.
- Blast radius: medium; spans scheduler coordination outside the direct stage handoff.

### 3. Unresolved-loop amplification
- Why it fits: repeated `analyzeHead -> fetchHead` retries for unresolved formats could starve downstream work.
- Supporting evidence: stalled shapes cluster around `m4a` retry scenarios.
- Weakening observation: if the retry path completes under the same unresolved head behavior once queue handoff is fixed, retry amplification is secondary.
- Expected impact if fixed: less upstream churn, but not necessarily enough to resolve a true wait cycle by itself.
- Blast radius: medium; changes retry semantics and format-specific behavior.

## Selected Primary Candidate
- `queue coordination deadlock`
- Reason: it best explains the exact synthetic stall shape and can be disproved cheaply with one isolated coordination change.

## Target Execution Model
- Source admission still fills `fetchHead`, but blocked stage handoffs no longer park workers in `waitForSpace()`.
- Deferred handoffs reserve capacity in queue occupancy, are promoted in FIFO order, and are admitted before new source work takes the freed slot.
- Completion remains runtime-defined: progress is recovered only if blocked upstream work is admitted and the job reaches downstream stages / terminal completion.
