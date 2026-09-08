# Which paper? A decision memo

Five candidate designs the existing data can support, and a recommendation.

Date: 2026-08-18. Status: **decision pending.**
Companion to `DECISIONS.md` (calls already made) and `.claude/CLAUDE.md` (`### Status`).

---

## The decision to be made

The 2026-08-17 rerun on the stricter attention-check frame broke step 6 of the argument
chain: explicit partisans show *more* behavioral AP than vote-anchored ones, not the same
amount. The skeleton in `index.qmd` survives — the design, the taxonomy, the model
specification, the pre-registered threshold discipline are all unaffected — but its
**headline does not**. What the paper is *about* is now open.

This memo sets out five designs the data on disk can support, scores each on the same
axes, and recommends one. It does **not** decide the direction or size of $\Delta$. That is
deliberate: no candidate below depends on how the type contrast comes out, and for the
recommended one that independence is a large part of the case.

---

## The bar

Top-tier general-interest journals take measurement papers when the measurement problem
*changes the answer to a substantive question people already care about*.

- "The filter is arbitrary" → *Political Analysis*, *BJPS*, *Sociological Methods*.
- "The filter is arbitrary **and** the stylized fact it produced is wrong" → APSR.

So one question discriminates across all five candidates: **what published finding does
this recalibrate?** In the current skeleton that content sits in §8 (`sec-comparative`),
filed as calibration. In most candidates below, §8 becomes the paper.

## The asset

`eu25games2019` is, as far as we can establish, the only source carrying an **attitudinal
and a behavioral AP measure on the same respondents across 25 European systems.** TRI-POL
is the only other source pairing the two at all, and does so in three European countries,
on an opt-in Netquest panel with no weights, with the game counterpart piped by a
type-dependent rule that varies the anchor as well as the reporting (see
`data/01_raw/external/tripol/tripol.md`).

That asset supports a larger claim than the skeleton currently makes. Whichever candidate
wins should spend it rather than hold it in reserve.

---

## At a glance

Candidates are **alternatives, not stages** — the letters are labels, not an order.

| | Candidate | Recalibrates | Primary data | Identification | Cost | Verdict |
|---|---|---|---|---|---|---|
| **A** | Selection filter | Comparative AP rankings | `eu25games2019` | Descriptive + within party-country cells | Low | Viable; APSR only if the substantive relationship moves |
| **B** | Identity vs. position | The party-over-policy debate | `eu25games2019` conjoint + placements | Cue randomized; distance randomized via the label; type is not | Low–med | Plausible headline; the mechanism behind C |
| **C** | Dealignment paradox | "Europe is polarizing" | CSES IMD + EB + `eu25games2019` | Decomposition over election studies | High | **Recommended** |
| **D** | Behavioral validation | Whether AP rankings travel to behavior | `eu25games2019` | Within-respondent, both measures | Very low | Best value per day; thin at country level |
| **E** | Partisanship as cleavage | Relative weight of partisan vs. other cleavages | `eu25games2019` conjoint | Fully randomized, causal | Low | Cleanest identification, weakest novelty |

---

## A. The selection-filter paper

*The current design, with the headline moved.*

**Claim.** Comparative AP rankings across European democracies are partly a ranking of
national willingness to say "close to a party," not of polarization.

**Design.** As specified in `index.qmd` — hold the anchor constant, vary only the reporting
— but §8 leads and §5/§6 become its mechanism. Add the "so what" test the skeleton
currently lacks: re-estimate a *published* cross-national relationship (AP × satisfaction
with democracy, AP × populist vote, AP × turnout) under all four ingroup codings and report
whether the estimate moves.

**Data.** `eu25games2019` alone for the contrast; one external country-level covariate for
the "so what" test.

**Clears the bar if.** A coding rule flips the sign or materially shifts a relationship the
literature already reports. Then the paper is not "your filter is arbitrary" but "your
finding depends on it."

**What kills it.** Country rank correlations near 0.95 *and* a stable substantive
relationship. Then it is a null measurement note — which we are committed in advance to
reporting, and which is worth publishing, just not here. This is cheap to find out; see
Gate 2.

---

## B. Identity vs. position — the party-over-policy debate, adjudicated behaviorally

