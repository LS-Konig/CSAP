# TRI-POL — data structure and modelling notes

Context file for `data/01_raw/external/tripol/`. Written 2026-08-06.

Facts marked **✔** were checked directly against the XLSX files in session (script pattern in
§8). Everything else comes from the survey protocols and questionnaires shipped alongside the
data and should be re-verified before it load-bears.

This file exists mainly for §6 — whether the project's Bayesian framework transfers to TRIPOL
without re-explaining it to readers. Short answer: the estimand and linear predictor transfer
unchanged; the *nesting* of the trust game does not, and there is one design problem with how
the counterpart party is chosen.

Keep in sync with the TRI-POL row in `data/01_raw/external-data.md`.

---

## 1. Provenance

- **Project:** "The triangle of polarization, political trust and political communication"
  (TRI-POL). PI **Mariano Torcal**, RECSM–Universitat Pompeu Fabra.
- **Data paper:** Torcal, Carty, Comellas, Bosch, Thomson & Serani (2023), *Data in Brief*.
  <https://www.sciencedirect.com/science/article/pii/S2352340923003384>
- **Repository:** <https://osf.io/3t7jz/> · project site <https://www.upf.edu/web/tri-pol>
- **Already cited in the project:** `@Comellas2023ideological` (bloc AP, 5 countries) is a
  TRI-POL paper and appears in `code/literature-overview.qmd:102`.
- Fieldwork by Netquest **online opt-in panels**, quota-sampled, 18+. Not probability samples.

## 2. What is on disk

```
tripol/
├── Survey panel-data/               5 × .XLSX  (the only data files)
├── Survey panel-DATA PROTOCOL/      5 × PDF, 130–145 pp  (codebooks: variable lists + value labels)
├── Survey panel-Questionnaires/     15 × PDF  (5 countries × 3 waves, English wording)
├── Survey panel-Polarization indices/  1 × PDF, 7 pp  (Comellas & Torcal index formulas)
└── Wiki images/                     logos, irrelevant
```

**✔ The XLSX are wide — one row per respondent**, single sheet named `Data`, wave suffixes
`_1` / `_2` / `_3` on the variable names.

| File | ✔ Rows | ✔ Cols | Suffix used *inside* the file |
|---|---|---|---|
| `TRI_POL_AR.XLSX` | 1,316 | 1,355 | `AR` |
| `TRI_POL_CL.XLSX` | 1,337 | 1,543 | **`CH`** |
| `TRI_POL_ES.XLSX` | 1,289 | 1,480 | `ES` |
| `TRI_POL_IT.XLSX` | 1,231 | 1,260 | `IT` |
| `TRI_POL_PT.XLSX` | 1,028 | 1,277 | **`PO`** |

**Not present, despite being advertised or expected:**

- No `.dta` / `.sav` / `.csv` / `.rds` — the protocol's §2 describes Stata 17 files that are
  not in this download. XLSX only.
- **No passive-meter trace files.** The `met1a`–`met6_3_mm` variables are *self-reported*
  questions about the metering software, not browsing data. The meter release is separate.
- No README, no Party Facts / ParlGov crosswalk.
- Codebook PDFs are untracked by git (`.gitignore` has a blanket `*.pdf`).

## 3. Panel structure

**✔ Three strictly nested waves** (everyone in W2 did W1; everyone in W3 did W2),
Sept 2021 – Apr 2022. Person ID = **`g6`** (`CodPanelista`, hashed string).
Participation flags **`wave_1` / `wave_2` / `wave_3`**.

| | ✔ W1 | ✔ W2 | ✔ W3 |
|---|---|---|---|
| AR | 1,316 | 1,114 | 979 |
| CL | 1,337 | 1,084 | 921 |
| ES | 1,289 | 1,162 | 1,080 |
| IT | 1,231 | 1,116 | 999 |
| PT | 1,028 | 905 | 823 |
| **Total** | **6,201** | **5,381** | **4,802** |

European subset relevant to this paper: **ES + IT + PT = 3,548 / 3,183 / 2,902**.
AR and CL sit outside the paper's frame (possible extra-European aside only).

**No survey weights exist in the files.** The "weights" in the protocol refer to party-size
weights *inside* the shipped polarization indices, not to sampling weights. Post-stratify
yourself if needed — demographics are `s1_` (gender), `s2_` (age), `g10` (region), `g11`/`g12`
(education), `g13` (habitat).

