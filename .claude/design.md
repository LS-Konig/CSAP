---
last_modified: 2026-10-22
scope: agreed empirical design: question, goals, partisan types, outcomes, limits of the contrast, estimands, model building, open decisions
---

# Design

Read this before touching `index.qmd`'s argument, planning an analysis, or choosing an
estimand. Data mechanics live in `data.md`.

**Status.** Tristan and Claude agreed this design in a consult on 2026-10-20. It fixes the
question, the outcomes, the estimands and the threats to inference. **It states no finding.**
The model-building ladder is a guide, not a fixed sequence: it is adjusted during model development and as fits come in.
The `index.qmd` notes were trimmed to match.

## Question and contributions

**What does partisanship *itself* contribute to the different forms of polarization?**
"Partisanship" means reporting an attachment to a party. It is compared with respondents of
the same party who deny one.

Contributions:

- the comparative literature on polarization and political behavior: many facets, 25 countries, over time;
- the US debate of party-over-policy vs. policy-over-party: is the group attachment what people dislike, or the policy position it signals?

Europe offers leverage the US lacks. Attachment and vote come apart, and every respondent faces
several out-parties at varying policy distances.

## Inferential goals

1. A **pooled European type contrast** per outcome (the main result).
2. **Comparative**: how the contrast varies across countries (one figure).
3. **Dynamic**: how it changes over time (one figure; not the games).
4. **Decomposition**: change over time and differences between countries, split into the
   *mix of types* (composition) and *polarization within types*.
5. **Party-over-policy diagnostic**: the profile of type contrasts across outcomes, plus the
   tests in step 9 of the model building.

## Partisan types

All four core types, plus leaners where a probe exists, are used from the start. They come from the attachment × vote tree, with
"same party" decided by `pf_match()` (see `data.md`).

| Type | Definition | What it adds | Main comparison |
|---|---|---|---|
| **Explicit** | attached, voted for the same party | the reference partisan | — |
| **Denier** (vote-anchored) | denies an attachment, reports a vote | same party, no attachment: the core contrast | vs. explicit, within the vote party |
| **Leaner** (CSES, EES 2009) | no attachment, but leans towards a party when probed, voted for it | a weaker attachment between explicit and denier: grades the attachment instead of treating it as on/off | vs. explicit and vs. denier, within the vote party |
| **Mismatched** | attached to A, voted for B | separates attachment from vote: shares the attachment with explicit partisans of A and the vote with deniers of B. In AP, rating A vs. B is a **within-person** comparison | vs. explicit within A; vs. deniers within B |
| **Non-partisan** | no attachment, no vote | baseline for composition and for how parties are rated in general. **Diagnostic**: if deniers resemble non-partisans on pre-treatment traits but explicit partisans on the outcome, the vote is selecting them on the outcome | country-level reference, not within party |

- **No contrast identifies the attachment effect alone.** Each is selected by the vote in its
  own way. Whether it acts as a floor or a ceiling depends on the direction of that selection,
  which the design does not fix in advance:
  - *Explicit vs. denier* (within the vote party): a **floor** if deniers vote for the party
    partly because they dislike the alternatives (selection on the outcome). A **ceiling** if
    deniers are less engaged voters who vote for it out of habit, so the contrast also carries
    engagement.
  - *Explicit vs. non-partisan* (country level): a **ceiling** if not voting and not being
    attached both go with low engagement, so the contrast adds the vote and engagement to
    attachment. Not a ceiling if non-partisans hold strong views but reject parties. In AP,
    non-partisans have no in-party, so this compares only how the same targets are rated.
  - *Explicit vs. mismatched* (within the attachment party A): holds attachment fixed and
    varies the vote. It bounds nothing alone. If attachment and vote add up, it splits
    explicit vs. non-partisan together with the denier contrast.
  - *Mismatched vs. denier* (within the vote party B): same vote, attachment elsewhere. It
    shows whether an attachment pulls against the party voted for, not the effect of being
    attached to it.
  - Read together: if the floor and ceiling candidates fall in the order their conditions
    imply, the effect lies between them. If they cross, at least one condition fails. The
    non-partisan diagnostic above and the step-9 adjustments show which.
- **Mismatched respondents belong to two parties.** Respondent-level models give them both
  an attachment-party and a vote-party membership (cross-classified), so both comparisons are
  within party.
