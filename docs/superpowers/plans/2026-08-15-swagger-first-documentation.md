# Swagger-First Documentation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Document how contributors can start the backend and inspect Swagger before connecting a real Supabase project.

**Architecture:** Keep `backend/README.md` as the complete backend setup source and add only a short discovery link to the root `README.md`. Use explicit non-secret local placeholders that satisfy startup validation, while clearly stating that protected authentication and data access require real Supabase credentials.

**Tech Stack:** Markdown, Fastify development server, Swagger UI, curl, Git

## Global Constraints

- Never include real credentials.
- Clearly label the values as Swagger-only placeholders.
- Do not weaken environment validation or change backend behavior.
- Do not add deployment instructions or domain API documentation.
- The Swagger URL is `http://127.0.0.1:3000/docs/`.
- The health URL is `http://127.0.0.1:3000/health`.

---

### Task 1: Add the Swagger-first setup guide

**Files:**
- Modify: `backend/README.md`
- Modify: `README.md`

**Interfaces:**
- Consumes: existing `backend/.env.example`, `npm run dev`, `/health`, and `/docs/`
- Produces: one detailed backend quick-start section and one root discovery section

- [ ] **Step 1: Add the detailed backend guide**

Insert this section in `backend/README.md` after **Local setup** and before
**Environment variables**:

````markdown
## Test Swagger first

You can start the backend and inspect its public OpenAPI documentation before
connecting a real Supabase project. In `backend/.env`, use these non-secret
local placeholders:

```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=swagger-only-placeholder
SUPABASE_JWT_ISSUER=http://127.0.0.1:54321/auth/v1
SUPABASE_JWT_AUDIENCE=authenticated
```

Keep `DOCS_ENABLED=true`, then start the server from `backend/`:

```bash
npm install
npm run dev
```

Open:

- Swagger UI: <http://127.0.0.1:3000/docs/>
- Health check: <http://127.0.0.1:3000/health>

Press `Ctrl+C` in the server terminal to stop it. These placeholders only
support startup, health, and Swagger inspection. Replace them with real
Supabase project values before testing authentication, protected endpoints,
or database access. Never use a service-role key in Flutter.
````

- [ ] **Step 2: Add the root discovery section**

Insert this section in the root `README.md` immediately after **Fastify
backend**:

```markdown
### Test Swagger first

The backend can run with non-secret local placeholders when you only need to
inspect its API documentation. Follow the
[Swagger-first backend setup](backend/README.md#test-swagger-first), then open
<http://127.0.0.1:3000/docs/> while `npm run dev` is running.
```

- [ ] **Step 3: Check documentation structure and whitespace**

Run:

```bash
rg -n "Test Swagger first|swagger-only-placeholder|127.0.0.1:3000/docs" README.md backend/README.md
git diff --check
```

Expected: both README files contain the Swagger-first section, the backend
README contains the placeholder and URL, and `git diff --check` exits 0.

- [ ] **Step 4: Verify the documented runtime flow**

From `backend/`, start the server without reading or changing a contributor's
real `.env` values:

```bash
HOST=127.0.0.1 \
PORT=3000 \
DOCS_ENABLED=true \
SUPABASE_URL=http://127.0.0.1:54321 \
SUPABASE_ANON_KEY=swagger-only-placeholder \
SUPABASE_JWT_ISSUER=http://127.0.0.1:54321/auth/v1 \
SUPABASE_JWT_AUDIENCE=authenticated \
npm run dev
```

In another terminal, run:

```bash
curl --fail http://127.0.0.1:3000/health
curl --fail --output /dev/null http://127.0.0.1:3000/docs/
```

Expected: both curl commands exit 0. Stop the development server with
`Ctrl+C`.

- [ ] **Step 5: Commit the user-facing documentation**

```bash
git add README.md backend/README.md
git commit -m "docs: add Swagger-first setup"
```
