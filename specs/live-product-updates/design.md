# Design: Update product data without redeploying

## Approach

Add a trusted internal `PUT /products-microservice/product/{asin}` endpoint in products-microservice that accepts a full product update payload for an existing ASIN. The controller will validate the request, delegate to ProductService, and return the persisted ProductMetadata or a shaped error response. ProductService will read the current row, merge only supported mutable fields, save through ProductMetadataRepo, and retry the save once for transient Cassandra driver failures. Reads already hit YCQL through ProductMetadataRepo, so the next product read will reflect the last successful write without restarting the service or storefront.

## Touchpoints

| Service or file | Change |
|---|---|
| products-microservice ProductCatalogController | Add `PUT /products-microservice/product/{asin}` with request validation and HTTP 404/4xx/5xx responses. |
| products-microservice ProductService and ProductServiceImpl | Add update orchestration: load existing product, merge supported fields, save atomically, and retry transient database failures once. |
| products-microservice ProductMetadataRepo | Use the CassandraRepository `save` path for persisted updates. |
| products-microservice ProductMetadata | Add mutable `sale` and `discount` fields and keep existing mutable product fields serializable. |
| resources/schema.cql | Add nullable `sale` and `discount` columns to `cronos.products`. |
| products-microservice tests | Add controller/service tests for success, validation rejection, not found, rollback/no partial save, and retry behavior. |

## Data

Add nullable product fields to `cronos.products`:

```cql
sale boolean,
discount double
```

Existing seed rows can omit both fields. The update API supports these fields alongside existing `price`, `title`, `description`, `brand`, `imUrl`, and `categories`. The `product_rankings` table remains unchanged because the accepted criteria target product reads by ASIN and persistence of product fields, not ranking maintenance.

## Criteria mapping

| Criterion | How it is satisfied |
|---|---|
| WHEN an internal API caller submits a valid update for an existing product by ASIN THE products-microservice SHALL persist the changed product fields and return the updated product. | `PUT /products-microservice/product/{asin}` validates the payload, updates the existing ProductMetadata row through ProductService, and returns the saved ProductMetadata. |
| WHEN a product update is successfully persisted THE products-microservice SHALL make the changed values available on the next product read. | ProductService saves to `cronos.products`; existing `GET /products-microservice/product/{asin}` reads from the same repository and returns the saved values. |
| WHEN an update changes price, sale or discount values, title, description, brand, image URL, or categories THE products-microservice SHALL persist those changed fields without requiring an application restart or redeployment. | ProductMetadata and `cronos.products` include all supported mutable fields, including new `sale` and `discount` columns, and the PUT path persists them live. |
| IF the submitted ASIN does not identify an existing product THEN the products-microservice SHALL reject the update with HTTP 404 and a human-readable reason. | ProductService returns a not-found result when the initial lookup is empty; the controller maps it to 404 with an error body. |
| IF any submitted field is invalid THEN the products-microservice SHALL reject the entire update with an appropriate HTTP 4xx status and a human-readable reason. | The controller validates ASIN consistency, supported field names, nonblank text fields where present, nonnegative price, discount range, image URL syntax, and nonempty categories before saving. |
| IF an update is rejected THEN the products-microservice SHALL preserve all existing values for that product. | Validation and not-found checks run before calling `save`; tests verify rejected requests do not invoke persistence and the original product remains unchanged. |
| IF the database operation fails transiently THEN the products-microservice SHALL retry the update once. | ProductService catches transient Cassandra driver exceptions from `save` and performs exactly one second save attempt. |
| IF the retry also fails THEN the products-microservice SHALL reject the update with an appropriate HTTP 5xx status and a human-readable reason. | ProductService reports retry exhaustion; the controller maps it to 503 or 500 with an error body. |
| THE products-microservice SHALL continue serving the last successfully persisted product values while no update is being committed. | Reads remain independent of the PUT request object and continue using the last committed YCQL row; failed validation and failed saves do not replace the existing row. |
| THE products-microservice SHALL accept updates without requiring a redeployment of the products-microservice or the storefront. | The live PUT endpoint writes YCQL rows at runtime; no file regeneration, seed reload, service restart, or storefront build is part of the update flow. |

## Rejected alternatives

- Expose this update through the storefront gateway first: the story assumes a trusted internal caller and does not require a browser-facing management UI.
- Update `product_rankings` in the same story: ranking table consistency is not covered by an acceptance criterion and would broaden the write path beyond product-by-ASIN reads.