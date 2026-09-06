## Purpose

Defines how the CodeRabbit review fix-loop (`coderabbit-fix-loop.yml`)
communicates a false-positive verdict back to CodeRabbit on the exact
review thread it concerns, instead of only surfacing that judgment in a
generic PR comment - closing the gap that let the same static-analysis
finding be re-raised across multiple review rounds.

## Requirements

### Requirement: Structured per-finding verdict output
The fix-loop's Copilot invocation SHALL write one verdict block per
gathered finding to `/tmp/fix-summary.md`, each identifying the finding
number, a `Verdict: fixed` or `Verdict: false-positive` line, and a
one-line reason.

#### Scenario: Copilot judges a finding a false positive
- **WHEN** Copilot verifies a gathered finding against the current code
  and determines it does not apply
- **THEN** it writes a block for that finding to `/tmp/fix-summary.md`
  containing `Verdict: false-positive` and a one-line reason, and makes
  no code change for that finding

#### Scenario: Copilot fixes a genuine finding
- **WHEN** Copilot verifies a gathered finding and determines it is a
  real issue
- **THEN** it applies the code fix and writes a block for that finding
  to `/tmp/fix-summary.md` containing `Verdict: fixed` and a one-line
  reason

### Requirement: Findings carry their GitHub review-comment ID
The "Gather open findings" step SHALL capture each open finding's
underlying review comment's numeric database ID, in addition to its
path, line, and body, so a later step can address that exact comment.

#### Scenario: Gathering open findings
- **WHEN** the fix-loop queries open review threads via GraphQL
- **THEN** each returned finding includes the `databaseId` of its first
  comment alongside its existing path, line, and body fields

### Requirement: Reply on false-positive findings' own threads
When a finding's verdict is `false-positive`, the fix-loop SHALL post a
reply on that finding's own review thread (using its captured comment
ID as the reply target) containing Copilot's one-line reason, and SHALL
NOT post a reply for findings verdicted `fixed`.

#### Scenario: A finding is judged false-positive
- **WHEN** the fix-loop's findings-verdict step records a
  `false-positive` verdict for a finding
- **THEN** the workflow posts exactly one reply on that finding's own
  review thread, containing the recorded one-line reason

#### Scenario: A finding is judged fixed
- **WHEN** the fix-loop's findings-verdict step records a `fixed` verdict
  for a finding
- **THEN** the workflow posts no reply for that finding, relying on
  CodeRabbit's automatic re-review of the pushed commit

#### Scenario: A finding has no matched verdict block
- **WHEN** Copilot's summary output omits or malforms the verdict block
  for a given finding
- **THEN** the workflow skips posting any reply for that finding, and
  does not fail the job because of it

#### Scenario: A finding's thread already carries this workflow's reply
- **WHEN** a finding's own review thread already contains a reply
  authored by the fix-loop's bot identity, from an earlier round
- **THEN** the workflow does not post another reply for that finding,
  regardless of how many rounds have passed since

### Requirement: Fix-loop never resolves or approves threads itself
The fix-loop SHALL NOT call any thread-resolve or PR-approval command or
API (including `@coderabbitai resolve` and `@coderabbitai approve`) at
any point in this or any other step. Only CodeRabbit's own subsequent
evaluation may mark a thread resolved or approve the pull request.

#### Scenario: A false-positive reply is posted
- **WHEN** the workflow posts a false-positive reply on a review thread
- **THEN** the workflow takes no further action on that thread's
  resolution or the pull request's approval state
