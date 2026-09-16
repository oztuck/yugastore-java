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

Instructions written so an agent (Copilot, Claude, Codex) can do this from the
prompt: *"Import the slides from `<path>/deck/slides.md` into my deck and
re-skin them with my palette."*

1. **Copy this folder** into the host deck, for example `imports/travis/`.
   Keep `slides.md`, `styles/`, and `setup/mermaid.ts` together.

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