*Reframed 2026-08-19. This was "identity vs. categorization", which is the same question under a
name only this subfield uses. Naming the American debate connects it to @orr2020policy,
@orr2023affective and @dias2022nature rather than to expressive partisanship alone.*

**Claim.** Party cues carry group membership **and** ideological content at once, so partisan
discrimination is observationally equivalent between an identity account and a policy account
[@orr2023affective]. The American resolution is to *add* policy information to the cue and see
whether the party effect survives [@orr2020policy; @dias2022nature] — which buys the
information-equivalence problem [@dafoe2018information]. Europe supplies the separation without
manipulation. **Estimand:** how much of partisan discrimination is graded by ideological
distance, and how much survives it.

**Design.** The backbone is specified at `index.qmd:154`–`351`; the no-cue baseline
$\mu_t(\text{None})$ still does the work of pricing $\Delta$ against the cue effect. Three
elements make it a party-over-policy design, and one correction is needed first.

- ⚠ **Correction to the previous version of this section.** It claimed the conjoint benchmarks
  the partisan attribute "against EU position, class and religion". **There is no policy
  attribute in the conjoint.** `cj_eupos` has levels `eu_citizen` / `not_eu_citizen` — raw
  wording *"Player 2 feels that he/she is an EU citizen"* — which is an **identity** attribute.
  The benchmark is against class, religion and EU *identity*. `.claude/CLAUDE.md` carries the
  same error in its §6 plan and needs the same fix.
- **Randomized distance.** The conjoint randomizes the displayed party from the respondent's own
  party system (`ext_cj_party_pf_name`: 137,100 rows, 316 parties). Attach a position to each
  party and the ideological distance between respondent and profile becomes **randomly
  assigned** — as a by-product of randomizing the label, with no policy statement ever shown.
  Nothing extra is disclosed, so nothing extra is inferred, and @dafoe2018information's objection
  does not arise. The estimand is within-respondent, averaged over each respondent's own
  party-system geometry: distance is randomized *conditional on* the respondent's fixed position,
  and a centrist faces a different distribution of available distances than someone at a pole.
- **Vote-anchored respondents are a naturally occurring "position without declared identity"
  group.** The sharpest point, and it is this project's existing design read in party-over-policy
  terms. Both types have a party, hence a position; they differ only in whether identity is
  *reported*. So $\Delta$ **is** a party-over-policy contrast: if animus is policy-driven,
  $\Delta$ should collapse once positional distance is conditioned on, because the two types are
  positionally alike; if identity-driven, it survives. The American literature cannot run this
  comparison, because nearly everyone there with a party also reports identifying with one.
- **Projection as a finding, not a nuisance.** Perceived placements are endogenous to affect —
  liked parties are pulled closer, disliked ones pushed away — so own-perceived distance cannot
  serve as a clean control. But the *gap* between perceived and external placement measures
  motivated perception. If self-identified partisans distort distance more than vote-anchored
  ones at the same external distance, that is identity operating **through** position, and part
  of the apparent positional effect is itself identity-produced. This is the one use that turns
  the placement batteries' main weakness into the contribution, and it is what earns the upstream
  Party Facts merge.

**Data.** `eu25games2019` conjoint (behavioral) and thermometers (attitudinal), plus the
ideological placement batteries: `q_lr_self` and `q_euint_self` (1–11; 86.5% and 93.6% coverage,
**19,247 respondents with both** — 4,243 vote-anchored, 12,509 explicit) and the perceived party
placements `q_lr_party_1..13` / `q_euint_party_1..10`. External positions (CHES 2019 or
equivalent) merge via Party Facts.

⚠ **Dependency.** The perceived-placement batteries carry **no Party Facts IDs**, so the
projection leg is blocked until they are merged upstream. The conjoint leg is not — the displayed
party is already PF-linked.

**Clears the bar if.** Three things Europe supplies that the American literature must manufacture:

- **Natural decoupling.** In a two-party system "out-party" is nearly synonymous with
  "ideologically distant", which is why that literature has to manufacture the separation with
  vignettes. In a multiparty system an out-party can be ideologically adjacent or opposite, and
  identity relationship and ideological distance vary independently in the data as it stands.
