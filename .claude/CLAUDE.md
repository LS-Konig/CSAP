# CLAUDE.md

Last modified: 2026-09-29

This is the entry point. It holds only what every task needs. The detail lives in the
context files indexed below, and you should open those only when a task needs them.

## Project

A comparative study of **partisanship and affective polarization (AP) across 25 European
democracies**. It uses the thermometer ratings and the conjoint trust/dictator games from Hahm,
Hilpert & König (2024), together with EES, CSES, ESS and Eurobarometer for the over-time side. The authors are Tristan
Muno and Thomas König, University of Mannheim. The paper is targeted at APSR or another general-interest journal.

## Status (as of 2026-09-29)

**The framing is being restarted.** On 2026-09-08 the repo was stripped back to a manuscript
stub, the deck, the data and a notebook template, so that a new argument can be built without
an older one arguing back. The notes at the top of `index.qmd` are the current direction. They are a
sketch, not a specification (summarised in `design.md`). Do not treat them, or anything
reconstructed from git history, as settled.

Built so far: the Party Facts coding of the ESS, CSES and EES party items, the attachment-vote
match rule, and the partisan composition trees. There are no analysis models yet. The near-term aim in the
notes is first results and a presentation by 7 October 2026.

## No claim is settled

Nothing in the repo currently states a claim. Do not write toward one until Tristan fixes it.
If a task presupposes a finding or a direction of effect that is not written down in these
files, ask. New analyses are exploratory by default. Report estimates with their uncertainty,
not verdicts.

## Working rules

- **Ask before reading reading material**: anything under `literature/`, and the codebook and
  methodology PDFs that ship with the raw data. Name the file and say why it's needed. The
  two designated variable references are exempt: the eu25games upstream codebook HTML and the ESS codebook
  HTML (see `data.md`). The rule also does not apply to the project's own code, data or config.
- **`.claude/context/` is Tristan's own folder** for material he collects for specific
  prompts: the dissertation proposal (`proposal.qmd`) and his prompt scratchpad
  (`prompt-canvas.qmd`). Read a file there only when he points to it. Do not edit it.

## Stack and commands

- **R 4.6.1** at `C:\Program Files\R\R-4.6.1\bin\Rscript.exe`, **not on `PATH`**. Packages
  come from the user library (`C:/Users/Tris/AppData/Local/R/win-library/4.6`). There are two traps:
  - `C:\Program Files\R\R-4.5.2` is a broken partial install (DLLs only, no `Rscript.exe`).
  - The 421-package `win-library/4.5` **cannot be loaded by 4.6**: compiled packages fail at `rlang.dll`. Install into 4.6 instead.
- There is deliberately **no renv** until the directory is frozen for replication, when `renv::init()` will bring it back. Until then, do not add `.Rprofile`, `renv/` or `renv.lock`.
- **Quarto 1.9.36**, **brms** (Bayesian multilevel), **ggplot2 / ggpubr / ggrepel / ggdag**, **Git LFS** for files >100 MB.

Because R is not on `PATH`, bare `quarto render` fails with "Unable to locate an installed
version of R". Point Quarto at R first. `QUARTO_R` takes the **bin directory**, not the
executable, and it must be a real shell variable, because a Quarto `_environment` file ignores it:

```powershell
$env:PATH = "C:\Program Files\R\R-4.6.1\bin;" + $env:PATH
$env:QUARTO_R = "C:\Program Files\R\R-4.6.1\bin"

quarto render index.qmd         # manuscript
quarto render presentation.qmd  # RevealJS deck
```

## Context index

| File | Read when… | Last modified |
|------|-----------|---------------|
| `.claude/design.md` | the task concerns the argument, the explicit vs. vote-anchored contrast, outcomes, estimands, models, or `index.qmd`'s notes | 2026-09-29 |
| `.claude/data.md` | editing any `code/` notebook, joining sources, matching parties, or reasoning about coverage, item codings or variable names | 2026-09-29 |
| `.claude/workflow.md` | adding files or notebooks, rendering, committing data, or working with the literature submodule (repo layout, pipeline order, Quarto quirks, LFS) | 2026-09-29 |

## Maintaining this system

- Every context file starts with `last_modified: YYYY-MM-DD` frontmatter. On any content edit, update it
  and the index row above.
- Each fact lives in one file. CLAUDE.md points to it and doesn't repeat it.
- Split a file when it passes ~300 lines, or when a topic becomes its own work stream (e.g.
  `theory.md` once the argument is fixed, or `models.md` once estimation starts).
- Claude proposes new files or splits, and Tristan approves them. New files go directly in `.claude/`
  and are added to the index above.
