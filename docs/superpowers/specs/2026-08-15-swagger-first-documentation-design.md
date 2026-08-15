# Swagger-First Documentation Design

## Goal

Let a new contributor start the Fastify backend and inspect Swagger before
creating or connecting a real Supabase project.

## Documentation placement

- Add a short **Test Swagger first** section to the root `README.md` so the
  workflow is easy to discover.
- Add the complete Swagger-only setup to `backend/README.md`, which remains the
  source of truth for backend configuration.
- Link the root summary to the detailed backend section instead of duplicating
  the full instructions.

## Backend instructions

The detailed guide will:

1. Copy `backend/.env.example` to `backend/.env`.
2. Provide local, non-secret placeholder values for `SUPABASE_URL`,
   `SUPABASE_ANON_KEY`, and `SUPABASE_JWT_ISSUER` that satisfy startup
   validation without claiming authentication works.
3. Run `npm install` and `npm run dev` from `backend/`.
4. Link to `http://127.0.0.1:3000/docs/` and the health endpoint.
5. Explain that `Ctrl+C` stops the local server.
6. State that real Supabase credentials are required before testing protected
   authentication or data access.

## Safety and scope

- Never include real credentials.
- Clearly label the values as Swagger-only placeholders.
- Do not weaken environment validation or change backend behavior.
- Do not add deployment instructions or domain API documentation in this
  change.

## Verification

- Start the backend using the documented Swagger-only configuration.
- Confirm `/health` and `/docs/` return HTTP 200.
- Confirm both README links and commands match the repository structure.
- Run a Markdown whitespace check with `git diff --check`.