- **In AP the relation is coded per target party**: attached and voted / attached only /
  voted only / neither. Which in-party yields more polarization for mismatched respondents is
  then a contrast inside one model, not a choice between two codings.
- The mismatched group mixes strategic or coalition voting, multiple PID, recall error and
  match artefacts. Splitting within-bloc from cross-bloc mismatches, and auditing
  `pf_match()` for successor parties and alliances, come before interpretation.
- **Leaners exist only where a probe was fielded**: CSES and EES 2009. Leaner-specific
  results rest on those studies, and cover outcomes 0, 1, 3 and 5 (CSES has no EU items and
  no games). Where there is no probe, leaners sit among the deniers (if they voted) or the
  non-partisans, so a denier in ESS or eu25 is not the same category as a probed CSES denier.
  The probed studies show how much of the explicit vs. denier gap leaners carry. A leaner who
  voted for another party is kept apart from the mismatched type and reported only if the
  cell allows.
- Two further complications of the type: multiple PID, and wording that asks about
  attachment, closeness or identity (the ESS "closer to" item already takes in some leaners).

## Outcomes

| Outcome | Data, time | Unit | Polarization quantity | Type estimand | Multilevel structure | Specialities |
|---|---|---|---|---|---|---|
| **0 Composition** | EES, CSES, ESS, eu25; over time | respondent | — | share of each type by country and time | respondents in surveys in countries; trend by country | feeds the decomposition; wording and study differences are part of the model |
| **1 Ideological polarization** (LR, EU) | EES, CSES (mostly LR), ESS (EU in some rounds), eu25; over time | respondent | extremity (individual); dispersion and bimodality (group) | Δ extremity within party; group quantities on each type's distribution under a **common party mix** | respondents in party × country × survey; surveys in countries; trend | the centre of extremity is open (report alternatives); EU coverage is thinner |
| **2 Ideological sorting** (LR × EU) | where both items exist (EES, ESS rounds, eu25); over time | respondent (joint distribution) | strength of the LR–EU association, whatever its shape | alignment within each type, common party mix | as 1 | a group quantity; nonlinear (inverted U, Hooghe, Marks & Wilson 2002); the sign differs between countries, so measure within country and pool magnitudes |
| **3 Perceived party polarization** (LR, EU) | EES, CSES (LR), eu25; over time | respondent × placed party | spread of a respondent's placements over a fixed party set; scale-use-corrected stretch (Bayesian Aldrich–McKelvey) as an extension | Δ spread within party; Δ excess over a benchmark of actual positions | placements in respondents in party × country × survey; time | everyone in a country-survey faces the same real party system |
| **4 Perceived party sorting** | EES, eu25; over time | respondent × placed party | how aligned a respondent's own LR and EU placements are across parties | Δ perceived alignment; Δ excess over actual alignment | as 3 | few parties per respondent, so pool across respondents rather than computing a per-person correlation |
| **5 Vertical attitudinal AP** (+ EES 2024 horizontal attitudinal) | EES (PTV), CSES (like/dislike), eu25 thermometer; EES 2024 ratings of party supporters | respondent × rated party | in vs. out rating | $AP_t$, $\Delta AP$; two in-relations for mismatched; gradient in distance to the target | ratings in respondents and target parties; respondents in party × country × survey; time | relation coded per target; PTV is not pure affect, so it is a separate operationalization; EES 2024 fills the horizontal-attitudinal cell |
| **6 Horizontal behavioral AP** | eu25 games, 2019 only | respondent × round | tokens to a co- vs. out-partner | $AP_t$, $\Delta AP$, split into **in-group favoritism** (co vs. control) and **out-group derogation** (control vs. out) | rounds in respondents in party × country | see *Games specifics* |

Sorting means the two dimensions becoming more strongly correlated (the HMS deck's
*Sortierung*). Sorting of respondents relative to their party's position is **out of scope**.
Distance to one's own party is not an outcome either. Distance to the *target* party enters
AP as the party-vs.-policy test.

## Scope and limits of the within-party contrast

**What holds for every outcome:**

