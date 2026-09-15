# Pricing Rules Feature Discussion Recap — 2026-09-15 (morning)

Distilled from [2026-09-15-pricing-rules-feature-discussion.md](2026-09-15-pricing-rules-feature-discussion.md)
(raw transcript, ~9 minutes). Speaker attribution in the raw transcript is
unreliable; decisions below are the team's unless noted.

## Purpose

Talk through the first feature to take through the spec loop, then feed
this transcript to the write-spec skill and see what it produces.

## The feature: business rules for pricing, not just price edits

- The gap is a **CMS for business rules**, not only editing a product's
  price. Changing a single price could be a direct update to the product
  data; the harder case is pricing *rules* around products: a percentage
  off for items with a given tag, buy-one-get-one, and similar promotions.
- "CMS" here means content management in the loose sense: a way to change
  product and pricing information **without redeploying the whole system**.
- Two shapes were floated, neither chosen:
  1. A separate CMS-like microservice holding the rules (could be as simple
     as JSON or Markdown served independently).
  2. Change products-microservice so product information is no longer
     read-only and supports live updates.
- Either way the live-update process needs designing. There is no
  authorization service, so who may change rules is an open design
  question.
- Lightweight free CMS libraries were mentioned as an option; nobody
  committed to evaluating one. Open whether the app is big enough to
  warrant a library at all.
- A quick prototype was suggested as the way to explore this.

## Process decisions

- **Skip the Ideate stage for this feature.** Ideation is for discovering
  what could be added; this feature is already chosen, so go straight to
  Specify.
- **Docs-only `requirements.md` on master with `status: proposed`**, per
  the spec convention.
- **Feed this transcript to write-spec** as the input for the first spec,
  and treat the run as a test of how that flow works and what needs
  fixing.
- Everyone has been committing straight to master; the team should move to
  branches, but for now speed wins.

## Action items

- Travis: save this transcript into `.transcripts/` and push it. Done.
- Team: run write-spec against this transcript to draft
  `specs/<slug>/requirements.md` for the pricing rules feature.
- Someone (unclear): push the design-spec skill changes. Done (`d872b54`).

## Open questions

- Separate rules microservice, or open a write path in products-microservice?
- What does the live-update process look like end to end?
- How is authorization handled given no auth service exists?
- Is a CMS library warranted, or is a JSON/Markdown rules file enough?
