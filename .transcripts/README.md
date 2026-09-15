# Transcripts

Raw meeting/session transcripts for this project, kept for reference by both humans and agents.

## Convention

For each recorded session, add two files with the same base name:

- `YYYY-MM-DD-short-title.docx` — the original file as downloaded, untouched.
- `YYYY-MM-DD-short-title.md` — plain-text extraction (`pandoc -t markdown file.docx`), so the content is greppable and readable by agents that can't parse `.docx` directly.

Optionally add a `YYYY-MM-DD-short-title-recap.md` — a distilled summary of the
raw transcript, for quick reference without re-reading the whole thing.

## Index

- [2026-09-14-kickoff-meeting](2026-09-14-kickoff-meeting.md) ([recap](2026-09-14-kickoff-meeting-recap.md)) — Team "Pirate Brown Pants" (Team #2) kickoff: brownfielding Yugastore, agent-agnostic tooling, agentic collaboration, CMS/business-rules gap, no Kubernetes, plain-jar local dev.
- [2026-09-14-collaboration-playbook-review](2026-09-14-collaboration-playbook-review.md) ([recap](2026-09-14-collaboration-playbook-review-recap.md)) — Afternoon working session: Issues enabled, spec-to-issue mirroring, "spec-enabled not spec-driven", PRs for process changes, AGENTS.md to principles with a setup skill, review-pr recommends only, personas as skills.
- [2026-09-15-pricing-rules-feature-discussion](2026-09-15-pricing-rules-feature-discussion.md) ([recap](2026-09-15-pricing-rules-feature-discussion-recap.md)) — Short morning sync: first feature is a CMS for pricing business rules (tag discounts, BOGO) without redeploying; separate rules service vs. write path in products-microservice left open; skip Ideate, go straight to write-spec with this transcript as input.
