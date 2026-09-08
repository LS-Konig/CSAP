# Data inventory

Authoritative record of every dataset this project uses or plans to use, and whether it
is on disk. Update this file whenever a dataset is downloaded, moved, or ruled out.

The manuscript (`index.qmd`) no longer carries a dataset list — it points here.

## Status legend

| Mark | Meaning |
|---|---|
| ✅ | On disk in this repo |
| ⬜ | Identified, not yet downloaded |
| 🔒 | Requires registration, application, or a data-use agreement before download |
| ❌ | Considered and **ruled out** — kept so it is not re-proposed, with the reason stated |

Sizes are approximate. Codebook PDFs are present on disk but **not in the repo** —
`.gitignore` contains a blanket `*.pdf` rule (see [Storage and Git LFS](#storage-and-git-lfs)).

---

## A. Primary analysis data

Everything under `data/01_raw/` that is not in `external/`. There is exactly one primary
input, and it is externally published and citable.

| Status | File | Size | Role |
|---|---|---|---|
| ✅ | `eu25games2019.rds` | 29 MB | **The analysis source.** Harmonized release of the Hahm, Hilpert & König (2024) three-wave EU-elections survey, 25 European democracies, 103,685 respondent-waves × 847 columns, xz-compressed (>1 GB in memory). Carries the thermometer ratings (attitudinal AP), the conjoint dictator/trust games (behavioral AP), and Party Facts IDs merged onto every party-bearing item. |

**Provenance.** Muno, Tristan, and Thomas König. *eu25games2019: A cleaned three-wave EU
elections survey (2019) across 25 countries*. Zenodo, v1.0.0.
<https://doi.org/10.5281/zenodo.21294634> — source repo
<https://github.com/LS-Konig/eu25games2019>. Code is MIT; **the data is CC BY 4.0** and
carries a re-identification / ethical-use notice in the upstream `LICENSE`. Cite the
dataset *and* the source study (`@hahm2024divided`).

**Variable reference.** The upstream codebook, `eu25games2019/code/08_codebook.html`
(~11 MB), is authoritative: per-variable question wording in all 25 languages plus the
empirical coded↔raw value maps. `data/03_final/variable_crosswalk.csv` in that repo maps
each variable to its original Dynata code per wave. Do not re-document variables here.

**Refreshing the copy.** `code/01_preparation/1.1_datasets.qmd` has a `download_fresh`
flag that pulls the current `main` over HTTPS; `code/00_helper/copyR.R` copies from a
local sibling clone instead. The committed copy is what the manuscript renders against —
notebook 1.1 asserts its shape on load, so a changed upstream release fails fast.

Downstream pipeline:

```
01_raw/eu25games2019.rds
  │  1.1_datasets.qmd   clean, fold in the French fork, wide → long
  ▼
02_processed/eu25games2019_long.rds
  │  2.1_key_variables.qmd   partisan type T, anchor A, relationship R
  ▼
03_final/eu25games2019.rds  ──►  03_final/thermo_long.rds  (written by 3.2)
```

**Superseded and removed.** `hahmetal-data/aff_pol_df_analy_jan2023.RData` (Hahm et al.'s
own analysis frame), `raw-survey-data/data_w1w2.RData`, `old-codebook-data/dfw{1,2}.RData`
and the loose `EU25_Survey_Austria.csv` were deleted when the pipeline moved to the
published release; all of their content is in it. They remain recoverable from git history
and from the upstream repo's `data/01_raw/Wave{1,2,3}.rds`.

---

## B. External data — collected

All under `data/01_raw/external/`. The "Role" column states what the source is for in this
paper; section and step numbers refer to the **provisional** outline in `.claude/CLAUDE.md`,
which is one candidate framing rather than a fixed structure — read `### Status` there first.
A source's role here is a note on why it was collected, not a commitment about where it lands.

### CSES — Comparative Study of Electoral Systems

The **only** source carrying the branching closeness probe (close → leaner → strength)
alongside vote recall. That makes it the sole basis for decomposing "no attachment" into
leaners and true non-partisans, and therefore for the leaner-overlap estimate the design
section needs.

| Status | Path | Version on disk | Files | Role and caveats |
|---|---|---|---|---|
| ✅ | `cses/imd/` | `VER2024-FEB-27` | `cses_imd.rdata` (18 MB) + 5 codebook PDFs (ZA7481) | Integrated Module Dataset: 395,797 × 406, 230 elections, 59 polities, Modules 1–5 integrated. This is the **Phase 4** release and the current one — no Phase 5 announced as of Aug 2026. **Section 4:** estimate the overlap between vote-anchored respondents and leaners. **Argument step 2:** cross-national variation in attachment shares. |
| ✅ | `cses/mod5/` | — | `cses5.rdata` (9 MB) + 9 codebook/questionnaire PDFs (ZA7557) | Module 5 (2016–2021), the module closest in time to the 2019 Hahm et al. fieldwork. **Adds nothing on its own — it is a strict subset of the IMD** (see below). Reach for it only for Module-5-specific variables the IMD does not harmonise; for period-matched attachment shares, filter the IMD on `IMD1008_MOD_5 == 1`. |
| ✅ | `cses/mod6/` | `VER2025-DEC-16` | `cses6.rdata` (89 MB) + 7 codebook PDFs (ZA7748) | Module 6 (2021–2026), 33,871 × 676, 18 studies. This is the **Second Advance Release** (Dec 2025) — current, but still an advance release: the full release is pending and country coverage will change. Treat any Module 6 result as provisional and re-run on the final release. |

Source: <https://cses.org/data-download/download-data-documentation/>

**CSES holdings are complete and current; nothing to download.** Verified Aug 2026 by reading
the version variables in the files themselves — `IMD1002_VER` in `cses_imd.rdata`, `f1002_ver`
in `cses6.rdata` — not from the release pages. Modules 1–4 need no standalone download because
the IMD integrates Modules 1–5. Recorded as D16 in `DECISIONS.md`, with both version strings, so
that a future re-download is a deliberate act with a visible diff rather than a silent upgrade.

**The IMD already contains Module 5 in full** — 114,714 of its 395,797 rows carry
`IMD1008_MOD_5 == 1`, exactly the row count of `cses5.rdata`, and **all 56** of Module 5's
election studies are present. Stacking IMD and Module 5 double-counts every Module 5
election. Module 6 shares no study IDs with either. Default to **IMD + Module 6**; reach for
`cses5.rdata` only when you need Module-5-specific variables the IMD does not harmonise.

An earlier version of this note said 55 of 56 IDs matched, implying Greece 2015 was unique
to Module 5. That was a **naming artefact**, corrected in
`code/03_explanal/3.5_cses_partisanship.qmd`, which prints the evidence. Greece held two
elections in 2015 and the IMD splits them (`GRC12015` January, 1,008 rows; `GRC22015`
September, 1,078 rows) while Module 5 carries one `GRC_2015` — of exactly 1,078 rows, i.e.
the IMD's September study. **The IMD departs from `POL_YEAR` IDs in two ways**, and both
bite when matching study IDs across releases:

- *two elections in one year* — `DEU12002`/`DEU22002`, `GRC12015`/`GRC22015`
- *regional samples* — `BELF1999`/`BELW1999` and `BELF2019`/`BELW2019` (Flanders/Wallonia).
  Wallonia 1999 never fielded the attachment item, so a Belgium-1999 cell is Flanders only,
  at a `close` share of 0.95 — an outlier to treat as an administration artefact.

Practical notes, verified against the files:

- CSES stores metadata **Stata-style at the data-frame level**: `attr(d, "var.labels")` runs
  parallel to `names(d)` and `attr(d, "label.table")` holds the value labels. The per-column
  `attr(x, "label")` that `haven` would set is `NULL`, so a naive label search finds nothing.
- **Module 6 uses lowercase variable names and renumbers items.** The attachment battery is
  `IMD3005_*` in the IMD, `E3024_*` in Module 5 and `f3023_*` in Module 6 — and `f3005_*` in
  Module 6 is an unrelated item ("country better run by"). Never assume a code carries across
  releases.
- `cses6.rdata` loads two objects, `cses6` and a stray `.Traceback`; select by name.
- Weight tiers differ. Use the *within-sample* weight for within-country shares: `IMD1010_1`
  (IMD), `f1101_1` (Module 6). Module 6's `f1103_1` ("polity weight") is identically 1 within a
  polity — it exists for pooling across polities, so using it is equivalent to running unweighted.
- `IMD1006_EU` / `f1007_eu` flag EU membership **at the time of the election**, which implements
  an accession-year filter natively.
- Attachment value labels are identical across releases: `0` no, `1` yes, `7` volunteered
  refused, `8` volunteered don't know, `9` missing. DK and refusal are separately coded, so a
  three-way harmonisation needs no reconstruction.
- CSES has **no East/West Germany split**: all German studies are post-unification and `IMD1007`
  (sample component) is documented only as "see election study notes".

⚠️ **The branching probe is missing for whole election studies, and code `9` hides it.** Verified
in `code/03_explanal/3.5_cses_partisanship.qmd`, which exports per-study availability flags to
`data/03_final/cses_item_availability.csv`:

- Code `9` conflates "not asked" with "missing", so a naive `leaner == 1` test silently counts
  every respondent in an affected study as a non-leaner and drives the leaner share down to the
  close-only share. **This is the single easiest way to get the leaner-overlap estimate wrong.**
- **Norway never fielded the probe** — not in any of its studies. Slovenia, Latvia, Belgium and
  Switzerland 2007 lose most or all of theirs.
- The **strength** item fails on a *different* set of studies — Belgium-Flanders 1999, Finland
  2015 and 2019, Ireland 2011, Slovenia 1996 have none among the close, Hungary 2002 essentially
  none — so the two suppressions are independent and must be flagged separately.
- Any pooled series has to be computed on a **common base** of studies carrying all the items
  being compared. Averaging each definition over whichever studies happen to carry its item makes
  the lines means of different populations, and they then cross in ways impossible within any
  single cell.
- **The branch is leaky and CSES leaves it that way**: respondents named parties without reporting
  closeness, and reported strength without naming a party. The codebook documents this and says
  the data "remain unchanged".
- Modules 1 and 2 asked about "any particular *political* party", fielded long and short versions
  depending on whether party blocs formed, and folded inconsistent answers into the binary. Early
  IMD points carry more measurement noise than later ones.
- Reading the battery moves the answer as much as the country does: adding leaners raises the
  measured partisan share substantially, requiring "very" or "somewhat" close lowers it
  substantially again. Same conclusion as the Eurobarometer's sympathiser category, from a
  cleaner instrument — the CSES at least asks the questions separately, so all three readings are
  constructible rather than assumed.

#### The common base: how many studies carry all three items at once

Any trend that compares affect across coding rules needs the attachment item, a vote item and a
party-affect measure **in the same study**. The IMD carries all three — `IMD3005_1`–`_4` (the
full branching battery), `IMD3002_LH_PL` (vote choice, current lower house, party list) and
`IMD3008_A`–`_I` (like–dislike, 9 parties) — so the question is coverage, not availability.

Counted on the file (study-year kept when a majority of respondents answer substantively,
treating `7`/`8`/`9` and the `9999992`–`9999999` and `95`–`99` bands as non-substantive):

| Scope | Study-years with all three | Span | Polities |
|---|---|---|---|
| All polities | **149 of 230** | 1996–2021 | 45 |
| Within the 25-country frame | **82 of 105** | 1996–2021 | **22 of 25** |

Per-country counts in the frame: DEU 8, CZE 7, NLD 6, FIN/GRC/POL/SWE 5, BEL/DNK/ESP/PRT/SVN 4,
AUT/HUN/LVA/SVK 3, BGR/LTU/ROU 2, EST/HRV/ITA 1. **France, Ireland and the United Kingdom carry
no study-year with all three** — the single largest coverage cost of using the IMD this way.

Two caveats belong with the number. It is a **crude study-level flag**, not the per-item
availability audit that `cses_item_availability.csv` provides, and it keys on **party A only**
for like–dislike, so a study offering the battery for parties B–I but not A would be
undercounted. Re-derive rather than cite these figures if they become load-bearing.

The span starts at 1996 because the CSES itself does, which is why the pre-1996 leg has to come
from somewhere else — see [C.6](#c6-long-run-ap-backbones-candidate-undecided).

### Eurobarometer

Everything under `data/01_raw/external/eb/`. **This whole directory is git-ignored** — 1.4 GB
on disk, freely re-downloadable from GESIS after registration. It exists on the analysis
machine and not in the repo; a fresh clone must re-download it from the links below. See
[Storage and Git LFS](#storage-and-git-lfs).

| Status | Path | File | Size |
|---|---|---|---|
| ✅ 🔒 | `eb/mannheim-eurobarometer-trend-file-1970-2002/` | `ZA3521_v2-0-1.dta` | 218 MB |
| ✅ 🔒 | `eb/eb-2004-2011/` | `harmonised_EB_2004-2021_v3-0-0.dta` | 1.1 GB |
| ✅ 🔒 | `eb/eb-2004-2011/` | `953_new.dta` (raw EB 95.3, 2021) + `EB_953.do` | 17 MB |
| ✅ 🔒 | `eb/ceeb/` | `ZA3648.dta` (Central & Eastern EB trends, 1990–1997) | 62 MB |

Also on disk, alongside the data: `Trends_EBs_1970-2021.xlsx` (the wave-by-item coverage
grid), `ERRATA_harmonised_EB_2004-2021.txt`, `User_Guide_Harmonized_Eurobarometer_2004-2021.pdf`,
the codebook PDFs, and a `citation.bib` in each subdirectory carrying the canonical citation.

Sources and citations:

- Mannheim trend file — Schmitt, Scholz, Leim & Moschner, ed. 2.0.1, ZA3521, DOI
  [10.4232/1.10074](https://doi.org/10.4232/1.10074).
  <https://search.gesis.org/research_data/ZA3521>
- Harmonized Eurobarometer 2004–2021 — Russo & Bräutigam, v3.0.0, DOI
  [10.7802/2539](https://doi.org/10.7802/2539).
- Central and Eastern Eurobarometer 1990–1997 (Trends CEEB1–8) — ZA3648, DOI
  [10.4232/1.3648](https://doi.org/10.4232/1.3648).
- Standard EB 95.3 (2021) raw file — ZA7783, distributed here as `953_new.dta` with its
  harmonisation do-file.

**Role.** Argument step 2: the long-run trajectory of party attachment in Europe, and — more
usefully — a demonstration that the measured partisan share is as much a coding decision as a
measurement. The Mannheim file carries both attachment and party preference, so an explicit /
vote-anchored split is constructible for the years the attachment item was fielded.

#### What the item actually covers

Verified in `code/03_explanal/3.4_eb_partisanship.qmd`, which inventories all four files:

- **The item was fielded in 1970, every half-year from 1975 fall to 1994 fall, spring 1996, and
  autumn 2009 — and in no other wave.** This is the full list, read off the wave-by-variable
  grid in `Trends_EBs_1970-2021.xlsx` (sheet `1 Trends`, row `party_att_deg`, where a cell
  carries the source variable number and a blank means not fielded). **Nothing exists for
  1997–2008**, so the hole is a property of the Eurobarometer programme, not of what happens to
  be on disk. The gap is left blank in the figures — no interpolation, no bridging line. The
  2009 point is one wave and is not a trend.
- **The consequence is settled: the pre-1996 long-run series cannot come from the Eurobarometer.**
  There are no unfielded waves left to hunt for, so a national-election-study harmonisation has
  to carry the trend. See [C.6 Long-run AP backbones](#c6-long-run-ap-backbones-candidate-undecided).
  Recorded as D15 in `DECISIONS.md`.
- **1970 fields a two-category variant** (`1 deeply` / `3 only a little`, recoded by Mannheim to
  align with later versions), which `closepty` does not reach — hence the earlier note that the
  Mannheim series starts in 1975. The 1970 point is not comparable to the four-category item and
  is not a fourth reading of it.
- **EB 44.2bis (ZA2828, Jan–Mar 1996) is the one recoverable wave.** The trends grid confirms
  spring 1996 fields the item; the wave is absent from the Mannheim trend file, which jumps
  EB 44.1 → EB 45.1, and falls before the harmonised file's 2004 start. It exists as a
  standalone GESIS study and is the only download that would extend the series.
  ⚠ Two dates to reconcile before relying on the 2009 point: the harmonised file locates it in
  **EB 71.3, which fielded in spring 2009**, while the trends grid places the item in **autumn
  2009**. One of the two is mislabelled; check which wave the responses actually come from.
- **The CEEB carries no attachment item at all** — vote intention and past vote only. Central
  and Eastern Europe is therefore absent from the attachment series until the 2009 wave brings
  the 2004 and 2007 accession states in for one observation.
- Austria, Finland and Sweden acceded in 1995, after the item was dropped, so they have **no**
  Eurobarometer attachment series.
- `voteint` covers 1970–2002 but is absent in 1998 and 2001; `lastvote` is fielded only in 1979
  and 1982–1995.

#### What the series actually shows

**Frame, stated first because every number here depends on it:** computed from
`data/02_processed/pid_cache/eb_raw.parquet` on the raw `nation1` units, restricted to the 20
years the item was fielded, denominator = substantive responses (`closepty` 1–4, so DK excluded),
weighted within country, then an **unweighted mean over countries** per D12. The **balanced
panel** is the 10 `nation1` units present in all 20 of those years.

| Category | 1975–79 | 1990–94 | Change | Relative |
|---|---|---|---|---|
| Very close | 10.1% | 7.9% | −2.2pp | **−22%** |
| Fairly close | 18.5% | 17.7% | −0.8pp | −4% |
| Merely a sympathiser | 34.9% | 28.1% | −6.8pp | −20% |
| **Any attachment (the binary filter)** | **63.5%** | **53.7%** | **−9.8pp** | **−15%** |

**What the country set is worth.** On the *unbalanced* series — same frame, same denominator,
country set growing 10 → 15 as Greece (1981), Spain and Portugal (1986) and East Germany (1990)
enter — the same comparison gives 63.5% → 55.6%, a decline of **−7.9pp**. So composition masks
about **two points of a ten-point fall**. It is a real distortion and it is worth holding the
set constant (D17), but on this series it does **not** flip the sign.

**The finding replicates on the project's own frame.** `pid_country_year.csv` applies the
EU-scope rule (D3), `country_unit` rather than `nation1` (D11) and keeps DK in the denominator
(D7). Levels there run ~2–3 points lower, as the DK share implies, and the change is the same:
**61% → 51% balanced (−9.9pp)** and 61% → 52% unbalanced (−8.9pp), computed by
`3.3_pid_over_time.qmd` (`pooled_contrast`). Two frames, one conclusion.

⚠ **Compare period means, not endpoint years.** A 1975-vs-1994 comparison on the project frame
shows a fall of only 1.6pp, because 1975 sits at a local low and 1994 at a local high; the
five-year period means show ten. An earlier draft of this file quoted the endpoint figure and
read the series as flat. A conclusion that depends on which year sits at the edge of the window
is not a trend, and `pooled_contrast` now uses period means for that reason.

Two substantive points follow, and both bear on the paper rather than on data management:

- **Dealignment here is disproportionately a decline in intensity.** "Very close" loses 22% of
  its 1975–79 level against 15% for the binary. The gap is real but moderate — it should be
  stated as a difference in rate, not as "the binary is flat", which it is not.
- **Any single headline number is meaningless without its coding rule *and* its frame.** D2
  records that moving "merely a sympathiser" across the line moves the measured share by ~31
  points; the frame choice above is worth another 8. A figure quoted without both is
  unfalsifiable, not merely imprecise.

#### Why "the attachment item" is not one item

- The stimulus changes from supporter/involvement to closeness at **EB 10**, the question is
  asked in a different position at **EB 16**, and 2009 reverts to the earlier involvement value
  labels. Points left of 1978 come from a differently worded item.
- **English- and French-derived questionnaires ask different questions.** The English version
  asks the absolute form, the French the relative one ("closer to one party than the others").
  Documented at Mannheim codebook footnote 119 and in
  [@sinnott1995variations; @katz1985measuring; @schmitt1989onparty]. The instrument is therefore
  not measurement-equivalent across countries **within a single wave**, and any cross-country
  comparison of attachment *levels* from this source inherits the asymmetry.
- **`closepty` folds status and strength into one variable**: `1` very close, `2` fairly close,
  `3` merely a sympathiser, `4` no party, `8` DK/NA, `9` inap. Moving "merely a sympathiser"
  across the attached / not-attached line changes the measured European partisan share by
  roughly **31 percentage points**, from one instrument fielded unchanged. Both readings are
  plotted in 3.4 rather than one being chosen. DK/refusal is reported separately and never
  folded into "not attached" — declining the item is not denying attachment.

#### Other variables, verified against the files

- `feelclo` — *which* party the respondent feels close to (country-specific party codes). Not a
  status item; fielded erratically.
- `voteint` — vote intention; `lastvote` — last vote (past-vote recall); `inclvote` —
  inclination to vote. **Three different constructs; never merge them.**
- `nation1` is the country identifier to use: it separates West (`4`) from East (`14`) Germany
  and Great Britain (`9`) from Northern Ireland (`10`). `nation2` pools both pairs irrecoverably,
  and 3.4 keeps them apart for exactly this reason.
- Weights: `wsample`, `wnation` (within-country — the right one for national shares), `weuro`
  (weights countries to EU population).
- The harmonised file codes non-substantive answers as **haven tagged NAs** (`d` don't know,
  `i` inapplicable) where Mannheim uses plain numeric `8`/`9`. An *untagged* NA means the item
  was not fielded in that wave at all. 3.4 maps both schemes onto one code set; do not assume
  either convention when reading a new file.
- Country codes are **not shared across files**: Mannheim code `19` is Switzerland, harmonised
  code `19` is Cyprus. Use each file's own value labels.
- ⚠️ The harmonised file ships an errata note: `mem` / `ben` (EU membership good/bad and
  benefit) are wrong or switched in EB 90.3, 91.5 and 95.3, and possibly other waves. An update
  is pending from the provider. Not used by this project so far — check before it is.

The attachment battery is largely dropped from the Standard Eurobarometer after 2002, so the
Mannheim file ends at a genuine discontinuity rather than an arbitrary cut.

### Derived item crosswalks

Written to `data/03_final/` by the two inventory notebooks. They are the same objects the
notebooks recode with, exported rather than re-typed, so the recode and the documentation
cannot drift apart. Small, tracked in the repo, and safe to read without the source data.

| File | Written by | Contents |
|---|---|---|
| `eb_item_crosswalk.csv` | 3.4 | One row per Eurobarometer source × response code: `code_label`, the `status` it maps to (`attached` / `not_attached` / `dk_refused` / `not_asked`) and the `strength` it implies. |
| `eb_item_wording.csv` | 3.4 | One row per partisanship item × wording era across all four EB files, with verbatim wording, categories and notes. |
| `cses_item_crosswalk.csv` | 3.5 | One row per battery item × code (`close`, `leaner`, `strength`), identical across all three CSES releases. |
| `cses_item_wording.csv` | 3.5 | Verbatim wording of the four battery items, with what each is asked of — the branch structure made explicit. |
| `cses_item_availability.csv` | 3.5 | **One row per election study**, with `probe_available` / `strength_available` flags and the underlying counts. Consult this before any leaner or strength calculation. |

### Partisan discrimination / behavioral reference studies

| Status | Path | Files | Role |
|---|---|---|---|
| ✅ | `carlin-love-2018/` | `BJPS data.dta` (3.4 MB), `BJPS US 2011 Bin Laden Study.dta` (16 KB) | Carlin & Love, partisan trust-game discrimination. Out-of-sample benchmark for the behavioral result — establishes what a copartisan effect of the size we estimate looks like elsewhere. |
| ✅ | `westwood-et-al-2015/` | `trustGameSSI.csv`, `partisanIAT-SSI.csv`, `dscoreLR.csv`, `dscoreWB.csv`, `AJPSResponsivenessNegativity.csv` | Westwood et al., partisan trust game + partisan IAT. Reference measures for behavioral and implicit AP; the IAT files are the comparison point for any claim about implicit vs. self-reported animus. |

### TRI-POL — Torcal et al. three-wave panel

| Status | Path | Files | Role and caveats |
|---|---|---|---|
| ✅ | `tripol/` | 5 × `TRI_POL_{AR,CL,ES,IT,PT}.XLSX` (21 MB) + 21 codebook/questionnaire PDFs (27 MB) | Three-wave panel, Sept 2021–Apr 2022, 6,201 respondents in W1. Carries party/leader thermometers, an **incentivized** partisan trust game, a W3 conjoint, within-person social-distance items, and the attachment item in all three waves. **The only external source with an attitudinal *and* a behavioral AP measure on the same respondents** — hence the robustness leg for sections 5–6, and a section 7 candidate. |

**→ `data/01_raw/external/tripol/tripol.md` is the detailed reference for this dataset:**
full variable inventory, verified design facts, the modelling-transfer table, and the import
gotchas. Read it before touching the files. Only the inventory-level summary lives here.

Provenance: TRI-POL, PI Mariano Torcal (RECSM–UPF). Data paper Torcal, Carty, Comellas, Bosch,
Thomson & Serani (2023), *Data in Brief*
<https://www.sciencedirect.com/science/article/pii/S2352340923003384>. Repository
<https://osf.io/3t7jz/>. Already cited in the project as `@Comellas2023ideological`
(`code/literature-overview.qmd:102`). Netquest **online opt-in quota panels — not probability
samples, and the files carry no survey weights.**

The three facts that determine how it can be used, all verified against the files:

- **The trust game is between-subjects.** `GAME_SHOW_2` shows each respondent the in-party
  *or* the out-party counterpart; respondents answering both = **0**, in all five countries.
  So the unit of observation is the respondent, not round-within-respondent, and the model is
  one level shallower than the main analysis. `esmP11_2` — an anonymous-counterpart round
  present for **100%** of cued players — substitutes for the respondent random intercept.
- ⚠️ **The counterpart party is piped by a type-dependent rule**: attachment where available,
  top PTV otherwise. TRI-POL therefore varies the anchor *and* the reporting, which is exactly
  what section 4's design exists to prevent, and it is most-liked-party coding besides.
  Re-anchor everyone on `p36_` PTV and retain only matches; this must be the primary
  specification, not a footnote.
- ✅ **The section 7 gate is cleared.** 18–23% of respondents switch attachment status per
  wave, in both directions, in every country (ES W1→W2: 176 yes→no, 89 no→yes). Recorded, not
  committed — see C.1.

Only ES, IT and PT are in the paper's frame; AR and CL are extra-European.

**Not in this download**, despite being expected: no Stata `.dta` (XLSX only, wide, one row per
respondent), no passive-meter trace files (`met*` variables are self-reports *about* the meter),
no Party Facts crosswalk. No file approaches the LFS threshold — largest is 4.9 MB.

---

## C. External data — planned

### C.0 Collection order

What to download next, in order, as of 2026-08-18. Everything below is *planned*; the reasoning
for each sits in its own subsection.

| # | Source | Why this position | Where |
|---|---|---|---|
| 1 | **ESS R1–R11** | Free, and the only continuous 2002–2024 attachment + vote-recall series covering the frame. Highest value per unit of effort. Composition only — never affect (D18). | [C.2](#c2-cross-national-attitudinal-infrastructures) |
| 2 | **West European Voter** | The pre-1996 affect backbone, and the only Gate 1b candidate confirmed to carry thermometers before 1996. Licence still to check. | [C.6](#c6-long-run-ap-backbones-candidate-undecided) |
| 3 | **EB 44.2bis (ZA2828)** | Cheap, and the only recoverable Eurobarometer attachment wave. Adds one point, not a series (D15). | [Eurobarometer](#eurobarometer) |
| 4 | **TEV (ZA5054) / EES** | Only if WEV fails Gate 1b on coverage or licence. | [C.6](#c6-long-run-ap-backbones-candidate-undecided) |
| — | ~~EU Open Data Portal~~ | **Ruled out** — aggregates only, microdata is at GESIS (D19). | [C.2](#c2-cross-national-attitudinal-infrastructures) |

Nothing on this list is needed for Gate 1c, which runs on the CSES already on disk.

Not downloaded, with one exception noted below. Links and notes carried over from the
manuscript inventory.

### C.1 Section 7 panel candidates

Section 7 (the within-person leg, main text) needs one panel with repeated attachment
measurement. **Gate: choose on the attachment transition matrix.** Check within-person
movement in the attachment item *before* committing; if movement is thin, drop section 7
rather than report an underpowered result. One country done properly beats several done
shallowly — so exactly one of these gets *used*.

**TRI-POL is now on disk** (it was collected for the sections 5–6 robustness leg, not for
section 7) and has cleared the gate. That does not settle the choice: the others below remain
open, and several have more waves or probability samples. It does mean the gate can be checked
against a real transition matrix rather than assumed.

| Status | Dataset | Coverage | Link | Notes |
|---|---|---|---|---|
| ⬜ 🔒 | GLES Panel 2016–2021 | DE | <https://doi.org/10.4232/1.14114> · <https://www.gesis.org/en/gles> | Scalometers for parties and leaders; PID with strength. |
| ⬜ 🔒 | BES Internet Panel | UK | <https://www.britishelectionstudy.com/data-objects/panel-study-data/> · <https://doi.org/10.5255/UKDA-SN-8202-2> | Waves 1–29, ~30k per wave. Paradata (response times) enables satisficing checks — directly relevant to the reporting-disposition interpretation. |
| ⬜ 🔒 | LISS panel | NL | <https://www.lissdata.nl> · <https://www.dataarchive.lissdata.nl/study-units/view/22> | Probability panel. Carries like–dislike toward party *supporters*, not only parties. Accepts external module proposals — a route to fielding attitudinal and behavioral items on the same respondents. |
| ⬜ | POLAT Panel | ES, 12 waves | <https://doi.org/10.34810/DATA1486> · <https://www.nature.com/articles/s41597-025-05684-4> | Built because household panels carry thin political batteries. Most waves of any candidate. |
| ⬜ 🔒 | AUTNES Online Panel 2017–2024 | AT | <https://doi.org/10.11587/HNUFCC> | Long multi-wave voter panel, recently documented. |
| ✅ | TRI-POL | ES, PT, IT (+ AR, CL) | see [section B](#tri-pol--torcal-et-al-three-wave-panel) · `tripol/tripol.md` | **Downloaded, and the gate is cleared** — 18–23% of respondents switch attachment status per wave, both directions, all five countries. The only candidate carrying thermometers, an incentivized behavioral measure *and* within-person attachment movement. Trace data is **not** in the download. |
| ⬜ | Finnish online panel (Kekkonen & Ylä-Anttila) | FI | <https://www.frontiersin.org/journals/political-science/articles/10.3389/fpos.2022.920567/full> | Partisan social distance + like–dislike. Addresses in/out-group definition under multipartyism head-on. |

### C.2 Cross-national attitudinal infrastructures

| Status | Dataset | Coverage | Link | Notes |
|---|---|---|---|---|
| ⬜ 🔒 | **European Social Survey R1–R11** — **priority collection** | 2002–2024, ~30 countries | <https://www.europeansocialsurvey.org/data-portal> | **The 2002–2024 composition and taxonomy series.** Carries "closer to a particular party than all others" + strength + vote recall (`prtcl*` / `prtv*`), so the explicit / vote-anchored split is constructible on the same respondents, continuously, across the frame — the only free source that does this after 2002. **Constraint, not a dismissal: it has no party thermometers**, so it may carry the composition legs and may never enter an affect estimate (D18). R11 = 31 countries; R12 (2025/26) goes mixed-mode → expect a break. |
| ⬜ 🔒 | European Election Study 2024 (ZA8868) | 27 member states, 25,904 R | <https://search.gesis.org/research_data/ZA8868> | PTVs rather than thermometers; items linkable to CHES. |
| ⬜ 🔒 | EES series 1989–2019 | Five-yearly, EU-wide | <https://www.gesis.org/en/services/finding-and-accessing-data/international-survey-programs/european-election-studies> | Closeness + strength + EP and national vote recall. Long series with consistent core items. ⚠ Its affect measure is a propensity-to-vote battery, **not** a thermometer. |
| ❌ | ~~EU Open Data Portal~~ | — | <https://data.europa.eu> | **Ruled out, Aug 2026.** It publishes *aggregated* Eurobarometer tables; the microdata lives at GESIS. Aggregates cannot support a respondent-level attachment × vote cross-tab, which is what the taxonomy requires. Recorded so it is not re-proposed. |

### C.3 Partisanship over time

| Status | Dataset | Coverage | Link | Notes |
|---|---|---|---|---|
| ✅ 🔒 | Standard Eurobarometer, post-2002 | 2004–2021 | see [Eurobarometer](#eurobarometer) · <https://www.gesis.org/en/eurobarometer-data-service> | **Collected** as the harmonised 2004–2021 file. It confirms the discontinuity rather than repairing it: the attachment item appears in **one wave only** (2009, EB 71.3), and nothing covers 1995–2008. EB 44.2 (1996) is documented as fielding the item and would need downloading separately. |
| ⬜ 🔒 | ISSP background variables | 1985– | <https://www.gesis.org/en/issp> | Party affiliation as a standard background item. |
| ⬜ 🔒 | Politbarometer (DE) | monthly, 1977– | <https://www.gesis.org/en/elections-home/politbarometer> | Monthly *Parteineigung* with a cumulative file. Within-year variation no cross-national source matches; one of the two longest constant-wording stretches available. |
| ⬜ | British Election Study | 1964– | <https://www.britishelectionstudy.com> | Longest continuous national election series. |
| ⬜ | Other national election studies | 1950s– | national archives | SE (1956–), NO (1957–), IT/ITANES (1968–), NL/DPES (1971–), CH/Selects (1971–), DK (1971–), ES/CIS barometers monthly (1979–). |

### C.4 Behavioral / experimental

| Status | Dataset | Link | Notes |
|---|---|---|---|
| ⬜ | Hahm et al., "Divided by Europe" (WEP) | <https://www.tandfonline.com/doi/full/10.1080/01402382.2022.2133277> | Dictator games, 25 member states, hypothetical stakes. Companion to the main analysis file. |
| ⬜ | "(Alleged) consequences of AP", 9 democracies (EJPR) | <https://www.cambridge.org/core/journals/european-journal-of-political-research/article/alleged-consequences-of-affective-polarization-a-survey-experiment-in-nine-democracies/22A263E738B4718273BE92A52D2582ED> | Manipulates AP directly, measures downstream behavioral/normative outcomes. |
| ⬜ | OECD Trustlab | <https://www.oecd.org/en/publications/trust-and-its-determinants_869ef2ec-en.html> | Incentivized trust/dictator/public-goods + institutional IAT in FR, DE, IT, SI, LU, UK. **Counterparts are anonymous strangers — no partisan cue.** Use as a prosociality baseline, never as an AP measure. |

### C.5 Aggregate proxies and crosswalks

| Status | Dataset | Coverage | Link | Notes |
|---|---|---|---|---|
| ⬜ | MAPP party membership | 1945–2014, 31 countries | <https://zenodo.org/record/61234> · <https://link.springer.com/article/10.1057/s41304-016-0098-z> | 6,307 membership observations across 397 parties. Organizational counterpart to declared attachment. |
| ⬜ | Electoral volatility (Emanuele et al.) | national since 1945; EP since 1979 | <https://access.gesis.org/sharing/2739/5793> | Behavioral counterpart: volatility as revealed weak attachment. |
| ⬜ | Party Facts | — | <https://partyfacts.org> | Party ID crosswalk for merging any of the above. |
| ⬜ | Political Parties Crosswalk | cross-national surveys | [10.1080/2474736X.2022.2048957](https://doi.org/10.1080/2474736X.2022.2048957) | Maps the party codes used *inside* cross-national surveys (CSES, ESS, EB, EVS, ISSP and others) onto Party Facts IDs. Directly useful because `eu25games2019` already carries PF IDs on every party-bearing item, so this is the join key for putting any new source alongside the primary data. |

### C.6 Long-run AP backbones (candidate, undecided)

The Eurobarometer cannot carry the pre-1996 series (see D15 in `DECISIONS.md` and the
Eurobarometer section above), and the CSES starts in 1996. Anything reaching further back
has to be an *ex post*
harmonisation of national election studies. Three exist. **None is on disk, and none has been
chosen** — they are recorded here as co-equal candidates to be decided on measured coverage
rather than on documentation.

| Status | Source | Coverage | Affect measure | Access |
|---|---|---|---|---|
| ⬜ | **West European Voter (WEV)** | 182 election studies, 16 West European democracies, 1961–2020, 464,033 R | Harmonised **party and leader thermometers** — the only candidate confirmed to carry an affect measure before 1996 | SWISSUbase, DOI [10.48573/38dd-gn73](https://doi.org/10.48573/38dd-gn73) (versioned: `10.48573/rhdr-2923`). Licence not yet checked. |
| ⬜ 🔒 | **True European Voter (ZA5054)** | 23 countries, *ex post* harmonisation of national election studies | Original (`O*`) and recoded (`R*`) variables; **thermometer coverage unverified** | GESIS, registration — <https://access.gesis.org/dbk/71116> |
| ⬜ 🔒 | **EES voter studies 1989–2024** | EU-wide, five-yearly, all members at time of fielding; reaches CEE from 2004 | Closeness, vote choice, past vote and **propensity to vote** — ⚠ PTV is *not* a thermometer | GESIS, free after registration |

**The ESS is not a candidate here.** It is the strongest source in [C.2](#c2-cross-national-attitudinal-infrastructures)
and carries no affect measure at all, so it cannot compete on the Gate 1b criterion below —
which is item *co-occurrence including a party-affect measure*. ESS carries the composition legs;
these three compete to carry the affect trend. Do not merge the two roles.

⚠ **Construct warning, and it is the trap here.** A thermometer, a like–dislike scale and a
propensity-to-vote battery are three different instruments. PTV asks how likely you are ever to
vote for a party, which is not how warmly you feel toward it; the two correlate but are not the
same quantity, and pooling them would manufacture a series no instrument measures. This is the
same rule as [E. Comparability caveats](#e-comparability-caveats) and D10 — compare slopes within
a source, never levels across sources.

#### Comparison protocol

Fixed here so that the choice, when it is made, is made on evidence and not on whichever
codebook was read most recently. For each of the three, record on a common template:

1. **Item co-occurrence** — in how many study-years do a party-affect measure, an attachment item
   and a vote item all appear *together*? Not "does the project carry it" but the same
   study-level intersection used for the CSES common base above.
2. **Construct** — thermometer, like–dislike, PTV or sympathy, recorded per study-year, never
   assumed constant across the span of a source.
3. **Frame coverage** — how many of the 25, and whether it reaches CEE at all.
4. **Span**, and specifically what it does with 1995–2008.
5. **Overlap with CSES 1996–2021** — a source that only duplicates the CSES window adds nothing
   to a trend leg. The value of each candidate is entirely in the pre-1996 years and in FRA, IRL
   and GBR, which the IMD common base misses.
6. **Licence and access cost.**

**Decision rule, fixed in advance:** the source that maximises **pre-1996 study-years carrying
all three items** wins, with construct consistency as the tie-break. If none reaches
meaningfully before 1996, then the trend leg is CSES-only from 1996 and the Eurobarometer stands
as a separate, non-spliced attachment series — which D10 already requires, and which is a
reportable result rather than a failure.

---

## D. Measurement references (not datasets)

Listed so they are not mistaken for collectable data.

| Source | Link | Why |
|---|---|---|
| Wagner et al., brief AP measures (EJPR 2025) | <https://ejpr.onlinelibrary.wiley.com/doi/pdfdirect/10.1111/1475-6765.70022> | 39 countries, N=66,880; validity of 3–5 party subsets; DK-as-missing convention. |
| Garzia et al., parties vs. leaders (APSR) | <https://www.cambridge.org/core/journals/american-political-science-review/article/patterns-of-affective-polarization-toward-parties-and-leaders-across-the-democratic-world/E1C891801A4CB1DEBE2AACE6446F6845> | Splits party-directed AP into party- and leader-directed. |
| Handbook of Affective Polarization, ch. 2 (open access) | <https://www.elgaronline.com/edcollchap-oa/book/9781035310609/chapter2.xml> | Conceptual inventory of AP measures. |

---

## E. Comparability caveats

- **Wording is not equivalent across sources.** Eurobarometer asks about *attachment* with
  degrees; ESS asks whether you feel closer to one party *than all others* (a relative, lower
  bar); CSES asks whether you *usually think of yourself* as close, then probes leaners.
  Non-attachment rates differ systematically as a result — compare slopes within a source,
  never levels across sources.
- **The Eurobarometer is not even equivalent to itself.** English-derived questionnaires ask the
  absolute question, French-derived ones the relative one, within the same wave and the same
  variable. So the EB pooled — inconsistently, and across countries — respondents that the CSES
  deliberately keeps in separate branches (`close` vs. `leaner`). This is the sharpest case of
  the rule above: an EB cross-country *level* comparison is partly comparing two instruments,
  and no recode fixes it after the fact. See
  [@sinnott1995variations; @katz1985measuring; @schmitt1989onparty] and notebook 3.5, which
  states the CSES side of the comparison.
- **Mode transitions bite this construct hardest.** The vote-anchored group is defined by a
  negative answer on one item and a positive on another, exactly where self-completion vs.
  interviewer effects are strongest. EES moved online, national studies migrated to web
  panels, ESS R12 is mixed-mode. A jump in vote-anchored partisans around a mode switch is
  not evidence of dealignment.
- **The anchor is not constructed the same way across sources.** The main analysis holds the
  anchor constant and varies only whether attachment is reported. TRI-POL cannot do this by
  design — it pipes the game counterpart from attachment where available and from top PTV
  otherwise — and it has **no vote-recall item at all**, so its vote anchor must come from
  intention or PTV. Any TRI-POL estimate compared against the main result must state which
  anchoring rule produced it; the two are not interchangeable.
- **Sample type differs where it matters most.** The main analysis file and CSES rest on
  probability or quota-controlled designs; TRI-POL is an opt-in Netquest panel with **no
  survey weights** in the release. Treat TRI-POL results as a within-source replication of a
  *contrast*, never as a source of population levels.
- **Practical rule:** treat each source as its own series, never splice, and anchor claims to
  constant-mode / constant-wording stretches. The Mannheim trend file and Politbarometer give
  the longest such stretches.

---

## Storage and Git LFS

Three tiers, in order of preference:

1. **Not in the repo at all.** If a source is large *and* freely re-downloadable, ignore it and
   document the link here instead. `data/01_raw/external/eb/` is the case that set the rule:
   1.4 GB, of which the harmonised 2004–2021 file alone is 1.1 GB, against a `.git` already past
   3 GB. `.gitignore` carries `/data/01_raw/external/eb/`, and a fresh clone re-downloads the
   four files from the GESIS links in [the Eurobarometer section](#eurobarometer).
2. **LFS**, for tracked files over ~50 MB. Currently that is
   `data/01_raw/external/cses/mod6/cses6.rdata` (89 MB), and nothing else. The Mannheim trend
   file was LFS-tracked until it moved into `eb/`; its blob remains in history at the old path,
   which is why ignoring the directory stops future growth rather than reversing past growth.
3. **Plain blobs** for everything smaller.

`code/00_helper/glftrackeR.R` appends entries for files over 100 MB, but its threshold is the
*hard* GitHub limit — `cses6.rdata` at 89 MB sat under it and had to be added by hand. Anything
in the 50–100 MB band needs the same treatment. And a file already `git add`-ed as a plain blob
stays plain even after `.gitattributes` gains its entry: `git rm --cached <file>`, stage
`.gitattributes`, re-add, then verify with `git check-attr filter -- <file>`.

**Codebook PDFs are not in the repo.** `.gitignore` carries a blanket `*.pdf` rule, so every
`ZA*_cdb_*.pdf` and questionnaire under `external/` exists on disk but is untracked. Re-download
from the source links above if setting up a fresh clone.