- **Absorbed**: everything shared within party × country: platform, status, the set of out-parties, elite cues, national norms about admitting an attachment.
- **Not absorbed**: individual-level confounders of attachment (age and socialization, parental partisanship, political interest, ideological intensity).
- **The vote can be a collider.** Deniers are selected on their reasons to vote for the party: proximity, candidates, dislike of the alternatives.
- **Measurement**: self-labelling and wording, plus recall error in the vote. Triangulating across studies and wordings addresses measurement, but not confounding that all studies share: a robust pattern can be robustly biased.
- **A causal reading needs**: conditional ignorability of attachment given party × country and pre-treatment covariates, no selection on the outcome through the vote, and a type that means the same across wordings.
- The posterior reflects sampling uncertainty and the pooling assumptions. It does not reflect selection or the composition of a group.

| Outcome family | What the contrast buys | Boundaries | Causal reading also needs | Where it likely fails |
|---|---|---|---|---|
| **Composition** | how the type mix varies across countries and time; the weights for the decomposition | trends partly reflect switching between studies or wordings | none (descriptive) | level comparisons across studies without wording effects |
| **Ideology and sorting** | rules out "attached partisans are in more extreme parties"; with the common party mix, group quantities are not driven by party choice | **reverse causation**: extreme or coherent people may attach *because* their views fit a party. Selection on proximity makes deniers look less extreme at centrist parties and more extreme at flank parties. Sorting within one party has restricted range | attachment prior to positions; no proximity selection | the strongest threat: ideology → attachment is at least as plausible as the reverse. Read as association net of party sorting. Type × party position tests the selection |
| **Perceived polarization and sorting** | the real party system is fixed within a country-survey, so perceived differences are not system differences; a benchmark separates perception from reality | **sophistication** raises attachment and may make perceived spread *more accurate*, not more biased; scale use differs; the set of placed parties differs by type | ignorability given sophistication; comparable scale use | the sophistication confound is likely substantial. Benchmark and scale-use correction narrow it; they do not remove it |
| **Vertical AP** (+ 2024 horizontal attitudinal) | within party plus **within person** across targets; target effects absorb how well liked a party is in general; the mismatched A-vs-B rating is the best-identified quantity in the design | the vote as collider (deniers vote for P partly because they dislike the others) plausibly **pulls ΔAP toward zero**; out-party sets differ by type; adjusting for distance gives a *controlled direct effect*, because distance is partly a consequence of attachment; PTV mixes liking with viability | no selection on the outcome through the vote; no path from dislike of others to attachment (negative partisanship) | selection by the vote; its plausible direction is attenuation. The mismatched group is itself selected on voting against its attachment |
| **Horizontal behavioral AP** | the partner's party is **randomized**, so $AP_t$ is a causal effect of the partner label for each type; the control splits favoritism from derogation; the same respondents rate the thermometer, so attitudinal vs. behavioral is within person | $\Delta AP$ is how a causal effect *varies by a non-randomized moderator*, so it is descriptive; few co-partners for deniers and few vote-only partners for mismatched respondents; the party label also carries inferred policy; one election year | the same ignorability of type | ΔAP inherits every confounding problem of type; only the effect of the partner label is experimental |

## Estimands

The quantities of interest are contrasts of marginal means, not coefficient arithmetic:

- $AP_t = E(Y \mid Co, t) - E(Y \mid Out, t)$
- $\Delta AP = AP_{\text{explicit}} - AP_{\text{denier}}$, and the analogous contrasts for the other types

- **g-computation** from the fitted model: set type and relation counterfactually, predict with all varying effects, and average with respondent weights over parties in common support (`ap_draws()` in notebook 3.2).
- **Group-level quantities** (dispersion, bimodality, alignment) are computed on a type's predicted distribution mixed with **common party weights**. Otherwise "deniers are more dispersed" could only mean "deniers vote for more varied parties".
- The **same estimand at every model step**, so that the steps can be compared.
- **Cross-outcome comparisons** in SD units, reported as posterior probabilities. The attitudinal vs. behavioral comparison is made on eu25 only (same respondents).
- **Decomposition** over time and across countries, computed on the posterior draws: type mix vs. within-type change.

## Model building

The ladder below is a **guide, not a fixed sequence**. Steps are merged, reordered or added
as fits come in. At each step, track how the estimand moves, not only LOO. Stability across
steps is a result; the step that moves it is informative.