Missing-value scheme: Stata extended missings `.a` = DK, `.b` = DA, `.c` = NA,
`.y` = NA control group, `.z` = not in wave. **✔ These leak into the XLSX as literal strings**
(`".z"`, `".c"` appear as values), so every numeric column needs explicit coercion.

## 4. Partisanship items

### Attachment (the selection filter — the paper's central variable)

| Variable | Content |
|---|---|
| `p33_1/_2/_3` | *"Regardless of the party or candidate you intend to vote for, do you consider yourself close to any political party?"* **1 = Yes, 2 = No.** All three waves. A branching gate. |
| `p33a_<CC>_1/_2/_3` | "Which one?" — closest party, numeric code with country-specific labels |
| `p33b_1/_2/_3` | Closeness level: **0 = not at all, 1 = not very, 2 = somewhat, 3 = very** |
| `p33c_` … `p33j_` | **8-item 0–10 partisan social-identity battery** (Bankert/Huddy style): self-identification with the party, sensitivity to criticism, identification with supporters, "my party", etc. All three waves. |

**✔ Attachment shares, wave 1:** AR 45.9%, CL 31.7%, **ES 50.9%, IT 39.3%, PT 50.6%**.
Comparable to the band in the main study, so the cross-source comparison is not strained.

The `p33b_` + `p33c_`–`p33j_` combination is **better than anything in the main dataset** for
section 2: it lets the binary *selection filter* vs. graded *identity measure* distinction be
shown empirically on the same respondents, which is the strongest available answer to the
Bankert/Huddy expressive-partisanship counter.

### Vote

| Variable | Content |
|---|---|
| `p37_<CC>_1/_2/_3` | Vote **intention** ("if the next general election were tomorrow"), asked of everyone; includes blank/would-not-vote/no-right/DK/refuse codes |
| `p36a_`–`p36p_<CC>_` | **Propensity to vote 0–10 for each named party.** ✔ 21–48 items depending on country |
| `p35_` | Probability of voting at all, 0–10 (W1, W3) |
| `p40_<CC>_2/_3` | Explicitly nominated *disliked* party (W2/W3) |

⚠️ **There is no vote-recall item.** The vote anchor must be built from intention (`p37_`) or
from top PTV (`p36_`). This is a genuine difference from `der_vote_cat` in the main pipeline,
which coalesces intended → hypothetical → past. Since intention is first in that coalesce
order anyway, the practical gap is small — but it must be stated, not glossed.

## 5. Outcome measures

### Attitudinal — feeling thermometers

- **`p16a_`–`p16o_<CC>_1/_2/_3`** — feelings toward **party voters** (✔ 30–49 items per
  country), including left-wing / centrist / right-wing voters as generic targets.
- **`p17a_`–`p17n_<CC>_1/_2/_3`** — feelings toward **party leaders** (✔ 21–41 per country).
- Presented as a 0–100 slider but **discretized to 9 points: 0, 15, 30, 40, 50, 60, 70, 85,
  100**. 888 = DK. Rescale to 0–10 exactly as the main pipeline does, or treat as ordinal.
- `p17a1_`–`p17n6_` — discrete emotion batteries (hopeful/proud/angry/fearful/indifferent/
  disgusted) per leader.
- `p13a_`–`p13n_<CC>_` perceived party L–R; `p12_` own L–R self-placement.

### Shipped polarization indices

Pre-computed and present in all five files: `WAPDV_`, `WAPSV_`, `InLikeV_`, `OutDislikeV_`,
`MaxV_`, `maxVoters_` (in-group party as a string), per-party `APpp_`, `APpsoe_`, `APvox_`…;
leader versions `WAPDL_`, `WAPSL_`, `InLikeL_`, `OutDislikeL_`, `maxLeader_`; ideological
`WPIP_`, `IE_`; bloc variants `*B_` / `*Bip_` (CL only). Wagner-2020 family, formulas in the
polarization-indices PDF.

⚠️ `maxVoters_` is **most-liked-party** coding — the coding section 8 flags as selecting on
the outcome. Useful as one of the four codings; never as the default.

### Behavioural — the trust game (wave 2 only)

Berg-style, incentivized, real payout: respondent receives 5 points, sends 0–5, the amount is
tripled, the counterpart may return some. Framed as an interaction with other real panelists
in the same country. Comprehension checks `esmP8_2`–`esmP10_2` gate entry; `esmP0c_2` is
explicit consent.

