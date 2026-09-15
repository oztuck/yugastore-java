# Design: Change pricing rules without a redeploy

## Approach

In one sentence: a new file-driven rules service, and products-microservice applies its rules so every consumer sees discounted prices through the field they already read.

- **New service.** Add a seventh module, `pricing-rules-microservice`. It loads a JSON rules file from a configured path, re-reads it when the file's modification time changes, and serves the valid rules over one GET endpoint. It has no database.
- **Products applies the rules.** `products-microservice` fetches rules through a Feign client with a short timeout and a short in-memory cache, then applies the single largest matching percent-off rule to each product it returns.
- **`price` stays the effective price.** The response keeps `price` as the discounted price and adds `originalPrice` and `discountPercent`.
- **Downstream is unchanged.** Checkout, the cart page, and the storefront already read `price`, so they pick up discounted totals with no logic change.
- **Two small edits in transit.** The storefront renders the original price when present, and the gateway's typed product models gain the two new fields so Jackson does not drop them.

**Services and data flow.** Solid arrows are runtime calls; the dotted arrow
is the file read. Only the two shaded boxes change.

```mermaid
%%{init: {'theme':'base','themeVariables':{'background':'#ffffff','primaryColor':'#eef0ff','primaryBorderColor':'#555','primaryTextColor':'#111','lineColor':'#333','edgeLabelBackground':'#f4f4f4','clusterBkg':'#ffffff','fontSize':'14px'}}}%%
flowchart TB
    M([Merchandiser]) -->|edits| F[(pricing-rules.json)]
    F -.->|poll mtime every 5 s| PR

    PR["pricing-rules-microservice :8087<br/>load, validate, GET /rules"]
    P["products-microservice :8082<br/>apply largest percent-off<br/>price = effective, + originalPrice"]
    GW[api-gateway :8081]
    UI[react-ui storefront]
    CK[checkout-microservice :8086]

    PR -->|GET rules, 500 ms timeout| P
    P --> GW --> UI
    P --> CK

    style PR fill:#fff3bf,stroke:#333
    style P fill:#fff3bf,stroke:#333
```

**Inside products-microservice.** One product read, rules unavailable path on
the right.

```mermaid
%%{init: {'theme':'base','themeVariables':{'background':'#ffffff','primaryColor':'#eef0ff','primaryBorderColor':'#555','primaryTextColor':'#111','lineColor':'#333','edgeLabelBackground':'#f4f4f4','clusterBkg':'#ffffff','fontSize':'14px'}}}%%
flowchart TB
    DB[(cronos.products)] --> A
    C[PricingRulesRestClient] --> K[PricingRulesCache<br/>10 s TTL]
    K -->|rules| A[PriceRuleApplier]
    K -.->|client failed:<br/>empty rules| A
    A --> R["price, originalPrice,<br/>discountPercent"]
```

When the rules service is unreachable, the cache hands the applier an empty
rule set, `price` stays at the base value, and every consumer downstream sees
original prices with no code path of its own to handle the outage.

### Scenarios

One sequence per flow the test plan exercises. `Rules` is pricing-rules-microservice, `Products` is products-microservice.

**Scenario 1: a merchandiser changes a rule, one rule is invalid.**

```mermaid
%%{init: {'theme':'base','themeVariables':{'background':'#ffffff','primaryColor':'#eef0ff','primaryBorderColor':'#555','primaryTextColor':'#111','lineColor':'#333','actorBkg':'#eef0ff','actorBorder':'#555','signalColor':'#333','signalTextColor':'#111','noteBkgColor':'#fff3bf','noteBorderColor':'#555','fontSize':'14px'}}}%%
sequenceDiagram
    actor M as Merchandiser
    participant F as pricing-rules.json
    participant S as Rules: scheduler
    participant L as Rules: loader
    participant R as Rules: active set

    M->>F: edit file (Books 20%, Toys 150%)
    loop every 5 s
        S->>F: read mtime
    end
    S->>L: mtime changed, reload
    L->>F: read and parse JSON
    L-->>L: Books 20% valid
    L-->>L: Toys 150% skipped, WARN logged
    L->>R: swap in {Books 20%}, skippedCount = 1
    Note over R: new rules live within 30 s, no restart
```

