---
name: start-app
description: Starts the full Yugastore stack (Eureka, all microservices, and the react-ui) on macOS or Windows using pre-built jars. Use when a developer asks to "start the app", "start all services", "run yugastore locally", or after setup-local has already built the modules and initialized YugabyteDB.
---

# start-app

Use this skill to bring up the whole running application once the modules are
already built and YugabyteDB is already initialized (see the `setup-local`
skill for those one-time steps). This skill only launches processes; it does
not build code or touch the database schema.

## Prerequisites

- Each module has already been built: `target/*.jar` exists in
  `eureka-server-local`, `api-gateway-microservice`, `products-microservice`,
  `checkout-microservice`, `cart-microservice`, and `react-ui`. If any jar is
  missing, run the build from the `setup-local` skill first.
- YugabyteDB is already running and loaded with schema/data.
- JDK 17 is on `PATH` (`java -version`). On macOS, if needed:
  ```sh
  export JAVA_HOME=$(brew --prefix openjdk@17)/libexec/openjdk.jdk/Contents/Home
  export PATH="$JAVA_HOME/bin:$PATH"
  ```

## Start everything

**macOS / Linux:**
```sh
.agents/skills/start-app/scripts/start-app.sh
```

**Windows (PowerShell):**
```powershell
.agents\skills\start-app\scripts\start-app.ps1
```

Both scripts:
1. Start `eureka-server-local` and wait for it to report readiness.
2. Start `api-gateway-microservice`, `products-microservice`,
   `checkout-microservice`, and `cart-microservice` together, then pause ~15s
   for them to register with Eureka.
3. Start `react-ui` last.
4. Write each service's stdout/stderr to `logs/<module>.log` at the repo root,
   and its process id to `.run/<module>.pid`, so it can be checked or stopped
   later.

Each script resolves the repo root relative to its own location, so it can be
invoked from any working directory. Use the `stop-app` skill to shut down
everything these scripts start.

## Verify it's up

- Eureka dashboard (all services should show `UP`):
  `http://localhost:8761/eureka/apps`
- App entry point: `http://localhost:8081` (the api-gateway; not a backend
  service directly)
- Tail a log if a service isn't registering:
  ```sh
  tail -f logs/<module>.log        # macOS/Linux
  Get-Content logs\<module>.log -Wait   # Windows
  ```

## Stop everything

Use the separate `stop-app` skill to shut everything down.

## Troubleshooting and gotchas

- If a jar is missing for a module, the start script logs a warning and
  skips that module rather than failing the whole run — check the build.
- On macOS, avoid port 7000 for anything else — AirPlay may hold it, but
  that only affects the Yugabyte admin UI, not these services.
- Re-running the start script does not check for already-running instances;
  use the `stop-app` skill first to avoid port conflicts.

## Done when

`http://localhost:8761/eureka/apps` lists all five services as `UP` and the
react-ui is reachable through the gateway at `http://localhost:8081`.
