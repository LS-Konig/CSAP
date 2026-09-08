# DECISIONS

Judgement calls made in this project that are not derivable from the code or the data, with
the reasoning behind each. Newest section last. Where a decision has a switch in code, the
switch is named.

---

## 3.3 Party attachment over time (Mannheim EB + CSES)

Notebook: `code/03_explanal/3.3_pid_over_time.qmd`.
Date: 2026-08-04.

### D1. CSES Module 5 is excluded from the stack

**Decision.** The CSES leg is IMD + Module 6. `cses5.rdata` is not read.

**Why.** The Integrated Module Dataset already contains Module 5 in full: 114,714 of its
395,797 rows carry `IMD1008_MOD_5 == 1`, exactly the row count of `cses5.rdata`, and 55 of
Module 5's 56 election-study IDs appear in IMD. Stacking the two would count every Module 5
election twice. Module 6 shares zero study IDs with either, so it is a genuinely
independent addition.

**Alternative rejected.** Filtering IMD to `IMD1008_MOD_5 == 0` and adding Module 5 as its
own series would also avoid double-counting, but splits the IMD harmonisation at an
arbitrary seam for no analytical gain.

### D2. Eurobarometer "merely a sympathiser" counts as attached

**Decision.** `closepty == 3` maps to `attached` with `pid_strength = "sympathizer"`, and
carries an `is_sympathizer` flag. Switch: `sympathizer_as_attached`.

**Why.** It is the closest Eurobarometer analogue to a CSES leaner, which the CSES
branching probe also counts as attached, so it keeps the two instruments as close as their
wordings allow.

**Caveat, and it is a large one.** This is worth about **thirty percentage points** of the
Eurobarometer attachment share — the measured level roughly halves if sympathisers move to
`not_attached`, consistently across 1975-1994. The notebook reports both versions rather
than burying the choice. This is not merely a robustness check: it is a live demonstration
of step 3 of the argument chain (coding choices shift the population of inference) inside a
single unchanged survey item.

### D3. EU scope is "ever a member", UK included

**Decision.** Any country that has been an EU/EC member at any point enters with all of its
available years. Norway and Switzerland are excluded. Switch: `eu_scope`, alternative
`"from_accession"`.

**Why.** The literal reading of "currently a member" would drop the UK, which left in 2020,
and with it a large part of both the 1975-1994 Eurobarometer series and the CSES series.
For a historical question about attachment that is the wrong exclusion. The accession-year
filter remains available and is implemented from `eu_accession` plus the native CSES
"member at time of election" flags.

**Note.** East Germany inherits Germany's 1958 accession year, so the `"from_accession"`
scope does not blank out the East German series. That is correct — the territory entered
through unification, not an accession of its own.

### D4. The CSES time index is the election year, not the fieldwork year

**Decision.** `year` is `IMD1008_YEAR` / `f1009` for CSES. `field_year` is carried
separately and unused as an index.

**Why.** Discovered empirically: indexing on fieldwork year split single election studies
across a calendar boundary and produced spurious near-empty cells (Belgium 1999/2000 at
n = 4, Sweden 2023 at n = 4). Election year is what a post-election study is a study of,
and keeps one study in one cell. After the change no country-year falls below the minimum
effective N.

**Consequence accepted.** A country running two studies of one election (`DEU12002`,
`DEU22002`) or two elections indexed to one year is pooled into a single country-year. The
series is descriptive and the alternative is an arbitrary tie-break.

### D5. Weights: within-sample, not between-polity

**Decision.** `IMD1010_1` for IMD, `f1101_1` for Module 6, `wnation` for Eurobarometer.

**Why.** Every estimate is a share *within* a country-year. Module 6's `f1103_1` ("polity
weight: sample") is identically 1 within a polity — it exists to make polities count
equally when pooling, not to correct a sample — so using it would amount to running
unweighted. Eurobarometer's `weuro` weights countries to EU population and is wrong for the
same reason; `wnation` is the within-country weight. Verified rather than assumed: the
notebook asserts the chosen weights vary.

### D6. No `survey` / `srvyr`; Kish effective N with a Wilson interval

**Decision.** Design-corrected intervals come from the Kish effective N,
`(sum w)^2 / sum(w^2)`, fed into a Wilson score interval. Neither package is installed and
neither is added.