**Scenario 2: a shopper opens a discounted product page.**

```mermaid
%%{init: {'theme':'base','themeVariables':{'background':'#ffffff','primaryColor':'#eef0ff','primaryBorderColor':'#555','primaryTextColor':'#111','lineColor':'#333','actorBkg':'#eef0ff','actorBorder':'#555','signalColor':'#333','signalTextColor':'#111','noteBkgColor':'#fff3bf','noteBorderColor':'#555','fontSize':'14px'}}}%%
sequenceDiagram
    actor U as Shopper
    participant UI as react-ui
    participant GW as api-gateway
    participant P as Products
    participant C as Products: rules cache
    participant R as Rules
    participant DB as cronos.products

    U->>UI: open product page
    UI->>GW: GET /api/v1/product/{asin}
    GW->>P: GET /products-microservice/product/{asin}
    P->>DB: read product (price 12.99, categories {Books, Gifts})
    P->>C: rules()
    alt cache older than 10 s
        C->>R: GET /pricing-rules-microservice/rules (500 ms timeout)
        R-->>C: [Books 20%, asin X 15%]
    end
    C-->>P: rules
    P-->>P: largest match Books 20%, 12.99 -> 10.39 (half-up)
    P-->>GW: {price: 10.39, originalPrice: 12.99, discountPercent: 20}
    GW-->>UI: same JSON, fields kept by typed model
    UI-->>U: $10.39 with $12.99 struck through
```

**Scenario 3: checkout with a discounted product in the cart.**

```mermaid
%%{init: {'theme':'base','themeVariables':{'background':'#ffffff','primaryColor':'#eef0ff','primaryBorderColor':'#555','primaryTextColor':'#111','lineColor':'#333','actorBkg':'#eef0ff','actorBorder':'#555','signalColor':'#333','signalTextColor':'#111','noteBkgColor':'#fff3bf','noteBorderColor':'#555','fontSize':'14px'}}}%%
sequenceDiagram
    actor U as Shopper
    participant UI as react-ui
    participant GW as api-gateway
    participant CK as checkout-microservice
    participant P as Products
    participant DB as YCQL

    U->>UI: checkout
    UI->>GW: POST /api/v1/cart/checkout
    GW->>CK: checkout(userId)
    CK->>P: GET product/{asin} for each cart line
    P-->>CK: {price: 10.39, originalPrice: 12.99}
    CK-->>CK: total = 10.39 x qty (unchanged code, reads price)
    CK->>DB: decrement inventory, insert order with total
    CK-->>GW: order
    GW-->>UI: order confirmation at discounted total
```

**Scenario 4: the rules service is down.**

```mermaid
%%{init: {'theme':'base','themeVariables':{'background':'#ffffff','primaryColor':'#eef0ff','primaryBorderColor':'#555','primaryTextColor':'#111','lineColor':'#333','actorBkg':'#eef0ff','actorBorder':'#555','signalColor':'#333','signalTextColor':'#111','noteBkgColor':'#fff3bf','noteBorderColor':'#555','fontSize':'14px'}}}%%
sequenceDiagram
    participant P as Products
    participant C as Products: rules cache
    participant R as Rules (down)
    participant Any as gateway / checkout

    Any->>P: any product read
    P->>C: rules()
    C-xR: GET rules, connection refused or 500 ms timeout
    C-->>P: [] for the next 10 s
    P-->>P: no rules match, price unchanged
    P-->>Any: {price: 12.99} with no originalPrice
    Note over Any: storefront shows base price, checkout totals at base price
```

## Touchpoints

