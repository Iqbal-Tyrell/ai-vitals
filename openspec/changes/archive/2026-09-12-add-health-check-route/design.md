# Design: Add health-check route

## Approach

Register a `GET /up` route directly in `routes/web.php` using a closure that
returns `response()->json(['status' => 'ok'])`. This mirrors the existing `/`
route's simplicity in this file and avoids introducing a controller for a
single trivial responder.

No middleware group changes are needed - the default `web` middleware group
is sufficient and does not require CSRF/session for a GET JSON response.

## Alternatives Considered

- Laravel's built-in `/up` framework health-check, previously registered via
  `bootstrap/app.php`'s `withRouting(health: '/up')` option, renders an HTML
  view, not the required `{"status": "ok"}` JSON body. That option is
  removed and replaced by the dedicated JSON route in `routes/web.php`, so
  there is exactly one `/up` route and no ambiguity in match order.
- A dedicated `HealthCheckController` was considered but rejected as
  over-engineering for a single-line JSON responder; a closure route matches
  the file's existing convention.

## Testing

A Pest feature test asserts `GET /up` returns HTTP 200 with JSON body
`{"status": "ok"}`.