- **Two cross-cutting dimensions.** Left–right and EU integration divide parties *within* left
  and *within* right in 2019, separating "does any disagreement drive animus" from "does
  cleavage-defining disagreement drive it" — a distinction a single-dimension system cannot pose.
- **A behavioral outcome.** The debate has been fought largely on ratings; token allocations in
  the dictator and trust games put it to costly-ish behavior across 25 systems.

**What kills it.**

- **No policy attribute.** Positional variation enters *only* through the party label, so this
  design tests whether discrimination is **graded by** ideological distance — not whether policy
  alone suffices, which is what @orr2020policy and @dias2022nature establish. Flat in distance
  favors categorization; rising in distance favors position. This is a weaker claim than the
  American vignette studies make and must not be written as an equivalent one.
- **$T$ is still a self-report.** The randomized label gives an *experimental* positional
  gradient, so this is no longer purely "two self-reports and a behavior" — but partisan type is
  not assigned, and no grouping structure changes that. The ceiling at `index.qmd:340` stands.
- **Extremity confound.** Distance to a given party correlates with the respondent's own
  extremity, which independently predicts AP. "Distance to this party" and "own extremity" have
  to be separable before any of this reads as positional.
- **Differential non-response.** Left–right self-placement is missing for **19.8%** of
  vote-anchored respondents against **7.4%** of explicit ones, so listwise deletion selects on
  type — the same concern the model specification already records for thermometer don't-knows.

**Verdict.** Upgraded from "strong section, weak headline". A randomized positional gradient and
a named debate to enter make B a plausible headline in its own right. Against C it is the
**mechanism** and C is the **trend**: C explains why the composition of the partisan population
matters over time, B explains what the partisan cue is actually doing to behavior. If C is
written, B is its mechanism section rather than a rival.

---

## C. The dealignment–polarization paradox — **recommended**

**Claim.** The composition of the partisan population changed underneath a filter that could not
see it. European dealignment is a decline in the **intensity** of party attachment, while the
binary attached / not-attached item the field uses to select partisans moves far less. Because AP
is estimated on whoever clears that binary, measured AP trends confound a change in *who
qualifies* as a partisan with a change in *how partisans feel*. Decompose the trend and report
how much survives.

**The premise, measured** *(balanced 10-country Eurobarometer panel, 1975–79 vs 1990–94, frame
and denominator stated in `external-data.md`; D17)*. "Very close" falls 10.1% → 7.9%, losing
**22%** of its level; "merely a sympathiser" — which the binary counts as attached — falls
34.9% → 28.1%; and the binary itself falls 63.5% → 53.7%, losing **15%**. So intensity declines
about half again as fast as the filter that selects on it. That is the claim: a difference in
rate, not a binary that fails to move.

**Robustness.** The decline replicates on the project's own frame (`pid_country_year.csv`:
EU-scope, `country_unit`, DK in the denominator): 61% → 51% balanced, 61% → 52% unbalanced. Two
frames, one conclusion — so the ~10-point fall is not an artefact of the denominator.

**Two corrections to earlier drafts of this memo, kept visible because they are the same error
the paper is about.** It first said attachment "collapsed", which overstates a 10-point fall. It
then said the unbalanced series is *flat* — that came from comparing **single endpoint years**
(1975 vs 1994) rather than period means. 1975 is a local low and 1994 a local high, so that
comparison returns −1.6pp where five-year means return −10pp. Composition is worth ~1–2pp here,
not the difference between flat and falling.

**The composition demonstration.** The balanced/unbalanced contrast remains a candidate figure,
but it must be presented at its true size: ~1–2pp of a ~10pp decline. The larger and more
teachable effect is the **window** — endpoint years versus period means turned a real decline
into an apparent null on this very series, in this project, before the period-mean check caught
it. That is the version worth showing, and it is a failure we walked into rather than one
constructed for a referee.

**Design.** Compute Reiljan-style AP per election study under each coding rule, then
decompose $\Delta \mathrm{AP}$ over time into (i) change in *who counts* as a partisan and
(ii) change in *how partisans feel* — a Kitagawa–Oaxaca decomposition, or DFL reweighting
if the composition shift is multivariate. `eu25games2019` supplies the individual-level
mechanism and the behavioral validation no time series can give.