| Variable | Counterpart | ✔ n (AR/CL/ES/IT/PT) |
|---|---|---|
| `esmP11_2` | **Anonymous**, no partisan cue. **Pre-treatment.** | 1,030 / 944 / 969 / 994 / 781 |
| `esmP19_2` | **In-party** supporter (piped party name) | 489 / 442 / 468 / 465 / 371 |
| `esmP20_2` | **Out-party** supporter (piped party name) | 487 / 439 / 468 / 465 / 370 |
| `GAME_SHOW_2` | Randomizer: 1 → in-party arm, 2 → out-party arm | |
| `MOST_LIKED_SHOW_esmP19_2`, `LEAST_LIKED_SHOW_esmP19_2` | string: which party was actually shown | |
| `esmP12_2` | 5-arm framing treatment: Control / Polarizing / Unifying / Populist / Non-populist | |
| `esmP21_2`–`esmP24_2`, `esmP23_2_1`…`_6` | Player-2 role, **strategy-method** return schedule | |

**✔ Totals:** in-party 2,235, out-party 2,229 (European subset ES+IT+PT: 1,304 / 1,303).

⚠️ **✔ The game is wave 2 only.** `esmP19_3` / `esmP20_3` / `GAME_SHOW_3` do not exist.
`MOST_LIKED_SHOW_esmP19_3` is a stray piping variable with no game attached.

### Behavioural-adjacent — social distance (wave 3), **within-person**

`p42a/b/c_3` (marry), `p43a/b/c_3` (work with), `p44a/b/c_3` (party they now support), each
0–10 "displeased → pleased", each rated against **three targets**: `a` = most-liked party
supporter, `b` = least-liked, `c` = a random moderate party. Targets recorded in
`MOST_LIKED_SHOW_p42p43p44_a_3`, `LEAST_LIKED_SHOW_p42p43p44_b_3`,
`MODERATE_SHOW_p42p43p44_c_3`.

✔ ES `p42`: in-party modal 5 with a long right tail (161 at 10); out-party modal **0**
(n = 333). Large raw gap.

This is the only TRIPOL outcome that maps 1:1 onto `der_partisan_relationship`
{`Co`, `Out`, `None`} on the same 0–10 scale — see §6.

### Conjoint (wave 3)

**✔ 12 forced-choice tasks per respondent**, 2 profiles each, 11 randomized attributes
(`esmP12{a..k}_{task}_{A|B}_<CC>_3`): national/subnational identity, ideology, immigrant,
language (ES) or vaccination status (IT), same-sex vs. heterosexual partner, **party
supporter**, education, environmentalist, pet owner, religion, politicisation. Choice in
`esmP12_{task}_<CC>_3`. ✔ 252–276 conjoint columns per file.

### Wave 1 experiment

`esmp1a_1`, `esmP0a_1`–`esmP6_1` — a Twitter-following field experiment with meter
verification. Not relevant to this paper.

---

## 6. Does the project's Bayesian framework transfer? — the reason this file exists

The framework being asked about is the one recovered from git history (see §7): a single
linear predictor applied to both outcomes,

```
outcome = α + β₁·copartisan + β₂·type + β₃·(copartisan × type)
AP_t    = β₁ + t·β₃          β₃ is the key parameter
```

estimated in `brms` over the nesting *observation ⊂ respondent ⊂ anchor ⊂ country*, with
anchor- and country-varying slopes.

**The linear predictor, the estimand, and the posterior-simulation quantities transfer to all
four TRIPOL outcomes unchanged.** That is the part the manuscript does not have to
re-explain. What differs is nesting and likelihood, per outcome:

| TRIPOL outcome | Nesting | Likelihood | Transfer cost |
|---|---|---|---|
| Thermometers `p16*` / `p17*` | rating ⊂ respondent ⊂ anchor ⊂ country — **identical** | Gaussian on 0–10 after rescaling | **None.** Reuse verbatim. |
| Social distance `p42/43/44` | rating ⊂ respondent ⊂ anchor ⊂ country — **identical**, 3 targets/person | Gaussian on 0–10 | One sentence defining the three targets. Stated, not incentivized. |
| **Trust game** `esmP19_2`/`esmP20_2` | **respondent ⊂ anchor ⊂ country** — one level shallower | 0–5 integer; `binomial(5)` or `cumulative` | Three sentences — see below. |
| W3 conjoint | profile ⊂ task ⊂ respondent ⊂ country | Bernoulli/logit | Coefficients are AMCEs in log-odds; **the token-unit ROPE has no analog here.** |

