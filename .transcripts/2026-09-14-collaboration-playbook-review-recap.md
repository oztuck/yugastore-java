# Collaboration Playbook Review Recap — 2026-09-14 (afternoon)

Distilled from [2026-09-14-collaboration-playbook-review.md](2026-09-14-collaboration-playbook-review.md)
(raw transcript, ~2h, heavy side conversation omitted). Speaker attribution
in the raw transcript is unreliable; decisions below are the team's unless
noted.

## Decisions

- **GitHub Issues enabled** on the fork, collaborators only. Discussions not
  enabled.
- **Spec folder is the source of truth; Issues mirror it** so stories are
  readable without opening markdown. Sync is spec-to-issue only. A closed
  issue is frozen and keeps its content as history even if the spec folder
  is later pruned.
- **Issues and specs are not one-to-one.** Backlog items, bugs, and ideas
  live as plain issues. Something becomes a spec only when it is ready to be
  worked. Framed as "spec-enabled, not spec-driven": full features go
  through SDD, two-hour fixes do not.
- **Only spec markdown commits straight to master.** Skills, personas,
  AGENTS.md, and anything that changes the process for others go through a
  PR.
- **Ideation step before Specify**, with an explore-idea skill for shaping
  and prototyping. A tighter "loop inside the loop" to shorten the
  requirements bottleneck was discussed and deferred.
- **Adopt the drafted playbook, spec convention, and ADR as-is and dogfood
  them**, then revise from use. All three reviewed in Proof and pushed.
- **AGENTS.md becomes short and principle-based.** Build and run detail
  moves into a setup skill loaded on demand; architecture stays. Remove the
  link to the raw kickoff transcript so agents do not read it every
  session. AGENTS.md must say that Claude Code needs the symlink adapter so
  a Copilot user adding a skill knows why it exists.
- **Personas are skills.** No separate author persona; write-spec plays
  that role.
- **review-pr recommends, humans approve and merge.**
- Spec archive retention: not worth solving this week.

## Action items

- Travis: publish the Proof skill so teammates can use it. Done (`77d6afa`).
- One teammate: move AGENTS.md setup detail into a setup skill and rewrite
  AGENTS.md to principles. Done (`b1955e2`).
- Skills split across people: write-spec, test-plan, design-spec each owned
  by a different teammate (who took which: unclear in transcript).
- Fix the mangled loop diagram after step 0 was added. Done in `43fbb2a`.
- Link a skill-writing best-practices guide when generating skills (URL not
  captured).

## Open questions

- When does an issue graduate to a spec, and is that manual or agent-driven?
- Commit specs to master at creation, or only when done? Concern that
  incomplete specs confuse automated testing against specs.
- Where do unit tests, as opposed to per-story verification, fit in the loop?
- Are the human-in-the-loop points explicit enough in the playbook?
- Should `docs/` be renamed, since the pre-existing folder holds screenshots?
  Left as-is.
- tasks.md vs Issues: resolved as issue = what, tasks = how; kept.

## Observations

- One teammate on Copilot with Claude models reports much lower token use
  than Claude Code for similar work; interest in tracking usage like another
  team does.
- Proof is open source and self-hostable; mild concern about pushing repo
  docs to a hosted editor, accepted for non-sensitive hackathon content.
- Everyone pushed directly to master on day one, which the new PR rule
  changes going forward.
- The team noted the drafted AGENTS.md contained content "we never talked
  about"; its detail was agent-inferred from the codebase, not team-decided.

## Follow-ups against the committed docs

See the session notes for 2026-09-15: playbook principle 6 and the Review
stage need updating to match the AGENTS.md and review-pr decisions above,
and the PR rule, frozen-issue rule, and spec-enabled framing need adding.
