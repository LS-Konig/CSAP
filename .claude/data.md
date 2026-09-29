---
last_modified: 2026-09-29
scope: raw input, variable references, party matching, derived files, external sources
---

# Data

Read this before editing any notebook in `code/`, joining sources, or reasoning about
coverage and item codings. The design constraints on how these data may be contrasted live in
`design.md`.

## Raw input

**One raw input**: `data/01_raw/eu25games2019.rds`, the published harmonized release of the
Hahm et al. survey (Zenodo DOI [10.5281/zenodo.21294634](https://doi.org/10.5281/zenodo.21294634),
v1.0.0, repo `LS-Konig/eu25games2019`). It has 103,685 respondent-waves × 847 columns in wide format. It is
xz-compressed to 29 MB but takes more than 1 GB in memory. Party Facts IDs are already merged onto every
party-bearing item as `ext_*_pf_name` / `ext_*_pf_id`.

**The upstream codebook is the variable reference**, not anything in this repo:

- `C:/R/research/eu25games2019/code/08_codebook.html`: question wording in all 25 languages, and empirical coded↔raw value maps.
- `data/03_final/variable_crosswalk.csv` in that repo: each variable mapped to its original Dynata code per wave.

Do not re-document variables here.

## Party matching

Whether a respondent's attachment party is the party they voted for is decided in one place,
`pf_match()` in `code/00_helper/pf_code.R`, with the tables of notebook 1.9, in all four
sources alike. Two answers are the **same party** by one of four routes:

1. an identical Party Facts name;
2. an **alias**, meaning an eu25games label for a listed party;
3. an **alliance** containing the other party, in either direction;
4. **lineage**: a party and the party it continued in through a rename, refoundation or merger. This route applies only in surveys from the year of the succession on.

These pairs are **different**:

- two members of one alliance;
- two predecessors of one successor;
- a breakaway and its parent.

The tables are pairwise and never chained.

Lineage counting as *same* is a deliberate choice (Tristan, 2026-09-29). `pf_match_route()`
and the `ext_route_*` columns of the match files record the route of every *same*, so an
analysis can exclude lineage. Change the rule only in 1.9 and `pf_code.R`, never per notebook.

## Derived files still on disk

The deleted pipeline produced these. They are usable, but nothing in the repo regenerates them.

- `data/02_processed/eu25games2019_long.rds`: one row per respondent × game × round.
- `data/03_final/eu25games2019.rds`: the analysis frame, 22,858 respondents × 6 game rounds
  = 137,148 rows. It keeps respondents who passed the attention check (`der_att_check_3`),
  completed the questionnaire, are not within-wave duplicates, and played the games. Each
  panelist is reduced to their earliest game wave.
- `data/03_final/thermo_long.rds`: thermometer ratings in long format.
- `data/03_final/{pid,eb,cses}_*.csv`: attachment-share series and item crosswalks from the
  external sources.

Derived variable names in the analysis frame:

- `der_pid`: the explicit partisan indicator.
- `der_vote_cat`.
- `der_partisan_type`: 1 explicit, 0 vote-anchored, NA otherwise.
- `der_partisan_anchor`.
- `der_partisan_relationship`: `None`/`Co`/`Out`. This is the co-partisan indicator. There is no `der_copartisan`.
- `cj_pl2`: the token allocation.
- `cj_treatment`.
- `cj_nationality_shown`.

Published upstream names are used throughout. Match the codebook, not older notebooks.

The old data inventory: `git show 4651e2c:data/01_raw/external-data.md`.

## Terminology

The variable levels say `implicit`. In prose, the neutral term is **vote-anchored**. Translate in
prose, but do not rename the data. Vote-anchored respondents are not *leaners*: leaners come
from an attitudinal probe, these from vote recall. Never use the two terms interchangeably.

## External sources

These are on disk, **git-ignored**, and freely re-downloadable from GESIS and cses.org. Codebook PDFs sit
alongside each dataset but are untracked, because `.gitignore` has a blanket `*.pdf` rule. Ask before
opening them (see `CLAUDE.md`).

- `data/01_raw/cses/{imd,mod5,mod6}/`: the CSES Integrated Module Dataset, Module 5 (2016–2021,
  fully contained in the IMD), and Module 6 (2021–2026, advance release only). The IMD is the only
  source carrying the branching closeness probe. Matching study IDs across releases needs
  care, because the IMD splits two elections held in one year (`DEU12002`/`DEU22002`,
  `GRC12015`/`GRC22015`) and regional samples (`BELF`/`BELW`).
- `data/01_raw/eb/`: Eurobarometer. It holds the Mannheim trend file 1970–2002, the harmonised files 2004–2021,
  EB 95.3, and the Central & Eastern EB 1990–1997 (1.4 GB in total). The attachment item runs 1975–1994,
  plus a single 2009 wave. The CEEB carries none. Verify coverage wave by wave.
- `data/01_raw/ees/{1999,2004,2009,2014,2019,2024}/`: European Election Studies.
  `data/01_raw/key-items.qmd` maps the PID, vote choice, like/dislike and PTV items to their
  per-wave question numbers.
- `data/01_raw/ess/`: the European Social Survey, as a Data Wizard subset of the cumulative file.
  `Datafile-subset.csv` is 1.5 GB (430,581 × 2,836, rounds 1–11, 222 country × round cells) and comes with
  its codebook HTML, **which is the variable reference**. Do not re-document ESS variables
  elsewhere. `code/01_preparation/1.1_ess_to_parquet.qmd` converts the CSV to
  `data/01_raw/ess/parquet/`, hive-partitioned `cntry=<X>/essround=<N>/`, ZSTD, with missing codes
  left untouched. Read it with `arrow::open_dataset()` or DuckDB `read_parquet(...,
  hive_partitioning = true)` rather than touching the CSV. Round 10 is two stacked samples
  (`ESS10e03_3` and the self-completion `ESS10SCe03_2`) that share `essround == 10` and are
  separable only by `name`.
- `data/01_raw/external/tripol/`: the TRI-POL three-wave panel (ES/PT/IT + AR/CL); see
  `tripol.md`. It is the only external source with both an attitudinal *and* a behavioral AP measure on the
  same respondents.
- `data/01_raw/external/{carlin-love-2018,westwood-et-al-2015}/`: reference studies for the partisan trust game
  and the partisan IAT.