**Why.** Neither source ships primary sampling units or strata, so `survey::svydesign()`
could only ever be given weights — which is exactly what this computes. Adding a dependency
would buy nothing. This is a considered equivalence, not a shortcut; if a source with real
design variables is added later, this decision must be revisited.

### D7. Don't-know is never collapsed into "not attached"

**Decision.** `pid_status` has four levels: `attached`, `not_attached`, `dk_refused`,
`not_asked`. DK/refused is reported in every table and drawn as its own band.

**Why.** A respondent who declines the attachment item is not a respondent who denies
attachment. Both CSES releases code refused (`7`) and don't-know (`8`) as volunteered and
separate, so the distinction is in the data and only an analyst can destroy it. DK rates
move substantially across waves and countries and are part of the finding.

### D8. "Not asked" is separated from item nonresponse at the survey level

**Decision.** `item_fielded` is TRUE for a survey if any respondent in it answered
substantively. Surveys that never fielded the battery are dropped from denominators;
nonresponse inside a fielded survey stays in as `not_asked` and is reported.

**Why.** CSES codes both "this study did not field the item" and "this respondent has no
value" as `9`. Treating the two alike would either inflate `not_asked` in fielded surveys or
silently include unfielded surveys with a 100% `not_asked` share.

### D9. Both Eurobarometer vote constructs are kept, and kept apart

**Decision.** The Eurobarometer contributes two row-sets, `voteint` -> `vote_intention` and
`lastvote` -> `past_vote`, distinguished by `vote_item_type`. CSES contributes `past_vote`
only. A country-year may legitimately appear twice.

