---
last_modified: 2026-11-12
scope: repo layout, notebook pipeline, Quarto quirks, Git LFS, literature submodule and summaries
---

# Workflow

Read this before adding files or notebooks, rendering, or committing data.

## Repo layout

| Path | What it is |
|------|-----------|
| `index.qmd` | The manuscript (it becomes the paper source). Since 2026-11-09 a workshop draft: argument (§1–3) and high-level design (§4) in prose, placeholder callouts for the empirical sections (§5–8), a Limitations and Open Issues section (§9) that collects everything not to forget, and the partisanship-items table in the appendix. No empirics yet. The previous notes are in git history (`10a9442`) |
| `presentation_uottawa.qmd` | RevealJS slides (rendered output `presentation_uottawa.html`, kept in git for documentation) with the University of Mannheim SCSS theme (`theme.scss`). Three figure embeds are commented out, because the notebooks that produced them were deleted |
| `presentation_hms.qmd` | German 10-minute deck for the Hanns Martin Schleyer-Stiftung (Berlin, October 2026), same theme. It recomputes the eu25games composition sample of notebook r2.01 (reading the raw release, chunk cached). Its result slides read only `data/05_results/eu25_ap_post.rds` (notebook r2.03), so the deck renders without loading any fit. `images/eu25-thermo-ie.png` is cropped from the Irish wave-3 questionnaire in the sibling `eu25games2019` repo |
| `argument.qmd` | The argument ledger: every argumentative step as premises ⇒ conclusion, by RQ, each marked agreed or open. Tristan's working file; not rendered by the project. Add a step only once it is agreed |
| `_quarto.yml` | The project config. Only the notebooks it lists are rendered by the project |
| `code/code-template.qmd` | Boilerplate for a new analysis notebook (tidyverse + here + sessioninfo) |
| `code/01_prep/1.01_ess_parquet.qmd` | Converts the raw ESS CSV to a partitioned Parquet dataset. It only converts the raw-layer format: no cleaning, no recoding. It is idempotent and re-renders cheaply once the output is current |
| `code/01_prep/1.02`–`1.04` | Party Facts coding of the ESS, CSES and EES party items (attachment, vote, batteries). They write `ext_*_pf_name` / `ext_*_pf_id` as in the eu25games release, to `data/02_processed/{ess,cses,ees}_party_pf.{csv,parquet}`. Each ends in a *Known Quirks* section that lists every hand decision |
| `code/01_prep/1.05`–`1.08` | Share of reported party attachment over time: EES 2004–2024 (1.05), CSES IMD + module 6 1996–2024 (1.06), ESS rounds 1–11 (1.07), and the eu25games PID distribution (1.08). Exploratory. **They write nothing.** |
| `code/01_prep/1.09_all_match.qmd` | The attachment-vote match rule. It builds the alias, alliance and lineage tables (`data/02_processed/pf_{aliases,alliances,lineage}.csv`) and writes the match files `{ess,cses,ees}_party_match.parquet`. See *Party matching* in `data.md` |
| `code/02_types/2.01`–`2.04` | Partisan composition trees for eu25games, EES, CSES and ESS. Each opens with a *Question Order* table of every turnout, vote and attachment item, with sources. The tree levels follow that order: vote → attachment → leaner probe → same party where the vote came first (all but CSES module 3). There is a leaner level where a probe exists (CSES, EES 2009). Each notebook draws Mermaid flowcharts pooled, by period, by country and by country × period, a faceted leaf-share plot, and HMS-deck style country bars, pooled and by period in tabs. They render as plain pages, not manuscript notebooks (see the comment in `_quarto.yml`) |
| `code/02_types/2.01_eu25_types.qmd` (output) | Also writes `data/02_processed/eu25_partisan.rds`, the eu25games partisan classification that r2.01 builds on |
| `code/02_types/2.01`–`2.04` (weights, type files) | Shares and figures are weighted (see *Weights* in `data.md`); trees show unweighted N and weighted shares. Each notebook ends with a weighted-vs-unweighted table and writes `{source}_types.parquet` |
| `code/rq1_who/r1.01_all_cells.qmd` | Composition over time without a model: survey × country cells from the four type files, one line per source and one figure per type (weighted and unweighted tabs), coverage and overlap tables, and leaners among deniers. Writes `composition_cells.parquet` |
| `code/rq1_who/r1.02_all_model.qmd` | Multinomial brms model of the cells (source offsets, a European spline, country levels and slopes, a cell effect), fitted with cmdstanr. A `full_fit` switch as in r2.02 caches fits in `data/04_models/` and writes `data/05_results/composition_post.rds`. Not listed in `_quarto.yml` |
| `code/rq2_what/r2.01_eu25_prep.qmd` | eu25games analysis data. Carried variables are set in its *Variables* section. Sample and within-wave duplicate handling, partisan type and anchor, display-aware conjoint attributes, the pooled wave-2+3 composition figure, and two long datasets: `data/03_final/eu25_games.rds` (one row per round) and `eu25_thermo.rds` (one row per party rating). No models |
| `code/rq2_what/r2.02_eu25_ap-model.qmd` | Model set-up for the within-party explicit vs. vote-anchored AP contrast in the games and the thermometers: DAG, estimand code (g-computation on the common support), Gaussian and beta-binomial brms models, prior and posterior predictive checks. A `full_fit` switch. `TRUE` (current) fits the full samples, caches every fit (prior-only fits included) as `data/04_models/<name>.rds` (git-ignored), and writes sampler progress to the terminal and to `data/04_models/logs/` (`progress.log` plus one log per model). `FALSE` runs everything on a 10% development subsample and saves nothing. Not listed in `_quarto.yml`, so `freeze` does not apply: only the brms file cache makes re-renders cheap |
| `code/rq2_what/r2.03_eu25_ap-post.qmd` | Posterior post-processing of r2.02's four cached fits (never refits). Rebuilds r2.02's estimation data verbatim (keep the two in sync), computes AP, ΔAP and the cross-measure difference by g-computation once per model by country (pooled = weight-averaged country means), checks the pooled values against r2.02's output, and writes `data/05_results/eu25_ap_post.rds` (draws, Pr(>0)-ready). Not listed in `_quarto.yml`; a render takes long because it loads ~2.2 GB of fits |
| `code/rq2_what/r2.04_eu25_ap-loo.qmd`, `r2.05_eu25_ap-ppc.qmd` | LOO and estimand-focused posterior predictive checks of r2.02's fits; write `data/05_results/eu25_{loo,ppc}.rds` |
| `code/rq3_where/`, `code/rq4_sowhat/` | Empty (`.gitkeep`) until RQ3 and RQ4 notebooks exist |
| `code/00_helper/` | `pf_code.R` (Party Facts coding helpers, checks, and the match rule `pf_match()` / `pf_match_route()`), `pid_tree.R` (composition-tree helpers), `copyR.R` (refreshes the raw file from a sibling clone), `glftrackeR.R` (auto-LFS tracking) |
| `data/` | See `data.md` |
| `references.bib` | APSR-format bibliography (~1,750 entries) |
| `images/` | Figures used by the deck |
| `literature/` | Git submodule for the private repo `LS-Konig/CSAP-lit`. `summaries/` may be read freely; ask before opening `md/` or `pdf/` (see `CLAUDE.md`) |

