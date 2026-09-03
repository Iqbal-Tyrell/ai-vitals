# Tasks: Install Laravel Boost and generate AGENTS.md

- [x] 1. Run `composer require laravel/boost --dev` to add Laravel Boost as
      a dev dependency and update `composer.json`/`composer.lock`.
- [x] 2. Run `php artisan boost:install` to generate Boost's guidelines and
      MCP server configuration, letting it regenerate `AGENTS.md`.
- [x] 3. Reconcile `AGENTS.md`: ensure project-specific conventions from
      `openspec/config.yaml`'s context (SQLite single-file data layer,
      provider plugin contract, determinism rules, doc-comment policy,
      architecture layering) are preserved/re-added if Boost's generated
      file doesn't already retain them.
- [x] 4. Run `vendor/bin/pint --dirty`, `vendor/bin/phpstan analyse`, and
      `php artisan test` to confirm the change is clean and passing.
