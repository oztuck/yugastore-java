# Interview log

Chronological record of the design-interview between the requirements author
(Travis) and the agent. Agent turns are summarised; author answers are quoted
as given, lightly trimmed for typos.

## Preconditions the agent flagged

- `design-spec` expects `status: accepted`. The spec is `proposed` on
  `master`. The author is also the requirements owner and asked for the
  redesign, so the agent proceeded and recorded the exception here.
- A prior design exists on branch `pricing-rules-without-redeploy`. The author
  chose not to reuse it so the interview starts from the spec alone.

## Codebase facts the agent gathered before proposing

- `products-microservice` has three GET endpoints on `ProductCatalogController`
  (product by ASIN, paged products, paged products by category). It already
  depends on Eureka client, OpenFeign, and actuator.
- `ProductMetadata` maps to YCQL table `products`; `ProductRanking` maps to
  `product_rankings` and carries its own `price`.
- `checkout-microservice` totals an order in `CheckoutServiceImpl.getTotal` by
  calling products for each ASIN and multiplying `price` by quantity.
- The gateway re-serialises product responses through its own typed
  `ProductMetadata` and `ProductRanking` models, so new fields must be added
  there or Jackson drops them.
- The storefront renders `product.price` in `Products` and `ShowProduct`;
  the cart page sums `price` client-side.
- No service has timeouts, circuit breakers, or fallbacks today.

## Round 1: direction, capture, priority

**Agent proposal.** Restated the shape of the earlier design as a starting
point: new file-driven `pricing-rules-microservice` on 8087, products applies
the largest percent-off rule and keeps `price` as the effective price, base
prices when the rules service is down.

**Q1. Keep that direction or reopen it?**
Author: "I want to go with the new pricing rules microservice, but start over
from scratch with the design so that we can capture the session of
interacting with the design skill."

**Q2. Where should the collaboration record live?**
Author: "Do this work on a new branch so we start from scratch with only the
spec and not the first design. Add a new sub-folder in docs to capture the
session and create info for a presentation to show the collaboration. The
outcome will be both the design.md. I really want to focus on capturing the
collaboration with you on writing the design.md, creating diagrams, etc."

**Q3. Most important thing the design must get right?**
Author: "It's all about the demo and showing the design.md that was written
collaborating with AI. The demo will focus more on the AI collaboration but
the proof will be the design.md produced and showing diagrams, etc."

**Decisions from round 1.**
- Direction: a new `pricing-rules-microservice`. Everything else is open.
- Record: this folder, `docs/sessions/2026-09-16-pricing-rules-design/`.
- Priority: a clear, well-diagrammed `design.md` that demonstrates the
  collaboration. Trade-offs favour legibility over cleverness.

## Round 2: price shape, reload, failure mode, diagrams

**Agent proposal.** The rules service owns loading, validating, and serving
the file. Products is the only consumer that applies rules and keeps `price`
as the effective price, so checkout's existing total is correct unchanged.

**Q4. How should the discounted price reach checkout and the storefront?**
Options offered: (a) `price` becomes the effective price plus `originalPrice`;
(b) keep `price` as base and add `effectivePrice`; (c) checkout also calls the
rules service.
Author: "I want to brainstorm more on this so I better understand."
Agent action: paused the decision and opened a brainstorm (round 3).

**Q5. How should the rules service notice the file changed?**
Author chose: poll file mtime every 5 s. Rejected `WatchService` (flaky on
macOS and mounted volumes) and re-read-per-request.

**Q6. Products behaviour when the rules service is unreachable?**
Author chose: Resilience4j circuit breaker rather than a bare Feign timeout.
Reason recorded by the agent: ties the story to the client's
graceful-degradation goal and gives something visible to demo. Serving
last-known rules rejected because both WHILE criteria say original prices.

**Q7. Which diagrams should design.md carry?**
Author chose: service map flowchart, one sequence diagram per scenario, and a
rules-file schema diagram. Declined the inside-products component diagram.

## Round 3: brainstorm on the price shape

The author asked to understand the price-shape decision before choosing. The
agent laid out how prices flow today and what each option changes.

**How it works today.** Products returns one number, `price`. Three things
read it: the storefront prints it on the list and product pages, the cart
page sums it in the browser, and checkout fetches each product at order time
and multiplies `price` by quantity to write the order total. Nobody else
computes a price.

