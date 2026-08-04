# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Comparative study of affective polarization (AP) across 25 European democracies (~29,800 respondents), using the thermometer ratings and conjoint trust/dictator games from Hahm, Hilpert & König (2024). Authors: Tristan Muno and Thomas König, University of Mannheim.

The paper is targeted at APSR/general-interest. Its subject is a measurement choice: AP is estimated on partisans, so someone must decide who counts as one. The study holds the partisan anchor constant and varies only whether the respondent *reports* attachment, comparing self-identified partisans against vote-anchored respondents who deny feeling close to any party. See `## The paper` for the argument, section structure, and what is deliberately out of scope.

## The paper

### Central claim

Every section serves this claim. Recorded verbatim — do not paraphrase it away:

> Vote-anchored partisans who deny feeling close to a party discriminate against out-partisans just as much as self-identified partisans do — yet they report substantially less party-directed animus. Self-reported attachment inflates measured polarization without corresponding to any additional discrimination in behavior.

### Phrasing rule (critical)

**Never** write the behavioral result as "no behavioral AP" or as "attachment does not correspond to behavioral discrimination." Both partisan types show large, credibly non-zero copartisan effects in the games (β₁). The finding is that this effect does **not differ by type** (β₃ ≈ 0).

- The results section must report the magnitude of β₁ **before** discussing β₃, so the reader sees the effect exists before being told it does not vary.
- β₁ is also the paper's primary evidence that the instrument has power — cite it when addressing the "the null reflects weak design" objection.

β₁/β₃ index the linear predictor sketched at `notes2.qmd:68`: `outcome = α + β₁·copartisan + β₂·type + β₃·copartisan×type`.

### Argument chain (roter Faden)

1. AP is measured on partisans, so someone must decide who counts.
2. In Europe the attachment item does not cleanly identify partisans (Converse & Dupeux; Thomassen — attachment reports the vote rather than preceding it; attachment shares range ~41% LV to ~85% DK).
3. Coding choices therefore shift the population of inference differently in each country.
4. The literature makes this choice, mostly silently. → **EMPIRICAL CLAIM 1**
5. Whether it distorts conclusions is answerable: hold the anchor constant, vary the reporting.
6. Answer depends on the measure — large attitudinal gap, no behavioral gap. → **EMPIRICAL CLAIM 2**
7. Therefore attachment behaves like a reporting disposition, not an identity.

Sections 3, 6, 7 are load-bearing. Sections 2 and 4 make them necessary. Sections 5 and 8 are calibration. Everything else is appendix.

### Section structure

1. **Introduction** — claim in the first paragraph. Names what it contradicts: standard coding practice and the identity literature.
2. **What attachment measures in Europe** — 3–4 pages, not a review. Engages Bankert/Huddy expressive partisanship as the strongest counter. Key distinction: attachment as a binary *selection filter* vs. as a graded identity measure. Taxonomy (PIDs / vote-anchored / non-partisans) as a figure.
3. **Coding practice in comparative AP research** — EMPIRICAL CLAIM 1. Census (not sample) of comparative/European AP articles in a named journal set over defined years, hand-coded on two dimensions only: ingroup criterion, non-identifier treatment. Target ~40 papers. *Journal set and year range are not yet fixed — Tristan will specify.*
4. **Design: holding the anchor constant** — the section referees will attack. See assumptions below.
5. **Attitudinal result** — explicit/implicit gap in thermometer AP. Framed as the *contrast case*, not the finding; concede the partly mechanical correlation between the attachment item and the thermometer. Country heterogeneity as one figure here, not a separate section.
6. **Behavioral result** — EMPIRICAL CLAIM 2. The null, properly tested.
7. **Does attachment do work, or mark prior investment?** — within-person panel leg. MAIN TEXT, not appendix.
8. **What this does to comparative estimates** — four ingroup codings, country rank correlations.
9. **Discussion** — measurement implication first; theory implication ceilinged; limitations owned.

### Assumptions and how each is tackled

- **Groups not otherwise comparable.** Party-within-country varying intercepts and slopes; contrast estimated inside party-country cells. Report balance. State plainly: rules out composition, does NOT identify a causal effect.
- **Recall-maximizing rule assigns anchor by fiat for defectors** (attachment party ≠ vote party). Code both anchors for defectors; test which predicts ratings and allocations.
- **Vote-anchored ≠ leaners.** Leaners come from an attitudinal probe, ours from vote recall. Use the CSES branching probe to estimate overlap. The paper uses the neutral term "vote-anchored" and discusses the relation to leaners explicitly.
- **A null needs an equivalence test.** Pre-specified ROPE in token units, justified against the size of the copartisan main effect. Report posterior mass inside the ROPE. Overlapping intervals are not evidence of equivalence.
- **Null could be weak design.** Benchmark the partisan attribute against EU position, class, and religion within the same conjoint.
- **Ten hypothetical tokens may not be where identity shows up.** Unresolvable. Concede in the discussion before a referee raises it.
- **Panel leg may lack within-person movement.** Check the attachment transition matrix BEFORE committing to section 7. If thin, drop the section rather than report underpowered results.
- **Rank correlations across codings may be ~0.95.** Committed in advance to reporting either way — a deflationary result is still a contribution. Note that most-liked-party coding selects on the outcome and is mechanically inflationary.