**Data.** CSES IMD (`VER2024-FEB-27`, Phase 4) carries the party like–dislike battery
(`IMD3008_A`–`_I`) alongside the full branching attachment battery (`IMD3005_1`–`_4`) and vote
choice (`IMD3002_LH_PL`), over 230 election studies in 59 polities — and **149 of those
study-years carry all three items at once**, 82 of them inside the 25-country frame, spanning
1996–2021. Eurobarometer supplies the pre-1996 attachment trajectory motivating the composition
channel, over 1970 and 1975–1994 (plus spring 1996). Both are on disk and current; notebooks
3.3, 3.4 and 3.5 have already done the inventory work this rests on.

**Clears the bar if.** It answers a question the whole field asks — *is Europe polarizing?*
— rather than a question about the field's methods. It resizes a stylized fact and yields a
headline number. And it makes the measurement argument load-bearing without being the
point: §3's coding census becomes the *reason the decomposition is necessary*, not a
standalone contribution.

**Direction-agnostic.** The paper stands whichever way $\Delta$ comes out, because the
composition channel is driven by the *share* of attachers and the *gap* between types, not
by the gap's sign. This is the strongest structural argument for C over A and B.

**What kills it.**

- **Wording and mode breaks.** Documented in `external-data.md`: the leaky CSES branch,
  code `9` conflating "not asked" with "missing", Norway never fielding the probe, EB's
  English/French asymmetry within a single wave.
- **The EB hole, now confirmed as permanent.** 1997–2008 is not covered by *any* Eurobarometer
  wave — the item was not fielded, so no download closes it (D15). Nor is it bridgeable to the
  CSES: zero country-years carry both instruments (D10). The pre-1996 leg must come from a
  national-election-study harmonisation, which is Gate 1b.
- **A thin common base.** The decomposition needs election studies carrying attachment,
  vote recall *and* like–dislike simultaneously. If that set is small or clustered in
  recent years, the trend leg dies. See Gate 1 — **now answered, and it passed**: 149 of 230
  study-years carry all three items, 82 of 105 within the frame. What remains open is only the
  pre-1996 extension, Gate 1b.

**Cost.** Highest of the five, but every file is already on disk and
`cses_item_availability.csv` exists precisely to answer the gating question.

---

## D. Does attitudinal AP predict behavior?

**Claim.** Country rankings on thermometer AP do — or do not — predict country rankings on
behavioral partisan discrimination.

**Design.** Individual-level association, country-level rank correlation, partisan type as
moderator. `eu25games2019` alone; nothing needs downloading.

**Clears the bar if.** The correlation is weak. Then every cross-national AP ranking
(Reiljan, Wagner, Gidron) ranks something that does not travel to behavior — a large, clean
claim from data nobody else has.

**What kills it.** Twenty-five country-level points. The country correlation will carry
wide uncertainty and **a null cannot be claimed from it** — the same inference discipline
that governs $\Delta$ applies here. Ten hypothetical tokens invite the reply that the
behavioral measure is the invalid one; the Carlin & Love and Westwood benchmarks on disk
help and do not settle it.

**Verdict.** Cheapest of the five and the best value per day. **Run it regardless of which
paper wins** — it also tells us whether C's behavioral leg has anything to say.

---

## E. Is partisanship a European cleavage?

**Claim.** Benchmark partisan discrimination against class, religion, EU identity and
nationality within the same randomized profiles, across 25 systems. Where does partisanship
rank as a basis for discrimination in Europe, and what explains the cross-national spread?

⚠ Corrected 2026-08-19: this said "EU position". The conjoint attribute `cj_eupos` is EU
**citizenship** (*"Player 2 feels that he/she is an EU citizen"*), not a position on
integration — so every cleavage in this benchmark is an ascriptive or identity category, and
none is a policy position. That narrows what E can claim: it ranks partisanship against other
**identities**, not against policy disagreement. See candidate B for the same correction.

**Design.** Pure experiment. Causal within respondent, no self-report identification
problem at all; partisan type enters as heterogeneity rather than as the estimand.

**Clears the bar if.** The cross-national variation in the *relative* weight of
partisanship turns out to be systematic and explicable.

**What kills it.** Closest to @hahm2024divided's published paper. The new angle would have
to carry the whole contribution, and "we added the partisan-type split" may not be enough
distance. Also drifts descriptive easily.