**Planned: a `presentation/` subfolder.** Move the deck into its own folder: `presentation_uottawa.qmd`, its rendered HTML, `theme.scss` and `images/` (the last two are used only by the deck). The bibliography then becomes `../references.bib`, and the render command in `CLAUDE.md` changes to match. Do this on `main` once the r2.02 fits and renders are finished, not while they are running.

**Notebook naming** (since 2026-11-12). Folder = stage, file = `<id>_<source>_<topic>.qmd`.

- Folders: numbered preparation stages (`01_prep`, `02_types`), then one folder per study named by its question word (`rq1_who`, `rq2_what`, `rq3_where`, `rq4_sowhat`). Digits sort before letters, so the folders list in pipeline order.
- `<id>`: stage code plus a two-digit sequence: `1.01`, `2.03`, `r1.02`, `r2.05`. Two digits keep sorting right past nine. In prose: "notebook r2.03".
- `<source>`: one of `ees`, `cses`, `ess`, `eu25`, or `all` (pooled sources).
- `<topic>`: one or two words joined by `-`, so `_` only separates the three parts.
- A new notebook takes the next free id in its folder and starts from `code/code-template.qmd`. A notebook rendered as a plain page (not a manuscript notebook) needs its folder in `page_dirs` in `code/00_helper/post_render.R`.

Renumbering on 2026-11-12: 1.1–1.9 → 1.01–1.09; 2.1–2.4 → 2.01–2.04; 2.5, 2.6 → r1.01, r1.02; 3.1–3.5 → r2.01–r2.05. The `_freeze/` entries of the old paths no longer apply, so moved notebooks re-execute on their next render.