### The trust game: what changes and why the estimand survives

**✔ The game is between-subjects in all five countries.** `GAME_SHOW_2` assigns each
respondent to the in-party *or* the out-party counterpart; the number answering both is
**0 / 0 / 0 / 0 / 0**. Consequences:

- The unit of observation is the **respondent**, not round-within-respondent.
- `copartisan` varies **between** respondents (randomized), not within.
- The respondent random intercept `u_i0` is **not identified** — one cued observation per
  person.

The estimand is unaffected. β₃ becomes a between-subjects 2×2 of target arm × attachment,
randomized on the target dimension. **✔ Cell sizes** (W1 attachment × arm):

| | in-party arm | out-party arm |
|---|---|---|
| attached (`p33_1` = 1) | 1,066 | 1,051 |
| not attached (= 2) | 1,167 | 1,177 |

European subset only (ES+IT+PT): 673 / 665 / 629 / 636. Ample for a **pooled** β₃; too thin
for a per-country β₃ᶜ, so country should enter as varying intercepts with tight priors (five
groups) rather than as varying slopes on the interaction.

**✔ `esmP11_2` is the substitute for the lost respondent random intercept.** Every single
cued player has it — 976/976, 881/881, 936/936, 930/930, 741/741, i.e. **100% in all five
countries**. It is a pre-treatment, person-level measure of baseline generosity toward an
anonymous counterpart: exactly the variance `u_i0` existed to absorb. Enter it as a covariate
(or model `cued − anon`) and most of what the respondent RE did is recovered.

⚠️ `esmP12_2`, the 5-arm framing treatment, is administered **between** the anonymous round
and the cued round. It must be controlled or interacted; the anonymous baseline is clean of
it, the cued decision is not.

⚠️ **✔ Likelihood.** 0–5 integer with heavy mass at both ends (ES out-party: 134 zeros, 102
fives) strains Gaussian harder than the main study's 0–10 tokens did. The
Gaussian-for-a-bounded-outcome justification recovered from `manuscript.qmd` @ `3635a37` does
not carry over unmodified.

### ⚠️ The design problem: the anchor is not held constant across partisan types

TRIPOL pipes the counterpart party from **attachment where available, top PTV otherwise**.
**✔ Confirmed empirically, not inferred:** in `TRI_POL_ES.XLSX` the piped party labels for
`p33_1 = 1` respondents come from the `p33a_` closeness list ("VOX", "Unidas Podemos (En Comú
Podem)") while `p33_1 = 2` respondents get labels from the PTV list ("Vox", "Podemos y otras
listas municipales afiliadas…") — two disjoint spelling sets, cleanly split by attachment.

This is exactly what section 4 of the paper is built to avoid: it varies the anchor **and**
the reporting, rather than holding the anchor constant. It is also most-liked-party coding,
which section 8 flags as mechanically inflationary.

**Mitigation:** re-anchor everyone on `p36_` PTV (asked of all respondents) and retain only
those whose piped party equals their top-PTV party. Automatic for non-identifiers; among
identifiers it drops the defector-like cases where attachment party ≠ top PTV. That restores
a common rule at the cost of a selected subsample, and it mirrors the main study's defector
handling. **This should be the primary specification, not a footnote** — the raw comparison
is not the same contrast as the main analysis.

### Verdict

TRIPOL supports the robustness check and the reader does not need a second framework — only a
short "structure of the TRIPOL replication" paragraph covering: (a) the game is
between-subjects so the model is one level shallower with `esmP11_2` in place of the
respondent RE, (b) a 0–5 bounded-count likelihood, (c) the PTV re-anchoring. The thermometer
leg needs no explanation whatsoever.

### Section 7 (panel leg): the gate is passed

CLAUDE.md gates the panel section on within-person movement in the attachment item.
**✔ Movement is substantial and consistent across all five countries** (`p33_` transitions):

