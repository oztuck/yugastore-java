# Agentic Team Collaboration

How a piece of work moves from idea to done on this project, and how humans
and AI agents share context along the way. This is the playbook that every
teammate and every agent reads. If a step here does not match what actually
happens, fix this document, not the habit.

Related: [spec-convention.md](spec-convention.md) for how a spec is written, [AGENTS.md](../../AGENTS.md) for how to build and run the app, and `docs/decisions/` for why things are the way they are.

## The problem this solves

Individual AI use is easy. One person, one session, one head holding all the
context. Team AI use breaks because the author's *why*, the developer's *how*,
and the tester's *what to verify* never land in one place that every agent
reads. Handoffs lose information, each person re-explains the project to their
own tool, and three people end up with three private processes.

The fix is to make the repository the team's shared brain. Every artifact any
role's agent needs is a markdown file in git with a defined lifecycle, and
every role's agent is pointed at the same files.

## Principles

1. **The repo is the shared memory.** If it is not in git, agents cannot see
   it. Specs, decisions, conventions, and learnings all live here in markdown.
2. **One artifact per story.** The spec folder is the single source of truth
   for a piece of work. Nothing about the work is written anywhere else and
   then copied in.
3. **Agent-agnostic by construction.** Nothing canonical lives in a vendor
   folder. Vendor folders hold only adapters with zero unique content. Adding
   a tool means adding an adapter, never rewriting content. See
   `docs/decisions/0001-agent-agnostic-layout.md`.
4. **One loop, defined handoffs.** Every story moves through the same stages.
   Each stage has an owner, an input, an output, and a definition of done.
5. **GitHub Issues track, GitHub PRs review.** Issues mirror the spec while they are open, and the spec is the source of truth. The write-spec skill generates the issue body from `requirements.md` and re-syncs it whenever the requirements change, one direction only, so the two cannot drift. Issues labeled `idea`, `spike`, or `chore` need no spec folder, so planning notes and future thoughts have a home. PRs hold code review and test evidence. Every tool on the team can read and write both from a shell.
6. **Write back what you learn.** Anything that cost more than ten minutes to
   figure out goes into the shared docs so the next agent does not rediscover
   it. AGENTS.md holds only what every session needs: build, run, repository layout, and the few gotchas that break the build. It stays under roughly 150 lines; past that, split content out and link to it. Role-specific guidance goes into the relevant skill, setup detail goes into `docs/setup/`, process friction goes here, and decisions go in `docs/decisions/`.
7. **Spend tokens on the task, not on re-explaining.** Keep always-loaded
   context short, load detail on demand through skills, and prefer recaps
   over raw transcripts.

## Roles

A role is a hat, not a person. One person may wear several across a day, but
never two on the same story at the same time. Each role has a matching
persona skill under `.agents/skills/` that tells an agent how to behave when
wearing that hat.

| Role      | Optimizes for                                                 | Produces                                |
| :-------- | :------------------------------------------------------------ | :-------------------------------------- |
| Author    | A clear, testable statement of intent                         | `requirements.md` and the tracker issue |
| Developer | Working code that satisfies the requirements and nothing more | `design.md`, `tasks.md`, branch, PR     |
| Tester    | Evidence that every acceptance criterion holds                | Test plan and results on the PR         |
| Reviewer  | Design fit, convention fit, no unrequested behavior           | Review on the PR                        |

Anyone can be the author, including non-developers. The reviewer is never the
developer on the same story. On a small team the tester usually wears the
reviewer hat too.

## The spec folder

Every story is one folder: `specs/<slug>/`. The slug is short, lowercase, and
hyphenated, for example `specs/pricing-write-path/`. It contains three files,
added in order by the stages below.

| File              | Written by | Contains                                                                                                     |
| :---------------- | :--------- | :----------------------------------------------------------------------------------------------------------- |
| `requirements.md` | Author     | Status line, one-line user story, EARS acceptance criteria                                                   |
| `design.md`       | Developer  | How the change fits the architecture, services and tables touched, open questions flagged back to the author |
| `tasks.md`        | Developer  | Ordered checklist of small tasks, each traceable to an EARS line and mappable to a commit                    |

