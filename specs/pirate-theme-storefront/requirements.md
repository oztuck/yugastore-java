# Give the storefront a site-wide pirate theme

status: proposed
issue: #15

## Story

As a shopper, I want the entire storefront to look and read like a pirate ship's deck, so that browsing, adding to cart, and checking out feels like a fun swashbuckling adventure.

## Acceptance criteria

THE storefront SHALL render every page (homepage, category browse, product detail, cart, checkout) using a pirate color palette of weathered wood browns/tans, deep navy/teal "ocean" tones, and gold accents.
THE storefront SHALL render every page using pirate-styled typography and decorative elements evoking rope, parchment, and aged wood.
THE storefront SHALL restyle the existing Yugastore logo mark with pirate-themed visual treatment (e.g. a ship's wheel or skull-and-crossbones flourish) while keeping the "Yugastore" name unchanged.
THE storefront SHALL display bold, immersive pirate-themed illustrated imagery (ships, pirate characters, treasure chests, skull-and-crossbones, treasure maps, parchment textures) as prominent background art and accents on the homepage hero, category sections, and product/cart/checkout pages, not limited to small icon-scale flourishes.
THE storefront SHALL apply the pirate product card style to every page that reuses the product card component, including category browse pages such as /Books and /Music.
THE storefront SHALL replace shopper-facing storefront-generated text pervasively (navigation labels, buttons, headings, form labels, tooltips, footer copy, empty-state and error messages) with pirate-speak equivalents (e.g. "Add to Cart" becomes "Stow in the Hold", an empty cart reads "Yer hold be empty, matey"), not limited to a small set of highlight strings.
THE storefront SHALL leave catalog data (product names and descriptions) unchanged; pirate-speak applies only to storefront-generated text, not product content.
THE storefront SHALL display header navigation links with sufficient contrast against the new pirate-themed header background to remain readable.
WHEN a page is viewed on a mobile-width viewport THE storefront SHALL reflow pirate-themed layouts (hero, category sections, product cards) into a single-column layout.
WHEN a page is viewed on a desktop-width viewport THE storefront SHALL display pirate-themed layouts in a multi-column layout.
WHEN a shopper adds an item to the cart from a pirate-styled product card THE storefront SHALL retain the existing add-to-cart behavior unchanged.
WHEN a shopper proceeds through checkout THE storefront SHALL retain the existing checkout behavior unchanged while displaying pirate-speak labels and messaging.
IF a hero or product image fails to load THEN THE storefront SHALL display a pirate-themed placeholder image instead of a broken image icon.

## Out of scope

- Any backend, catalog, or API changes.
- Rewriting product names or descriptions (catalog data) in pirate-speak.
- Changing the "Yugastore" store name.
- SEO or page-load performance work not directly caused by the visual changes.
- The `storefront-gothic-redesign` spec; it is left as-is for now and not dropped or merged with this one.

## Notes

This spec supersedes the visual direction of `storefront-gothic-redesign` (accepted but never built), though the PO chose to leave that spec's status untouched for now rather than drop it. Unlike the gothic redesign, this pirate theme is intentionally site-wide: homepage, header/nav, category browse, product detail, cart, and checkout all get the treatment, and shopper-facing copy (not just visuals) changes to pirate-speak. Relevant components: `react-ui/frontend/src/components/Home`, `Main/components/Hero`, `Products` (shared by category routes via `App/index.js`), `ShowProduct`, and `Cart`. No visual design system or brand guide exists today. The design stage should propose a concrete palette, type scale, iconography direction, and a pirate-speak copy glossary (covering nav labels, buttons, empty states, and error messages) for review before implementation.
