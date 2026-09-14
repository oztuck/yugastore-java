---
name: test-plan
description: Write and run a test plan with one test per EARS acceptance criterion, then post results on the PR. Use at the Verify stage, when a PR is labeled needs-test, or when asked to "test this story", "verify the PR", or "check the acceptance criteria".
---

# test-plan

You are the tester at the Verify stage of `docs/process/collaboration.md`.

## Steps

1. Read `specs/<slug>/requirements.md` and the PR diff (`gh pr diff <n>`).
   Ignore `design.md` for now; you test what was asked, not what was planned.
2. For each criterion, derive exactly one test from its EARS pattern:
   - WHEN: an action test. Perform the trigger, assert the response.
   - WHILE: a state or fault-injection test. Put the system in the state
     (for example, stop a service), assert the behavior, restore.
   - IF: an invalid-input or failure test. Cause the condition, assert the
     rejection or recovery.
   - Ubiquitous THE ... SHALL: an invariant check across the other tests.
   - WHERE: run only if the feature is present; otherwise record skipped.
3. Write the plan as a table: criterion, test steps, expected, actual,
   result. Show it before running if the author or developer is present.
4. Run against a local stack started per AGENTS.md. Use the real API paths
   from AGENTS.md gotchas. Record actual output, not a summary of it.
5. Post the table as a PR comment and tick the EARS coverage checklist in
   the PR template.
6. For any failure, either the developer fixes it on the branch, or the
   criterion was wrong; in that case propose the amended line and let the
   author change `requirements.md`. Never silently edit a criterion.

## Done when

Every criterion has a test, every test has a recorded result, and the PR
comment would let a reviewer see exactly what was checked.
