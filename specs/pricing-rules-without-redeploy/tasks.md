# Tasks: Change pricing rules without a redeploy

- [ ] 1. Scaffold `pricing-rules-microservice`: pom with Spring Boot 2.6.3, web, actuator, Eureka client, exec docker step; main class; `application.yml` on port 8087 with `pricing.rules.path` and `pricing.rules.refresh-ms`; add to root `pom.xml` modules (THE load file, THE GET endpoint)
- [ ] 2. Rules model and `RulesFileLoader` with per-rule validation, skip-and-log, and empty set on missing or invalid file; unit tests for each validation branch (THE load file, IF percentage outside, IF file missing)
- [ ] 3. `RulesRefreshScheduler` polling mtime every 5 s and `GET /pricing-rules-microservice/rules`; integration test that edits a temp file and sees new rules within the window (WHEN file changes, THE GET endpoint)
- [ ] 4. Add sample `resources/pricing-rules.json` with one category rule, one ASIN rule, and one deliberately invalid rule (THE load file, IF percentage outside)
- [ ] 5. `PricingRulesRestClient` Feign client in products-microservice with 500 ms timeouts, and `PricingRulesCache` with 10 s TTL that returns an empty list on any failure; unit test for the failure path (WHILE unavailable products, WHILE unavailable checkout)
- [ ] 6. `PriceRuleApplier` with largest-discount selection and half-up rounding; `originalPrice` and `discountPercent` transient fields on `ProductMetadata` and `ProductRanking`; apply in all three `ProductCatalogController` endpoints; unit tests for ASIN match, category match, overlap, no match, and rounding (WHEN ASIN matches, WHEN belongs to a category, WHEN more than one, WHEN an order is placed, THE round)
- [ ] 7. Add `originalPrice` and `discountPercent` to the gateway's `ProductMetadata` and `ProductRanking` so `/api/v1` responses keep them (WHEN a product has a discounted price)
- [ ] 8. Storefront: render `originalPrice` struck through with the percent badge in `Products` and `ShowProduct` when present (WHEN a product has a discounted price)
- [ ] 9. Update AGENTS.md: service table row for pricing-rules-microservice on 8087, run order, and a gotcha that rules edits take up to 30 s to show (spec Notes; no criterion)
