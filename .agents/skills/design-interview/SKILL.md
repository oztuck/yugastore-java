---
name: design-interview
description: Collaboratively interview the requirements author to validate design approach and decisions before design.md is written. Use when you need to align with the human on design choices, priorities, and constraints. Ensures design direction is agreed upon.
---

# design-interview

You are facilitating a collaborative design conversation between yourself (the
agent) and the requirements author. The goal is to understand and document the
human's design priorities, constraints, and preferences so that the design.md
reflects agreed-upon decisions, not agent-only choices.

Read `docs/process/spec-convention.md` and `docs/process/collaboration.md`
first to understand the design stage and file shapes.

## Steps

1. Read `specs/<slug>/requirements.md` and understand the acceptance criteria.
2. Skim the services and files mentioned in the requirements. Do not deeply
   read the codebase; just orient yourself on what exists.
3. Propose an initial design approach (2-3 sentences: what changes, which
   services, why this direction). Say "Here's what I'm thinking..." and ask
   if this aligns with their intent.
4. Interview the author on design decisions. Ask about:
   - **Priorities**: Performance, simplicity, consistency with existing patterns,
     or something else?
   - **Constraints**: Budget, timeline, team skills, deployment windows, data
     residency, or compliance?
   - **Technology**: Any services or tech the author prefers or wants to avoid?
   - **Scale**: Expected load, data volume, or growth assumptions?
   - **Risk**: What could break the feature? What's the acceptable failure mode?
   - **Integration**: Does this touch external systems, other teams, or
     deprecated code that needs a migration strategy?
5. For any significant design choice (new endpoint, schema change, service
   boundary shift), ask: "Why does it need to work this way?" or "What
   happens if we do it differently?"
6. Document the decisions. Create a summary of what was agreed:
   - Initial approach (author-validated)
   - Key constraints or priorities the design must respect
   - Technology choices and why
   - Any risk areas or open questions the author flagged
   - Rejected alternatives the author mentioned
7. Show the summary and ask: "Is this an accurate capture of what we
   discussed?" Refine until the author agrees.

## Output

A clear, documented design direction that the author has explicitly validated.
The summary is ready for design-spec (or another skill) to use when writing
`design.md` and `tasks.md`. Include:

```
## Validated Design Direction

**Approach:** [Author-agreed approach summary]

**Key Constraints:** [What the design must respect]

**Technology Decisions:** [What and why]

**Risk Areas:** [Known hazards or concerns raised]

**Rejected Alternatives:** [What was considered and dismissed, and why]

**Open Questions:** [Anything that needs author input before building]
```

## Done when

The author explicitly agrees that the summary is accurate, and you have
clarity on at least:
- The main design direction
- The 1-2 most important constraints or priorities
- Any technology choices that differ from the default pattern
- Open questions, if any
