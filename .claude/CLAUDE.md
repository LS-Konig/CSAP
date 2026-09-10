# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Comparative study of **partisanship and affective polarization (AP) across 25 European democracies**, using the thermometer ratings and conjoint trust/dictator games from Hahm, Hilpert & König (2024). Authors: Tristan Muno and Thomas König, University of Mannheim. Targeted at APSR/general-interest.

**The framing is being restarted.** As of 2026-09-08 the repo was stripped back to a manuscript stub, the deck, the data and a notebook template, so that a new argument can be built without an older one arguing back. The notes at the top of `index.qmd` are the current direction — a sketch, not a specification. Do not treat them, or anything reconstructed from git history, as settled.

Nothing in the repo currently states a claim. Do not write toward one until Tristan fixes it. New analyses are exploratory by default; report estimates with their uncertainty, not verdicts.

### Recovering the old material

The superseded drafts, notes and analysis notebooks were deleted in commit `4651e2c` (backup) and the cleanup commit that follows it. Everything is recoverable:

```bash
git show 4651e2c:notes.qmd
git show 4651e2c:DECISIONS.md
git show 4651e2c:PAPER-DESIGN.md
git show 4651e2c:data/01_raw/external-data.md          # the old data inventory
git show 4651e2c:code/03_explanal/3.2_ap_measures.qmd  # AP measurement notebook
git show 4651e2c --stat                                # everything in the backup
```

Retrieve from history when a specific piece of prior work is wanted. Do not restore wholesale.

## Stack

- **R 4.6.1** at `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`, **not on `PATH`**. Packages come from the user library (`C:/Users/Tris/AppData/Local/R/win-library/4.6`). Two traps: `C:\Program Files\R\R-4.5.2` is a broken partial install (DLLs only, no `Rscript.exe`), and the 421-package `win-library/4.5` **cannot be loaded by 4.6** — compiled packages fail at `rlang.dll`. Install into 4.6 rather than trying to reuse it. There is deliberately **no renv** during active development; it will be re-introduced with `renv::init()` only when the directory is frozen for replication. Do not add `.Rprofile`, `renv/`, or `renv.lock` back before then.
- **Quarto 1.9.36** for all documents
- **brms** for Bayesian multilevel regression (Stan-based)
- **ggplot2 / ggpubr / ggrepel / ggdag** for visualization
- **Git LFS** for large data files (>100 MB)

## Commands

Because R is not on `PATH`, bare `quarto render` fails with "Unable to locate an installed version of R". Point Quarto at R first — `QUARTO_R` takes the **bin directory**, not the executable, and must be a real shell variable (it is ignored in a Quarto `_environment` file):

```powershell
$env:PATH = "C:\Program Files\R\R-4.6.1\bin;" + $env:PATH
$env:QUARTO_R = "C:\Program Files\R\R-4.6.1\bin"

quarto render index.qmd         # manuscript
quarto render presentation.qmd  # RevealJS deck
```

Quarto is configured with `freeze: auto`; delete the notebook's subdirectory under `_freeze/` to force re-execution (`--no-freeze` is not accepted on a single-file render — Quarto passes it through to pandoc, which errors). Rendered output goes to `_manuscript/` (git-ignored).

## Repo layout

| Path | What it is |
|------|-----------|
| `index.qmd` | The manuscript. Currently YAML front matter plus Tristan's direction notes — no prose, no sections |
| `presentation.qmd` | RevealJS slides, University of Mannheim SCSS theme (`theme.scss`). Three figure embeds are commented out where the notebooks that produced them were deleted |
| `code/code-template.qmd` | Boilerplate for a new analysis notebook (tidyverse + here + sessioninfo). Numbered notebooks go in `code/`, following the old `NN_topic/N.N_name.qmd` convention |
| `code/01_preparation/1.1_ess_to_parquet.qmd` | Converts the raw ESS CSV to a partitioned Parquet dataset. Raw-layer format conversion only — no cleaning, no recoding. Idempotent: re-renders cheaply once the output is current |
| `code/00_helper/` | `copyR.R` (refresh the raw file from a sibling clone), `glftrackeR.R` (auto-LFS tracking) |
| `data/` | See below |
| `references.bib` | APSR-format bibliography (~2,000 entries) |
| `images/` | Figures used by the deck |

There is no *analysis* code in the repo — only the ESS conversion notebook above. The old pipeline was written in `code/01_preparation/` through `code/04_models/` and lives only in git history; the derived data files it produced are still on disk (see below), so a new pipeline can start from those or from the raw release.

## Data

