---
name: stop-app
description: Stops the Yugastore stack (Eureka, all microservices, and react-ui) that was started by the start-app skill, on macOS or Windows. Use when a developer asks to "stop the app", "stop all services", "shut down yugastore locally", or "kill the running services".
---

# stop-app

Use this skill to shut down every process launched by the `start-app` skill.
It reads the pid files that `start-app` writes to `.run/` at the repo root
and stops each corresponding process.

## Stop everything

**macOS / Linux:**
```sh
.agents/skills/stop-app/scripts/stop-app.sh
```

**Windows (PowerShell):**
```powershell
.agents\skills\stop-app\scripts\stop-app.ps1
```

Each script:
1. Reads every `.run/<module>.pid` file at the repo root.
2. Sends a termination signal to each pid that is still running (Spring Boot
   apps take a few seconds to shut down gracefully after this).
3. Reports pids that were already stopped.
4. Removes the pid files once handled.

Logs in `logs/` are left in place for inspection after shutdown.

## Verify it's down

```sh
ps aux | grep -- '-jar.*yugastore-java' | grep -v grep   # macOS/Linux, expect no output after ~10s
```
```powershell
Get-Process java -ErrorAction SilentlyContinue   # Windows
```

## Troubleshooting and gotchas

- If `.run/` doesn't exist, the script reports there's nothing to stop and
  exits cleanly — this is expected if `start-app` was never run.
- If a pid file exists but the process is already gone (e.g. after a reboot
  or manual kill), the script reports it as already stopped and still
  removes the stale pid file.
- Processes may take several seconds to fully exit after being signaled;
  re-check with `ps`/`Get-Process` before assuming a stop failed.

## Done when

No java processes for any Yugastore module remain running and `.run/` no
longer contains stale pid files.
