# Design: Install Laravel Boost and generate AGENTS.md

## Approach

1. Require `laravel/boost` as a dev-only dependency via
   `composer require laravel/boost --dev`. It is dev-only because it is an
   AI-onboarding/tooling aid, not runtime application code, matching how
   `laravel/pail` and `laravel/pint` are already scoped in this repo.
2. Run `php artisan boost:install` (interactive by default; run
   non-interactively where the installed version supports it, e.g. with
   `--no-interaction` / accepting defaults) to let Boost detect the stack
   (Laravel 13, Filament, Pest, Larastan/PHPStan, Pint) and generate:
   - A regenerated `AGENTS.md` with tailored code-development guidelines.
   - Boost's MCP server registration (wherever the installed Boost version
     places it - e.g. `.mcp.json` or an IDE-specific config).
3. Preserve this repo's existing project-specific conventions (SQLite single
   file, provider plugin contract, determinism rules, doc-comment policy)
   by re-adding them to `AGENTS.md` after Boost's generation if Boost's
   installer does not offer a merge/append step, so no established guidance
   is lost.
4. Re-run the existing CI-equivalent checks locally (`vendor/bin/pint`,
   `vendor/bin/phpstan analyse`, `php artisan test`) to confirm nothing
   broke.

## Alternatives Considered

- Hand-writing code-development guidelines directly into `AGENTS.md` instead
  of using Boost: rejected per the project plan, which explicitly designates
  Boost (official first-party package) as the L6 mechanism for this content,
  and because Boost keeps guidance in sync with the actual installed
  package versions via its own MCP server.
- Requiring `laravel/boost` in `require` (production) instead of
  `require-dev`: rejected - Boost is a development-time aid with no runtime
  application need, consistent with how other dev tooling is scoped in
  `composer.json`.

## Testing

- `vendor/bin/pint --test` (or `--dirty` if only formatting-adjacent files
  changed) to confirm style compliance.
- `vendor/bin/phpstan analyse` to confirm level 8 static analysis still
  passes.
- `php artisan test` (Pest via ParaTest) to confirm the full existing test
  suite still passes after the dependency addition.
