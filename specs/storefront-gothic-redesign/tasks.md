# Tasks: Give the storefront a dark, modern gothic redesign

- [x] 1. Define the shared gothic palette and type scale (near-black backgrounds, single blood-red accent, sharp modern font stack) and apply it in `Home/index.css` and `Hero/index.css` (WHEN homepage hero/category sections rendered)
- [x] 2. Apply the same dark palette to `NavBar/index.css` and set nav link text color for sufficient contrast against the new header background (THE storefront SHALL render the header ..., THE storefront SHALL display header navigation links with sufficient contrast)
- [x] 3. Create the new original vampire/gargoyle-themed logo mark SVG and swap it into `Logo/index.js`, preserving the existing `mode` light/dark prop contract (THE storefront SHALL replace the Yugastore logo)
- [x] 4. Create original gothic background art SVG and wire it into `Hero/index.js` in place of `background@2x.png` (THE storefront SHALL display gargoyle/vampire-themed background art)
- [x] 5. Create original gargoyle/vampire icon accent SVGs and render one per category section in `Products/index.js` (THE storefront SHALL display gargoyle/vampire-themed icon accents)
- [x] 6. Add responsive layout to `Home/index.css`: single-column below the mobile breakpoint, multi-column above it (WHEN mobile-width viewport, WHEN desktop-width viewport)
- [ ] 7. Restyle `Products/index.css` cards with the new palette, verified consistent on `/Books`, `/Music`, and other category routes (THE storefront SHALL apply the redesigned product card style)
- [ ] 8. Add `onError` placeholder fallback (new `assets/gothic/placeholder.svg`) to hero and product images in `Hero/index.js` and `Products/index.js` (IF a hero or product image fails to load)
- [ ] 9. Regression-check add-to-cart from a restyled product card still works end-to-end with no logic changes (WHEN a shopper adds an item to the cart from a redesigned product card)