**Verdict.** Cleanest identification, weakest novelty. Best used as §6 of another paper.

---

## Recommendation

**Write C, with B as its mechanism section and D as its validation section.**

The measurement argument (A) becomes the *reason the decomposition is needed* rather than
the contribution itself. That reframing is what moves this from a good methods paper to a
general-interest one, and §3's coding census survives intact and becomes more important,
not less.

Three properties decide it:

1. **It recalibrates a stylized fact**, which is the bar stated above. A, B and E
   recalibrate a practice; D recalibrates an instrument.
2. **It is direction-agnostic.** The current skeleton's §6 heading commits to a contrast
   whose direction is open. C's viability does not depend on it.
3. **It spends the asset.** The attitudinal/behavioral pairing becomes the mechanism
   evidence behind a trend claim, rather than the whole paper.

Gate 1 has since passed, so the fallback is no longer live in the form written here: C's trend
leg stands on the CSES from 1996 whatever Gate 1b returns. The fallback if **Gate 2** also comes
back deflationary is **A with the "so what" test attached** — not the skeleton as it stands.

---

## What to do next

Three gates. None is a section; all are checks that decide which paper gets written. Effort
figures are rough.

### Gate 1 — the CSES common base *(ANSWERED 2026-08-18: pass)*

The gate asked whether enough election studies carry the attachment item (`IMD3005_1`), a vote
item (`IMD3002_LH_PL`) and the like–dislike battery (`IMD3008_A`) *together*. Counted directly
on the IMD:

| Scope | Study-years with all three | Span | Polities |
|---|---|---|---|
| All polities | **149 of 230** | 1996–2021 | 45 |
| Within the 25-country frame | **82 of 105** | 1996–2021 | **22 of 25** |

Against the pass threshold set above — 150+ studies, 25+ years, 20+ polities — this **passes** at
the all-polity level (149 studies is a rounding error from the bar) and passes on span and
polities within the frame. **C's trend leg is live on the CSES alone from 1996.**

Two things the count also settled. **France, Ireland and the United Kingdom carry no study-year
with all three** — the largest single coverage cost, and worth stating in the paper rather than
discovering in review. And the series cannot start before **1996**, because the CSES does not.

Caveats to carry with the number: it is a crude study-level flag (majority-substantive per
study-year), not the per-item audit in `cses_item_availability.csv`, and it keys on **party A
only** for like–dislike. Re-derive before it becomes load-bearing. The documented traps still
apply — code `9` conflates "not asked" with "missing", and any pooled series must rest on a
common base of studies carrying every item being compared.

### Gate 1b — the pre-1996 extension *(the remaining open question; ~2–3 days)*

What Gate 1 does *not* settle is whether the trend reaches back far enough to speak to
dealignment. The Eurobarometer cannot supply it: the attachment item was fielded in 1970,
1975–1994, spring 1996 and autumn 2009, and **in no wave between 1997 and 2008** — verified from
the wave-by-variable grid and recorded as D15 in `DECISIONS.md`. So the pre-1996 leg has to come
from an *ex post* harmonisation of national election studies.

Three candidates, none on disk, none chosen: **West European Voter** (182 studies, 16 West
European democracies, 1961–2020, harmonised party *and leader* thermometers — the only one
confirmed to carry affect before 1996), **True European Voter** (ZA5054, 23 countries,
thermometer coverage unverified), and the **EES voter studies** (EU-wide, five-yearly, reaching
CEE from 2004, but the affect measure is propensity-to-vote, ⚠ a different construct from a
thermometer and not poolable with it).

The comparison protocol and the decision rule are fixed in advance in
`data/01_raw/external-data.md` §C.6 — in short, the source maximising **pre-1996 study-years
carrying all three items** wins, construct consistency as tie-break.

- **Pass** — a candidate adds a meaningful run of pre-1996 study-years → C gets its dealignment
  arm, and the decomposition spans roughly 1960s–2021.
- **Fail** — none reaches usefully before 1996 → the trend leg is CSES-only from 1996 and the
  Eurobarometer stands as a separate, non-spliced attachment series. C survives on a shorter
  window; the composition argument is unaffected, only its span is.

