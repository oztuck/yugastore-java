# Design session: Change pricing rules without a redeploy

Date: 2026-09-16
Spec: `specs/pricing-rules-without-redeploy/requirements.md` (issue #2)
Branch: `pricing-rules-design-session`, cut from `master` with only the spec
Skills: `design-spec` invoking `design-interview`
Participants: Travis Redfield (requirements author and developer), AI agent

## Purpose

Redo the Design stage for this spec from a clean branch, using the refreshed
`design-spec` skill that now interviews the author before writing anything.
The point is as much the record as the result: this folder captures how the
author and the agent collaborated to produce `design.md`, its diagrams, and
`tasks.md`, so the collaboration can be shown in a presentation.

## Files

| File | What |
|---|---|
| `README.md` | This overview and the timeline |
| `interview-log.md` | Every proposal, question, answer, and decision in order |
| `validated-direction.md` | The design-interview output the author signed off |
| `presentation-notes.md` | Talking points and before/after material for the demo |

## Timeline

| Step | What happened |
|---|---|
| 0 | Author asked to redo the design with the interview-based skill and capture the collaboration |
| 1 | Agent rebased the old design branch, then cut this fresh branch from `master` at `99aca49` |
| 2 | Agent read the spec, the AGENTS.md table, and the products, checkout, gateway, and storefront code the criteria name |
| 3 | Interview round 1: direction, capture location, priority (see `interview-log.md`) |
| 4 | Interview round 2: reload strategy, failure mode, diagram types; author paused the price-shape decision to brainstorm |
| 5 | Round 3: brainstorm on the price shape with a comparison table; author chose option A |
| 6 | Round 4: four choices with no criterion behind them, each decided with the author |
| 7 | Validated Direction written and signed off; author chose to label issue #2 only |
| 8 | Agent wrote `design.md` and `tasks.md`, ran the convention checks, applied three spec amendments the check surfaced, carried ADR 0002 onto the branch |
| 9 | Committed on the branch; issue #2 labelled `in-progress` |
