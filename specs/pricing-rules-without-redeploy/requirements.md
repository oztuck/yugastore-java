# Change pricing rules without a redeploy

status: in-progress
issue: #2

## Story

As a merchandiser, I want to change percentage discounts by editing a rules file, so that pricing promotions do not wait on an engineering release.

## Acceptance criteria

THE pricing-rules-microservice SHALL load pricing rules from a JSON file at a path set in its configuration.
WHEN the rules file changes on disk THE pricing-rules-microservice SHALL serve the new rules within 30 seconds without a restart.
THE pricing-rules-microservice SHALL return the active rules as JSON from a GET endpoint.
WHEN a product's ASIN matches a percent-off rule THE products-microservice SHALL return the discounted price and the original price in the product response.
WHEN a product belongs to a category with a percent-off rule THE products-microservice SHALL return the discounted price and the original price in the product response.
WHEN more than one percent-off rule matches a product THE products-microservice SHALL apply only the largest discount.
WHEN a product has a discounted price THE storefront SHALL show the discounted price and the original price on the product list and product page.
WHEN an order is placed for a discounted product THE checkout-microservice SHALL total the order using the discounted price.
IF a rule has a percentage outside 0 to 100 or is missing a required field THEN THE pricing-rules-microservice SHALL skip that rule, log the reason, and serve the remaining rules.
IF the rules file is missing or is not valid JSON THEN THE pricing-rules-microservice SHALL log the reason and serve an empty rule set.
WHILE the pricing-rules-microservice is unavailable THE products-microservice SHALL return original prices with no discount.
WHILE the pricing-rules-microservice is unavailable THE checkout-microservice SHALL total orders at original prices.
THE products-microservice SHALL round a discounted price to the nearest cent, rounding half-up.

## Out of scope

- Buy-one-get-one and other quantity-based rules. Follow-up spec; the rules
  file format must leave room for a rule type field so it can be added.
- An API for changing rules, and authentication for it. Long-term direction
  is a write endpoint protected by a shared secret; this story is file-only.
- Scheduling rules by start and end date.
- Price history or audit of rule changes.
- Discounts shown on the cart page.
- Category rules on category listing pages for a product's *other* categories.
  Listing rows carry only the category being listed, so a product in Books and
  Gifts discounted via a Books rule shows full price on the Gifts listing. Known
  gap, accepted 2026-09-15; the product page is correct.

## Notes

Discussed 2026-09-15, see `.transcripts/2026-09-15-pricing-rules-feature-discussion-recap.md`.

`pricing-rules-microservice` does not exist yet. This spec introduces it, and the
story adds a row to the AGENTS.md service table. The reasons for a new service
rather than a write path in products-microservice or a rules table in YugabyteDB
are recorded in `docs/decisions/0002-pricing-rules-service.md`.

Assumption (2026-09-15): a merchandiser can get a changed `pricing-rules.json`
onto the host pricing-rules-microservice reads from without a redeploy. How the
file gets there is outside this story.
