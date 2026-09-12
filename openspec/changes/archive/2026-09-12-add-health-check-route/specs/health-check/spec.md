# Health Check Spec Delta

## ADDED Requirements

### Requirement: Health-check endpoint
The system SHALL expose a `GET /up` route that returns a `200` response with
a JSON body of `{"status": "ok"}`, requiring no database access or
authentication.

#### Scenario: Requesting the health-check route
- **WHEN** a client sends `GET /up`
- **THEN** the response status is `200`
- **AND** the response body is JSON equal to `{"status": "ok"}`
