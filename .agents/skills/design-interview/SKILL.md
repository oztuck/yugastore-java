---
name: design-interview
description: Interview the requirements author on design priorities, constraints, technology choices, and risks before design.md is written, and return a validated design direction. Use at the Design stage before drafting design.md, when asked to "walk me through the design", "check the approach with me", "what are we optimizing for", or when invoked by design-spec.
---

# design-interview

You are facilitating a collaborative design conversation between yourself (the
agent) and the requirements author. The goal is to understand and document the
human's design priorities, constraints, and preferences so that the design.md
reflects agreed-upon decisions, not agent-only choices.

Read `docs/process/spec-convention.md` and `docs/process/collaboration.md`
first to understand the design stage and file shapes.

## Input

`specs/<slug>/requirements.md` with `status: accepted`.

## When to skip

If the requirements already specify the approach in detail, or the author
says "just design it without a discussion", collapse step 3 (propose, confirm)
and stop. Small stories with a clear path do not need a full interview.

## Steps

1. Read `specs/<slug>/requirements.md` and understand the acceptance criteria.
2. If you have not already read them, skim the services and files mentioned in
   the requirements enough to understand what exists. If you are invoked by
   `design-spec`, reuse the codebase context from its step 2 rather than
   re-reading.
3. Propose an initial design approach (2-3 sentences: what changes, which
   services, why this direction). Say "Here's what I'm thinking..." and ask
   if this aligns with their intent.
4. Interview the author on design decisions, one topic at a time in plain
   language. Ask only about topics the requirements leave open. Stop when you
   can answer all three: (1) What is the main approach? (2) What are the 1-2
   most important constraints or priorities the design must respect? 
   (3) Are there technology choices that differ from the default pattern?
   Use these as optional probes only if relevant:
   - **Scale**: Expected load, data volume, or growth assumptions?
   - **Risk**: What could break the feature? Acceptable failure mode?
   - **Integration**: External systems, other teams, or deprecated code needing
     a migration strategy?
5. For any significant design choice (new endpoint, schema change, service
   boundary shift) that has no acceptance criterion behind it, ask: "Why does
   it need to work this way?" or "What happens if we do it differently?"
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
The summary is returned in-conversation (not written to a file) and is ready
for `design-spec` (or another skill) to use when writing `design.md`. The
Approach, Key Constraints, and Technology Decisions sections are mandatory;
the rest may be `none` if not discussed. These sections feed the same-named
sections of `design.md`:

```
## Validated Design Direction

**Approach:** [Author-agreed approach summary]

**Key Constraints:** [What the design must respect]

**Technology Decisions:** [What and why]

**Risk Areas:** [Known hazards or concerns raised; write "none" if not discussed]

**Rejected Alternatives:** [What was considered and dismissed; write "none" if none discussed]

**Open Questions:** [Anything that needs author input before building; write "none" if resolved]
```

## Done when

The author explicitly agrees that the summary is accurate, and you have
clarity on at least:
- The main design direction
- The 1-2 most important constraints or priorities
- Any technology choices that differ from the default pattern
- Open questions, if any
