# Agent Onboarding Spec Delta

## ADDED Requirements

### Requirement: Boost-managed code-development guidance
The repository SHALL use `laravel/boost` (declared in `composer.json`
`require-dev`) as the mechanism that generates `AGENTS.md` code-development
guidance (deterministic/predictable code, language best practices,
paradigms, maintainability), rather than that content being hand-maintained
bootstrap instructions.

#### Scenario: Boost dependency present
- **WHEN** `composer.json` is inspected
- **THEN** `require-dev` contains `laravel/boost`

#### Scenario: AGENTS.md reflects Boost generation
- **WHEN** `AGENTS.md` is inspected after running `php artisan boost:install`
- **THEN** it no longer consists solely of the bootstrap-only
  "install Boost" instructions
- **AND** it contains code-development guidance tailored to the detected
  stack (Laravel, Filament, Pest, Larastan/PHPStan, Pint)

### Requirement: CI checks remain green
Adding `laravel/boost` SHALL NOT break any existing CI check.

#### Scenario: Static analysis and tests pass after install
- **WHEN** `vendor/bin/phpstan analyse` and `php artisan test` are run after
  installing `laravel/boost` and regenerating `AGENTS.md`
- **THEN** both complete successfully with no new errors or failures
