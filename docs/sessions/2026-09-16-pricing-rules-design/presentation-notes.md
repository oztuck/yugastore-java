# Presentation notes: designing with an agent through an interview

Material for the Friday demo. The story is the collaboration; the proof is
`specs/pricing-rules-without-redeploy/design.md`.

## One-line pitch

The agent did not write the design and ask for approval. It proposed,
interviewed, taught when asked, recorded every decision, and only then wrote
the document, so the design.md reflects the author's choices, not the
agent's assumptions.

## Shape of the session

| Phase | Turns | What the human did | What the agent did |
|---|---|---|---|
| Set-up | 1 | Asked to redo the design from scratch and capture the collaboration | Rebased the old branch, cut a clean branch, read the code, opened a session folder |
| Round 1 | 3 questions | Chose the direction, the capture location, and the priority (the demo) | Restated the old design as a starting proposal |
| Round 2 | 4 questions | Picked polling, a circuit breaker, and three diagram types. Asked to brainstorm the price shape | Paused the decision instead of defaulting |
| Round 3 | brainstorm | Chose option A after reading the trade-offs | Explained how prices flow today, laid out three options and a hybrid, wrote a comparison table |
| Round 4 | 4 questions | Decided four choices with no criterion behind them | Asked "why must it work this way" on each instead of deciding silently |
| Sign-off | 2 questions | Approved the Validated Direction; chose which tracker steps to run | Wrote the summary first, files second |
| Writing | 0 | | Wrote design.md, tasks.md, ran the convention checks, found a spec drift, fixed it and logged it |

Fourteen questions in total. Every one is in `interview-log.md` with the
answer as given.

## Moments worth showing

1. **"I want to brainstorm more on this."** The agent had recommended an
   option. The author asked to understand first. The agent explained the
   current code path and the consequences of each option, and the author
   then chose the recommended one with reasons on record. Show the
   comparison table.
2. **Choices with no criterion.** The listing-page gap came from reading the
   `product_rankings` table, not from the spec. The skill made the agent
   raise it rather than paper over it.
3. **The check caught real drift.** The spec on `master` was missing a
   criterion that the previous design had added on a branch. The mapping
   check found it, the agent traced why, and the fix is dated and logged.
4. **Diagrams as a design choice.** The author picked which diagram types
   the document should carry. The agent produced a service map, four
   sequence diagrams, and a class diagram, all top-down and light-themed
   per the spec convention.

## Before and after

- Before: one branch, a design written in one pass and reviewed afterwards
  in Proof, with decisions scattered across commit messages.
- After: a clean branch, a design written after a fourteen-question
  interview, with a validated direction the author signed, a chronological
  log, and a table of rejected alternatives that reads like minutes.

## Files to open during the demo

1. `docs/sessions/2026-09-16-pricing-rules-design/interview-log.md`, round 3
2. `docs/sessions/2026-09-16-pricing-rules-design/validated-direction.md`
3. `specs/pricing-rules-without-redeploy/design.md`, service map and
   scenario 4
4. `specs/pricing-rules-without-redeploy/tasks.md`

## Honest caveats

- The spec is still `proposed` on `master` and overlaps spec #1. The design
  stands on its own, but nothing merges until the team reconciles them.
- The agent's starting proposal was shaped by the earlier design. A truly
  cold start would have taken more rounds.
