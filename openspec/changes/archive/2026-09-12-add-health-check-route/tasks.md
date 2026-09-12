# Tasks: Add health-check route

- [x] 1. Remove Laravel's default HTML `/up` health-route registration in
      `bootstrap/app.php` (the `health: '/up'` option) so it doesn't conflict
      with the new JSON route.
- [x] 2. Add `GET /up` route in `routes/web.php` returning
      `response()->json(['status' => 'ok'])` with a 200 status.
- [x] 3. Add `tests/Feature/HealthCheckTest.php` Pest test asserting
      `GET /up` responds 200 with JSON `{"status": "ok"}`.
- [x] 4. Run `vendor/bin/pint --dirty`, `vendor/bin/phpstan analyse`, and
      `php artisan test --filter=HealthCheck` (or the project's Pest runner)
      to confirm the change is clean and passing.
