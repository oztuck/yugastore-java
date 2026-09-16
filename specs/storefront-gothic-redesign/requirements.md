# Give the storefront a dark, modern gothic redesign

status: proposed
issue: #11

## Story

As a shopper, I want the homepage and site header to have a dark, muted, modern gothic look, so that the storefront feels current and distinctive to browse.

## Acceptance criteria

THE storefront SHALL render the homepage hero banner and category sections using a dark, muted "modern gothic" color palette (near-black/desaturated backgrounds, a single blood-red accent color, sharp/edgy modern typography).
THE storefront SHALL render the site header and navigation bar using the same dark, muted "modern gothic" color palette on every page.
THE storefront SHALL keep the existing Yugastore logo image unchanged, while updating the header background and surrounding styling so the logo remains clearly visible against the new dark palette.
THE storefront SHALL display header navigation links with sufficient contrast against the new header background to remain readable.
WHEN the homepage is viewed on a mobile-width viewport THE storefront SHALL reflow the hero banner and category sections into a single-column layout.
WHEN the homepage is viewed on a desktop-width viewport THE storefront SHALL display the hero banner and category carousels in a multi-column layout.
THE storefront SHALL apply the redesigned product card style to every page that reuses the product card component, including category browse pages such as /Books and /Music.
WHEN a shopper adds an item to the cart from a redesigned product card THE storefront SHALL retain the existing add-to-cart behavior unchanged.
IF a hero or product image fails to load THEN THE storefront SHALL display a placeholder image instead of a broken image icon.

## Out of scope

- Redesign of pages other than the homepage, the site header/navigation bar, and the shared product card component (e.g., cart, checkout, product detail pages).
- A new logo image or brand identity change (only the logo's surrounding background/styling is updated, not the logo asset itself).
- Any backend, catalog, or API changes.
- SEO or page-load performance work not directly caused by the visual changes.

## Notes

The homepage is `react-ui/frontend/src/components/Home`, composed of a `Hero` component (`Main/components/Hero`) and category `Products` carousels. The `Products` component is also used by category browse routes (e.g., `/Books`) in `App/index.js`, so its restyle will be visible there too, per PO decision. The site header/nav bar is a separate shared component rendered on every page; it needs a coordinated dark-theme update so it doesn't clash with the new homepage styling. No visual design system or brand guide exists today; direction is dark, muted, and "depressing" in mood, with a single blood-red accent color kept, so the design stage should propose a concrete palette and type scale for review before implementation.
