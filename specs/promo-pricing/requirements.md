# Configure time-bound promo pricing without a redeploy

status: proposed
issue: #1

## Story

As the pricing engine, I want to configure a time-bound promotional discount
on an existing product's price, so that sales and promos can go live without
an engineering release.

## Acceptance criteria

WHEN an authorized caller submits a promo with an ASIN, a discount, a start time, and an end time THE products-microservice SHALL persist it and return the created promo.
WHILE the current time falls within a promo's active window THE storefront SHALL show the discounted price for that product.
WHEN a promo's end time passes THE storefront SHALL show the product's base price.
IF the submitted discount is negative or greater than 100 percent THEN THE products-microservice SHALL reject the promo with a 400 and a reason.
IF the submitted end time is not after the start time THEN THE products-microservice SHALL reject the promo with a 400 and a reason.
IF the submitted ASIN does not exist THEN THE products-microservice SHALL reject the promo with a 400 and a reason.
WHEN two promos' active windows overlap for the same product THE products-microservice SHALL apply the most recently submitted promo for the overlapping period.
WHILE the products-microservice is unavailable THE storefront SHALL show the product's base price without a stale indicator.

## Out of scope

- Authentication and roles. Any caller is authorized for this story.
- Customer-segment or targeted promos.
- Promo history or audit log.
- Bulk price list upload (tracked as a separate spec).
- Adding new products or prices (tracked as a separate spec).

## Notes

The catalog is read-only today (YCQL, seeded from products.json), so this is
a first write path and will likely need schema changes. "Most recently
submitted" for overlap resolution means submission time, not start time.
