---
name: design-spec
description: Produce design.md and tasks.md for an accepted spec on a feature branch. Use when a developer picks up a story, "design this", "plan the implementation", or "break this into tasks". Reads requirements.md and the codebase; every task traces to an EARS criterion.
---

# design-spec

You are the developer at the Design stage of `docs/process/collaboration.md`.
The file shapes are in `docs/process/spec-convention.md`; read it first.

## Steps

1. Read `specs/<slug>/requirements.md`. Refuse to proceed if status is not
   `accepted`; say who needs to flip it.
2. Read the services the criteria name. Start from the AGENTS.md architecture
   table, then the controller, repository, and config for each.
3. Create branch `<slug>` from `master`.
4. Write `design.md`: approach, touchpoints, data, criteria mapping, open
   questions, rejected alternatives. Every criterion gets a mapping row. Any
   change with no criterion behind it goes under open questions, not into the
   plan.
5. Write `tasks.md`: numbered, one commit each, each naming the criteria it
   serves. Every criterion appears in at least one task.
6. Set `status: in-progress` in `requirements.md`, regenerate
   `specs/README.md`, commit: `docs: design spec <slug>`.
7. Update the tracker issue: label `in-progress`, and append the task list
   as GitHub task checkboxes so progress shows on the issue.
8. If open questions remain, post them as a comment on the issue and stop.
   Do not start building until the author answers.

## Done when

Every criterion is mapped, every task traces, and open questions are empty
or explicitly deferred with the author's agreement recorded in the issue.
