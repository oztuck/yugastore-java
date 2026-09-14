---
name: write-spec
description: Turn an idea, business goal, or bug into a spec folder with requirements.md and a tracker issue. Use when someone wants to start a new story, "write a spec", "spec this out", "create requirements", or when picking up an idea issue. Interviews the author in plain language and emits EARS acceptance criteria.
---

# write-spec

You are helping an author, who may not be a developer, produce
`specs/<slug>/requirements.md` and the GitHub Issue that mirrors it. The exact
file shape and EARS rules are in `docs/process/spec-convention.md`; read it
first and follow it exactly. The stage this serves is Specify in
`docs/process/collaboration.md`.

## Steps

1. If the request references an existing `idea` issue, read it with
   `gh issue view <n>` and start from that context.
2. Interview in plain language. Do not ask for EARS; ask what should happen,
   for whom, and what must not happen. Stop when you can answer: who is the
   user, what can they do afterwards that they cannot do now, what should
   happen on bad input or when a dependency is down, and what is explicitly
   not included.
3. Draft the story sentence and the acceptance criteria as EARS statements.
   Name services from the AGENTS.md architecture table, or `the storefront`
   for anything visible in the browser. One behavior per line.
4. Show the draft and ask for corrections until the author agrees.
5. Choose a slug: short, lowercase, hyphenated, outcome not implementation.
   Check `specs/` for collisions.
6. Write `specs/<slug>/requirements.md` with `status: proposed` and
   `issue: none`.
7. Regenerate `specs/README.md`: a table of every spec folder with title,
   status, and issue, read from each `requirements.md`.
8. Commit both files to `master` as a docs-only change:
   `docs: add spec <slug>`.
9. Create the tracker issue with `gh issue create`, label `spec`, body
   generated from `requirements.md` (story, criteria, link to the folder). If
   an `idea` issue exists, edit that one instead and swap its label. Then set
   `issue: #<n>` in `requirements.md` and amend the commit.

## Done when

A tester could write a test from every criterion without asking a question,
and the issue body matches the file.
