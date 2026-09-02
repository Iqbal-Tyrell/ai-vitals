# Setup

## Prerequisites

- Docker (any engine — Docker Desktop, OrbStack, etc.)
- Git

No local PHP, Composer, or Node install is required — everything runs
inside Docker.

## Run it

```bash
git clone https://github.com/Iqbal-Tyrell/ai-vitals.git
cd ai-vitals
docker compose up -d
```

Visit http://localhost:8080. The admin panel is at
http://localhost:8080/admin.

## Create an admin user

```bash
docker compose exec app php artisan make:filament-user
```

## Data model

ai-vitals owns a single SQLite database (`database/database.sqlite`,
persisted in the `app-database` Docker volume). It holds both Laravel's
own operational tables (users, sessions, jobs, migrations) and the
provider-scanned usage data. The provider-scanned tables are fully
disposable and rebuilt via:

```bash
docker compose exec app php artisan vitals:scan
```

Rebuilds are scoped: only ai-vitals' own provider-data tables are
truncated and reinserted. Operational tables are never touched, and
`migrate:fresh`/`db:wipe` are never used for this.

## Local development commands

```bash
docker compose exec app php artisan tinker
docker compose exec app vendor/bin/pest --parallel
docker compose exec app vendor/bin/phpstan analyse --memory-limit=512M
docker compose exec app vendor/bin/pint
```

## Environment

The `app` container bootstraps its own `.env` on first boot (copied
from the committed `.env.example` — sane local-dev defaults: SQLite,
file-based cache, `APP_URL=http://localhost:8080` — plus a generated
`APP_KEY`) and persists it in the `app-storage` volume, so it survives
image rebuilds. No manual `.env` setup is needed.

To run `artisan`/Composer commands outside Docker, copy `.env.example`
to `.env` yourself first.
