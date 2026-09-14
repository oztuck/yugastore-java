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
./mvnw -DskipTests package
```

Builds all 7 modules, including `react-ui`'s frontend bundle. The frontend's
`frontend-maven-plugin` downloads and manages its own Node — no separate
`npm install` needed even on Apple Silicon.

## Database setup (once per fresh YugabyteDB instance)

1. Start YugabyteDB with YSQL, YCQL, and the master UI exposed:
   ```sh
   docker run -d --name yugastore-db \
     -p 7000:7000 -p 9000:9000 -p 5433:5433 -p 9042:9042 \
     yugabytedb/yugabyte:latest bin/yugabyted start --daemon=false
   ```
2. `yugabyted` binds to the container's internal IP, not `localhost` —
   get it with `docker exec yugastore-db bin/yugabyted status`. The host
   has no `cqlsh`/`ysqlsh`, so run schema loads from inside the container:
   ```sh
   docker cp resources/ yugastore-db:/tmp/resources
   docker exec yugastore-db bin/ysqlsh -h <container-ip> -U yugabyte -d yugabyte -f /tmp/resources/schema.sql
   docker exec yugastore-db bin/ycqlsh <container-ip> 9042 -f /tmp/resources/schema.cql
   ```
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

- `products-microservice`'s `/products` and `/products/category/{cat}`
  endpoints use Spring Data's `@Param` instead of `@RequestParam` for
  `limit`/`offset`, so both are required with no default — omitting either
  gives a 500, not a 400. Always pass `?limit=N&offset=M`.
- The product catalog is read-only end to end — this is a known gap
  (tracked business goal: add a CMS / write path for pricing and product data).
- Colima's default VM disk (20GB) fills up fast with unrelated image layers.
  If YugabyteDB starts rejecting writes with "insufficient disk space,"
  check `docker exec yugastore-db df -h /` before assuming it's an app bug.

## Conventions

- Conventional commits (`feat:`, `fix:`, `chore:`, etc.).
- Raw meeting/session transcripts go in `.transcripts/` (see that folder's
  README) — don't paste transcript content into other docs; link to it instead.
