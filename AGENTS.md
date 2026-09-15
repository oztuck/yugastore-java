# AGENTS.md

This file is the repo’s high-level agent guide: project context, rules, and
shared conventions. Detailed local setup and startup instructions live in the
setup skill under `.agents/skills/`.

## Agent policy

- Keep the working context narrow and task-focused.
- Read the smallest relevant files before changing code.
- Prefer repo conventions over ad hoc patterns.
- Respect the spec lifecycle in `docs/process/collaboration.md` and
  `docs/process/spec-convention.md`.
- Do not add new infrastructure, scripts, or service assumptions without a
  clear reason tied to the story.
- Commit only when a skill step names a commit or the human asks. Otherwise
  leave edits in the working tree and say they are uncommitted.

## Project

Yugastore is a Java/Spring Boot microservices e-commerce sample app backed by
YugabyteDB (YSQL + YCQL) with a React UI and Eureka service discovery.

- Fork: https://github.com/oztuck/yugastore-java (`origin`)
- Upstream: https://github.com/YugabyteDB-Samples/yugastore-java (`upstream`)

## Architecture

| Service | Port | API | Notes |
|---|---|---|---|
| eureka-server-local | 8761 | - | Service discovery; start first |
| api-gateway-microservice | 8081 | - | Single UI entry point via Eureka |
| products-microservice | 8082 | YCQL | Read-only catalog, seeded from `resources/products.json` |
| cart-microservice | 8083 | YSQL | Shopping cart |
| checkout-microservice | 8086 | YCQL | Checkout + inventory |
| login-microservice | 8085 | YSQL | Work in progress |
| react-ui | 8080 | - | Served by Spring Boot after Maven frontend build |

## Rules and guardrails

- No Kubernetes. Local dev runs as plain Java processes.
- Docker is used only for YugabyteDB; the app services are started with
  `java -jar` from their module directories.
- Use JDK 17 exactly. Spring Boot 2.6.3 is not reliably compatible with newer
  Java.
- Keep service names aligned with the architecture table above.
- Prefer EARS acceptance criteria in specs; one behavior per line.
- Product catalog APIs are prefixed and have required pagination params.

## Major gotchas

- The storefront and gateway use different URLs; the gateway is the stable path
  for browser-facing requests.
- Product endpoints require both `limit` and `offset` values when used; do not
  assume they have defaults.
- The catalog is intentionally read-only today; pricing and write paths are
  tracked as future work.
- `gh` in this checkout defaults to the upstream YugabyteDB-Samples repo, so
  `gh issue` and `gh pr` commands must pass `--repo oztuck/yugastore-java`, or
  run `gh repo set-default oztuck/yugastore-java` once per machine.

## Repository layout for agents

| Path | What | Notes |
|---|---|---|
| `AGENTS.md` | Project rules and operating context | Keep short and policy-oriented |
| `CLAUDE.md` | Claude-specific wrapper | Imports this file; keep minimal |
| `.agents/skills/<name>/SKILL.md` | Role-specific tasks and setup recipes | Canonical for agent behavior |
| `specs/<slug>/` | One folder per story | `requirements.md`, `design.md`, `tasks.md` |
| `docs/process/` | Team workflow and conventions | Read before changing process |
| `docs/decisions/` | Architecture decisions | Short rationale records |
| `.github/` | Tracker and PR config | Not agent policy |

## Conventions

- Conventional commits: `feat:`, `fix:`, `chore:`, etc.
- Work follows the loop in `docs/process/collaboration.md`.
- Follow `docs/process/spec-convention.md` for EARS acceptance criteria and
  spec structure.
- Keep setup and local environment details in the setup skill, not in the agent
  policy file.
