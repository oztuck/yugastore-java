---
theme: default
title: Designing with an agent, on the record
colorSchema: dark
aspectRatio: 16/9
canvasWidth: 1180
css: unocss
htmlAttrs:
  lang: en
fonts:
  sans: Inter
  mono: JetBrains Mono
mdc: true
---

<div class="eyebrow">Yugastore · .agents/skills/design-interview · invoked by design-spec, step 3</div>
<h1 class="title small">A skill that makes the agent <span class="hi">ask before it designs</span></h1>
<div class="sub">Before <code>design-spec</code> writes a line of <code>design.md</code>, <code>design-interview</code> has to get the author to sign a Validated Direction.</div>

<div class="skill">

<div class="card wide">
<h3>The loop it enforces</h3>

```mermaid {scale: 0.55}
flowchart LR
    R["requirements.md<br/>status: accepted"] --> C["read the code<br/>the criteria name"]
    C --> P["propose<br/>“Here's what I'm thinking…”"]
    P --> I["interview<br/>one topic at a time"]
    I --> W["for choices with no criterion:<br/>“why must it work this way?”"]
    W --> V["Validated Direction<br/>author signs off"]
    V --> D["design.md · tasks.md<br/>convention checks"]
    %% highlight classes (hex on purpose: Mermaid renders in a shadow DOM and cannot see tokens.css)
    classDef gold fill:#3b2f00,stroke:#fbbf24,color:#fde68a
    classDef mint fill:#052e2b,stroke:#6ee7b7,color:#e5e7eb
    classDef violet fill:#2a2450,stroke:#c4b5fd,color:#e5e7eb
    class P,I violet
    class W gold
    class V mint
```

</div>

<div v-click class="card">
<h3>Stops when it can answer three things</h3>
<ol class="three">
<li><b>What is the main approach?</b></li>
<li><b>What are the 1–2 constraints</b> the design must respect?</li>
<li><b>Which technology choices</b> differ from the default pattern?</li>
</ol>
<p class="fine">Scale, risk, and integration probes are optional. Clear, small stories skip the interview.</p>
</div>

<div v-click class="card">
<h3>What the author signs</h3>
<pre class="vd"><span class="k">## Validated Direction</span>
<span class="req">**Approach:**</span>            author-agreed summary
<span class="req">**Key Constraints:**</span>     what the solution must respect
<span class="req">**Technology Decisions:**</span> what and why
**Risk Areas:**          or "none"
**Rejected Alternatives:** or "none"
**Open Questions:**      or "none"</pre>
<p class="fine"><span class="req">Mandatory</span> sections map one-to-one onto <code>design.md</code>.</p>
</div>

<div v-click class="card">
<h3>Why it exists</h3>
<p class="quote">“…so that any downstream artifact reflects agreed-upon choices, <b>not agent-only assumptions</b>.”</p>
<div class="chips">
<span class="chip">agent-agnostic · Claude, Copilot, Codex</span>
<span class="chip mint">personas are skills</span>
<span class="chip gold">humans approve, agents recommend</span>
</div>
</div>

</div>

<div class="foot"><span>.agents/skills/design-interview/SKILL.md · docs/process/collaboration.md, stage 2</span><span>1 of 3</span></div>

<!--
This is the skill we wrote yesterday and dogfooded today. The key move: the agent cannot write design.md until the author has signed a Validated Direction. It proposes first, asks one topic at a time, and has to challenge any design choice that has no acceptance criterion behind it. The output template is the same shape as design.md, so nothing signed gets lost in translation.
-->

---

<div class="eyebrow">Yugastore · spec #2 · change pricing rules without a redeploy</div>
<h1 class="title small">The design was <span class="hi">interviewed</span> into existence</h1>
<div class="sub">One developer, one agent, fourteen questions over four rounds. The agent proposed, asked, taught when asked, and only then wrote <code>design.md</code>.</div>

<div class="flow">

<div class="round" data-n="Round 1 · decisions">
<h3>Pick the mechanics</h3>
<div class="bubble agent"><b>Agent:</b> Reload? Failure mode? Which diagrams?</div>
<div class="bubble human"><b>Travis:</b> Poll mtime every 5 s. <b>Resilience4j breaker.</b> Service map, scenarios, schema.</div>
<div class="bubble human"><b>Travis:</b> Price shape? <b>I want to brainstorm more</b> so I understand.</div>
</div>

<div v-click class="round pivot" data-n="Round 2 · brainstorm">
<h3>Agent pauses to teach</h3>
<div class="bubble agent"><b>Agent:</b> Today three readers use <code>price</code>. Option A overwrites it; B adds a field every reader must learn; C puts a second applier in checkout.</div>
<div class="bubble agent"><b>Agent:</b> Comparison table: touchpoints × risk × semantics.</div>
<div class="bubble human"><b>Travis:</b> <b>A.</b> And keep the table for the deck.</div>
</div>

<div v-click class="round" data-n="Round 3 · no-criterion calls">
<h3>Why must it work this way?</h3>
<div class="bubble agent"><b>Agent:</b> Listing rows only know one category. Gap or extra query?</div>
<div class="bubble human"><b>Travis:</b> Accept the gap. No gateway route. Typed rules file. Ties by file order.</div>
</div>