| Step | Layer added | What it contributes | What to compare |
|---|---|---|---|
| 1 | **Likelihood**, on one survey | a family that reproduces the outcome's shape and cell means | posterior predictive checks by cell |
| 2 | **Party within country** (plus respondent and target layers for repeated outcomes) | the within-party contrast, assuming one common gap. **The benchmark** | against raw within-party cell means |
| 3 | **Contrast varying by country** | comparative inference with partial pooling: the comparative figure | how much countries differ, relative to the prior |
| 4 | **Contrast varying by party** | heterogeneity across parties; the estimand uses the stated weights instead of implicit precision weights | a shift from step 2 means the gap varies with party composition |
| 5 | **Dual party membership** for mismatched respondents | separates attachment from vote in one model | against fits that code only one in-party |
| 6 | **Study and wording layer** (pooling sources) | one European scale across operationalizations | separate per-study fits as triangulation |
| 7 | **Time**: surveys within countries, type-specific smooth trends varying by country | dynamic inference (the over-time figure) and the decomposition | stability when single studies are dropped; trends vs. switching between studies |
| 8 | **Distributional layer** (dispersion by cell) | calibrated uncertainty by cell | predictive checks and calibration by cell |
| 9 | **Diagnostics and adjustments**: distance to the target (party vs. policy), the perception benchmark, type × party position, pre-treatment covariates | the party-vs.-policy tests; robustness of identification | adjusted vs. unadjusted; sensitivity to an unobserved confounder |

- **Time** enters as an ordered trend. Year intercepts would absorb the trend instead of estimating it, and time is not nested in party or country. Few elections per country make country-specific trends lean on the prior.
- **Alongside every step:** prior sensitivity (small groups' variance components lean on the prior), uncorrelated varying effects as a check, and fake-data recovery of known contrasts at the real cell sizes from step 4 on.
- **The games** use steps 1–5, 8 and 9 (one study, one time point).
- **Figures need not come from one model.** The comparative figure can come from a cross-section at step 4, the over-time figure from step 7. Only the decomposition needs both at once.
- The dynamics are not read causally. Age, period and cohort are not separated, but are kept in mind when interpreting.

## Design facts

- **Target and measurement mode are perfectly confounded** in the eu25 data. The thermometer
  is vertical-attitudinal and the games are horizontal-behavioral, so a contrast across the two is
  **attitudinal vs. behavioral**, never vertical vs. horizontal. The EES 2024 ratings of party
  supporters (horizontal-attitudinal) partly fill the gap, but descriptively only: different
  respondents and a different year.
- **Attachment is not randomly assigned** (see *Scope and limits*). Candidate controls come
  from the DAG and from the literature on the determinants of partisanship, and must be
  pre-treatment.

## Games specifics

- **Randomization is stratified by type.** Attached respondents were more likely to see a
  co-partisan partner; the round is random. Co vs. out is random within type and party, so
  $AP_t$ is identified. The cost is precision for deniers. The drawn relationship is recorded in
  every round (`der_cj_partisan_relationship_drawn`), so P(drawn co | type, anchor party) can be
  tabulated. Check whether it depends on anything outside the model, and how thin the
  vote-only cell of mismatched respondents is.
- **Control** = a co-national partner with no party shown. The conditions with an EU or a drawn
  nationality are not the control.
- **The EU attribute is an identity cue** ("sees themselves as an EU citizen"), not a policy
  position. It offers no randomized party-vs.-policy test.
- **Beta-binomial is ruled out**: it is unimodal or U-shaped, misses the spikes at 0, 5 and 10,
  and recovers the cell means poorly. Current line: a mean model with cell-specific dispersion
  (the Gaussian on cell means, the main estimate in notebooks 3.3 and 3.5), with an ordinal
  model as a check of the shape.

## Open decisions

- The **centre for extremity**: scale midpoint, country mean or median. Report alternatives.
- The **sorting measure**: a flexible association (e.g. variance in EU explained by a smooth
  function of LR), within country, pooling magnitudes, never raw correlations.
- A **coverage table**, item × study × round × country (LR and EU self-placement, LR and EU
  placements, PTV and like/dislike, attachment wording): the first deliverable, checked
  against the codebooks.
- The **likelihood per outcome**, chosen by predictive checks.
- The **identity vs. policy predictions** for the two sorting outcomes (`tbl-predictions` in
  `index.qmd`). Write them down before fitting.

## Prior framing (superseded)

The old argument was deleted in commit `4651e2c` (backup) and the cleanup that followed.
Retrieve specific pieces when they are wanted. Do not restore them wholesale.

```bash
git show 4651e2c:notes.qmd
git show 4651e2c:DECISIONS.md
git show 4651e2c:PAPER-DESIGN.md
git show 4651e2c --stat      # everything in the backup
```
