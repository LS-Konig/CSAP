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