The first line of `requirements.md` is a status: `proposed`, `accepted`,
`in-progress`, `done`, or `dropped`. Because requirements are committed to
`master` as soon as they are written,&#x20;

this line is how anyone sees the queue without checking out a branch. The second line is `issue: #NN`, linking the tracker issue once it exists; the issue label always reflects the status line, never the other way round.

One issue per story. `tasks.md` is the developer checklist inside that story, and tasks map to commits, not to issues. Never open sub-issues per task. The design-spec skill mirrors the checklist into the issue body as GitHub task checkboxes so progress is visible without opening the branch.

Specs are permanent. A `done` spec stays in place as the living documentation of that feature. A `dropped` spec moves to `specs/archive/` so the main folder shows only live and shipped work. `specs/README.md` holds a generated index of slug, status, and issue so the folder stays browsable. Revisit archiving `done` specs if the folder passes twenty entries.

See [spec-convention.md](spec-convention.md) for the exact shape of each file.

## The loop

```
 0 Idea ──► 1 Specify ──► 2 Design ──► 3 Build ──► 4 Verify ──► 5 Review ──► Done
```

### 0. Idea

* **Owner:** Anyone.

* **Input:** A hunch, a business goal, a bug report, or a question from the daily sync.

* **How:** Open a GitHub Issue labeled `idea` in plain language, or raise it at the daily sync and have someone open it. Optionally run the `explore-idea` skill: it talks the idea through with you, asks clarifying questions, and can produce either a draft `requirements.md` or a throwaway prototype for a demo. This is the prototyping agent from the kickoff, scoped down. The skill is optional and will be built only if the first two stories leave time.

* **Output:** An `idea` issue with enough context for an author to pick it up.

* **Done when:** Someone takes the author hat and starts Specify. Ideas that nobody picks up stay open under the `idea` label until closed at a sync.

### 1. Specify

* **Owner:** Author.

* **Input:** An idea, a business goal, or a bug.

* **How:** Run the `write-spec` skill. It interviews you in plain language,
  writes `specs/<slug>/requirements.md` with the user story and EARS
  criteria, commits that one file to `master` as a docs-only change, and as its final act creates the GitHub Issue. The issue body is generated from `requirements.md`: the user story, the EARS criteria, and a link to the folder. If the work started as an `idea` issue, the skill attaches to that issue and relabels it instead of opening a new one, so the history stays in one place. The skill writes the resulting `issue: #NN` line back into `requirements.md`.

* **Output:** `requirements.md` on `master` with status `proposed`. Issue
  labeled `spec`.

* **Done when:** Every acceptance criterion is an EARS statement naming a
  service from the AGENTS.md service table, and a tester could write a test
  from each line without asking a question. The team, or whoever owns
  priorities that day, flips the status to `accepted`.

### 2. Design

* **Owner:** Developer, in conversation with the requirements author.

* **Input:** An `accepted` requirements file.

* **How:** Create a branch named after the slug. Run the `design-spec` skill,
  which invokes `design-interview` to align with the author on design approach,
  constraints, and technology choices, then reads the codebase and drafts 
  `design.md` and `tasks.md` in the same folder. Any design choice with no 
  EARS line behind it is listed under open questions in `design.md` and raised 
  with the author before building.

* **Output:** `design.md` and `tasks.md` committed on the branch. Status flipped to `in-progress`. Issue labeled `in-progress`, with the `tasks.md` checklist mirrored into the issue body as task checkboxes. The developer ticks boxes in `tasks.md`; the skill re-syncs them to the issue.

* **Done when:** Every task traces to at least one EARS line, and the open
  questions list is empty or explicitly deferred with the author's agreement.

### 3. Build

* **Owner:** Developer, wearing the `persona-dev` skill.

* **Input:** The spec folder.

* **How:** Work through `tasks.md` in order, checking off tasks as they land.
  Follow AGENTS.md for build and run. Keep commits small and conventional.

