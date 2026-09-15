# Update product data without redeploying

status: proposed
issue: #4

## Story

As an internal catalog operator, I want to update an existing product through a live management API, so that product data and business pricing changes take effect without redeploying the application.

## Acceptance criteria

WHEN an internal API caller submits a valid update for an existing product by ASIN THE products-microservice SHALL persist the changed product fields and return the updated product.
WHEN a product update is successfully persisted THE products-microservice SHALL make the changed values available on the next product read.
WHEN an update changes price, sale or discount values, title, description, brand, image URL, or categories THE products-microservice SHALL persist those changed fields without requiring an application restart or redeployment.
IF the submitted ASIN does not identify an existing product THEN the products-microservice SHALL reject the update with HTTP 404 and a human-readable reason.
IF any submitted field is invalid THEN the products-microservice SHALL reject the entire update with an appropriate HTTP 4xx status and a human-readable reason.
IF an update is rejected THEN the products-microservice SHALL preserve all existing values for that product.
IF the database operation fails transiently THEN the products-microservice SHALL retry the update once.
IF the retry also fails THEN the products-microservice SHALL reject the update with an appropriate HTTP 5xx status and a human-readable reason.
THE products-microservice SHALL continue serving the last successfully persisted product values while no update is being committed.
THE products-microservice SHALL accept updates without requiring a redeployment of the products-microservice or the storefront.

## Out of scope

- Authentication, authorization, and admin roles; the first version assumes a trusted internal API caller.
- Creating new products.
- Deleting or deactivating products.
- Bulk file import or multi-product updates.
- Product change history, audit logging, or rollback.
- A separate pricing-rules engine; sale and discount values are product fields for this story.
- Changes to product ranking or recommendation datasets unless explicitly represented by the supported product fields.

## Notes

The current catalog is read-only from the application API and is initially populated from seed data. This story adds a live single-product update path for existing catalog records. Updates are atomic: a request containing an invalid field must not partially change the product.