<div v-click class="round done" data-n="Sign-off · then write">
<h3>Validated direction first</h3>
<div class="bubble agent"><b>Agent:</b> Approach, constraints, tech decisions, risks, rejected. Accurate?</div>
<div class="bubble human"><b>Travis:</b> Yes. Write design.md and tasks.md. Label the issue, hold the rest.</div>
<div class="bubble agent"><b>Agent:</b> Convention check found a <b>spec drift</b>: 12 criteria on master, 13 mapped. Fixed and logged.</div>
</div>

</div>

<div v-click class="stats">
<div class="stat"><b>14</b><span>questions asked</span></div>
<div class="stat"><b>11</b><span>alternatives rejected on record</span></div>
<div class="stat"><b>6</b><span>diagrams produced</span></div>
<div class="stat"><b>1</b><span>spec drift caught</span></div>
<div class="legend"><span><i style="background:var(--agent)"></i>agent</span><span><i style="background:var(--human)"></i>human</span><span><i style="background:var(--gold)"></i>the pivot</span></div>
</div>


<div v-click class="cmp">
<div class="cmp-title">The round-2 artifact · how should the discounted price reach checkout?</div>
<table>
<thead><tr><th>Option</th><th>Readers that must change</th><th>Risk if one is missed</th><th><code>price</code> means</th></tr></thead>
<tbody>
<tr class="pick"><td><b>A</b> · <code>price</code> effective + <code>originalPrice</code></td><td>storefront only, to show the original</td><td>none, the discount flows by default</td><td>effective price</td></tr>
<tr><td><b>B</b> · keep <code>price</code> base + <code>effectivePrice</code></td><td>storefront, cart, checkout, gateway</td><td>discount shown, full price charged</td><td>list price</td></tr>
<tr><td><b>C</b> · checkout applies rules too</td><td>storefront, checkout</td><td>two appliers drift on rounding or ties</td><td>effective price</td></tr>
</tbody>
</table>
</div>

<div class="foot"><span>docs/sessions/2026-09-16-pricing-rules-design/interview-log.md</span><span>2 of 3</span></div>

<!--
The point of this slide: the agent did not write and ask for approval. It asked first. The gold card is the moment Travis said "I want to brainstorm more" and the agent switched from recommending to teaching. Every bubble here is in the interview log verbatim.
-->

---

<div class="eyebrow">The proof · specs/pricing-rules-without-redeploy/design.md</div>
<h1 class="title small">What the conversation <span class="hi">produced</span></h1>
<div class="sub">A file-driven rules service. Products applies the largest discount and keeps <code>price</code> effective, so checkout is correct unchanged.</div>

<div class="design">

<div class="card tall">
<h3>Service map</h3>

```mermaid {scale: 0.55}
flowchart LR
    M([Merchandiser]) -->|edits| F[(pricing-rules.json)]
    F -.->|poll mtime every 5 s| PR
    PR["pricing-rules :8087 · new<br/>load · validate · GET /rules"]
    P["products :8082<br/>breaker + cache<br/>largest percent-off<br/>price = effective"]
    GW["gateway :8081<br/>keeps new fields"]
    UI["react-ui :8080<br/>strikes original"]
    CK["checkout :8086<br/>unchanged"]
    PR -->|GET rules| P
    P --> GW --> UI
    P --> CK
    %% highlight classes (hex on purpose: Mermaid renders in a shadow DOM and cannot see tokens.css)
    classDef gold fill:#3b2f00,stroke:#fbbf24,color:#fde68a
    classDef mint fill:#052e2b,stroke:#6ee7b7,color:#e5e7eb
    classDef violet fill:#2a2450,stroke:#c4b5fd,color:#e5e7eb
    class PR,P gold
    class GW,UI mint
```

</div>

<div class="card">
<h3>Scenario 4 · rules service down</h3>

```mermaid {scale: 0.42}
sequenceDiagram
    participant Any as gateway / checkout
    participant P as Products
    participant B as breaker + cache
    participant R as Rules (down)
    Any->>P: any product read
    P->>B: rules()
    B-xR: GET rules fails
    Note over B: breaker opens
    B-->>P: [] fallback
    P-->>Any: {price 12.99}, no originalPrice
```

</div>

<div class="card">
<h3>Rules file · room for BOGO</h3>

```mermaid {scale: 0.4}
classDiagram
    direction LR
    class Rule {
        +id  non-empty, unique
        +type  percent_off · unknown skipped
        +match  exactly one key
        +percent  0..100
    }
    class Match {
        +asin
        +category
    }
    Rule --> Match
```

</div>

</div>

<div class="chips">
<span class="chip gold">13 criteria → 13 mapping rows</span>
<span class="chip mint">9 one-commit tasks</span>
<span class="chip">4 scenario sequences</span>
<span class="chip">11 rejected alternatives</span>
<span class="chip">6 diagrams, all top-down and light-themed in the repo</span>
</div>

<div class="foot"><span>branch pricing-rules-design-session · ADR 0002</span><span>every criterion mapped, every task traces · 3 of 3</span></div>

<!--
Walk the service map left to right: the merchandiser edits a file, the new service picks it up in under 30 seconds, products applies the discount, and everyone downstream just reads price. Then scenario 4: kill the rules service and the store keeps selling at base price. The class diagram shows the type field that leaves room for BOGO.
-->
