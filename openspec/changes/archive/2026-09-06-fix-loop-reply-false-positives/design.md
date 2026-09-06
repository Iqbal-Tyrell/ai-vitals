## Context

`coderabbit-fix-loop.yml` (`fix-on-changes-requested` job) gathers open
CodeRabbit review threads via GraphQL, invokes Copilot CLI with
`--allow-all-tools` to fix genuine findings, and pushes a commit. Its
prompt currently ends with: *"Do not reply to or resolve any review
threads yourself - CodeRabbit automatically re-reviews new commits and
resolves threads its own reviewers determine are addressed."* That
boundary was deliberate: the fix-loop must never unilaterally decide a
thread is closed.

In practice this leaves no channel at all for a false-positive verdict
to reach CodeRabbit. Only the pushed commit gets re-reviewed; a finding
Copilot declines to touch (because it's a false positive) has no new
commit to trigger re-evaluation, so CodeRabbit re-raises it on every
subsequent full review. Confirmed live on PR #17: the same finding -
about this workflow's own fork-PR checkout/push handling, unrelated to
whether PR #17 itself is a fork PR (it is not) - was independently
re-judged false-positive by Copilot in three separate rounds (3, 4, 5),
and CodeRabbit kept re-flagging it until a human posted a plain inline
reply directly on that thread - which CodeRabbit read and resolved
within about a minute, with no other change to the code.

CodeRabbit's own command reference confirms the mechanism: an inline
reply scoped to one review thread applies only to that thread's finding
(the same scoping documented for `@coderabbitai autofix`); by contrast
`@coderabbitai resolve` and `@coderabbitai approve` are top-level-comment
only and affect every open thread on the PR at once - too blunt for a
single-finding judgment and not usable as an inline reply regardless.

## Goals / Non-Goals

**Goals:**
- Give CodeRabbit the same per-finding signal a human reviewer would
  give it: a reply, on that finding's own thread, explaining why it's a
  false positive.
- Keep this fully auditable - the reply text is exactly Copilot's own
  one-line reasoning, nothing synthesized separately.
- Preserve the existing safety boundary: the fix-loop still never calls
  any resolve/approve command or API. CodeRabbit alone still decides
  whether a reply is sufficient to close the thread.

**Non-Goals:**
- Not changing anything about how genuine findings are fixed (unchanged:
  fix the code, push a commit, let CodeRabbit's automatic re-review of
  that commit do its job).
- Not using `@coderabbitai resolve` / `@coderabbitai approve` - both are
  all-threads-at-once commands, unsuited to a single-finding reply.
- Not provisioning a CodeRabbit "Agentic" API key - that key is for
  headless `coderabbit` CLI runs (a different product surface entirely)
  and has no bearing on posting a GitHub PR review-thread reply, which
  the existing GitHub App token (`pull-requests: write`) already covers.

## Decisions

**1. Structured per-finding verdict output instead of one free-form paragraph.**
The prompt currently asks for a single "one-paragraph summary" written to
`/tmp/fix-summary.md`. Replace that with a per-finding block Copilot
writes to `/tmp/fix-summary.md`, one per finding, each starting with the
finding number and a `Verdict: fixed` or `Verdict: false-positive` line
followed by a one-line reason. A lightweight heading-based markdown
format (not JSON) was chosen because Copilot CLI's free-form generation
is more reliably well-formed as short markdown blocks than as strictly
valid JSON, and a regex-based parse tolerates minor formatting drift
without needing a schema-validation retry loop.

**2. Capture each finding's REST comment ID alongside path/line/body.**
The "Gather open findings" step's GraphQL query already reads each
thread's first comment's `author`, `path`, `line`, `body`. Add
`databaseId` to that same selection - GraphQL's `databaseId` on a
`PullRequestReviewComment` is exactly the numeric ID the REST reply
endpoint (`POST .../pulls/{pr}/comments/{comment_id}/replies`) requires.
No second API call is needed; this is a same-query field addition. A
thread's comments connection is paginated (20 per page) with its own
follow-up query per thread when a thread has more than 20 comments, so
a prior reply late in a long thread is never missed by the
`alreadyReplied` check described in decision 3.

**3. New step: reply on each false-positive finding's own thread.**
Runs after "Fix open findings" (Copilot has already written verdicts),
gated identically to the existing conditional steps
(`open_count != '0' && round < 5`). It parses `/tmp/fix-summary.md` for
`Verdict: false-positive` blocks, matches each back to its finding's
`databaseId` from step 1's output, and posts one reply per match via
`POST /repos/{owner}/{repo}/pulls/{pull_number}/comments/{comment_id}/replies`
(Octokit: `pulls.createReplyForReviewComment`) with `comment_id` set to that
ID. Uses the existing `app-token` (already
scoped `pull-requests: write`); no new permission needed. A within-run
`Set` alone cannot prevent a *later* round from replying again to the
same still-unresolved thread, so the "Gather open findings" step also
fetches each thread's later comments (not just the first) and flags
`alreadyReplied` when one is already authored by this workflow's own bot
identity; the reply step skips any finding carrying that flag.

**4. No behavior change for "fixed" verdicts.**
A genuine fix's pushed commit is what CodeRabbit re-reviews automatically;
posting a reply on top would be redundant noise on a thread the commit
itself is about to address.

## Risks / Trade-offs

- [Risk] Copilot omits or malforms a verdict block for a given finding →
  Mitigation: the parser is tolerant - a finding with no matched verdict
  block is simply skipped (no reply posted), which is exactly today's
  behavior for that finding. No new failure mode, only a missed
  opportunity for that one finding in that one round.
- [Risk] A reply might itself read as new content CodeRabbit chooses to
  re-evaluate, consuming a review-allowance slot. → Mitigation: unverified
  either way; monitor after rollout. No code changes anticipated unless
  observed.
- [Risk] This doesn't change who decides false-positive vs genuine issue -
  Copilot already made that call today, silently. Mitigation: not a new
  risk - the decision authority is identical to current behavior; only the
  notification channel is new. CodeRabbit still independently re-evaluates
  before resolving anything.
- [Risk] Multiple false-positive replies in one round could read as
  reply-spam. → Mitigation: exactly one reply per finding (never per
  round), each carrying real reasoning - matches normal human-reviewer
  conduct on a thread.
- [Risk] A thread that stays unresolved across multiple rounds could get
  a duplicate reply each round, since a within-run guard alone can't see
  prior rounds' replies. → Mitigation: the gather step checks each
  thread's own comment history for an existing reply from this workflow's
  bot identity and flags it; the reply step skips any finding already
  carrying that flag, regardless of how many rounds have passed.
- [Risk] Out of this change's original scope but flagged live on PR #17:
  the fix-loop's `npm install -g @github/copilot@1.0.83` pins the direct
  version but not its transitive tree (e.g. `detect-libc`), so a
  compromised transitive release could still run with the job's
  `COPILOT_GITHUB_TOKEN` and `--allow-all-tools`. → Mitigation: a
  committed lockfile (`.github/copilot-cli/package-lock.json`) pins the
  full resolved tree by integrity hash; the install step now runs
  `npm ci --prefix .github/copilot-cli` instead.

## Migration Plan

Implemented directly on `.github/workflows/coderabbit-fix-loop.yml`.
Purely additive (new prompt section, one new GraphQL field, one new
step) - no data migration for the workflow code itself. Validate with
YAML syntax check, then live-test on an open PR that already has a
recurring false-positive finding (PR #17 currently has this exact
scenario available). Rolling back the workflow code (deleting the one
new step and the verdict-format prompt change) instantly stops any
*future* replies, same as the sync-step revert done earlier this
session - but it does not undo replies already posted, nor reopen any
thread CodeRabbit already resolved because of one. Those are published
review state on GitHub's side, independent of this repo's code; undoing
them (deleting a reply, reopening a thread) is a separate, manual
GitHub action if ever needed.

## Open Questions

- Should CodeRabbit's `@coderabbitai rate limit` command be polled by the
  workflow to time full-review re-triggers more intelligently? Deferred -
  out of scope for this change.
