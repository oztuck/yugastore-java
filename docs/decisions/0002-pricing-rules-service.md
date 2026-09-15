# ADR 0002: A Separate Pricing Rules Service

Status: proposed
Date: 2026-09-15

Pricing business rules live in a new `pricing-rules-microservice` that loads
them from a file at runtime and serves them to the services that apply them.
This record explains why a new service rather than extending an existing one,
and what that costs.

## Context

The kickoff named a CMS for business rules as the main gap in Yugastore. The
2026-09-15 morning discussion narrowed that to pricing rules: percentage
discounts by category or product, and later quantity-based promotions such as
buy-one-get-one. The goal is to change those rules without redeploying any
service. See `.transcripts/2026-09-15-pricing-rules-feature-discussion-recap.md`.

Today `products-microservice` is read-only and serves a fixed `price` per
product. `checkout-microservice` totals an order by fetching product details
and multiplying price by quantity. Neither knows anything about rules. There is
no authentication or authorization service.

The MVP changes rules by editing a file the service reloads, with no write API.
The long-term direction is a write endpoint protected by a shared secret.

The spec convention requires every acceptance criterion to name a service from
the AGENTS.md table. There is no neutral way to say "something loads a rules
file" without choosing an owner, so the first spec forces this decision.

## Decision

1. A new Spring Boot module, `pricing-rules-microservice`, owns the rules. It
   loads a JSON rules file from a configured path, reloads it when the file
   changes, and exposes the active rules over a GET endpoint. It registers
   with Eureka like every other service and is added to the AGENTS.md table.
2. `products-microservice` fetches rules from it and returns discounted and
   original prices on product reads. `checkout-microservice` fetches rules
   from it and applies them to order totals.
3. Both consumers degrade to original prices when the rules service is
   unavailable. Rules are a promotion, never a dependency for selling.
4. The rules file carries a rule type field from the first version so that
   quantity-based rules can be added without a format change.
5. The future write API and its shared-secret check are added to this service
   when that story is specified. Nothing about it is built now.

## Alternatives considered

**`products-microservice` reads the rules file directly.** Fastest for the MVP
and no new module. Rejected because quantity-based rules can only be applied
at checkout, so `checkout-microservice` needs the rules too. Products would
then have to expose a rules endpoint and would become a rules server anyway,
while also giving up its read-only simplicity. Keeping the catalog read-only
was a deliberate property, not an accident.

**Rules in a YugabyteDB table.** No file, no new service, and the database is
already shared by every service. Changing a rule is a CQL insert. Rejected for
now because the team chose a file-based MVP so a merchandiser-facing edit needs
no database tooling, and because two services would each need rule-loading
and matching code with no single owner. It remains a reasonable storage
backend for the rules service itself later.

**A third-party lightweight CMS.** Mentioned in the discussion. Not pursued
because the rule set is small and structured, and a CMS adds a runtime and a
data model the team would have to learn during a three-day hackathon.

## Consequences

Easier: one owner for rules, one place to add the write API and its auth, and
consumers that stay simple because they only match rules against a product or
a cart. The rules service has no database dependency in the MVP, so it starts
fast and can be tested alone.

Harder: a seventh module to build, run, and register. AGENTS.md, the gateway
routes, and the local run order all change. Two services now make a network
call on paths that were local, so both need a timeout and a fallback, and the
test plan needs fault-injection tests for the service being down.

To revisit: whether the file stays the source of truth once a write API
exists, or the service moves rules into YugabyteDB and the file becomes a
seed. Also whether `cart-microservice` should show discounts, which the first
spec leaves out.