| Service or file | Change |
|---|---|
| `pom.xml` | Add `pricing-rules-microservice` to `<modules>` |
| `pricing-rules-microservice/` (new) | Spring Boot 2.6.3 module, port 8087, Eureka client, actuator, no DB. `exec-maven-plugin` docker step included for parity, skipped by `-Dexec.skip=true` like the others |
| `pricing-rules-microservice/.../RulesFileLoader` | Reads `pricing.rules.path`, parses JSON, validates each rule, logs and skips invalid ones, serves an empty set on missing file or invalid JSON |
| `pricing-rules-microservice/.../RulesRefreshScheduler` | `@Scheduled` every `pricing.rules.refresh-ms` (default 5000): compare mtime, reload on change |
| `pricing-rules-microservice/.../PricingRulesController` | `GET /pricing-rules-microservice/rules` returns `{rules:[...], loadedAt, skippedCount}` |
| `resources/pricing-rules.json` (new) | Sample rules file with one category rule and one ASIN rule, used by local dev and the test plan |
| `products-microservice/.../rest/clients/PricingRulesRestClient` | `@FeignClient("pricing-rules-microservice")`, connect and read timeout 500 ms |
| `products-microservice/.../service/PricingRulesCache` | Wraps the client. Caches rules for 10 s. Any exception or timeout yields an empty rule list for that window (no stale-rule fallback, per the WHILE criteria) |
| `products-microservice/.../service/PriceRuleApplier` | Pure function: (asin, categories, price, rules) to (price, originalPrice, discountPercent, appliedRuleId). Largest percent wins; rounds half-up to 2 decimals |
| `products-microservice/.../domain/ProductMetadata`, `ProductRanking` | Add `originalPrice` (Double, null when no discount) and `discountPercent` (Integer, null when no discount) as `@Transient` fields so Spring Data Cassandra ignores them |
| `products-microservice/.../controller/ProductCatalogController` | Apply the rule applier to every product in all three GET responses |
| `api-gateway-microservice/.../domain/ProductMetadata`, `ProductRanking` | Add the two fields so the gateway's typed pass-through keeps them |
| `react-ui/frontend/src/components/Products/index.js`, `ShowProduct/index.js` | When `originalPrice` is present, render it struck through next to `price`, plus the percent badge |
| `AGENTS.md` | New architecture table row (8087, no API, "pricing rules from `resources/pricing-rules.json`, hot-reloaded"); reword the gotcha that says pricing is future work |
| `.agents/skills/setup-local/SKILL.md` | Add the service to the start order after Eureka, the rules file path, that edits take up to 30 s, and the upload assumption |

`react-ui`'s Spring layer (`DashboardRestConsumer`) returns the gateway's JSON
as a raw string, so its Java `ProductMetadata` model needs no change. Checkout
and cart need no change: they read `price`, which is now the effective price.

## Data

No YugabyteDB schema changes. The rules file is the only new data:

```json
{
  "rules": [
    {"id": "books-20", "type": "percent_off", "match": {"category": "Books"}, "percent": 20},
    {"id": "asin-deal", "type": "percent_off", "match": {"asin": "0001048791"}, "percent": 15}
  ]
}
```

Validation: `id` non-empty and unique; `type` is `percent_off` (unknown types
are skipped now, so quantity-based types can be added later); `match` has
exactly one of `asin` or `category`; `percent` is a number in 0 to 100
inclusive.

**Where the rules file lives.** `pricing.rules.path` defaults to `../resources/pricing-rules.json`, so in local dev it is the `resources/pricing-rules.json` file in the checkout on the machine running pricing-rules-microservice. **Assumption, agreed 2026-09-15:** a merchandiser has some way to upload a changed file to the host the service reads from without a redeploy (a shared folder, a mounted volume, or a copy step owned by operations). That mechanism is outside this story. Once the file lands, the scheduler picks it up within 30 s with no restart. The follow-up write-API story replaces the upload with an authenticated endpoint.

## Criteria mapping

