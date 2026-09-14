# ADR 0001: Agent-Agnostic Repository Layout

Status: proposed
Date: 2026-09-14

Skills and personas live in a vendor-neutral folder, `.agents/skills/`. Tools
that read that folder natively use it directly. Tools that do not get a thin
adapter with zero unique content. Claude Code is the one tool on the team that
needs an adapter today, and it gets a single directory symlink. Personas are skills
rather than subagents. This record explains why, what we checked, and what to
watch for.

## Context

The kickoff set agent-agnostic tooling as the first goal. The team uses Claude
Code and GitHub Copilot, with at least one teammate on Windows and IntelliJ.
The stated principle was that the generic specification is canonical and
Claude adapts to it, not the other way round. We had already applied that with
`AGENTS.md` as the source of truth and `CLAUDE.md` as a two-line file that
imports it.

The first draft of the collaboration layout put shared skills under
`.claude/skills/`. It worked technically, because Copilot and Codex cross-read
that folder. But it inverted the principle: the canonical copy sat in one
vendor's folder and every other tool accommodated it. To a Copilot-only
teammate the repo would read as a Claude project that Copilot tolerates. The
team challenged the draft on exactly this point, and the challenge was right.

## What we verified

We checked vendor documentation on 2026-09-14 for where each tool discovers
project-level skills.

| Tool | Reads `.agents/skills/` | Notes |
|---|---|---|
| Copilot cloud agent, CLI, VS Code, JetBrains | Yes, natively | Also reads `.github/skills/` and `.claude/skills/`. JetBrains support is public preview and must be enabled under Settings, GitHub Copilot, Chat, Agent. |
| Codex | Yes, natively | Scans `.agents/skills/` from the working directory up to the repo root. |
| Claude Code | No | Reads only `.claude/skills/`. No setting adds paths. Per-skill symlinks inside that folder are documented as supported and deduplicated. |

Two further facts shape the decision.

Claude Code does not read `AGENTS.md`. Its documentation recommends a
`CLAUDE.md` that starts with `@AGENTS.md`, which is what the repo already has.
The skills adapter follows the same pattern.

There is no neutral discovery path for agents or personas. Copilot custom
agents live in `.github/agents/*.agent.md`. Claude subagents live in
`.claude/agents/*.md`. Both formats require `name` and `description` in
frontmatter and treat `tools` as optional. VS Code also reads `.claude/agents/`,
but that is a vendor folder again and is not confirmed for JetBrains or the
cloud agent.

## Decision

1. Canonical skills and personas live in `.agents/skills/<name>/SKILL.md`,
   following the Agent Skills open standard.
2. The Claude Code adapter is a single symlink: `.claude/skills` points at
   `.agents/skills`. The adapter carries no content, and adding a skill to
   the neutral folder needs no further step for any tool. Directory-level
   symlinks are not documented by Claude Code, only per-skill ones are, but
   this was verified working on Claude Code 2.1.271 on 2026-09-14 with a
   headless run that discovered and invoked a skill through the link. If a
   future Claude Code release stops following it, fall back to one symlink
   per skill, created by a one-line script.
3. Personas are skills, not subagents. A persona skill says what to read
   first, what to produce, and what done means for that role.
4. No `.github/copilot-instructions.md` is added unless the JetBrains check
   shows `AGENTS.md` is not picked up there. Copilot reads `AGENTS.md`
   natively in its other surfaces.
5. GitHub issue and pull request templates stay in `.github/`. They configure
   the tracker, not an agent, and any tool on the team can create issues
   through the CLI.

The rule in one sentence: nothing canonical lives in a vendor folder, vendor
folders hold only adapters with zero unique content, and adding a tool means
adding an adapter, never rewriting content.

## Alternatives considered

**Keep `.claude/skills/` canonical and let other tools cross-read it.**
Rejected. It works today but inverts the team principle and depends on other
vendors continuing to accommodate one vendor's folder name. It also signals
the wrong thing to the half of the team not using Claude.

**Neutral folder plus committed copies and a sync script.** Rejected for now.
Copies drift unless a script or CI check enforces them, and that is more
plumbing than a three-day hackathon should carry. It remains the fallback if
symlinks prove troublesome.

**Personas as subagents with adapters in both vendor folders.** Rejected. A
symlinked adapter into `.github/agents/` checks out as a plain text file on a
Windows machine without symlink support. Copilot silently skips files whose
frontmatter is invalid, so the Windows teammate would get no personas and no
error. Avoiding that means committed copies in two folders, with the drift
problem above. Personas as skills need no adapter beyond the one already
planned, because Copilot reads the neutral folder directly on every platform.

The trade-off accepted with the last point: a persona skill runs in the main
session rather than in a separate context window. On this team each role is a
different person in a different session on a different machine, so isolation
comes for free. If one person later wants to chain roles in a single session,
subagent adapters can be added then.

## Consequences

Easier: one place to author a skill, one place to review it, and a layout that
tells a new tool exactly where to look. Adding Codex, Cursor, or Gemini CLI
costs nothing if they read the neutral folder, and one adapter if they do not.

To verify on Tuesday, 2026-09-15:

- On the Windows and IntelliJ machine, confirm the Agent Skills preview toggle
  is on and Copilot discovers the neutral folder. Confirm `AGENTS.md` is
  picked up.
- On a Mac, confirm Copilot does not list each skill twice when it sees both
  the neutral folder and the Claude symlinks. The documentation does not state
  precedence. If it double-lists, the fallback is to gitignore the Claude
  symlinks and create them with a one-line setup command.
- Confirm that a Windows checkout turns the symlink into a small text file
  that contains a path, which Copilot ignores because it is not a directory
  with a `SKILL.md` inside.

AGENTS.md gets a short repository-layout section stating: new skills and
personas go in `.agents/skills/` only; no adapter step is needed for Claude
Code because `.claude/skills` is a directory symlink; after a Claude Code
upgrade, run a quick check that skills still list. This is the single place a
contributor learns the rule, so the knowledge does not live only in this
record.

To revisit: whether personas need separate context windows once the team runs
more than one role per session, and whether a neutral agents folder appears in
vendor tooling that would let personas become subagents without adapters.

## Sources

- [Adding agent skills for GitHub Copilot](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/add-skills)
- [Custom agents configuration for GitHub Copilot](https://docs.github.com/en/copilot/reference/custom-agents-configuration)
- [Copilot CLI and agentic enhancements in JetBrains IDEs, 2026-06-02](https://github.blog/changelog/2026-06-02-introducing-copilot-cli-and-agentic-capabilities-enhancements-in-jetbrains-ides/)
- [Codex skills documentation](https://developers.openai.com/codex/skills)
- [Agent Skills: adding skills support to a client](https://agentskills.io/client-implementation/adding-skills-support)
- [Claude Code skills](https://code.claude.com/docs/en/skills.md)
- [Claude Code subagents](https://code.claude.com/docs/en/sub-agents.md)
- [Claude Code memory and AGENTS.md](https://code.claude.com/docs/en/memory.md)
