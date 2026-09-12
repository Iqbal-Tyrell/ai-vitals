# Add health-check route

## Why

ai-vitals has no lightweight endpoint to confirm the app is up and responding
without touching the database or Filament admin panel. A simple `/up`
health-check route provides a fast, dependency-free liveness probe useful for
Docker Compose healthchecks, uptime monitors, and as a well-scoped smoke test
for the L4 pipeline.

## What Changes

- Add a `GET /up` route that returns a `200` JSON response `{"status": "ok"}`.
- Add a Pest feature test verifying the route returns `200` and the expected
  JSON payload.

## Impact

- Affected specs: `health-check` (new capability)
- Affected code: `routes/web.php`, `tests/Feature/HealthCheckTest.php`
- No database, provider, or Filament changes required.