| | W1→W2 stay-yes / yes→no / no→yes / stay-no | movers | W2→W3 movers |
|---|---|---|---|
| AR | 366 / 151 / 90 / 506 | 241 (21.7%) | 210 (21.4%) |
| CL | 230 / 110 / 95 / 646 | 205 (19.0%) | 165 (18.0%) |
| **ES** | 427 / 176 / 89 / 468 | **265 (22.8%)** | 221 (20.5%) |
| **IT** | 319 / 134 / 82 / 577 | 216 (19.4%) | 179 (18.0%) |
| **PT** | 334 / 129 / 70 / 371 | 199 (22.0%) | 181 (22.1%) |

~18–23% of respondents switch attachment status per wave, in both directions, everywhere.
**The gate is cleared.** TRIPOL is the only downloaded candidate carrying feeling
thermometers, an incentivized behavioural measure, *and* within-person attachment movement.
ES/IT/PT are the European subset. Recorded, **not committed** — CLAUDE.md still says exactly
one panel gets used, and the comparison against GLES / BES / LISS / POLAT / AUTNES is open.

---

## 7. Related: the recovered Bayesian specification

The framework §6 refers to was removed from `index.qmd` in the `5332c70` restructuring. It
survives in git history; retrieve with `git show <commit>:<file>`:

- **`3635a37:manuscript.qmd`** (L215–330) — **the most complete version.** Gaussian
  justification for a bounded outcome, priors `N(0,2)` fixed / `N(5,2)` intercept /
  `Half-t(3,0,1)` RE SDs / `Half-t(3,0,2)` residual, correlated unstructured 3×3 Σ_a and Σ_c,
  `@heisig2019you` on omitting the respondent slope. File no longer on disk.
- **`c854c4a:index.qmd`** (L713–815) — last full-text draft; three-stage strategy; the
  sentence that rescales thermometers 0–100 → 0–10 to match the token scale.
- **`eb7ace3:index.qmd`** (L68–218) — original 4-level spec, Study 1 = thermometer /
  Study 2 = tokens with the same μ.
- **`9685b69:index.qmd`** — adds `re_formula = NULL` marginalization and the cross-study
  comparison `P(β₁^thermo > β₁^tokens | data)`.
- **`66329d8:code/modelling/03.1_priorpredictive.qmd`** — prior predictive checks.
- On disk: `notes2.qmd` L62–86 (compact framework), L116–176 (moderator extensions),
  L352–354 (the ROPE rule); `notes.qmd` L431–484 has the only surviving brms grouping syntax
  (`1 + T | party_id`, `1 | respondent_id`, `1 | country_id`).

## 8. Gotchas

Each of these will cost an hour if hit cold.

1. **✔ Country suffixes inside the files disagree with the filenames:** `AR`, **`CH`**
   (Chile), `ES`, `IT`, **`PO`** (Portugal) — but the files are `TRI_POL_CL` and
   `TRI_POL_PT`. Generic harmonization code must map filename → suffix explicitly.
2. **✔ Stata extended missings leak in as literal strings** (`.a` `.b` `.c` `.y` `.z`).
   Read with `col_types = "text"` first, then coerce deliberately.
3. **✔ Party codes differ between items within the same country.** ES: Ciudadanos is 5 in
   `p33a_ES_` but 4 in `p37_ES_`. The crosswalk must be built by hand from §7 "Codes for
   Categorical Variables" of each protocol PDF (pp. ~73–138). There is no Party Facts ID.
4. **Party-name strings are mojibake** (`APcaÃ±o_1`, `APmuÃ±oz_1`, and "Compromis" vs
   "Compromís" as distinct values). Read as UTF-8 and repair before matching on names.
5. **✔ Piped-party label spelling reveals which source the piping used** — the tell for the
   type-dependent anchor problem in §6. Do not normalise those strings away before checking.
6. **✔ Thermometers are a 9-point discretized slider**, not continuous 0–100.
7. **Reading is slow** — ✔ a full ES read takes ~40 s. Pass an explicit column subset via
   `readxl::read_excel(..., sheet = "Data", col_types = ...)`.
8. Item coverage varies by country (✔ `p16*` ranges 30–49 items, `p36*` 21–48). Never assume
   a variable exists across all five files — guard with `%in% names(d)`.

### Minimal read pattern

```r
library(readxl)
base <- here::here("data/01_raw/external/tripol/Survey panel-data")
d <- read_excel(file.path(base, "TRI_POL_ES.XLSX"), sheet = "Data", col_types = "text")
# then coerce: strings ".a" ".b" ".c" ".y" ".z" -> NA, everything else as.numeric
```
