# ai-vitals

A local, single-user, cross-AI-provider usage/cost dashboard. It detects
and scans local AI coding tool logs (GitHub Copilot CLI, Claude Code,
Codex CLI) and displays usage/cost analytics via a Filament 4 admin
panel, running on Laravel 13 + PHP 8.4.

## Status

Bootstrap infrastructure (CI, contribution pipeline, releases) is in
place; the core scanning/dashboard features are actively under
development. See open issues and the project board for current
progress.

## Getting started

See [SETUP.md](SETUP.md) for running the app locally via Docker Compose
— no local PHP, Composer, or Node install required.

## Data model

ai-vitals owns a single SQLite database holding both Laravel's own
operational tables and disposable, provider-scanned usage data,
rebuilt via `php artisan vitals:scan`. See [SETUP.md](SETUP.md) for
details.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for branching, CI checks, and
the AI-assisted PR pipeline this project uses.

## License

MIT — see [LICENSE](LICENSE).