### Design confound (stated in section 4, not in limitations)

Target and measurement mode are perfectly confounded in the Hahm et al. data: thermometers are vertical-attitudinal, the conjoint is horizontal-behavioral, so the diagonal cannot be separated. The claim is therefore **attitudinal vs. behavioral**, never vertical vs. horizontal.

### Dropped, demoted, promoted

Recorded so none of it creeps back:

- **DROPPED: the LLM literature-classification pipeline** (200 hand-coded papers, classifier validation, per-dimension κ thresholds, OSF preregistration of the coding scheme). Replaced by the hand-coded census in section 3. The pipeline remains viable as a separate standalone paper — the Part I/Part II notes stay in the repo (`index.qmd`, see `### Documents`), flagged out of scope for this manuscript.
- **DROPPED: vertical/horizontal as the headline framing.** Retained only as a conceptual 2×2 inside section 6, explaining why the answer splits.
- **DEMOTED: identity vs. categorization debate.** Still generates the competing predictions in the theory section, but the adjudication claim moves to the discussion with an explicit ceiling: the design cannot separate attachment *creating* investment from *marking* it.
- **DEMOTED: individual-level moderators.** Appendix, labelled either preregistered or exploratory — no middle option. Not a third results section.
- **PROMOTED: external panel data** from robustness to main text (section 7). One country, done properly, beats several done shallowly.

### Standing rule

Before adding any analysis to the manuscript, ask whether it changes step 7 of the argument chain. If not, it belongs in the appendix. Analyses run "to see whether they pay off" are exploratory by definition and go in the appendix or a separate document.

## Stack

- **R 4.5.3** — packages come from the user library (`C:/Users/Tris/AppData/Local/R/win-library/4.5`). There is deliberately **no renv** during active development; it will be re-introduced with `renv::init()` only when the directory is frozen for replication. Do not add `.Rprofile`, `renv/`, or `renv.lock` back before then.
- **Quarto 1.9.36** for all documents (manuscript, analysis notebooks, presentation)
- **brms** for Bayesian multilevel regression (Stan-based)
- **ggplot2 / ggpubr / ggrepel / ggdag** for visualization
- **Git LFS** for large data files (>100 MB)

## Commands

**Render the full manuscript (HTML + PDF + DOCX):**
```bash
quarto render index.qmd
```

**Render a single analysis notebook:**
```bash
quarto render code/03_explanal/3.2_ap_measures.qmd
```

**Render the presentation:**
```bash
quarto render presentation.qmd
```

Quarto is configured with `freeze: auto` — code chunks that have already been executed are cached; re-run only changed chunks. To force a full re-render, delete the `_freeze/` directory first.

## Architecture

### Data pipeline

```
data/01_raw/          → data/02_processed/      → data/03_final/
(raw survey files)      (harmonized RData)         (analysis-ready RDS)
```

The main analysis object is `eu25games2019` (stored as both `.RData` in `02_processed/` and `.rds` in `03_final/`). Thermometer scores are in `thermo_long.rds`.

### Code pipeline (numbered, sequential)

| Directory | Purpose |
|-----------|---------|
| `code/00_helper/` | Utility scripts: `copyR.R` (data copying), `glftrackeR.R` (auto-LFS tracking) |
| `code/01_preparation/` | Data loading from multiple raw sources (1.1), party harmonization (1.2), codebook (1.3) |
| `code/02_key_variables/` | Partisan identity variable construction (explicit vs. implicit partisans, anchor) |
| `code/03_explanal/` | Descriptive analyses (3.1) and AP measurement (3.2) — these two are the featured notebooks |
| `code/04_models/` | Bayesian regression models via brms |
| `code/literature-overview.qmd` | Systematic coding of comparative AP studies |

### Key variables

- `der_pid` — derived party ID (explicit partisan indicator)
- `der_vote_cat` — vote category (explicit / implicit / non-partisan)
- `der_partisan_anchor` — the party a respondent is anchored to
- `der_copartisan` — co-partisan indicator in the trust game
- Thermometer scores — the **attitudinal** AP measure; conjoint token allocations are the **behavioral** measure

