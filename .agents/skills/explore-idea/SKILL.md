---
name: explore-idea
description: Talk a hunch, business goal, bug report, or sync question into either an idea issue or a throwaway demo prototype. Use at the Idea stage, when asked to "explore an idea", "think this through", "spike this", or "mock this up for a demo", before a spec exists.
---

# explore-idea

You are at the Idea stage of `docs/process/collaboration.md`, before any spec
folder exists. This skill is optional and lighter weight than `write-spec`:
it is for thinking an idea through, not for producing acceptance criteria.
If the author already knows the shape of the story well enough for EARS
criteria, skip this and go straight to `write-spec`.

## Steps

1. Ask what triggered the idea: a hunch, a business goal, a bug, or a
   question from the daily sync. Talk it through in plain language — what
   problem does it solve, who feels the problem today, why now, and how big
   a swing is this (a tweak, a new capability, a rethink). Do not push for
   EARS statements or a service name yet; that is `write-spec`'s job.
2. Ask which output the author wants:
   - An **idea issue**, for someone (possibly someone else) to pick up later.
   - A **draft for write-spec**: a rough story and candidate acceptance
     signals, still unrefined, to save the author's next `write-spec` session
     a cold start.
   - A **throwaway prototype**: working code for a demo, not meant to ship.
3. For an idea issue or a write-spec draft: capture the discussion as a
   short brief — the problem, who it affects, why now, and any rough
   direction the author already has in mind. Do not write EARS criteria;
   that format is reserved for `requirements.md` under `write-spec`.
4. Create the issue with `gh issue create --label idea`, body set to the
   brief from step 3. If it is a write-spec draft, say so explicitly in the
   issue body (for example, "Draft for write-spec: ...") so the next session
   knows to run `write-spec` and attach to this issue rather than opening a
   new one.
5. For a throwaway prototype: build the smallest thing that lets the idea be
   demoed or judged — a script, a stub endpoint, a UI mockup. Work on a
   scratch branch named `spike/<short-name>`, never `master`. Say up front
   that none of this code is expected to survive; it exists to inform a
   decision, not to be reviewed or merged.
6. After a demo, either open an idea issue capturing what was learned (the
   prototype itself is not the record, the issue is), or delete the scratch
   branch if the idea is dropped. Never leave a spike branch as the only
   record of a decision.
7. Do not create a `specs/<slug>/` folder or a `requirements.md` from this
   skill. That folder and file are owned by `write-spec`; this skill only
   feeds it a warmer start.

## Done when

Either an `idea` issue exists with enough context for an author to run
`write-spec` from it without asking a question, or a prototype was demoed and
its outcome (adopt, adjust, drop) is recorded on an issue.
