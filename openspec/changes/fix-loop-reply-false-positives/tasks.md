## 1. Gather open findings with reply-target IDs

- [x] 1.1 Add `databaseId` to the GraphQL query's `comments(first: 1) { nodes { ... } }` selection in the "Gather open findings and round count" step
- [x] 1.2 Include each finding's `databaseId` in the `openFindings` filtered list alongside its existing path/line/body
- [x] 1.3 Write each finding's `databaseId` into `/tmp/open-findings.md` (or a parallel structured file) so the later reply step can map a finding number back to its comment ID

## 2. Structured per-finding verdicts from Copilot

- [x] 2.1 Update the "Fix open findings" step's prompt: replace the "one-paragraph summary" instruction with a per-finding block requirement (`Verdict: fixed` or `Verdict: false-positive` + one-line reason), written to `/tmp/fix-summary.md`
- [x] 2.2 Keep the existing false-positive/fix judgment instructions unchanged (verify against real code first; do not blindly apply fixes)
- [x] 2.3 Keep the existing "do not resolve or approve threads yourself" boundary in the prompt, unchanged

## 3. Reply on false-positive findings

- [x] 3.1 Add a new step after "Fix open findings" (same `if` gate: `open_count != '0' && round < 5`) that parses `/tmp/fix-summary.md` for `Verdict: false-positive` blocks
- [x] 3.2 Match each false-positive block to its finding's `databaseId` captured in step 1.3
- [x] 3.3 For each match, call `POST /repos/{owner}/{repo}/pulls/{pull_number}/comments/{comment_id}/replies` (Octokit: `pulls.createReplyForReviewComment`) with `comment_id` set to that `databaseId` and body set to the recorded one-line reason
- [x] 3.4 Skip (no error, no reply) any finding whose verdict block is missing or unparseable
- [x] 3.5 Confirm this step never calls a resolve/approve command or API - reply only

## 4. Validate and test

- [x] 4.1 Validate workflow YAML syntax after all edits
- [x] 4.2 Live-test on an open PR with a real, recurring false-positive finding (PR #17 currently has one) and confirm: a reply is posted on that exact finding's thread, containing Copilot's reasoning
- [x] 4.3 Confirm CodeRabbit's subsequent evaluation of that reply resolves the thread (or, if it doesn't, confirm the fix-loop itself made no further unilateral action)
- [x] 4.4 Confirm a genuinely fixed finding in the same round still receives no reply (only the pushed commit)
