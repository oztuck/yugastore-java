# Spec Convention

The exact shape of a spec folder. The playbook in
[collaboration.md](collaboration.md) says when each file is written and by
whom; this document says what goes in it. Skills that create or edit specs
follow this file, so if the convention changes, change it here first.

## The folder

Every story is one folder: `specs/<slug>/`.

- The slug is short, lowercase, hyphenated, and describes the outcome, not
  the implementation. `pricing-write-path`, not `add-put-endpoint`.
- The folder holds exactly three files: `requirements.md`, `design.md`,
  `tasks.md`. Supporting material such as diagrams or sample payloads goes in
  a `assets/` subfolder if needed.
- `specs/README.md` is a generated index of every folder with its status and
  issue. Do not edit it by hand; the write-spec and design-spec skills
  regenerate it.
- Dropped specs move to `specs/archive/<slug>/` unchanged. Done specs stay
  where they are as the living documentation of the feature.

## Status lifecycle

```
proposed ──► accepted ──► in-progress ──► done
    │            │
    └────────────┴──► dropped
```

| Status | Set by | Meaning |
|---|---|---|
| `proposed` | Author, via write-spec | Requirements written, not yet agreed |
| `accepted` | Whoever owns priorities that day | Ready for a developer to pick up |
| `in-progress` | Developer, via design-spec | Design and tasks exist on a branch |
| `done` | Reviewer, on merge | Shipped to `master` |
| `dropped` | Anyone, with a one-line reason | Not going ahead; folder moves to archive |

The status line in `requirements.md` is the source of truth. The GitHub Issue
label always follows it, never the reverse.

## requirements.md

Written by the author at the Specify stage. Committed to `master` on its own
as a docs-only change.

```markdown
# <Title in plain language>

status: proposed
issue: #NN

## Story

As a <role>, I want <capability>, so that <outcome>.

## Acceptance criteria

WHEN <trigger> THE <service> SHALL <response>.
WHILE <state> THE <service> SHALL <response>.
IF <unwanted condition> THEN THE <service> SHALL <response>.
THE <service> SHALL <response>.
WHERE <feature is present> THE <service> SHALL <response>.

## Out of scope

- <thing a reader might assume is included but is not>

## Notes

<anything the author wants the developer to know that is not a requirement>
```

Rules:

- The first two lines after the title are `status:` and `issue:`. The
  `issue:` line is `#NN` once the tracker issue exists, or `none` before
  that. Skills parse these lines, so keep the format exact.
- One story sentence. If you need two, you have two specs.
- Every acceptance criterion is an EARS statement. See the patterns below.
- `<service>` is a name from the AGENTS.md service table, or `the storefront`
  for anything the user sees in the browser. Never `the system`.
- Each criterion is one line and one behavior. If a line contains "and", it
  is probably two criteria.
- `Out of scope` is required, even if it says `none`. It stops the developer
  guessing.
- A tester must be able to write a test from each line without asking a
  question. That is the definition of done for this file.

### EARS patterns

| Pattern | Shape | Use it for |
|---|---|---|
| Ubiquitous | THE `<service>` SHALL `<response>` | Always-true behavior with no trigger |
| Event-driven | WHEN `<trigger>` THE `<service>` SHALL `<response>` | A response to an action or event |
| State-driven | WHILE `<state>` THE `<service>` SHALL `<response>` | Behavior that holds for as long as a condition is true |
| Unwanted behavior | IF `<condition>` THEN THE `<service>` SHALL `<response>` | Errors, invalid input, failures |
| Optional feature | WHERE `<feature is present>` THE `<service>` SHALL `<response>` | Behavior that only applies when something is configured or enabled |

The tester's skill picks the test type from the pattern: WHEN lines become
action tests, WHILE lines become state or fault-injection tests, IF lines
become invalid-input tests, ubiquitous lines become invariant checks.

### Worked example