**Option A: `price` becomes the effective price, plus `originalPrice`.**
Products applies the rule and overwrites `price` with the discounted number,
adding `originalPrice` and `discountPercent` only when a rule matched. Every
existing reader keeps working and sees discounts, including checkout and the
cart page. The storefront changes only to draw the struck-through original.
Cost: `price` no longer means list price; future consumers must know to read
`originalPrice` for the base.

**Option B: `price` stays base, add `effectivePrice`.** Clean semantics, but
every reader must be taught the new field: checkout's total, the cart sum,
two storefront components, and the gateway model. Miss one and the page shows
a discount while checkout charges full price, which is the bug the criteria
exist to prevent.

**Option C: checkout applies rules itself.** Checkout fetches rules and
recomputes. Products still applies them for display, so the applier logic
lives in two services and must agree on rounding, ties, and failure
behaviour. It buys independence from products' output, which no criterion
asks for.

**Hybrid named by the agent.** Option A plus an `appliedRuleId` field so the
fired rule is traceable in order details and in the test plan.

| Option | Services changed | Readers that must change | Risk if one reader is missed | Semantics of `price` |
|---|---|---|---|---|
| A: `price` effective + `originalPrice` | rules (new), products, gateway model, storefront | storefront only, to show the original | none, discount flows by default | effective price |
| A + `appliedRuleId` | as A | as A | none | effective price, traceable |
| B: `price` base + `effectivePrice` | rules (new), products, gateway model, storefront, cart page, checkout | storefront, cart, checkout | discount shown but full price charged | list price |
| C: checkout applies rules too | rules (new), products, checkout, gateway model, storefront | storefront, checkout | two appliers drift on rounding or ties | effective price |

**Q4 revisited.** Author chose: **A, `price` = effective price plus
`originalPrice`**. `appliedRuleId` not adopted; no criterion needs it.

**Q8. Right depth for the record?**
Author: log the explanation as written and add a comparison table for the
presentation. Done above.

## Round 4: choices with no criterion behind them

The skill requires asking about any significant choice the criteria do not
cover rather than deciding silently.

**Q9. Category rules on listing pages.** Listing rows come from
`product_rankings`, which stores only the category being listed, so a product
discounted via Books shows full price on a Gifts listing.
Author chose: accept the gap; the product page is correct. Recorded as a
known gap. Rejected a batched `IN` lookup per page (extra read on the busiest
endpoint) and rejected blocking Build on a team decision.

**Q10. Expose the rules endpoint through the gateway?**
Author chose: service-to-service only. No criterion asks for it; the tester
reads port 8087 directly. The future write-API story adds gateway exposure.

**Q11. Rules file location and shape.**
Author chose: `resources/pricing-rules.json` next to `products.json`, typed
rules (`id`, `type`, `match`, `percent`), unknown types skipped so BOGO can be
added later. Rejected shipping the file inside the module jar (weakens the
no-redeploy story) and a flat untyped file (spec asks for a type field).

**Q12. Tie-break when two rules match at the same percentage.**
Author chose: first in file order. Rejected ASIN-over-category.

## Sign-off

**Q13. Is the Validated Direction an accurate capture?**
Author: yes, write `design.md` and `tasks.md`. See `validated-direction.md`.

**Q14. Which tracker steps to run after the commit?** The 2026-09-15 session
had held all issue updates because of the #1 overlap.
Author chose: label issue #2 `in-progress` only. Task-list mirroring and the
open-questions comment stay held.

## Writing the files

After sign-off the agent wrote `design.md` (approach, service map, four
scenario sequences, rules-file class diagram, touchpoints, data, criteria
mapping, open questions, rejected alternatives) and `tasks.md` (9 tasks),
then ran the spec-convention checks.

**Check result and one fix.** The mapping had 13 rows but the spec on
`master` has 12 criteria. The half-up rounding criterion, the listing-gap
wording, and the file-upload assumption had been added to the spec during
the 2026-09-15 design review on the earlier branch and never reached
`master`. All three were re-decided in this interview (Technology Decisions,
Q9, and Open Questions), so the agent applied them to `requirements.md` on
this branch and dated them 2026-09-16. Author to confirm on review.

The ADR `0002-pricing-rules-service.md` was carried from the earlier branch
with its decision 2 and consequences reworded: products is the only
consumer, checkout follows through `price`.
