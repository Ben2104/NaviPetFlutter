# NaviPet Backend Milestone 1 Foundation Design

Date: 2026-08-14

Status: Approved

## Purpose

Create the first controlled increment of NaviPet's Node.js backend. This
milestone establishes a secure, testable Fastify foundation without changing
the Flutter application, database schema, or MultiSet integration.

The complete indoor-navigation MVP is intentionally decomposed into later
milestones. Database migrations, application APIs, pathfinding, favorites, and
guide content are outside this milestone.

## Current Repository State

The repository currently contains:

- A working Flutter application with Supabase Auth, including anonymous users.
- Mobile Mapbox navigation and prototype AR screens.
- A repeatable `supabase/schema.sql` containing profiles, classes,
  task-completion tables, triggers, and owner-scoped RLS policies.
- A root `.env.example` whose values are safe for the Flutter client.
- No Node.js package, Fastify application, TypeScript configuration, ESLint
  configuration, or Vitest configuration.

The backend will be an independent npm package under `backend/`. This prevents
server dependencies and secrets from entering the Flutter build while keeping
the mobile app, backend, and Supabase migrations in one repository.

## Decisions

- Use a lean modular Fastify package rather than adding repositories and
  service layers before they have real responsibilities.
- Use Fastify 5 on the installed Node.js 22 runtime.
- Use ESM and strict TypeScript.
- Use TypeBox for environment, request, response, and OpenAPI schemas.
- Use Vitest and `fastify.inject()` for tests.
- Use npm and commit `backend/package-lock.json`.
- Accept valid Supabase anonymous-user access tokens. Their email is absent.
- Preserve the existing Flutter application and Supabase schema in this
  milestone.

## File Layout

Milestone 1 creates this structure:

```text
backend/
├── package.json
├── package-lock.json
├── tsconfig.json
├── tsconfig.build.json
├── eslint.config.js
├── vitest.config.ts
├── .env.example
├── README.md
├── src/
│   ├── app.ts
│   ├── server.ts
│   ├── config/
│   │   ├── constants.ts
│   │   └── env.ts
│   ├── common/
│   │   └── errors/
│   │       ├── app-error.ts
│   │       └── error-codes.ts
│   ├── plugins/
│   │   ├── auth.ts
│   │   ├── cors.ts
│   │   ├── error-handler.ts
│   │   ├── rate-limit.ts
│   │   ├── supabase.ts
│   │   └── swagger.ts
│   ├── modules/
│   │   └── health/
│   │       ├── health.routes.ts
│   │       └── health.schema.ts
│   └── types/
│       └── fastify.d.ts
└── tests/
    ├── helpers/
    │   └── build-test-app.ts
    ├── unit/
    │   └── env.test.ts
    └── integration/
        ├── auth-guard.test.ts
        ├── error-handler.test.ts
        └── health.test.ts
```

No empty directories for later domain modules will be created. Later
milestones will add modules when their behavior is implemented.

## Application Composition

`src/app.ts` exports `buildApp(options)`. It creates and configures a Fastify
instance but does not open a network port. Dependencies that cross an external
boundary, especially JWT verification, can be injected through the options for
deterministic tests.

Plugin registration follows this order:

1. Application configuration and generated request IDs.
2. Central error handling.
3. CORS and rate limiting.
4. Swagger and Swagger UI when enabled.
5. Supabase client facilities.
6. Authentication decorators.
7. Health routes.

Fastify receives a one-megabyte body limit. Request IDs are generated with
UUIDs on the server rather than trusted from client headers. Built-in Pino
logging redacts authorization headers, cookies, Supabase credentials, and
MultiSet credentials.

`src/server.ts` is the only process entry point. It loads environment values,
calls `buildApp()`, listens on the configured host and port, and handles
`SIGINT` and `SIGTERM`. Shutdown stops accepting requests, closes Fastify, and
lets in-flight work finish according to Fastify's close behavior.

## Environment Configuration