```markdown
# Change a product price without a redeploy

status: proposed
issue: none

## Story

As a merchandiser, I want to change a product's price from an admin call,
so that pricing experiments do not wait on an engineering release.

## Acceptance criteria

WHEN an authorized user submits a new price for an ASIN THE products-microservice SHALL persist it and return the updated product.
WHEN a price is updated THE storefront SHALL show the new price on the next product read.
IF the submitted price is negative or not a number THEN THE products-microservice SHALL reject it with a 400 and a reason.
IF the ASIN does not exist THEN THE products-microservice SHALL respond with a 404.
WHILE the products-microservice is unavailable THE storefront SHALL show the last known price with a stale indicator.

## Out of scope

- Authentication and roles. Any caller is authorized for this story.
- Price history or audit log.
- Bulk updates.

## Notes

The catalog is read-only today and seeded from products.json. This is the
first write path, so expect the design to touch the YCQL schema.
```

## design.md

Written by the developer at the Design stage, on the feature branch.

```markdown
# Design: <same title as requirements.md>

## Approach

<Two to five sentences. What changes, in which services, and why this way.>

## Touchpoints

| Service or file | Change |
|---|---|
| products-microservice | New PUT endpoint on the catalog controller |
| resources/schema.cql | ... |

## Data

<Schema or table changes, if any. Say "none" otherwise.>

## Criteria mapping

| Criterion | How it is satisfied |
|---|---|
| WHEN an authorized user submits a new price ... | PUT /products-microservice/product/{asin}/price |
| ... | ... |

## Open questions

- <Any design choice that has no acceptance criterion behind it. Raise
  each one with the author before building. Delete this section when empty.>

## Rejected alternatives

- <Anything considered and not done, with one line on why.>
```

Rules:

- Every acceptance criterion appears in the criteria mapping. A criterion
  with no row means the design is incomplete.
- Every row in touchpoints traces to at least one criterion. A change with no
  criterion behind it goes to open questions, not into the code.
- Keep it short. The design explains the shape of the change to a reviewer;
  it is not a specification of every method.
- Diagrams are optional and go at the end of Approach. Use Mermaid, laid out
  top-down (`flowchart TB`), since wide left-to-right charts are unreadable in
  editor previews. Start every diagram with the light-theme init directive
  below so it renders on dark editors. Where the story has distinct runtime
  flows, add one `sequenceDiagram` per flow the test plan will exercise.

  ```
  %%{init: {'theme':'base','themeVariables':{'background':'#ffffff','primaryColor':'#eef0ff','primaryBorderColor':'#555','primaryTextColor':'#111','lineColor':'#333','edgeLabelBackground':'#f4f4f4','fontSize':'14px'}}}%%
  ```

## tasks.md

Written by the developer at the Design stage, worked through at Build.

```markdown
# Tasks: <same title>

- [ ] 1. Add price column handling to the products repository (WHEN submit)
- [ ] 2. Add PUT endpoint and validation on the catalog controller (WHEN submit, IF negative, IF 404)
- [ ] 3. Wire the gateway route (WHEN submit)
- [ ] 4. Storefront reads price on product view (WHEN updated)
- [ ] 5. Stale indicator when products service is down (WHILE unavailable)
- [ ] 6. Update AGENTS.md service table if the API surface changed
```

Rules:

- Ordered, numbered, and small enough that each task is one commit.
- Each task names the criteria it serves in parentheses, using the first few
  words of the line. Every criterion appears in at least one task.
- Tick the box in the same commit that lands the task. The design-spec
  skill mirrors this list into the GitHub Issue as task checkboxes and
  re-syncs the ticks.
- Tasks are not issues. Never open a sub-issue for a task.

## What the skills do with these files

| Skill | Reads | Writes |
|---|---|---|
| write-spec | An idea issue, or the author's answers | `requirements.md`, the tracker issue, `specs/README.md` |
| design-spec | `requirements.md`, the codebase | `design.md`, `tasks.md`, issue checkboxes, `specs/README.md` |
| test-plan | `requirements.md`, the PR diff | A PR comment with one test per criterion and results |
| review-pr | The whole folder, the PR diff | A PR review |

If a skill and this document disagree, this document wins and the skill has
a bug.