### Gate 1c — does the intensity decline replicate on a second instrument? *(~1–2 days)*

The intensity finding above rests entirely on the Eurobarometer, 1975–1994, on ten countries.
Before it carries the paper it has to appear on a different instrument. The CSES branching probe
supplies one: `IMD3005_4` ("how close"), 1996–2021, on the common base established in Gate 1.

Run the same decomposition — share very / somewhat / not very close among attachers, on a
**balanced set of countries** across the years compared (D17), which for the CSES means countries
with enough election studies to span the window rather than all 22.

- **Replicates** — intensity declines on both instruments, across different decades, wordings and
  country sets. The mechanism carries C, and the binary-filter argument is general rather than a
  property of the Eurobarometer's four-category item.
- **Does not replicate** — it stays a 1975–1994 finding, stated as such. C falls back on the CSES
  common base and the composition argument survives without the intensity mechanism, because the
  decomposition needs the *share* of attachers and the *gap* between types, not the intensity
  story.

⚠ The two instruments are not comparable in levels — different wording, different branch
structure, and the CSES asks strength only of those who already said "close". Compare the
**shape of the decline within each**, never the levels across them (D10).

### Gate 2 — the "so what" test for A *(~3–5 days; runs last)*

Estimate AP per country under all four ingroup codings (identity only; recall-maximizing;
vote only; most-liked party), then re-estimate a cross-national relationship the literature
already reports under each.

Start with a correlate available inside `eu25games2019` itself — cheapest, no new download.
Escalate to an external country-level covariate only if the within-survey version is
uninformative.

- **Pass** — an estimate moves beyond its own uncertainty, or flips sign, under a coding
  change → **A has its headline.**
- **Fail** — rank correlations ~0.95 and the relationship stable → report it as the
  deflationary result we pre-committed to. C is unaffected either way — it cleared Gate 1.

### Gate 3 — attitudinal vs. behavioral agreement *(~1 day; run regardless)*

From the existing `3.2_ap_measures.qmd` outputs and `thermo_long.rds`: the country-level
rank correlation between thermometer AP and conjoint AP across the 25, reported **with its
uncertainty**, plus the individual-level association.

- **Low agreement** → D is live as a standalone paper, and C gains a strong validation
  section.
- **High agreement** → D dies as a standalone; the two measures corroborate each other and
  C's mechanism section is simpler.

Either way this number is needed before anything can be claimed about *either* measure.
Non-overlapping intervals do not establish a difference and overlapping ones do not
establish a null — this applies to the correlation as much as to $\Delta$.

### Sequencing

Gate 1 is **done and passed**, which promotes C from candidate to working assumption.

**Gate 1c first** — it needs no new data, runs on the CSES already on disk, and it decides
whether the intensity mechanism is general or Eurobarometer-specific, which changes how C is
written. **Gate 1b and Gate 3 then run in parallel** — different sources, no dependency, and 3 is
cheap enough that it should simply be done. Gate 2 no longer gates the choice of paper; it now
only decides how much of A survives *inside* C, so it runs last.

Decision point after 1c, 1b and 3 report. Note that 1b is the only one waiting on a download.

### Blocking on Tristan, under every candidate

- **§3's journal set and year range are still unspecified.** The coding census cannot start
  until they are fixed, and §3 survives in every candidate above. Target remains ~40
  papers, hand-coded on two dimensions only.

### Do not start yet

- **The §7 panel leg.** Which panel is right depends on which paper wins — C changes what
  §7 has to do. TRI-POL has cleared the movement gate (18–23% switch per wave) but the
  choice is not settled, and exactly one candidate gets used.
- **Any further panel downloads.** Same reason.
- **Prose in `index.qmd`.** The section headers are provisional; writing into them now
  commits the structure before the gates report.

---

## What this memo does not decide

- The direction or size of $\Delta$. No candidate depends on it.
- The ROPE / effect-size benchmark. Fixed in §4 before any posterior is seen, per the
  standing discipline, whichever paper wins.
- Anything in `DECISIONS.md`. D1–D14 stand under all five candidates.
- The terminology. **Vote-anchored** in prose, never "leaners", never "implicit partisans";
  variable levels stay `implicit`. Claims remain **attitudinal vs. behavioral**, never
  vertical vs. horizontal.
