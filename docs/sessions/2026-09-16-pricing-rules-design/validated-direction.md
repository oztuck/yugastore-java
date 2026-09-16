# Validated Direction

Output of the `design-interview` skill for
`specs/pricing-rules-without-redeploy`, produced 2026-09-16 and shown to the
author for sign-off before `design.md` was written.

**Approach:** Add a seventh Spring Boot module, `pricing-rules-microservice`
(port 8087, Eureka client, actuator, no database). It loads
`resources/pricing-rules.json` from a configured path, validates each rule,
polls the file's modification time every 5 seconds and swaps the rule set in
memory when it changes, and serves the active rules from one GET endpoint.
`products-microservice` is the only consumer: it fetches rules through a Feign
client wrapped in a Resilience4j circuit breaker with a short in-memory cache,
applies the single largest matching percent-off rule to every product it
returns, and keeps `price` as the effective price while adding
`originalPrice` and `discountPercent`. Checkout, the cart page, and the
storefront therefore see discounts with no logic change; the storefront adds
the struck-through original and the gateway's typed models gain the two
fields.

**Key Constraints:**
1. The deliverable is a clear, well-diagrammed `design.md` that shows the
   collaboration. Legibility beats cleverness in every trade-off.
2. When the rules service is unreachable, both products and checkout must
   land on original prices with no discount, exactly as the WHILE criteria
   say. No stale rules.

**Technology Decisions:**
- New service rather than a write path in products or a YugabyteDB table:
  the author's direction from round 1; rationale in ADR 0002 on the earlier
  branch, to be carried onto this branch.
- File change detection by mtime polling every 5 s: portable across macOS,
  Windows, and Docker volumes, and meets the 30 s criterion with margin.
- Resilience4j circuit breaker around the rules client (new dependency in
  products): chosen over a bare Feign timeout because it ties to the
  client's graceful-degradation goal and is visible in a demo.
- `price` becomes the effective price; `originalPrice` and `discountPercent`
  are added: one applier, no downstream reader has to change to be correct.
- Rules file: typed JSON, `type: percent_off`, `match` has exactly one of
  `asin` or `category`, `percent` 0 to 100 inclusive; unknown types skipped.
- Rounding half-up to the cent via `BigDecimal`; ties broken by file order.

**Risk Areas:**
- Category rules on listing pages are applied only against the listed
  category. Accepted gap; product page is correct.
- Flaky demo if file watching were used; avoided by polling.
- Spec overlap with `specs/promo-pricing/` (#1), which is in Build inside
  products-microservice. Nothing from this branch should merge until the
  team reconciles #1 and #2.

**Rejected Alternatives:**
- Keep `price` as base and add `effectivePrice` (every reader must change).
- Checkout applies rules itself (two appliers to keep in sync).
- `appliedRuleId` in the response (no criterion needs it).
- `WatchService` and re-read-per-request for reload.
- Bare Feign timeout without a breaker; serving last-known rules.
- Batched category lookup on listing pages.
- Gateway route for the rules endpoint.
- Rules file inside the module jar; flat untyped rules.

**Open Questions:**
- The spec is `proposed`, not `accepted`, and overlaps #1. The author is
  proceeding on this branch knowing that; reconciliation is a team decision
  before merge.
- How a merchandiser gets a changed file onto the host is outside this story
  (assumption carried from the spec Notes).