**Terminology mapping (code vs. manuscript).** The variables still use `implicit`; the manuscript prose uses the neutral term **vote-anchored**. Keep the variable levels as they are and translate in prose. Vote-anchored respondents are not the same thing as *leaners* — leaners come from an attitudinal probe, these from vote recall — so never use the terms interchangeably; section 4 estimates the overlap using the CSES branching probe.

Four ingroup codings are compared in section 8: identity only; recall-maximizing (attachment, else vote); vote only; most-liked party.

### Documents

- `index.qmd` — primary manuscript (`draft: true`, draft mode visible). Currently also carries, in order: the core argument chain (`index.qmd:19`), working notes, then **Part I: Project Roadmap** (`index.qmd:113`) and **Part II: Coding Scheme & Instructions** (`index.qmd:305`).
  - **Part I/Part II are the dropped LLM literature-classification pipeline.** They stay in the repo as material for a possible separate paper, but are **out of scope for this manuscript** — do not draw on them when working on the sections above, and do not fold them into section 3, which is hand-coded.
- `data/01_raw/external-data.md` — **the data inventory.** Every dataset the project uses or plans to use, with a collected / not-downloaded / access-gated status mark, the role each source plays in the argument chain, and the cross-source comparability caveats. Section 7 panel candidates are listed there. Update it whenever a dataset is downloaded, moved, or ruled out; it used to live in `index.qmd` and must not drift back there.
- `presentation.qmd` — RevealJS slides with University of Mannheim SCSS theme (`theme.scss`)
- `notes.qmd` / `notes2.qmd` — working research notes; contains the partisan taxonomy framework and variable construction logic. The restructuring brief this file records is pasted at `notes2.qmd:261`–394; note that everything in `notes2.qmd` *above* that brief predates it and describes the superseded vertical/horizontal framing.
- `code/code-template.qmd` — boilerplate for new analysis notebooks (tidyverse + here + sessioninfo setup)
- `references.bib` — APSR-format bibliography (~2,000+ entries)

### External data

**`data/01_raw/external-data.md` is the authoritative inventory** — read it before looking for a dataset or proposing a new one. It covers both the collected sources and the planned ones, with status marks and access notes. What follows is a summary only; keep the two in sync, and put new detail in the inventory rather than here.

`data/01_raw/external/` holds supporting sources, separate from the main Hahm et al. file in `data/01_raw/hahmetal-data/`:

- `cses/imd/` — CSES Integrated Module Dataset. The only source carrying the branching closeness probe, so the sole basis for the leaner-overlap estimate in section 4 and for splitting "no attachment" into leaners vs. true non-partisans.
- `cses/mod5/` — CSES Module 5 (2016–2021). Closest module in time to the 2019 Hahm et al. fieldwork; use for period-matched attachment shares.
- `cses/mod6/` — CSES Module 6 (2021–2026). **Advance release only** — coverage will change on full release, so any Module 6 result is provisional.
- `mannheim-eurobarometer-trend-file-1970-2002/` — long-run attachment decline; carries both attachment and party preference, so the split is constructible back to the early 1970s. Item coverage varies by wave — verify wave by wave.
- `carlin-love-2018/`, `westwood-et-al-2015/` — partisan trust-game and partisan-IAT reference studies; out-of-sample benchmarks for the behavioral result.

Codebook PDFs sit alongside each dataset on disk but are untracked — `.gitignore` has a blanket `*.pdf` rule.

**The section 7 panel is not yet chosen or downloaded.** Candidates, with links and notes, are in the inventory under "Section 7 panel candidates": GLES Panel 2016–2021 (DE), BES Internet Panel (UK), LISS (NL), POLAT (ES, 12 waves), AUTNES Online Panel (AT), TRI-POL (ES/PT/IT), Finnish panel. The choice is gated on the attachment transition matrix — check within-person movement before committing, and exactly one gets downloaded.

### Output

Quarto writes rendered output to `_manuscript/` (git-ignored). Notebooks embed resources for portability (`embed-resources: true`).

## Git LFS

Large files (>100 MB) must be tracked with LFS — GitHub rejects larger plain blobs outright. Use `code/00_helper/glftrackeR.R` (run from the repo root) to auto-track any file exceeding the threshold before committing; it appends literal relative paths to `.gitattributes`, not globs.

Currently LFS-tracked: `data/01_raw/external/mannheim-eurobarometer-trend-file-1970-2002/ZA3521_v2-0-1.dta` (228 MB) and `data/01_raw/external/cses/mod6/cses6.rdata` (89 MB).

Two caveats:

- The helper's threshold **is** the hard limit, so it misses files just under it. `cses6.rdata` at 89 MB had to be added by hand — check anything in the 50–100 MB band yourself.
- A file already `git add`-ed as a plain blob stays plain even after `.gitattributes` gains its entry. Run `git rm --cached <file>`, stage `.gitattributes`, then re-add the file so the LFS filter applies. Verify with `git check-attr filter -- <file>`.