**Pipeline order.** `01_prep` runs before `02_types`, and that runs before the RQ folders. Within 01, 1.02–1.04 run
before 1.09, which reads their outputs. 2.01–2.04 run before r1.01, and r1.01 before r1.02. r2.01 reads the partisan file that 2.01 writes. r2.03–r2.05 read the cached fits of r2.02; r2.03 writes `data/05_results/eu25_ap_post.rds`.

r2.01 prepares the data. r2.02 holds the first model set-up, not yet fully fitted. The old pipeline (`code/01_preparation/` through
`code/04_models/`) lives only in git history. The derived files it produced are still on
disk (see `data.md`), so a new pipeline can start from those or from the raw release. To
recover an old notebook:

```bash
git show 4651e2c:code/03_explanal/3.2_ap_measures.qmd  # AP measurement notebook
```

## Quarto

`freeze: auto`. To force re-execution, delete the notebook's subdirectory under `_freeze/`.
`--no-freeze` is not accepted on a single-file render: Quarto passes it through to pandoc,
which errors. Rendered output goes to `_manuscript/`, which is git-ignored. See `CLAUDE.md` for the
render commands. `QUARTO_R` must be set first.

## Literature submodule

`literature/` holds `pdf/` (book chapters in `pdf/<book>/`) and the pdf2md output in `md/`. It is
plain git, with no LFS. After cloning, run `git submodule update --init`. Push new PDFs in batches of
≤100 MB.

### Literature summaries

`literature/summaries/` is the retrieval layer: one working-notes summary per `md/` entry, named
by citekey. Start with `INDEX.md`, a routing table grouped by theme with a hook for each entry,
and `THEMES.md`, which maps each topic tag to its entries. Every summary has YAML (`role_in_csap`,
`topics`, `fulltext`) and nine fixed `## ` sections: Gist · Role in CSAP · Data · Design ·
Measures · Findings · Limits · Where to look · Quotable. Edited volumes add `## Chapters`, with one
`###` block per chapter citekey. Search breadth-first: INDEX/THEMES → summary → the full text, only
at the lines that "Where to look" names.

When new `md/` conversions arrive:

1. **Find the gaps.** List the `md/` folders that have no `summaries/<citekey>.md`, and check each
   citekey against `references.bib`.
2. **Draft with subagents.** Use `general-purpose` agents with `model: haiku` for articles and
   chapters, 3–5 papers each (≤ ~300 KB of text). Use `model: sonnet` for books, edited volumes and
   files ≥ 300 KB, one per book; split large handbooks by chapter range into part files and merge
   them. Each prompt carries a condensed project brief, the rule that no claim is settled, the
   template, `reiljan2020fear.md` as the exemplar, and the procedure. Agents read the full text,
   take metadata from the bib and flag mismatches, take line ranges from `grep -n '^#'`, and grep
   every quote back out of the source. Each agent returns `citekey | type | hook | tags | flags`.
3. **Route.** Regenerate `INDEX.md` and `THEMES.md` from the summaries' YAML and the agents'
   hooks. Do not re-read the full texts.
4. **Check by script.** Every summary has the nine sections and a citekey that matches its file
   name. Each `fulltext:` path exists, and each Quotable quote is found verbatim in its source.
   Report the agents' flags to Tristan.

## Git LFS

Files larger than 100 MB must be tracked with LFS, because GitHub rejects larger plain blobs outright. Use
`code/00_helper/glftrackeR.R` (run it from the repo root) to auto-track any file above the
threshold before committing. It appends literal relative paths to `.gitattributes`, not globs.

**Not everything large belongs in the repo at all.** The whole of `data/01_raw/{cses,ees}/`
is git-ignored. It is ~0.2 GB, against a `.git` already past 3 GB, and all of it can be re-downloaded. Apply the
same test before LFS-tracking anything new.

Nothing is LFS-tracked at present. `.gitattributes` still carries an entry for
`data/01_raw/external/cses/mod6/cses6.rdata`. That path no longer exists, because the file moved to the
ignored `data/01_raw/cses/`, so the line is inert. It is harmless, but do not take it as a live rule.

Two caveats when you do track something:

- The helper's threshold **is** the hard limit, so it misses files just under it. Check
  anything in the 50–100 MB band yourself.
- A file already `git add`-ed as a plain blob stays plain even after `.gitattributes` gains
  its entry. Run `git rm --cached <file>`, stage `.gitattributes`, then re-add the file so
  the LFS filter applies. Verify with `git check-attr filter -- <file>`.