`src/config/env.ts` parses environment data once with TypeBox and returns an
immutable typed configuration object. Tests pass an explicit environment
object rather than mutate global process state.

The backend example includes:

```dotenv
NODE_ENV=development
PORT=3000
HOST=0.0.0.0
LOG_LEVEL=info
BODY_LIMIT_BYTES=1048576
RATE_LIMIT_MAX=100
RATE_LIMIT_WINDOW=1 minute
DOCS_ENABLED=true
SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
SUPABASE_JWT_ISSUER=
SUPABASE_JWT_AUDIENCE=authenticated
MULTISET_API_KEY=
MULTISET_API_BASE_URL=
CORS_ORIGINS=
```

Supabase URL, anon key, issuer, and audience are required. The service-role key
and MultiSet variables are optional in this milestone but are validated when
present. Documentation defaults to enabled outside production and disabled in
production; `DOCS_ENABLED` can override that default.

The root Flutter `.env` remains public-only. Server operators copy
`backend/.env.example` to `backend/.env`. A service-role key must never be put
in the root Flutter environment file because Flutter bundles that file as an
application asset.

## Supabase Client Boundary

The Supabase plugin exposes three distinct concepts:

- A public/auth client configured with the anon key and no persisted session.
- A factory that creates a request-scoped client carrying a verified user's
  access token. Later repositories use this client so Supabase RLS evaluates
  the authenticated user's identity.
- An optional admin client created only when a service-role key is configured.
  It is not attached to requests and is never the default database client.

The admin client is reserved for explicit privileged workflows added in later
milestones. Private user data such as profiles, favorites, and navigation
sessions will use user-scoped clients and owner RLS rather than blindly bypass
RLS.

No key or Supabase client is serialized into HTTP responses.

## Authentication

The auth plugin adds:

- `fastify.authenticate`, a protected-route pre-handler.
- `request.user`, containing `{ id: string, email?: string }` after successful
  authentication.
- Internal access to the verified bearer token for construction of a
  user-scoped Supabase client.

The production verifier:

1. Requires exactly one `Authorization: Bearer <token>` credential.
2. Calls `supabase.auth.getClaims(token)`.
3. Relies on Supabase's JWKS verification for asymmetric signing keys and its
   Auth-server fallback for legacy symmetric keys.
4. Confirms the configured issuer and audience.
5. Requires a non-expired token and a UUID `sub` claim.
6. Maps `sub` to `request.user.id` and copies `email` only when it is a string.

Valid anonymous Supabase tokens are accepted and produce a user without an
email. No separate username/password system exists in Fastify. The service-role
key never participates in end-user authentication.

The public `/api/v1/auth/me` endpoint is not added yet. It belongs to
Milestone 3. The authentication integration test registers a protected route
only inside its isolated test app.

## HTTP and Security Behavior

The request flow is:

```text
request
→ payload, CORS, and rate-limit controls
→ request ID and redacted logging
→ TypeBox validation
→ authentication pre-handler when required
→ route handler
→ centralized error mapper
```

CORS checks a comma-separated exact-origin allowlist. An empty list permits no
cross-origin browser origins; native Flutter networking is not governed by
browser CORS. Rate limiting is enabled globally using a configurable per-IP
limit. Health endpoints are excluded.

Swagger describes bearer authentication and all registered TypeBox schemas.
Swagger UI is exposed at `/docs` only when documentation is enabled.

Both health endpoints are public:

```text
GET /health
GET /api/v1/health
```

They share one handler and schema and return:

```json
{
  "status": "ok"
}
```

These endpoints report process liveness. They do not call Supabase or MultiSet.
A dependency-readiness endpoint can be added later if deployment needs it.

## Error Model

`AppError` carries an application error code, HTTP status, safe client message,
and optional internal cause. The defined code union includes:

```text
VALIDATION_ERROR
UNAUTHORIZED
FORBIDDEN
NOT_FOUND
CONFLICT
ROUTE_NOT_FOUND
DATABASE_ERROR
INTERNAL_ERROR
```

