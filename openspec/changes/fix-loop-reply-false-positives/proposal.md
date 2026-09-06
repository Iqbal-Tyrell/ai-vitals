## Why

The fix-loop (`coderabbit-fix-loop.yml`) currently instructs Copilot to
never reply to or resolve CodeRabbit review threads, so a false-positive
verdict only reaches the generic per-round PR comment, never the specific
thread CodeRabbit itself is tracking. CodeRabbit has no way to learn the
finding was already evaluated, and re-raises the same static-analysis
finding on every subsequent full review pass. This was observed live on
PR #17: the same fork-PR finding was correctly judged false-positive by
Copilot in rounds 3, 4, and 5, yet kept reappearing until a human posted
a manual inline reply on that exact thread - which CodeRabbit then acted
on and resolved within a minute. Without this capability, a PR can be
stuck in an unresolvable review loop purely because there's no channel
for the fix-loop's own false-positive judgment to reach CodeRabbit.

## What Changes

- Copilot's fix-loop prompt now returns a structured per-finding verdict
  (fixed / false-positive + one-line reason) instead of a single free-form
  summary paragraph, keyed to each finding's identifier.
- The "Gather open findings" step additionally captures each finding's
  GitHub review-comment ID (needed to reply within that exact thread).
- A new workflow step posts a targeted inline reply (`in_reply_to_id`) on
  each finding's own thread when Copilot judges it false-positive, quoting
  the one-line reason. Genuine fixes still rely on CodeRabbit's own
  re-review of the pushed commit, unchanged.
- The fix-loop still never resolves or approves threads itself (unchanged
  safety boundary) - only CodeRabbit decides whether a reply satisfies the
  finding and marks it resolved.

## Capabilities

### New Capabilities
- `coderabbit-fix-loop-false-positive-reply`: the fix-loop's behavior of
  posting a targeted, thread-scoped reply explaining a false-positive
  verdict, so CodeRabbit can evaluate and resolve that specific finding
  instead of re-raising it every subsequent review pass.

### Modified Capabilities
(none - no existing OpenSpec capability spec covers the CodeRabbit
fix-loop yet; this proposal introduces the first one, scoped to this
specific behavior only.)

## Impact

- `.github/workflows/coderabbit-fix-loop.yml`: prompt text, findings-
  gathering step, and one new reply-posting step.
- No application code (Laravel/Filament) affected.
- No new external dependencies - uses the existing GitHub App token's
  `pull-requests: write` permission already granted to this workflow.