* **Output:** A PR against `master` using the PR template, linking the issue
  and the spec folder. Issue labeled `needs-test`.

* **Done when:** All tasks are checked, the build passes with
  `./mvnw -DskipTests -Dexec.skip=true package`, and the PR description
  states which EARS lines the change satisfies.

### 4. Verify

* **Owner:** Tester, wearing the `persona-tester` skill.

* **Input:** `requirements.md` and the PR diff.

* **How:** Run the `test-plan` skill. It produces one test per EARS line,
  choosing the test type from the pattern: WHEN lines become action tests,
  WHILE lines become state or fault-injection tests, IF lines become
  invalid-input tests. Execute the plan against a running local stack.

* **Output:** The test plan and results posted as a PR comment, with the
  EARS coverage checklist in the PR template filled in.

* **Done when:** Every EARS line has a test, every test has a recorded
  result, and any failure is either fixed or written back into
  `requirements.md` as a new or amended criterion.

### 5. Review

* **Owner:** Reviewer, wearing the `persona-reviewer` skill.

* **Input:** The PR, the spec folder, and the tester's comment.

* **How:** Run the `review-pr` skill. It checks the diff against `design.md`
  and the conventions in AGENTS.md, and flags any behavior in the diff that
  has no EARS line behind it.

* **Output:** An approving review, or change requests on the PR.

* **Done when:** The review is approved and the PR is merged. Status flipped
  to `done`. The merge closes the issue.

## Handoff contract

A handoff is complete only when the receiver can start without asking the
sender a question. If a receiver has to ask, the answer goes into the spec
folder, not into a chat message, so the next handoff does not need the same
question.

| From      | To        | The artifact                         | The signal                  |
| :-------- | :-------- | :----------------------------------- | :-------------------------- |
| Author    | Developer | `requirements.md` on `master`        | Status `accepted`           |
| Developer | Developer | `design.md` and `tasks.md` on branch | Status `in-progress`        |
| Developer | Tester    | Open PR linking issue and spec       | Label `needs-test`          |
| Tester    | Reviewer  | Test results comment on PR           | Coverage checklist filled   |
| Reviewer  | Everyone  | Approved and merged PR               | Status `done`, issue closed |

## Shared context: where things live

| What                                  | Where             | Read by                                     |
| :------------------------------------ | :---------------- | :------------------------------------------ |
| How to build and run                  | `AGENTS.md`       | every agent, every human                    |
| How the team works                    | `docs/process/`   | every agent, every human                    |
| Why things are this way               | `docs/decisions/` | humans mostly, agents when asked why        |
| Skills and personas                   | `.agents/skills/` | every agent, natively or through an adapter |
| Requirements, design, tasks per story | `specs/<slug>/`   | everyone                                    |
| Story status and links                | GitHub Issues     | everyone                                    |
| Code review and test evidence         | GitHub PRs        | everyone                                    |
| Meeting transcripts and recaps        | `.transcripts/`   | humans, agents when asked for history       |
| Environment setup for humans          | `docs/setup/`     | humans, especially new joiners              |

## Working across tools

The team uses Claude Code and GitHub Copilot today. Both read `AGENTS.md`
and both discover skills. The only tool-specific files in the repo are
adapters: `CLAUDE.md` imports `AGENTS.md`, and `.claude/skills/` contains
symlinks into `.agents/skills/`. If you add a tool, add its adapter and
nothing else.

Each role in the loop is typically a different person in a different
session, so context isolation between roles comes for free. Do not chain
roles inside one session on one story; start a fresh session when you change
hats.

## Token discipline

* `AGENTS.md` and this document stay short and point to detail rather than
  containing it.

* Skills load only when triggered. Put reference material inside the skill
  folder, not in always-loaded instruction files.

* Agents read recaps, not raw transcripts, unless asked for a specific quote.

* During the hackathon, note the token or premium-request cost of each loop
  stage so we have a real number by Friday.

## What this does not cover

Deployment, containers, and the monitoring agent are out of scope for this
document. They are tracked as stretch goals in the kickoff recap and will get
their own process notes if they land.
