# Design: Give the storefront a dark, modern gothic redesign

## Approach

Introduce a shared dark, muted "modern gothic" palette and type scale (near-black/charcoal backgrounds, a single blood-red accent, a sharp modern sans-serif stack) and apply it via plain CSS across the Home page, Hero banner, header/nav bar, and shared Products card component — the same components and colors already validated in the throwaway spike prototype. Replace the existing text-wordmark Logo component with a new original vampire/gargoyle-themed SVG mark, and add original SVG icon accents and hero background art in the same style. All new artwork is hand-drawn line-art/silhouette SVGs authored for this story, avoiding any third-party or stock imagery. No backend, routing, or data-fetching logic changes; this is a CSS/asset-only redesign plus one component swap (Logo).

## Touchpoints

| Service or file | Change |
|---|---|
| `react-ui/frontend/src/components/Home/index.css` | New dark palette; responsive grid (single-column mobile, multi-column desktop) for hero + category sections |
| `react-ui/frontend/src/components/Main/components/Hero/index.js` | Swap `background@2x.png` for new gargoyle/vampire background art asset; add `onError` fallback to a placeholder image |
| `react-ui/frontend/src/components/Main/components/Hero/index.css` | Dark palette, typography, background art styling |
| `react-ui/frontend/src/components/Main/components/Hero/gothic-background.svg` (new) | Original SVG background art (gargoyle/vampire silhouette motif) |
| `react-ui/frontend/src/components/Main/components/Logo/index.js` | Replace the wordmark SVG paths with a new original vampire/gargoyle-themed logo mark SVG (keep existing `mode` light/dark prop contract used by `Navbar`) |
| `react-ui/frontend/src/components/Main/components/Logo/index.css` | Any sizing/spacing adjustments the new mark needs |
| `react-ui/frontend/src/components/Main/components/NavBar/index.css` | Dark header background from the shared palette; nav link colors meeting contrast against it |
| `react-ui/frontend/src/components/Products/index.js` | Add gothic icon accent markup on category section headers; add `onError` fallback to a placeholder image on product images |
| `react-ui/frontend/src/components/Products/index.css` | New card style (dark palette, accent border/shadow) applied consistently everywhere the component is reused (`/Books`, `/Music`, etc., per `App/index.js`) |
| `react-ui/frontend/src/components/Products/gargoyle-icon.svg` (new) | Original gargoyle/vampire icon accent used on category sections (colocated with `Products`, the sole consumer, matching the codebase's existing per-component asset convention) |
| `react-ui/frontend/src/components/common/gothic-placeholder.svg` (new) | Shared placeholder image for failed hero/product image loads (colocated under `components/common` since it's shared by both `Hero` and `Products`) |

## Data

None. No schema, API, or catalog changes.

## Criteria mapping

| Criterion | How it is satisfied |
|---|---|
| THE storefront SHALL render the homepage hero banner and category sections using a dark, muted "modern gothic" color palette ... | `Home/index.css` and `Hero/index.css` apply the shared palette and font stack |
| THE storefront SHALL render the site header and navigation bar using the same dark, muted "modern gothic" color palette on every page. | `NavBar/index.css` reuses the same palette values; header is rendered on every route via `App/index.js` |
| THE storefront SHALL replace the Yugastore logo with a new vampire/gargoyle-themed logo mark ... | `Logo/index.js` SVG paths replaced with the new mark |
| THE storefront SHALL display gargoyle/vampire-themed icon accents on the homepage category sections. | `Products/index.js` renders a new icon accent per category section, sourced from `assets/gothic/icons/*.svg` |
| THE storefront SHALL display gargoyle/vampire-themed background art behind the hero banner. | `Hero/index.js` renders the new `gothic-background.svg` in place of `background@2x.png` |
| THE storefront SHALL display header navigation links with sufficient contrast against the new header background to remain readable. | `NavBar/index.css` sets nav link text color to a light tone with contrast verified against the new dark header background |
| WHEN the homepage is viewed on a mobile-width viewport THE storefront SHALL reflow ... into a single-column layout. | `Home/index.css` media query collapses the grid below the mobile breakpoint |
| WHEN the homepage is viewed on a desktop-width viewport THE storefront SHALL display ... in a multi-column layout. | `Home/index.css` default (above-breakpoint) grid/flex layout |
| THE storefront SHALL apply the redesigned product card style to every page that reuses the product card component ... | `Products/index.css` is the single shared stylesheet for the component, used by `/Books`, `/Music`, etc. via `App/index.js` |
| WHEN a shopper adds an item to the cart from a redesigned product card THE storefront SHALL retain the existing add-to-cart behavior unchanged. | No change to `Products/index.js` cart-fetch/add-to-cart logic or the `Button`/`addItemToCart` prop wiring; only markup/CSS around it changes |
| IF a hero or product image fails to load THEN THE storefront SHALL display a placeholder image ... | `onError` handlers added in `Hero/index.js` and `Products/index.js` swap the `src` to `assets/gothic/placeholder.svg` |

## Open questions

none

## Rejected alternatives

- Sourcing stock/third-party vampire or gargoyle artwork — rejected for copyright risk; all new imagery is original SVG line art created for this story.
- CSS-in-JS or a Sass build step for the new theme — rejected to stay consistent with the codebase's existing plain-CSS-per-component convention.
