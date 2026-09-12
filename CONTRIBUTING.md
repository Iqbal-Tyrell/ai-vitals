# Contributing

This is a personal, single-maintainer project. External contributions
are not currently solicited — pull request creation is restricted to
repository collaborators. Forking is still allowed if you want to use
the code yourself.

## Branching and merging

- One approving review is required before merge (native GitHub branch
  protection — no admin-bypass workaround).
- Four required status checks must pass: `test`, `analyse`, `cs-check`,
  `audit` (see below).
- Merges are **squash-only**. Branches are auto-deleted after merge.
- **AI coding assistants must always open a PR, never push directly
  to `main`** — including for documentation-only changes. (Earlier L0
  bootstrap commits landed directly, before this pipeline existed to
  route them through; that precedent doesn't apply anymore now that
  L4 is fully built.) Use reasonable judgment on granularity: fold a
  set of small, related changes into one PR rather than opening a
  separate PR per tiny commit.

## CI checks

| Check | What it runs |
|---|---|
| `test` | Pest test suite via ParaTest (parallel) |
| `analyse` | PHPStan level 8 (Larastan) |
| `cs-check` | Laravel Pint, dry-run |
| `audit` | `composer validate --strict` → `composer install` → lockfile tripwire → `composer audit` |

Run them all locally before pushing:

```bash
docker compose exec app vendor/bin/pest --parallel
docker compose exec app vendor/bin/phpstan analyse --memory-limit=512M
docker compose exec app vendor/bin/pint --test
docker compose exec app composer audit
```

## Adding a new Composer dependency

Before adding one, check and be prepared to state:

1. **Maintenance** — recent commits/releases (~12 months), maintainer
   MFA enabled (Packagist surfaces this).
2. **Install scripts** — inspect the package's `composer.json` for
   pre/post-install-cmd hooks; avoid unless clearly necessary.
3. **Vendor/spelling** — check for typosquats of popular package names.
4. **Security history** — Packagist's advisory feed + Aikido
   malware-flag integration.
5. **Reputation** — download counts/stars are a supporting signal only,
   never sole justification.

## Labels

| Label | Meaning |
|---|---|
| `bump:patch` / `bump:minor` / `bump:major` | Which release bucket a merged PR lands in |
| `ready-for-merge` | Review is clean; a human may click Merge |
| `milestone-triage-pending` | Awaiting human approval for milestone triage |
| `needs-review` | PR is open and awaiting review |
| `needs-human-attention` | Escalated for a human to look at directly |
| `bug` / `enhancement` / `documentation` | Baseline classification |

## The AI-powered issue/PR pipeline (L4)

Once bootstrapped, most feature work flows through this pipeline
rather than direct commits:

1. An issue is opened and approved for milestone triage (checkbox).
2. Checking **Plan** posts an OpenSpec `explore` writeup as an issue
   comment (thinking only, no code).
3. Checking **Build** runs OpenSpec `propose -> apply` (using Laravel
   Boost's MCP server to see the app's real schema) and opens a PR,
   carrying `needs-review`.
4. **Code review is manual, not automated.** A human decides when a
   PR is ready and triggers CodeRabbit themselves (e.g. posting
   `@coderabbitai review` as a PR comment, or via the CodeRabbit
   Dashboard) — there is no scheduled poller, fix-loop, or other
   watcher acting on a PR's behalf. Addressing findings, pushing
   fixes, and re-requesting review are all done by a human (optionally
   assisted by an interactive AI session) as ordinary PR work.
5. Once satisfied, a human removes `needs-review`, applies
   `ready-for-merge`, and clicks **Merge** themselves — no pipeline
   step holds merge-capable permissions, and no automation applies this
   label on a human's behalf.

**No AI coding assistant (including one operating this repo via `gh`
CLI on a human's authenticated session) may execute `gh pr merge`,
`gh pr review --approve`, or any equivalent merge/approval action —
even though such actions are technically indistinguishable, at the
GitHub API level, from a human doing the same thing under the same
credentials.** This can't be enforced by branch protection or any
GitHub setting (a token can't tell who invoked it), so it's a hard
behavioral rule: an AI assistant must always stop and ask the human to
personally execute the merge/approval themselves (via the GitHub UI or
by typing the command), and wait for their confirmation, rather than
running it on their behalf.

## Releases (L5)

Three permanently-open milestone buckets track pending release
content: `next-patch`, `next-minor`, `next-major`. A merged PR's
`bump:*` label directly determines which bucket it lands in (see the
"Milestone assignment" workflow) — no separate inference step.

To cut a release: run the "Cut release" workflow
(`workflow_dispatch`), choosing which bucket to cut. It:

1. Computes the next semver tag from the bucket type and the latest
   existing tag.
2. Writes a `CHANGELOG.md` entry (Keep a Changelog format) listing the
   bucket's merged PRs.
3. Commits, tags, and pushes.
4. Creates a GitHub Release from the tag.
5. Closes the cut milestone and reopens an empty bucket with the same
   name for the next cycle.

Release cadence is a human decision — there is no scheduled/automatic
cutting.

## Coding conventions

`AGENTS.md` (generated by Laravel Boost) covers code-development
conventions specifically. This file covers repository/pipeline
mechanics only — see `SETUP.md` for how to run the project locally.
