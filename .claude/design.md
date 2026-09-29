---
last_modified: 2026-09-29
scope: current direction of the argument, core contrast, outcomes, estimands, open questions
---

# Design

Read this before touching `index.qmd`'s argument, planning an analysis, or choosing an
estimand. Data mechanics live in `data.md`.

**Everything here is a sketch taken from Tristan's notes at the top of `index.qmd`. None of it
is settled.** When the notes change, this file follows them, not the other way round.

## Question (working)

What does partisanship *itself* (net of everything else) contribute to the several facets of
polarization in Europe? This ties to the US debate between party-over-policy and
policy-over-party: is the group attachment what people dislike, or the policy position the
attachment signals?

## Core contrast

**Explicit partisans** report an attachment to a party. **Vote-anchored partisans** deny any
attachment but report a vote. The contrast is estimated *within party and country*. It comes
from the attachment × vote tree:

- explicit
- attached but voted for another party
- vote-anchored
- non-partisan

"Same party" is decided by `pf_match()` (see `data.md`). The notes name three complications:
leaner probes, multiple PID, and wording that asks about attachment, closeness or identity,
which may draw different answers.

## Outcomes (four facets) and sources

| Facet | Measure (sketch) | Sources | Time |
|-------|------------------|---------|------|
| Ideological extremity | Respondent-level position on LR, and on EU integration where asked. The distance measure is open | EES, CSES, ESS | Over time |
| Perceived polarization | Per-respondent SD of their own party placements | EES, CSES | Over time |
| Vertical AP (toward parties, attitudinal) | Thermometer, like-dislike, PTV. API primary, other measures as robustness | eu25, CSES, EES | Over time |
| Horizontal AP (toward partisans, behavioral) | Dictator/trust token allocation | eu25 only | 2019 cross-section |

**Vertical** means directed at parties, leaders and elites. **Horizontal** means directed at
partisans, i.e. ordinary people (Tristan, 2026-09-29).

ESS carries PID only, so it enters through the composition side, not an AP outcome.

## Estimands

The quantities of interest are contrasts of marginal means, not coefficient arithmetic:

- $AP = E(Y \mid Co) - E(Y \mid Out)$
- $\Delta AP = E(AP \mid \text{explicit}) - E(AP \mid \text{vote-anchored})$

Both come from hierarchical models with party, country and time nested. The hierarchy keeps
the contrast within parties. Where one type is rare (e.g. Denmark), the posterior shows it
through wider uncertainty. Comparing attitudinal with behavioral $\Delta AP$ requires
standardization, and the comparison is reported as a posterior probability statement.

## Design facts that constrain every analysis

- **Target and measurement mode are perfectly confounded** in the Hahm et al. data.
  Thermometers are vertical-attitudinal and the conjoint is horizontal-behavioral, so the
  diagonal is unobserved. A contrast across the two is therefore **attitudinal vs.
  behavioral**, never vertical vs. horizontal.
- **Attachment is not randomly assigned.** Candidate controls come from the DAG sketch
  (Type ← U → polarization, V → Type) and from the literature on the determinants of
  partisanship. Under what assumptions the contrast reads as causal is an open section in
  the notes.

## Modelling notes (token allocation)

- Start with a beta-binomial on the 0–10 allocation.
- Run posterior predictive checks on the zero mass and on the 1–10 distribution, overall and
  by condition.
- Use a hurdle model only if the zeros are systematically underpredicted while the positive
  allocations fit. A hurdle implies a different generative story.
- Keep a latent continuous allocation model as a sensitivity alternative.

## Candidate diagnostics (not adopted)

`index.qmd` sketches what the identity and policy accounts predict across the four outcomes
(`tbl-predictions`). It also sketches three tests:

- $\Delta$ with and without adjustment for policy distance
- perception bias against a benchmark (sample means, CHES, manifestos)
- horizontal vs. vertical

The details live there and are not repeated here.

## Open, or inconsistent in the notes

- The notes state a working expectation about how large the attachment gap is in the games
  vs. the thermometers. It is a hypothesis. Do not write toward it.

## Prior framing (superseded)

The old argument was deleted in commit `4651e2c` (backup) and the cleanup that followed.
Retrieve specific pieces when they are wanted. Do not restore them wholesale.

```bash
git show 4651e2c:notes.qmd
git show 4651e2c:DECISIONS.md
git show 4651e2c:PAPER-DESIGN.md
git show 4651e2c --stat      # everything in the backup
```