**One raw input**: `data/01_raw/eu25games2019.rds`, the published harmonized release of the Hahm et al. survey (Zenodo DOI [10.5281/zenodo.21294634](https://doi.org/10.5281/zenodo.21294634), v1.0.0, repo `LS-Konig/eu25games2019`). 103,685 respondent-waves × 847 columns, wide, xz-compressed to 29 MB but >1 GB in memory. Party Facts IDs are already merged onto every party-bearing item as `ext_*_pf_name` / `ext_*_pf_id`.

**The upstream codebook is the variable reference**, not anything in this repo: `C:/R/research/eu25games2019/code/08_codebook.html` (question wording in all 25 languages, empirical coded↔raw value maps) and `data/03_final/variable_crosswalk.csv` (variable → original Dynata code per wave) in that repo. Do not re-document variables here.

### Derived files still on disk

Produced by the deleted pipeline; usable, but nothing in the repo regenerates them.

- `data/02_processed/eu25games2019_long.rds` — 1 row = respondent × game × round
- `data/03_final/eu25games2019.rds` — the analysis frame: 22,858 respondents × 6 game rounds = 137,148 rows. Respondents who passed the attention check (`der_att_check_3`), completed the questionnaire, are not within-wave duplicates and played the games; each panelist reduced to their earliest game wave
- `data/03_final/thermo_long.rds` — thermometer ratings, long
- `data/03_final/{pid,eb,cses}_*.csv` — attachment-share series and item crosswalks from the external sources

Derived variable names in the analysis frame: `der_pid` (explicit partisan indicator), `der_vote_cat`, `der_partisan_type` (1 explicit / 0 vote-anchored / NA), `der_partisan_anchor`, `der_partisan_relationship` (`None`/`Co`/`Out` — this is the co-partisan indicator, there is no `der_copartisan`), `cj_pl2` (token allocation), `cj_treatment`, `cj_nationality_shown`. Published upstream names are used throughout — match the codebook, not older notebooks.

### Terminology and one design fact

Both survive the restart because they are about the data, not about any argument:

- The variable levels say `implicit`; in prose the neutral term is **vote-anchored**. Translate in prose, do not rename the data. Vote-anchored respondents are not *leaners* — leaners come from an attitudinal probe, these from vote recall — so never use the terms interchangeably.
- **Target and measurement mode are perfectly confounded** in the Hahm et al. data: thermometers are vertical-attitudinal, the conjoint is horizontal-behavioral, so the diagonal is unobserved. Any contrast across the two is therefore **attitudinal vs. behavioral**, never vertical vs. horizontal.

### External sources

On disk, **git-ignored**, freely re-downloadable from GESIS / cses.org:

- `data/01_raw/cses/{imd,mod5,mod6}/` — CSES Integrated Module Dataset, Module 5 (2016–2021, fully contained in the IMD), Module 6 (2021–2026, advance release only). The IMD is the only source carrying the branching closeness probe. Matching study IDs across releases needs care: the IMD splits two-elections-in-one-year (`DEU12002`/`DEU22002`, `GRC12015`/`GRC22015`) and regional samples (`BELF`/`BELW`)
- `data/01_raw/eb/` — Eurobarometer: Mannheim trend file 1970–2002, harmonised 2004–2021, EB 95.3, Central & Eastern EB 1990–1997 (1.4 GB). The attachment item runs 1975–1994 plus a single 2009 wave; the CEEB carries none — verify coverage wave by wave
- `data/01_raw/ees/{1999,2004,2009,2014,2019,2024}/` — European Election Studies. `data/01_raw/key-items.qmd` maps the PID, vote choice, like/dislike and PTV items to their per-wave question numbers
- `data/01_raw/ess/` — European Social Survey, a Data Wizard subset of the cumulative file: `Datafile-subset.csv` (1.5 GB, 430,581 × 2,836, rounds 1–11, 222 country × round cells) plus its codebook HTML, **which is the variable reference** — do not re-document ESS variables elsewhere. `code/01_preparation/1.1_ess_to_parquet.qmd` converts the CSV to `data/01_raw/ess/parquet/`, hive-partitioned `cntry=<X>/essround=<N>/`, ZSTD, missing codes untouched; read it with `arrow::open_dataset()` or DuckDB `read_parquet(..., hive_partitioning = true)` rather than touching the CSV. Round 10 is two stacked samples (`ESS10e03_3` and the self-completion `ESS10SCe03_2`) sharing `essround == 10`, separable only by `name`
- `data/01_raw/external/tripol/` — TRI-POL three-wave panel (ES/PT/IT + AR/CL); see `tripol.md`. The only external source with an attitudinal *and* a behavioral AP measure on the same respondents
- `data/01_raw/external/{carlin-love-2018,westwood-et-al-2015}/` — partisan trust-game and partisan-IAT reference studies

Codebook PDFs sit alongside each dataset but are untracked (`.gitignore` has a blanket `*.pdf` rule).

## Git LFS

Large files (>100 MB) must be tracked with LFS — GitHub rejects larger plain blobs outright. Use `code/00_helper/glftrackeR.R` (run from the repo root) to auto-track any file exceeding the threshold before committing; it appends literal relative paths to `.gitattributes`, not globs.

**Not everything large belongs in the repo at all.** The whole of `data/01_raw/{eb,cses,ees}/` is git-ignored: ~1.6 GB against a `.git` already past 3 GB, all of it re-downloadable. Apply the same test before LFS-tracking anything new.

Nothing is LFS-tracked at present. `.gitattributes` still carries an entry for `data/01_raw/external/cses/mod6/cses6.rdata`; that path no longer exists (the file moved to the ignored `data/01_raw/cses/`), so the line is inert — harmless, but do not take it as a live rule.

Two caveats when you do track something:

- The helper's threshold **is** the hard limit, so it misses files just under it. Check anything in the 50–100 MB band yourself.
- A file already `git add`-ed as a plain blob stays plain even after `.gitattributes` gains its entry. Run `git rm --cached <file>`, stage `.gitattributes`, then re-add the file so the LFS filter applies. Verify with `git check-attr filter -- <file>`.
