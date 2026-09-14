# AGENTS.md

Agent-agnostic instructions for working in this repo. Written to be read by any
coding agent (Claude, Copilot, Codex, GitLab Duo, etc.) — see `.transcripts/2026-09-14-kickoff-meeting.md`
for why: the team splits across tools and wants one shared source of truth instead
of per-tool config drifting apart.

## Project

Yugastore — a Java/Spring Boot microservices e-commerce sample app, backed by
YugabyteDB (YSQL + YCQL), with a React UI and Eureka service discovery.

- Fork: https://github.com/oztuck/yugastore-java (`origin`)
- Upstream: https://github.com/YugabyteDB-Samples/yugastore-java (`upstream`)

This is a brownfield hackathon project (team "Pirate Brown Pants"). Business/team
goals live in `.transcripts/`, not here — this file is scoped to "how to build,
run, and work in the codebase."

## Architecture

| Service | Port | API | Notes |
|---|---|---|---|
| eureka-server-local | 8761 | - | service discovery; start first |
| api-gateway-microservice | 8081 | - | single entry point for the UI, proxies to backend services via Eureka |
| products-microservice | 8082 | YCQL | **read-only** product catalog — no create/update/delete, no CMS. Data is seeded once from `resources/products.json`. |
| cart-microservice | 8083 | YSQL | shopping cart |
| checkout-microservice | 8086 | YCQL | checkout + inventory |
| login-microservice | 8085 | YSQL | work in progress |
| react-ui | 8080 | - | React app, built via `frontend-maven-plugin` during `mvn package` and served by Spring Boot |

