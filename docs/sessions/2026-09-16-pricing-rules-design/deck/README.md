# Deck: designing with an agent, on the record

Three Slidev slides from the 2026-09-16 pricing-rules design session.

```
npm install
npm run dev        # http://localhost:3030
npm run export     # PDF
```

## Files

| File | Purpose |
|---|---|
| `slides.md` | The three slides. Uses `v-click` reveals and Mermaid diagrams. |
| `styles/tokens.css` | Every colour, font, and background as a CSS variable. **The only file to edit to re-skin.** |
| `styles/layout.css` | Structure only. Consumes the tokens. Do not edit for colours. |
| `styles/index.css` | Imports the two above. Slidev auto-loads it. |
| `setup/mermaid.ts` | Diagram base palette. Mermaid cannot read CSS variables, so repeat your palette here. |

Diagram highlight colours (gold, mint, violet) are `classDef` lines inside the
diagrams in `slides.md`, because Slidev renders Mermaid in a shadow DOM.

## Importing these slides into another Slidev deck

Instructions written so an agent (Copilot, Claude, Codex) can do this from a
prompt. A ready-made prompt is at the end of this section.

1. **Fetch this folder from GitHub, no checkout needed.** From the root of
   the host deck, either source works; both put the files in
   `imports/travis/` (any folder name is fine, adjust the paths below).

   From the Yugastore branch, source of truth:

   ```bash
   npx degit oztuck/yugastore-java/docs/sessions/2026-09-16-pricing-rules-design/deck#pricing-rules-design-session imports/travis
   ```

   Or from the public mirror:

   ```bash
   npx degit tredfield/pricing-rules-design-deck imports/travis
   ```

   Fallback without degit: download the raw files one by one.

   ```bash
   B=https://raw.githubusercontent.com/tredfield/pricing-rules-design-deck/main
   mkdir -p imports/travis/styles imports/travis/setup
   for f in slides.md styles/tokens.css styles/layout.css setup/mermaid.ts; do
     curl -fsSL "$B/$f" -o "imports/travis/$f"
   done
   ```

   Only `slides.md`, `styles/tokens.css`, `styles/layout.css`, and
   `setup/mermaid.ts` are needed. Delete the rest if degit brought it.

2. **Import the slides** with one block in the host `slides.md` at the point
   they should appear:

   ```md
   ---
   src: ./imports/travis/slides.md
   ---
   ```

   The imported file's headmatter (title, fonts, canvasWidth) is ignored; the
   host deck's settings and slide transitions apply. `v-click` reveals and the
   speaker notes in `<!-- -->` comments come along unchanged.

3. **Load the styles.** Add to the host `styles/index.css`:

   ```css
   @import '../imports/travis/styles/layout.css';
   @import '../imports/travis/styles/tokens.css';
   /* then override tokens with the host palette, after the imports */
   :root {
     --ink: ...; --panel: ...; --line: ...; --text: ...; --muted: ...;
     --human: ...; --agent: ...; --gold: ...; --mint: ...;
     --slide-bg: ...; --font-sans: ...; --font-mono: ...;
   }
   ```

   `layout.css` scopes its rules to classes these slides use (`.round`,
   `.bubble`, `.card`, `.cmp`, `.skill`, `.flow`, `.design`, `.foot`) plus
   `.slidev-layout` for the background. If the host deck sets its own
   background on `.slidev-layout`, drop the `--slide-bg` token or override it.

4. **Diagram colours.** Either merge the `themeVariables` from
   `setup/mermaid.ts` into the host's `setup/mermaid.ts`, or copy the file if
   the host has none. Update the `classDef` hex values in `slides.md` to
   match the host palette (search for `classDef gold`).

5. **Check the fit.** These slides were laid out for `canvasWidth: 1180`,
   16:9, a dark background, and the Inter font. On a light theme, set
   `--slide-bg`, `--text`, `--panel`, and `--line` to light-appropriate
   values; the layout does not change. Run `npm run dev` and step through
   the three slides; the round cards on slide 2 are the tightest fit.

## Token reference

| Token | Used for |
|---|---|
| `--ink` | base background, pill badges |
| `--slide-bg` | full slide background (gradient or flat) |
| `--panel`, `--line` | card fill and border |
| `--text`, `--muted` | body text, eyebrows, footers |
| `--human` | Travis's speech bubbles, "human" legend |
| `--agent` | agent speech bubbles, list markers |
| `--gold` | the pivot card, mandatory sections, comparison table frame |
| `--mint` | sign-off card, chosen option row |
| `--font-sans`, `--font-mono` | body and code |

## Prompt to hand your agent

```
Add Travis's three slides to this Slidev deck.
1. Run: npx degit tredfield/pricing-rules-design-deck imports/travis
   and keep only slides.md, styles/tokens.css, styles/layout.css, setup/mermaid.ts.
2. In my slides.md, at the point the slides should appear, add a slide block
   whose frontmatter is just:  src: ./imports/travis/slides.md
3. In my styles/index.css, @import ../imports/travis/styles/layout.css and
   ../imports/travis/styles/tokens.css, then add a :root block after them that
   overrides the tokens with this deck's palette (see the token table in
   imports/travis/README.md).
4. Merge the themeVariables from imports/travis/setup/mermaid.ts into my
   setup/mermaid.ts (create it if absent), then update the classDef hex values
   in imports/travis/slides.md to match my palette.
5. Run the dev server and confirm the three imported slides render with my
   colours and their click reveals intact.
```
