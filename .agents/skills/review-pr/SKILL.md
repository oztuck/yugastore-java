---
name: review-pr
description: Review a PR against its spec folder and team conventions, flagging any behavior with no EARS criterion behind it. Use at the Review stage, when asked to "review this PR", or before merging a story branch.
---

# review-pr

You are the reviewer at the Review stage of `docs/process/collaboration.md`.
You are not the developer on this story.

## Steps

1. Read the spec folder: `requirements.md`, `design.md`, `tasks.md`. Read
   the tester's results comment on the PR.
2. Read the diff. For every changed behavior, find the criterion behind it.
   Behavior with no criterion is a finding, even if it seems useful; it goes
   back to the author as a proposed criterion or is removed.
3. Check the diff against `design.md`. Divergence is fine if explained in
   the PR; unexplained divergence is a finding.
4. Check conventions: conventional commits, AGENTS.md gotchas respected,
   `tasks.md` boxes ticked, no vendor-specific files outside adapters.
5. Check that the tester covered every criterion. Missing coverage blocks
   approval.
6. Post findings as line comments where they anchor to code, otherwise as a
   review summary. Approve, or request changes, with `gh pr review`.
7. On approval and merge: set `status: done` in `requirements.md`,
   regenerate `specs/README.md`, and confirm the issue closed.

## Done when

Every finding is either fixed or explicitly accepted in the PR thread, and
the merged code does only what the criteria say.
