---
name: design-spec
description: Produces design.md and tasks.md for an accepted spec on a feature branch, after validating the approach with the requirements author. Use when a developer picks up a story, "design this", "plan the implementation", or "break this into tasks". Reads requirements.md and the codebase; every task traces to an EARS criterion.
---

# design-spec

You are the developer at the Design stage of `docs/process/collaboration.md`.
The file shapes and rules are in `docs/process/spec-convention.md` (sections
`design.md` and `tasks.md`); read those sections first and follow them exactly.

## Steps

1. Read `specs/<slug>/requirements.md`. Refuse to proceed if `status:` is
   not `accepted`; say who needs to flip it (whoever owns priorities that
   day, per the status lifecycle).
2. Read the services the criteria name. Start from the AGENTS.md architecture
   table, then the controller, repository, and config for each.
3. Unless the requirements already specify the approach, invoke the 
   `design-interview` skill to collaboratively validate the design approach
   with the requirements author. Carry its Validated Design Direction (Approach,
   Key Constraints, Technology Decisions, Open Questions) into step 5 below.
4. Create the branch: `git checkout -b <slug> master`.
5. Write `specs/<slug>/design.md` using the template in spec-convention.md:
   approach, touchpoints, data, criteria mapping, open questions, rejected
   alternatives. Any change with no criterion behind it goes under open
   questions, not into the plan. Incorporate the Approach and Technology
   Decisions from the design-interview (if run), and carry over Open Questions
   and Rejected Alternatives as-is.
6. Write `specs/<slug>/tasks.md` using the template in spec-convention.md:
   numbered, one commit each, each naming the criteria it serves in
   parentheses.
7. Check both files against the rules in spec-convention.md before
   committing:
   - Every acceptance criterion has a row in the criteria mapping.
   - Every touchpoint row traces to at least one criterion.
   - Every criterion appears in at least one task.
   - Every task is small enough to be one commit.
   If any check fails, fix the file and run the checks again. Only proceed
   when all pass.
8. Set `status: in-progress` in `requirements.md`. Regenerate
   `specs/README.md` as a table of every spec folder with title, status, and
   issue, read from each `requirements.md`. Commit all three files:
   `docs: design spec <slug>`.
9. Update the tracker issue named on the `issue:` line with `gh issue edit`:
   add the label `in-progress`, and append the task list to the body as
   GitHub task checkboxes (`- [ ] 1. ...`) so progress shows on the issue.
10. If open questions remain, post them as a comment with `gh issue comment`
   and stop. Do not start building until the author answers.

## Done when

Every criterion is mapped, every task traces, and open questions are empty
or explicitly deferred with the author's agreement recorded in the issue.