**Why.** The trend file carries both a vote intention ("if there were a general election
tomorrow") and a last-vote recall. These are different constructs and averaging them would
manufacture a quantity neither instrument measures. Marginal attachment shares are computed
on the `vote_intention` row-set only, so the duplication does not double-count the
attachment item.

**Sub-decision.** A blank or spoilt ballot (`995`) counts as having voted but never as a
party choice; "would not vote" / "not voted" (`996`) counts as not voting; refused and DK
are `NA`, not FALSE.

### D10. No splicing, and the offset is not estimable

**Decision.** The two instruments are always plotted as separate series. No bridged line,
no calibration, no assumed constant instrument effect.

**Why.** Independent of preference, it is not estimable here: the Eurobarometer attachment
item ends in 1994 and the CSES series begins in 1996, so **zero** country-years carry both.
The overlap table is produced anyway so the emptiness is visible rather than merely
asserted. Only slopes within a source are comparable.

### D11. Germany and the UK are split where the source splits them

**Decision.** Eurobarometer `nation1` is used, not `nation2`, giving `DEU-W` / `DEU-E` and
`GBR-GB` / `GBR-NI` as distinct `country_unit` values under a shared `country_iso3`. CSES
German studies are labelled `DEU`.

**Why.** `nation2` pools both pairs and the information cannot be recovered afterwards. CSES
has no equivalent split: all German CSES studies are post-unification and `IMD1007` (sample
component) is documented only as "see election study notes", so no generic respondent-level
East/West indicator exists. The asymmetry is documented rather than papered over.

### D12. Pooled series are unweighted country averages, and are gated

**Decision.** Cross-country pooling is an unweighted mean over countries, labelled as such
everywhere, and years resting on fewer than three countries are not drawn
(`min_countries_pooled`).

**Why.** Countries are not population-weighted, so the pooled level is not an EU population
quantity. A CSES country contributes only in its election years, so the country set behind
each pooled point changes from year to year; without a floor the series would be dominated
by compositional change. Even with it, remaining movement mixes real change with
composition, and the caption says so.

### D13. The parquet cache is deliberately untracked

**Decision.** Parsed sources are cached to `data/02_processed/pid_cache/*.parquet`.

**Why the name matters.** `.gitignore` carries a blanket `*cache*` rule, so this directory
is untracked. That is intended — it holds derived artefacts rebuilt from the raw files, and
one of them would otherwise be a large binary in git. Recorded here so it reads as a choice
rather than an oversight. Note that labelled types (`haven_labelled`, the CSES
`label.table`) are stripped before writing, because they do not round-trip through parquet.

### D14. The crosswalk is emitted from the mapping objects

**Decision.** `data/03_final/pid_crosswalk.csv` is generated from the same `map_*` tibbles
that drive the recoding, not hand-written.

**Why.** A hand-written crosswalk drifts from the code the first time a mapping changes.
Generating it makes divergence impossible. The notebook additionally asserts that the value
codes CSES declares for the attachment item are exactly the codes the map covers, so a
release that renumbers a category fails loudly instead of silently falling through to
`not_asked`.

---

## External data coverage (CSES + Eurobarometer)

Verified against the files on disk and named sources.
Date: 2026-08-18.

### D15. The Eurobarometer attachment gap is not fillable; the long-run series comes from elsewhere

**Decision.** The Eurobarometer is the **pre-1995 leg only**. It is not extended, not bridged,
and not searched further. Any series reaching back before 1996 comes from an *ex post*
harmonisation of national election studies.

**Why.** The wave-by-variable grid in `Trends_EBs_1970-2021.xlsx` (sheet `1 Trends`, row
`party_att_deg`) lists every wave that fielded the item: **1970; every half-year from 1975 fall
to 1994 fall; spring 1996; autumn 2009.** Nothing in 1997–2008. The hole is therefore a property
of the Eurobarometer programme, not of what happens to be on disk, and no download closes it.

**Alternative rejected.** Assembling standalone EB waves for 1997–2008 from GESIS. There is
nothing to assemble — the item was not fielded in those years.

**What this leaves.** Exactly one recoverable wave: **EB 44.2bis, ZA2828 (Jan–Mar 1996)**,
absent from the Mannheim trend file (which jumps EB 44.1 → EB 45.1) and falling before the
harmonised file's 2004 start. Downloading it would add one point, not a series.

**Two corrections to earlier documentation.** The inventory previously said the series ran
"1975–1994 plus a single 2009 wave". 1970 also fields the item, in a two-category variant that
Mannheim's `closepty` does not reach and that is not comparable to the four-category version;
and 1996 is a fielded wave rather than merely a documented one.

**Open, and flagged rather than resolved.** The harmonised file places the 2009 fielding in
EB 71.3, which ran in **spring** 2009; the trends grid places it in **autumn** 2009. One label is
wrong. Check which wave the responses actually come from before the 2009 point carries weight.

**Consequence.** D10 already forbids splicing the Eurobarometer to the CSES, and this decision
removes the temptation to try: there is no overlap to calibrate on and no missing waves to find.
The candidate replacements are recorded in `data/01_raw/external-data.md` §C.6, undecided.

### D16. CSES is frozen at IMD Phase 4 and Module 6 Second Advance Release

**Decision.** The pinned versions are `VER2024-FEB-27` (IMD) and `VER2025-DEC-16` (Module 6),
recorded here and in the inventory table. Nothing further is downloaded.

**Why.** Both are current, verified by reading the version variables in the files themselves
(`IMD1002_VER`, `f1002_ver`) rather than from the release pages. IMD Phase 4 is the latest
release with no Phase 5 announced as of Aug 2026; `VER2025-DEC-16` is the Module 6 *Second*
Advance Release, not the first. Modules 1–4 need no standalone download because the IMD
integrates Modules 1–5, and Module 5 is already known to be a strict subset of the IMD (D1).

**Why record the strings.** "Advance release" no longer identifies a Module 6 file now that two
exist. Pinning both versions makes a future re-download a deliberate act with a visible diff
instead of a silent upgrade that moves estimates without explanation.

**Standing caveat, unchanged.** Module 6 remains an advance release: coverage will change on full
release, so any Module 6 result is provisional and must be re-run against the final file.

---

## Pooled series and source roles

Date: 2026-08-18. Prompted by checking a plausible-looking external summary table against the
project's own computed series, which it did not survive.

### D17. Pooled attachment series are computed on a balanced country panel

**Decision.** Any cross-country attachment series reported as a *trend* is computed on a
**constant set of countries** across the years compared. Unbalanced country means may be
computed and shown, but never described as a trend.

**Why.** The country set grows over the period — Greece 1981, Spain and Portugal 1986, East
Germany 1990 — and the entrants carry higher attachment, so an unbalanced mean understates the
within-country decline. On one frame (raw `nation1`, 20 fielded years, substantive denominator,
unweighted country mean), comparing 1975–79 against 1990–94:

| Series | 1975–79 | 1990–94 | Change |
|---|---|---|---|
| Unbalanced (10 → 15 countries) | 63.5% | 55.6% | −7.9pp |
| Balanced (10 countries, all 20 years) | 63.5% | 53.7% | **−9.8pp** |

Composition is therefore worth about **two points of a ten-point decline** on this series. Real,
worth removing, but it does not flip the sign.

**The finding replicates on the project's own frame.** On `pid_country_year.csv` — EU-scope rule
(D3), `country_unit` (D11), DK in the denominator (D7) — the same period means give **61% → 51%
balanced (−9.9pp)** and 61% → 52% unbalanced (−8.9pp). Levels run 2–3 points lower, as the DK
share implies; the change is the same. `pooled_contrast` in `3.3_pid_over_time.qmd` computes it.

**Endpoint years are the trap that actually bit, and are why this is written down.** An earlier
draft compared single years, 1975 against 1994, and read the series as **flat** — because 1975
sits at a local low and 1994 at a local high, so that comparison returns −1.6pp where the
five-year period means return −10pp. The country set was blamed for a difference the endpoint
choice produced.

**So the rule is wider than the heading.** A series is comparable across years only if the
country set, the denominator, the item-availability restriction **and the window** are held
constant. Contrasts are computed on multi-year period means, never on the first and last
observation; state the frame above any table of shares; and never read a number computed on one
frame as the counterpart of a number computed on another.

**Relation to D2.** The sympathiser rule is worth ~31 points and the frame choice here another
~8. Neither is recoverable after the fact from a quoted percentage, which is why both must travel
with the number.

**Relation to D12.** D12 gated pooled series at a minimum of three countries per year. That is
necessary and not sufficient: a year can clear the floor and still rest on a different country
set than the year it is compared to. D17 adds the constant-set requirement on top.

**Consequence beyond data management.** The balanced series also shows *where* the decline sits:
"very close" falls 10.1% → 7.9%, losing **22%** of its level, against **15%** for the binary
attached / not-attached filter. So dealignment in this period is disproportionately a decline in
**intensity**, which a binary selection filter registers only partially. State it that way — as a
difference in rate — and not as "the binary is flat", which it is not: the binary falls 9.8
points. The overstated version was in an earlier draft of this file and is the reason the
relative figures are now given alongside the absolute ones.

**Caveat carried with the numbers.** Unweighted means over countries, so the pooled level is not
an EU-population quantity (as D12 already states), and "merely a sympathiser" counts as attached
throughout (D2). Both readings of the sympathiser rule must be checked before any figure here is
published.

### D18. The ESS is the composition series, and never an AP source

**Decision.** The European Social Survey is promoted to priority collection and scoped to the
**attachment-share and taxonomy legs, 2002–2024**. It may not enter any affective-polarization
estimate.

**Why promoted.** It carries the closeness item with strength and vote recall on the same
respondents, across ~30 countries, biennially from 2002 — so the explicit / vote-anchored split
is constructible continuously over the frame. Nothing else free does this after 2002; the CSES
observes a country only in its election years, which is what makes CSES-based "European averages"
in a given year rest on whichever two to eight countries happened to vote.

**Why the ceiling.** The ESS has **no party thermometers**. It can say who counts as a partisan
and how that changes; it can say nothing about how warmly anyone feels. Treating it as an AP
source would mean substituting a closeness or trust item for an affect measure, which is the
construct error D10 and the comparability caveats already forbid.

**Splicing.** D10 applies between ESS and CSES exactly as between Eurobarometer and CSES: separate
series, no bridging, slopes compared within a source only. Different wording — the ESS asks the
*relative* form ("closer to one party than all the others"), a lower bar than the CSES "usually
think of yourself as close" — so the levels are not comparable even where the years overlap.

### D19. The EU Open Data Portal is ruled out

**Decision.** Not a source for this project. Eurobarometer microdata comes from GESIS.

**Why.** The portal publishes *aggregated* Eurobarometer volumes — variables broken down by
country and selected demographics — while respondent-level files are distributed by the GESIS
Eurobarometer Data Service. Every quantity this project needs is a respondent-level cross-tab of
attachment against vote, which no aggregate table can reconstruct.

**Recorded because it looks useful.** It is an official EU source with an open licence and turns
up first in searches, so it will be proposed again unless the reason for rejecting it is written
down.


---

Politbarometer equivalent for other countries?
Party specific PID?

What even is partisanship in Europe?
Decline or realignment? -> cross-national trends by party or challenger/mainstream status or center / periphery position

What does partisanship do?
Within-party contrast AP -> increases AP, but not needed for measurable AP

Perceived positions of parties vs "actual" positions of parties: divergence larger for PIDs?


What needs to be done:

- data and coverage overview (what country, what year, what item)
- literature RAG