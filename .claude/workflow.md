---
last_modified: 2026-09-29
scope: repo layout, notebook pipeline, Quarto quirks, Git LFS, literature submodule
---

# Workflow

Read this before adding files or notebooks, rendering, or committing data.

## Repo layout

| Path | What it is |
|------|-----------|
| `index.qmd` | The manuscript. For now it holds YAML front matter plus Tristan's direction notes (see `design.md`), with no prose sections |
| `presentation.qmd` | RevealJS slides with the University of Mannheim SCSS theme (`theme.scss`). Three figure embeds are commented out, because the notebooks that produced them were deleted |
| `_quarto.yml` | The project config. Only the notebooks it lists are rendered by the project |
| `code/code-template.qmd` | Boilerplate for a new analysis notebook (tidyverse + here + sessioninfo) |
| `code/01_preparation/1.1_ess_to_parquet.qmd` | Converts the raw ESS CSV to a partitioned Parquet dataset. It only converts the raw-layer format: no cleaning, no recoding. It is idempotent and re-renders cheaply once the output is current |
| `code/01_preparation/1.2`–`1.4` | Party Facts coding of the ESS, CSES and EES party items (attachment, vote, batteries). They write `ext_*_pf_name` / `ext_*_pf_id` as in the eu25games release, to `data/02_processed/{ess,cses,ees}_party_pf.{csv,parquet}`. Each ends in a *Known Quirks* section that lists every hand decision |
| `code/01_preparation/1.5`–`1.8` | Share of reported party attachment over time: EES 2004–2024 (1.5), CSES IMD + module 6 1996–2024 (1.6), ESS rounds 1–11 (1.7), and the eu25games PID distribution (1.8). Exploratory. **They write nothing.** Their `title:` fields still carry old numbers (1.2–1.5) |
| `code/01_preparation/1.9_party_alliances.qmd` | The attachment-vote match rule. It builds the alias, alliance and lineage tables (`data/02_processed/pf_{aliases,alliances,lineage}.csv`) and writes the match files `{ess,cses,ees}_party_match.parquet`. See *Party matching* in `data.md` |
| `code/02_composition/2.1`–`2.4` | Partisan composition trees (attachment → vote → same party) for eu25games, EES, CSES and ESS. Each draws Mermaid flowcharts pooled, by period, by country and by country × period, plus leaf-share plots. They render as plain pages, not manuscript notebooks (see the comment in `_quarto.yml`) |
| `code/00_helper/` | `pf_code.R` (Party Facts coding helpers, checks, and the match rule `pf_match()` / `pf_match_route()`), `pid_tree.R` (composition-tree helpers), `copyR.R` (refreshes the raw file from a sibling clone), `glftrackeR.R` (auto-LFS tracking) |
| `data/` | See `data.md` |
| `references.bib` | APSR-format bibliography (~2,000 entries) |
| `images/` | Figures used by the deck |
| `literature/` | Git submodule for the private repo `LS-Konig/CSAP-lit`. Ask before opening (see `CLAUDE.md`) |

**Pipeline order.** `01_preparation` runs before `02_composition`. Within 01, 1.2–1.4 run
before 1.9, which reads their outputs. New numbered notebooks go in `code/`, following the
`NN_topic/N.N_name.qmd` convention.

There is no *analysis* code in the repo yet. The old pipeline (`code/01_preparation/` through
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
≤100 MB. There is no `summaries/` folder yet.

## Git LFS

Files larger than 100 MB must be tracked with LFS, because GitHub rejects larger plain blobs outright. Use
`code/00_helper/glftrackeR.R` (run it from the repo root) to auto-track any file above the
threshold before committing. It appends literal relative paths to `.gitattributes`, not globs.

**Not everything large belongs in the repo at all.** The whole of `data/01_raw/{eb,cses,ees}/`
is git-ignored. It is ~1.6 GB, against a `.git` already past 3 GB, and all of it can be re-downloaded. Apply the
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