| Criterion | How it is satisfied |
|---|---|
| THE pricing-rules-microservice SHALL load pricing rules from a JSON file at a path set in its configuration | `RulesFileLoader` reads `pricing.rules.path` (default `../resources/pricing-rules.json` relative to the module dir) at startup |
| WHEN the rules file changes on disk THE pricing-rules-microservice SHALL serve the new rules within 30 seconds without a restart | `RulesRefreshScheduler` polls mtime every 5 s and swaps the in-memory rule set atomically |
| THE pricing-rules-microservice SHALL return the active rules as JSON from a GET endpoint | `GET /pricing-rules-microservice/rules` |
| WHEN a product's ASIN matches a percent-off rule THE products-microservice SHALL return the discounted price and the original price in the product response | `PriceRuleApplier` ASIN match; `price` discounted, `originalPrice` set |
| WHEN a product belongs to a category with a percent-off rule THE products-microservice SHALL return the discounted price and the original price in the product response | `PriceRuleApplier` category match against `ProductMetadata.categories`; for `ProductRanking` rows, against the row's own category key only (accepted gap, see Out of scope in requirements.md) |
| WHEN more than one percent-off rule matches a product THE products-microservice SHALL apply only the largest discount | `PriceRuleApplier` picks max `percent`; ties resolved by first rule in file order |
| WHEN a product has a discounted price THE storefront SHALL show the discounted price and the original price on the product list and product page | Gateway passes fields through; `Products` and `ShowProduct` components render `originalPrice` struck through when present |
| WHEN an order is placed for a discounted product THE checkout-microservice SHALL total the order using the discounted price | Unchanged `CheckoutServiceImpl.getTotal` multiplies `productDetails.getPrice()`, which is now the effective price |
| IF a rule has a percentage outside 0 to 100 or is missing a required field THEN THE pricing-rules-microservice SHALL skip that rule, log the reason, and serve the remaining rules | `RulesFileLoader` per-rule validation, WARN log with rule index and reason, `skippedCount` in response |
| IF the rules file is missing or is not valid JSON THEN THE pricing-rules-microservice SHALL log the reason and serve an empty rule set | `RulesFileLoader` catches `NoSuchFileException` and `JsonProcessingException`, logs ERROR, serves `rules: []` |
| WHILE the pricing-rules-microservice is unavailable THE products-microservice SHALL return original prices with no discount | `PricingRulesCache` returns empty list on any client failure; applier with no rules leaves `price` unchanged and `originalPrice` null |
| WHILE the pricing-rules-microservice is unavailable THE checkout-microservice SHALL total orders at original prices | Follows from the previous row: checkout reads `price` from products-microservice |
| THE products-microservice SHALL round a discounted price to the nearest cent, rounding half-up | `PriceRuleApplier` uses `BigDecimal.setScale(2, RoundingMode.HALF_UP)` |

## Open questions

- The spec is `status: proposed`, not `accepted`, and overlaps with
  `specs/promo-pricing/` (#1), which puts a write path and time-bound promos
  inside products-microservice. The author chose on 2026-09-15 to leave this
  open and proceed on this branch for our spec only. The team must reconcile
  #1 and #2 before anything merges to `master`.

## Rejected alternatives

- **Checkout calls the rules service itself.** Not needed for percent-off,
  since checkout already reads `price` from products. Quantity-based rules
  will need it and are a separate spec.
- **Return an `effectivePrice` field and leave `price` as the base.** Would
  require changes in checkout, cart, gateway, and three storefront components.
  Keeping `price` as the effective price makes the discount flow everywhere
  the base price already flows.
- **Filesystem watch (`WatchService`) instead of mtime polling.** More
  responsive, but inconsistent across macOS, Windows, and Docker-mounted
  volumes. A 5 s poll meets the 30 s criterion with margin and is portable.
- **Serve last-known rules when the rules service is down.** Rejected because
  both WHILE criteria say original prices, no discount.
- **Rules in YugabyteDB or a third-party CMS.** See
  `docs/decisions/0002-pricing-rules-service.md`. Reconsidered on 2026-09-15
  during design review and kept as the file: a table is multi-instance safe
  and gives history, but today a merchandiser would still need CQL or the
  deferred write API, and the loader isolates storage so the swap later is
  contained. A file-as-source, table-as-store hybrid was also rejected as more
  code than the story needs.
- **Extra category lookup on listing pages.** A batched `IN` query per
  listing page would make category rules correct on every listing row.
  Rejected for this story on 2026-09-15: it adds reads to the busiest
  endpoint for a corner case. Recorded as a known gap instead.
- **Gateway route `/api/v1/pricing-rules`.** No criterion asks for it and the
  rules call is service-to-service. Rejected on 2026-09-15; the tester reads
  port 8087 directly. The future write-API story will add gateway exposure.