**No Kubernetes.** No per-service containers in local dev, either — every
service runs as a plain `java -jar` process. The only thing that runs in
Docker is YugabyteDB itself. (`docker-run.sh` at the repo root assumes
pre-built per-service images and is Linux-only — don't use it as-is on macOS.)

## Prerequisites

- **JDK 17 exactly.** Spring Boot 2.6.3 doesn't reliably support newer JDKs.
  On macOS: `brew install openjdk@17` (it's keg-only, so it won't be on PATH
  or found by `/usr/libexec/java_home` automatically):
  ```sh
  export JAVA_HOME=$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home
  ```
- **Docker**, for YugabyteDB only. On Apple Silicon with Colima, use an
  image with a real arm64 manifest (e.g. `yugabytedb/yugabyte:latest`) —
  check with `docker manifest inspect <image>` before pulling, to avoid
  slow QEMU emulation.
- No Maven install needed — use the bundled `./mvnw`.
- Python 3, for the data-loading script.

## Build

```sh
./mvnw -DskipTests -Dexec.skip=true package      # macOS / Linux
mvnw.cmd -DskipTests -Dexec.skip=true package    # Windows
```

`-Dexec.skip=true` is required. Six module poms run `docker build` during the
`package` phase via `exec-maven-plugin`; without the flag the build fails if
Docker is not running and otherwise pulls base images nobody needs for
plain-jar local dev.

Builds all 7 modules, including `react-ui`'s frontend bundle. The frontend's
`frontend-maven-plugin` downloads and manages its own Node — no separate
`npm install` needed even on Apple Silicon.

## Database setup (once per fresh YugabyteDB instance)

1. Start YugabyteDB with YSQL, YCQL, and the master UI exposed:
   ```sh
   docker run -d --name yugastore-db \
     -p 7001:7000 -p 9000:9000 -p 5433:5433 -p 9042:9042 \
     yugabytedb/yugabyte:latest bin/yugabyted start --daemon=false
   ```
   The master UI is mapped to host port **7001**, not 7000: macOS AirPlay
   Receiver listens on 7000 and answers with an AirTunes 403, so the UI
   would be silently unreachable. Wait until `docker exec yugastore-db
   bin/yugabyted status` reports `Running` and `YSQL Status: Ready`.
2. `yugabyted` binds to the container's own hostname, not `localhost`, and
   the host has no `cqlsh`/`ysqlsh`, so run schema loads inside the container
   and let the container resolve its own address. Works as written from zsh,
   bash, and PowerShell; in cmd.exe swap the single quotes for double:
   ```sh
   docker cp resources/ yugastore-db:/tmp/resources
   docker exec yugastore-db sh -c 'bin/ysqlsh -h $(hostname) -U yugabyte -d postgres -f /tmp/resources/schema.sql'
   docker exec yugastore-db sh -c 'bin/ycqlsh $(hostname) 9042 -f /tmp/resources/schema.cql'
   ```
   Note `-d postgres`: `cart-microservice` and `login-microservice` connect to
   the `postgres` database as user `postgres` (see their `application.yml`),
   not to `yugabyte`.
3. Load sample data from the host (needs `JAVA_HOME` set, per above):
   ```sh
   cd resources
   python3 parse_metadata_json.py products.json
   ```
   Then run the three `cassandra-loader` commands listed in `resources/dataload.sh`
   against `localhost:9042` (the mapped port works fine from the host for this step).

## Run

Start in this order, each as `java -jar target/*.jar` from its module directory,
waiting a few seconds between steps:

1. `eureka-server-local` — wait for http://localhost:8761 to respond.
2. `api-gateway-microservice`, `products-microservice`, `checkout-microservice`,
   `cart-microservice` — any order, once Eureka is up.
3. `react-ui` — serves the built frontend at http://localhost:8080.

Verify registration at http://localhost:8761/eureka/apps rather than trusting
that a process starting means it's healthy. A 500 on `/` for a backend service
is normal (no root route is mapped) — check an actual API route instead.

## Known issues / gotchas

- Product API paths are prefixed. Direct: `http://localhost:8082/products-microservice/products`;
  through the gateway: `http://localhost:8081/api/v1/products`. A bare
  `/products` on either port is a 404.
- Those endpoints (and `/products/category/{cat}`) use Spring Data's `@Param`
  instead of `@RequestParam` for `limit`/`offset`, so both are required with
  no default — omitting either gives a 500, not a 400. Always pass
  `?limit=N&offset=M`.
- The product catalog is read-only end to end — this is a known gap
  (tracked business goal: add a CMS / write path for pricing and product data).
- Colima's default VM disk (20GB) fills up fast with unrelated image layers.
  If YugabyteDB starts rejecting writes with "insufficient disk space,"
  check `docker exec yugastore-db df -h /` before assuming it's an app bug.

## Repository layout for agents

Nothing canonical lives in a vendor folder. Vendor folders hold only adapters
with zero unique content. Adding a tool means adding an adapter, never
rewriting content. Why: `docs/decisions/0001-agent-agnostic-layout.md`.

| Path | What | Notes |
|---|---|---|
| `AGENTS.md` | This file. Build, run, layout, build-breaking gotchas | Canonical. Keep under ~150 lines; split and link past that |
| `CLAUDE.md` | Claude Code adapter | Imports this file. Claude does not read `AGENTS.md` natively |
| `.agents/skills/<name>/SKILL.md` | Skills and role personas | Canonical. Agent Skills format. Copilot and Codex read this path natively |
| `.claude/skills` | Claude Code adapter | A single directory symlink to `.agents/skills`. Add skills to the neutral folder only; no extra step. Re-check skills still list after a Claude Code upgrade |
| `.github/ISSUE_TEMPLATE/`, `PULL_REQUEST_TEMPLATE.md` | Tracker config | Not agent config; stays in `.github/` |
| `specs/<slug>/` | One folder per story: requirements, design, tasks | Shape in `docs/process/spec-convention.md` |
| `docs/process/` | How the team works | Start with `collaboration.md` |
| `docs/decisions/` | Why things are the way they are | Short decision records |
| `docs/setup/` | Human-facing environment setup | Longer runbooks; this file stays short |
| `.transcripts/` | Meeting transcripts and recaps | Agents read recaps, not raw transcripts |

## Conventions

- Conventional commits (`feat:`, `fix:`, `chore:`, etc.).
- Work moves through the loop in `docs/process/collaboration.md`; specs follow
  `docs/process/spec-convention.md`.
- Raw meeting/session transcripts go in `.transcripts/` (see that folder's
  README) — don't paste transcript content into other docs; link to it instead.
