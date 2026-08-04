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

Sizes are approximate. Codebook PDFs are present on disk but **not in the repo** —
`.gitignore` contains a blanket `*.pdf` rule (see [Storage and Git LFS](#storage-and-git-lfs)).

---

## A. Primary analysis data

Everything under `data/01_raw/` that is not in `external/`. Variable-level documentation
for these files lives in `code/01_preparation/1.1_datasets.qmd`.

| Status | File | Size | Role |
|---|---|---|---|
| ✅ | `hahmetal-data/aff_pol_df_analy_jan2023.RData` | 16 MB | **The analysis source.** Hahm, Hilpert & König (2024), 25 European democracies, N≈29,800. Thermometer ratings (attitudinal AP) and conjoint dictator/trust games (behavioral AP). |
| ✅ | `raw-survey-data/data_w1w2.RData` | 24 MB | Raw two-wave survey file underlying the Hahm et al. analysis object. |
| ✅ | `old-codebook-data/dfw1.RData`, `dfw2.RData` | 6 MB, 8 MB | Earlier codebook-era wave files. Retained for variable provenance. |
| ✅ | `EU25_Survey_Austria.csv` | 8 MB | Single-country export sitting loose at the root of `01_raw/`. **Unfiled** — no code path reads it; decide whether it belongs under `raw-survey-data/` or should be removed. |

Downstream pipeline:

```
01_raw/hahmetal-data/  →  02_processed/eu25games2019.RData  →  03_final/eu25games2019.rds
                                                              03_final/thermo_long.rds
```

---

## B. External data — collected

All under `data/01_raw/external/`. The "Role" column states what the source is for in this
paper; numbers refer to the argument chain and section structure in `.claude/CLAUDE.md`.

### CSES — Comparative Study of Electoral Systems

The **only** source carrying the branching closeness probe (close → leaner → strength)
alongside vote recall. That makes it the sole basis for decomposing "no attachment" into
leaners and true non-partisans, and therefore for the leaner-overlap estimate the design
section needs.

| Status | Path | Files | Role and caveats |
|---|---|---|---|
| ✅ | `cses/imd/` | `cses_imd.rdata` (18 MB) + 5 codebook PDFs (ZA7481) | Integrated Module Dataset: ~395k respondents, 230 elections, 59 polities. **Section 4:** estimate the overlap between vote-anchored respondents and leaners. **Argument step 2:** cross-national variation in attachment shares. |
| ✅ | `cses/mod5/` | `cses5.rdata` (9 MB) + 9 codebook/questionnaire PDFs (ZA7557) | Module 5 (2016–2021). Closest module in time to the 2019 Hahm et al. fieldwork — use for period-matched comparison of attachment shares. |
| ✅ | `cses/mod6/` | `cses6.rdata` (89 MB) + 7 codebook PDFs (ZA7748) | Module 6 (2021–2026). **Advance release only** — the full release is pending, country coverage will change. Treat any Module 6 result as provisional and re-run on the final release. |

Source: <https://cses.org/data-download/download-data-documentation/>

### Mannheim Eurobarometer Trend File 1970–2002

| Status | Path | Files | Role and caveats |
|---|---|---|---|
| ✅ 🔒 | `mannheim-eurobarometer-trend-file-1970-2002/` | `ZA3521_v2-0-1.dta` (228 MB) + codebook PDF | Ed. 2.0.1: 86 waves, 145 variables, >1m cases, Western Europe. Free after GESIS registration. **Argument step 2:** the long-run attachment decline. Carries **both** party attachment and party preference, so the explicit / vote-anchored split is constructible back to the early 1970s — no other source reaches that far. |

Caveats: item wording varies across waves and is documented in the codebook; **not all trend
variables are present in all waves** — verify item coverage wave by wave before building a
series. The attachment battery is largely dropped from the Standard Eurobarometer after 2002,
so this file ends at a genuine discontinuity, not an arbitrary cut.

Source: <https://search.gesis.org/research_data/ZA3521> (DOI 10.4232/1.10074)

### Partisan discrimination / behavioral reference studies

| Status | Path | Files | Role |
|---|---|---|---|
| ✅ | `carlin-love-2018/` | `BJPS data.dta` (3.4 MB), `BJPS US 2011 Bin Laden Study.dta` (16 KB) | Carlin & Love, partisan trust-game discrimination. Out-of-sample benchmark for the behavioral result — establishes what a copartisan effect of the size we estimate looks like elsewhere. |
| ✅ | `westwood-et-al-2015/` | `trustGameSSI.csv`, `partisanIAT-SSI.csv`, `dscoreLR.csv`, `dscoreWB.csv`, `AJPSResponsivenessNegativity.csv` | Westwood et al., partisan trust game + partisan IAT. Reference measures for behavioral and implicit AP; the IAT files are the comparison point for any claim about implicit vs. self-reported animus. |

---

## C. External data — planned

Not downloaded. Links and notes carried over from the manuscript inventory.

### C.1 Section 7 panel candidates

Section 7 (the within-person leg, main text) needs one panel with repeated attachment
measurement. **Gate: choose on the attachment transition matrix.** Check within-person
movement in the attachment item *before* committing; if movement is thin, drop section 7
rather than report an underpowered result. One country done properly beats several done
shallowly — so exactly one of these gets downloaded.

| Status | Dataset | Coverage | Link | Notes |
|---|---|---|---|---|
| ⬜ 🔒 | GLES Panel 2016–2021 | DE | <https://doi.org/10.4232/1.14114> · <https://www.gesis.org/en/gles> | Scalometers for parties and leaders; PID with strength. |
| ⬜ 🔒 | BES Internet Panel | UK | <https://www.britishelectionstudy.com/data-objects/panel-study-data/> · <https://doi.org/10.5255/UKDA-SN-8202-2> | Waves 1–29, ~30k per wave. Paradata (response times) enables satisficing checks — directly relevant to the reporting-disposition interpretation. |
| ⬜ 🔒 | LISS panel | NL | <https://www.lissdata.nl> · <https://www.dataarchive.lissdata.nl/study-units/view/22> | Probability panel. Carries like–dislike toward party *supporters*, not only parties. Accepts external module proposals — a route to fielding attitudinal and behavioral items on the same respondents. |
| ⬜ | POLAT Panel | ES, 12 waves | <https://doi.org/10.34810/DATA1486> · <https://www.nature.com/articles/s41597-025-05684-4> | Built because household panels carry thin political batteries. Most waves of any candidate. |
| ⬜ 🔒 | AUTNES Online Panel 2017–2024 | AT | <https://doi.org/10.11587/HNUFCC> | Long multi-wave voter panel, recently documented. |
| ⬜ | TRI-POL | ES, PT, IT, AR, CL | <https://osf.io/3t7jz/> · <https://www.upf.edu/web/tri-pol> | 3 waves, Sept 2021–Apr 2022. Embedded experiments; device-tracked trace data matched to survey. **No "don't know" option** except on knowledge items — a useful control for non-response artefacts. Read the data paper first: <https://www.sciencedirect.com/science/article/pii/S2352340923003384> |
| ⬜ | Finnish online panel (Kekkonen & Ylä-Anttila) | FI | <https://www.frontiersin.org/journals/political-science/articles/10.3389/fpos.2022.920567/full> | Partisan social distance + like–dislike. Addresses in/out-group definition under multipartyism head-on. |

### C.2 Cross-national attitudinal infrastructures

| Status | Dataset | Coverage | Link | Notes |
|---|---|---|---|---|
| ⬜ 🔒 | European Election Study 2024 (ZA8868) | 27 member states, 25,904 R | <https://search.gesis.org/research_data/ZA8868> | PTVs rather than thermometers; items linkable to CHES. |
| ⬜ 🔒 | EES series 1989–2019 | Five-yearly, EU-wide | <https://www.gesis.org/en/services/finding-and-accessing-data/international-survey-programs/european-election-studies> | Closeness + strength + EP and national vote recall. Long series with consistent core items. |
| ⬜ 🔒 | European Social Survey R1–R11 | 2002–2024, ~30 countries | <https://www.europeansocialsurvey.org/data-portal> | **No party thermometers** — not an AP source. Use for classifying explicit vs. vote-anchored partisans and for trust/participation outcomes. "Closer to a particular party than all others" + strength + vote recall. R11 = 31 countries; R12 (2025/26) goes mixed-mode → expect a break. |

### C.3 Partisanship over time

| Status | Dataset | Coverage | Link | Notes |
|---|---|---|---|---|
| ⬜ 🔒 | Standard Eurobarometer, post-2002 | 2002– | <https://www.gesis.org/en/eurobarometer-data-service> | Attachment battery largely dropped → discontinuity where the Mannheim trend file ends. |
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
- **Mode transitions bite this construct hardest.** The vote-anchored group is defined by a
  negative answer on one item and a positive on another, exactly where self-completion vs.
  interviewer effects are strongest. EES moved online, national studies migrated to web
  panels, ESS R12 is mixed-mode. A jump in vote-anchored partisans around a mode switch is
  not evidence of dealignment.
- **Practical rule:** treat each source as its own series, never splice, and anchor claims to
  constant-mode / constant-wording stretches. The Mannheim trend file and Politbarometer give
  the longest such stretches.

---

## Storage and Git LFS

Files over 100 MB must be tracked with Git LFS — GitHub rejects larger plain blobs outright.
Currently LFS-tracked:

- `data/01_raw/external/mannheim-eurobarometer-trend-file-1970-2002/ZA3521_v2-0-1.dta` (228 MB)
- `data/01_raw/external/cses/mod6/cses6.rdata` (89 MB)

`code/00_helper/glftrackeR.R` appends entries for files over 100 MB, but its threshold is the
*hard* limit — `cses6.rdata` at 89 MB sits under it and had to be added by hand. Anything in
the 50–100 MB band needs the same treatment.

**Codebook PDFs are not in the repo.** `.gitignore` carries a blanket `*.pdf` rule, so every
`ZA*_cdb_*.pdf` and questionnaire under `external/` exists on disk but is untracked. Re-download
from the source links above if setting up a fresh clone.