Every error response uses:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid request",
    "requestId": "server-generated-uuid"
  }
}
```

Fastify validation failures map to `VALIDATION_ERROR`. Unknown routes map to
`NOT_FOUND`. Authentication failures map to `UNAUTHORIZED`. Unrecognized
exceptions are logged with server-side context and returned as
`INTERNAL_ERROR` with a generic message. Production responses never include
stacks, JWTs, secrets, or database implementation details.

## TypeScript and Build

The package uses ESM and declares Node.js 22 or newer in `engines`.

`tsconfig.json` enables strict checking for source, tests, Vitest configuration,
and ESLint configuration. `tsconfig.build.json` extends it but includes only
`src/`, sets `rootDir` to `src`, and emits production files to `dist/`. This
keeps tests out of the runtime artifact.

ESLint uses flat configuration with the TypeScript-aware recommended rules.
Formatting is not delegated to a new formatter because the repository has no
existing JavaScript formatter convention. Source code follows a consistent
style enforced by ESLint and TypeScript.

The package exposes:

```text
npm run dev
npm test
npm run typecheck
npm run lint
npm run build
npm start
```

`dev` runs the TypeScript entry point in watch mode. `start` runs the emitted
JavaScript from `dist/server.js`.

## Tests

Tests run without real Supabase or MultiSet calls. `build-test-app.ts` supplies
valid dummy configuration, disables noisy logging, and injects a fake JWT
verifier where needed. Each test closes its Fastify instance.

Unit coverage verifies:

- Valid environment parsing and defaults.
- Rejection of invalid ports, URLs, origins, booleans, and numeric limits.

Integration coverage verifies:

- `GET /health` returns HTTP 200 and `{ "status": "ok" }`.
- `GET /api/v1/health` returns the same response.
- Missing and malformed bearer credentials return the safe unauthorized error.
- A fake verified standard user populates `request.user`.
- A fake verified anonymous user is accepted without an email.
- An invalid TypeBox request body returns the validation envelope.
- Unknown and unexpected errors use safe error envelopes.
- Swagger routes are present only when documentation is enabled.

No global coverage threshold is added in the foundation milestone. Later
domain milestones add focused coverage with their behavior.

## Documentation Changes

`backend/README.md` documents foundation setup, environment boundaries,
commands, health endpoints, Swagger, authentication verification, and the
current trust model. The root README receives a short link to the backend
README. Full database, routing, Flutter API, and MultiSet setup documentation
will be expanded as their milestones are implemented.

## Acceptance Criteria

Milestone 1 is complete only when:

- The backend starts with valid environment configuration.
- Invalid environment configuration fails before listening.
- Both health endpoints return the documented response.
- Protected test routes reject invalid credentials and accept injected valid
  normal and anonymous Supabase identities.
- Swagger works according to `DOCS_ENABLED`.
- Logs and client errors do not reveal credentials or stacks.
- These commands pass from `backend/` with fresh output:

  ```bash
  npm test
  npm run typecheck
  npm run lint
  npm run build
  ```

## Explicitly Deferred

Milestone 1 does not create or change:

- Supabase migrations or seed data.
- `GET /api/v1/auth/me` or user profile APIs.
- Building, floor, POI, favorite, navigation, session, guide, or spatial APIs.
- Routing or nearest-node algorithms.
- Production MultiSet network integration.
- Flutter API integration.
- Microservices, queues, caches, WebSockets, or analytics infrastructure.

## References

- [Fastify v5 LTS and Node.js support](https://fastify.dev/docs/v5.10.x/Reference/LTS/)
- [Fastify TypeBox type provider compatibility](https://github.com/fastify/fastify-type-provider-typebox)
- [Supabase `getClaims` JWT verification](https://supabase.com/docs/reference/javascript/auth-getclaims)
- [Supabase JWT signing keys](https://supabase.com/docs/guides/auth/signing-keys)
