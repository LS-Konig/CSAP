# Party Facts coding ------------------------------------------------------------
#
# Shared helpers for the Party Facts notebooks in code/01_preparation/
# (1.2 ESS, 1.3 CSES, 1.4 EES). They follow the eu25games release
# (eu25games2019/code/07_recode.qmd, chunks party-recode-map / -join /
# -validate): every party-bearing item <item> gets
#
#   ext_<item>_pf_name  Party Facts core name, "<original label> [og]" when the
#                       party is not in Party Facts, or one of pf_sentinels
#   ext_<item>_pf_id    Party Facts id; NA for [og] and sentinels
#
# The second half holds the rule that compares two party answers (attachment
# and vote) with the alias, alliance and lineage tables of notebook 1.9; see
# "Matching two party answers" below.

library(tidyverse)
library(here)

pf_dir <- here("data", "01_raw", "partyfacts")

# Non-party answers, as in the eu25games release
pf_sentinels <- c(
  "none",
  "dont-know",
  "refused",
  "other",
  "other-country",
  "independent",
  "did-not-vote",
  "blank-invalid",
  "not-eligible",
  "will-not-vote"
)

# ISO2 (ESS, eu25games) to ISO3 (Party Facts) for the 25 democracies
pf_iso3 <- c(
  AT = "AUT", BE = "BEL", BG = "BGR", CZ = "CZE", DE = "DEU",
  DK = "DNK", EE = "EST", ES = "ESP", FI = "FIN", FR = "FRA",
  GB = "GBR", GR = "GRC", HR = "HRV", HU = "HUN", IE = "IRL",
  IT = "ITA", LT = "LTU", LV = "LVA", NL = "NLD", PL = "POL",
  PT = "PRT", RO = "ROU", SE = "SWE", SI = "SVN", SK = "SVK"
)

# Year each ESS round began, the survey year of the ESS in pf_apply_eras(),
# pf_check_period() and pf_match()
ess_round_year <- c(2002L, 2004L, 2006L, 2008L, 2010L, 2012L, 2014L, 2016L, 2018L, 2020L, 2023L)

# Match key: fold non-breaking spaces, collapse whitespace, lower case
norm_key <- function(x) {
  x |>
    str_replace_all(" ", " ") |>
    str_squish() |>
    str_to_lower()
}

# Looser key for comparing party names: accents and punctuation removed
normalise_party <- function(x) {
  x |>
    stringi::stri_trans_general("Latin-ASCII") |>
    str_to_lower() |>
    str_replace_all("[^a-z0-9]+", " ") |>
    str_squish()
}

# Does `a` contain `b` as whole words? (both normalised)
contains_words <- function(a, b) {
  str_detect(paste0(" ", a, " "), fixed(paste0(" ", b, " ")))
}

# Party Facts core parties. Technical pseudo-parties ("other", "independent",
# "unknown", ...) are kept but flagged, since they become sentinels.
pf_core <- function() {
  read_csv(
    file.path(pf_dir, "partyfacts-core-parties.csv"),
    col_types = cols(.default = col_character()),
    na = ""
  ) |>
    transmute(
      country,
      pf_id = as.integer(partyfacts_id),
      pf_name = name,
      pf_short = name_short,
      pf_english = name_english,
      technical,
      year_last = as.integer(year_last)
    )
}

# Parties that ended before 1950 cannot be answers in surveys from 1996 on.
# Party Facts links some survey codes to them anyway (the CSES and several other
# datasets point Spain's Partido Popular to the Partido Progresista of 1834-74,
# 5750, whose short name is also "PP"), so automatic links and name matches skip
# them; the hand maps can still use any id.
pf_historic <- function(core = pf_core(), before = 1950L) {
  core$pf_id[!is.na(core$year_last) & core$year_last < before]
}

# Parties Party Facts splits at a rename or refoundation while a survey code or
# label stays the same (the CSES IMD codes follow a party's lineage across
# studies, and some labels outlive the party they first named): in survey years
# `from`-`to`, `old_id` becomes `new_id`.
pf_eras <- tribble(
  ~old_id, ~from, ~to, ~new_id,
  1545L, -Inf, 2006, 86L, # Die Linke; before 2007 the PDS / Linkspartei.PDS
  496L, -Inf, 2006, 213L, # MoDem; before 2007 the UDF
  5650L, -Inf, 2009, 1108L, # EELV; before 2010 Les Verts
  604L, -Inf, 2000, 622L, # CD&V; before 2001 the CVP
  553L, 2005, Inf, 1968L, # Vlaams Blok; from November 2004 Vlaams Belang
  1034L, 2002, Inf, 120L, # PSDR merged into the PSD in 2001; the CSES ROU_2014 attachment item still uses its code for the PSD
  1626L, 2013, Inf, 8058L # Forza Italia; refounded in 2013
)

# Apply pf_eras to one name/id column pair, given each row's survey year
pf_apply_eras <- function(df, year, id = "pf_id", name = "pf_name", core = pf_core()) {
  for (i in seq_len(nrow(pf_eras))) {
    e <- pf_eras[i, ]
    hit <- which(df[[id]] %in% e$old_id & df[[year]] >= e$from & df[[year]] <= e$to)
    df[[id]][hit] <- e$new_id
    df[[name]][hit] <- core$pf_name[core$pf_id == e$new_id]
  }
  df
}

# Party Facts parties that did not exist in the survey year: founded more than a
# year later, or gone from Party Facts more than 12 years earlier (`year_last`
# is often a small party's last year in parliament, not its end). A new hit
# stops the notebook; `accepted` holds ids reviewed and kept, with reasons in
# the notebook.
pf_check_period <- function(df, year, id = "pf_id", name = "pf_name", accepted = integer()) {
  hits <- df |>
    filter(!is.na(.data[[id]])) |>
    count(year = .data[[year]], pf_id = .data[[id]], pf_name = .data[[name]]) |>
    left_join(
      read_csv(
        file.path(pf_dir, "partyfacts-core-parties.csv"),
        col_types = cols(.default = col_character())
      ) |>
        transmute(pf_id = as.integer(partyfacts_id), year_first = as.integer(year_first), year_last = as.integer(year_last)),
      by = "pf_id"
    ) |>
    filter(
      (!is.na(year_last) & year_last < year - 12) |
        (!is.na(year_first) & year_first > year + 1)
    ) |>
    mutate(accepted = pf_id %in% accepted)
  new <- filter(hits, !accepted)
  if (nrow(new) > 0) {
    print(new, n = Inf)
    stop("pf_check_period: Party Facts party outside its years; hand-code it or add it to `accepted`")
  }
  hits
}

# Links from one external dataset to Party Facts. Links to technical ids
# ("1 percent", "other", "independent", ...) carry no party: they keep the
# `technical` flag with pf_name / pf_id NA, and the label decides whether the
# answer is a sentinel or a small party coded "<label> [og]".
pf_links <- function(key, core = pf_core()) {
  read_csv(
    file.path(pf_dir, "partyfacts-external-parties.csv"),
    col_types = cols(.default = col_character()),
    na = ""
  ) |>
    filter(dataset_key == key, !is.na(partyfacts_id)) |>
    transmute(
      country,
      dataset_party_id,
      link_short = name_short,
      link_name = name,
      link_english = name_english,
      pf_id = as.integer(partyfacts_id)
    ) |>
    left_join(
      select(core, pf_id, pf_name, pf_short, pf_english, technical),
      by = "pf_id"
    ) |>
    mutate(
      pf_name = if_else(is.na(technical), pf_name, NA_character_),
      pf_id = if_else(is.na(technical), pf_id, NA_integer_)
    )
}

# Checks on a finished map. `keys` are the columns that must identify a row.
pf_check <- function(map, keys, core = pf_core()) {
  dup <- map |>
    count(across(all_of(keys))) |>
    filter(n > 1)
  if (nrow(dup) > 0) {
    print(dup)
    stop("pf_check: key not unique")
  }

  real <- core |>
    filter(is.na(technical)) |>
    select(pf_id, core_name = pf_name)
  bad_id <- map |>
    filter(!is.na(pf_id)) |>
    left_join(real, by = "pf_id") |>
    filter(is.na(core_name) | core_name != pf_name)
  if (nrow(bad_id) > 0) {
    print(bad_id)
    stop("pf_check: pf_id not in core, or pf_name differs from the core name")
  }

  bad_na <- map |>
    filter(
      (pf_name %in% pf_sentinels | str_ends(pf_name, " \\[og\\]")) &
        !is.na(pf_id)
    )
  if (nrow(bad_na) > 0) {
    print(bad_na)
    stop("pf_check: [og] or sentinel row carries a pf_id")
  }

  invisible(map)
}

# Matching two party answers ----------------------------------------------------
#
# Attachment and vote (or any two party answers of one respondent) are compared
# by their Party Facts names (ext_*_pf_name), with three tables built in notebook
# 1.9 (data/02_processed/). Two answers are the *same party* by one of four
# routes, checked in this order:
#
#   identical  the same name;
#   alias      a label from the eu25games release that names a party coded
#              under another name, e.g. an "[og]" EP-list label of the PvdA
#              (pf_aliases.csv: cntry, alias, name);
#   alliance   a party and an electoral alliance, joint list or party union
#              that contains it, in either direction (pf_alliances.csv: cntry,
#              alliance_name, member_name, member_id);
#   lineage    a party and the party it continued in: a rename, a refoundation
#              or a merger into it, in either direction, in surveys from the
#              `year` of the succession on (before it the two were separate
#              parties and a PDL supporter voting PNL in 2012 switched)
#              (pf_lineage.csv: cntry, predecessor, predecessor_id, successor,
#              successor_id, year).
#
# Everything else with two party answers is *different*: two members of one
# alliance (CDU and CSU), two predecessors of one successor (FI and AN, both
# merged into the PdL), a breakaway and its parent (Smer and Hlas). The tables
# are looked up pair by pair, never chained: AN -> PdL and PdL -> FI (2013) do
# not make AN and FI (2013) the same party. Names are Party Facts core names or
# "<label> [og]", exactly as in the ext_*_pf_name variables.

pf_alliances <- function() {
  read_csv(
    here("data", "02_processed", "pf_alliances.csv"),
    col_types = cols(member_id = col_integer(), .default = col_character())
  )
}

pf_lineage <- function() {
  read_csv(
    here("data", "02_processed", "pf_lineage.csv"),
    col_types = cols(predecessor_id = col_integer(), successor_id = col_integer(), year = col_integer(), .default = col_character())
  )
}

pf_aliases <- function() {
  read_csv(
    here("data", "02_processed", "pf_aliases.csv"),
    col_types = cols(.default = col_character())
  )
}

# All three tables, as pf_match() takes them
pf_rules <- function() {
  list(aliases = pf_aliases(), alliances = pf_alliances(), lineage = pf_lineage())
}

# Is the pair (a, b) or (b, a) in the table's pairs (x, y)?
pf_pair_in <- function(cntry, a, b, tcntry, x, y) {
  links <- paste(tcntry, x, y, sep = "\r")
  paste(cntry, a, b, sep = "\r") %in% links | paste(cntry, b, a, sep = "\r") %in% links
}

# Replace aliases by the name they stand for
pf_resolve <- function(cntry, x, aliases) {
  key <- match(paste(cntry, x, sep = "\r"), paste(aliases$cntry, aliases$alias, sep = "\r"))
  if_else(is.na(key), x, aliases$name[key])
}

# Year from which the pair (a, b) or (b, a) counts as lineage; NA if not listed
pf_lineage_year <- function(cntry, a, b, lineage) {
  keys <- paste(lineage$cntry, lineage$predecessor, lineage$successor, sep = "\r")
  y1 <- lineage$year[match(paste(cntry, a, b, sep = "\r"), keys)]
  y2 <- lineage$year[match(paste(cntry, b, a, sep = "\r"), keys)]
  coalesce(y1, y2)
}

# How two answers are the same party: "identical", "alias", "alliance",
# "lineage"; NA when they are not (different, or unmatchable). `year` is the
# survey year, which lineage needs.
pf_match_route <- function(cntry, a, b, rules, year) {
  ra <- pf_resolve(cntry, a, rules$aliases)
  rb <- pf_resolve(cntry, b, rules$aliases)
  al <- rules$alliances
  li <- rules$lineage
  case_when(
    is.na(a) | is.na(b) | a %in% pf_sentinels | b %in% pf_sentinels ~ NA_character_,
    a == b ~ "identical",
    ra == rb ~ "alias",
    pf_pair_in(cntry, ra, rb, al$cntry, al$alliance_name, al$member_name) ~ "alliance",
    coalesce(year >= pf_lineage_year(cntry, ra, rb, li), FALSE) ~ "lineage",
    .default = NA_character_
  )
}

# "same" (by any route of pf_match_route()), "different", or "unmatchable"
# when either side is missing or a non-party answer (pf_sentinels)
pf_match <- function(cntry, a, b, rules, year) {
  case_when(
    is.na(a) | is.na(b) | a %in% pf_sentinels | b %in% pf_sentinels ~ "unmatchable",
    !is.na(pf_match_route(cntry, a, b, rules, year)) ~ "same",
    .default = "different"
  )
}

# Checks on the tables ----------------------------------------------------------

# Ids must be real Party Facts parties of the row's country, under their core
# name (a same-named party of another country passes a name check only)
pf_check_ids <- function(df, name, id, what, core = pf_core()) {
  real <- core |>
    filter(is.na(technical)) |>
    select(pf_id, core_name = pf_name, core_country = country)
  bad <- df |>
    filter(!is.na(.data[[id]])) |>
    left_join(real, by = setNames("pf_id", id)) |>
    filter(
      is.na(core_name) | core_name != .data[[name]] |
        core_country != pf_iso3[cntry]
    )
  if (nrow(bad) > 0) {
    print(bad)
    stop(what, ": id not in core, from another country, or name differs from the core name")
  }
}

pf_check_alliances <- function(alliances, core = pf_core()) {
  dup <- alliances |>
    count(cntry, alliance_name, member_name) |>
    filter(n > 1)
  if (nrow(dup) > 0) {
    print(dup)
    stop("pf_check_alliances: duplicate alliance-member rows")
  }
  self <- filter(alliances, alliance_name == member_name)
  if (nrow(self) > 0) {
    print(self)
    stop("pf_check_alliances: an alliance lists itself")
  }
  pf_check_ids(alliances, "member_name", "member_id", "pf_check_alliances", core)
  invisible(alliances)
}

pf_check_lineage <- function(lineage, alliances, core = pf_core()) {
  dup <- lineage |>
    count(cntry, predecessor, successor) |>
    filter(n > 1)
  if (nrow(dup) > 0) {
    print(dup)
    stop("pf_check_lineage: duplicate rows")
  }
  self <- filter(lineage, predecessor == successor)
  if (nrow(self) > 0) {
    print(self)
    stop("pf_check_lineage: a party succeeds itself")
  }
  both <- lineage |>
    filter(pf_pair_in(cntry, predecessor, successor, alliances$cntry, alliances$alliance_name, alliances$member_name))
  if (nrow(both) > 0) {
    print(both)
    stop("pf_check_lineage: pair is also in the alliance table")
  }
  pf_check_ids(lineage, "predecessor", "predecessor_id", "pf_check_lineage", core)
  pf_check_ids(lineage, "successor", "successor_id", "pf_check_lineage", core)
  invisible(lineage)
}

# An alias is a label, not a Party Facts name, listed once
pf_check_aliases <- function(aliases, core = pf_core()) {
  core_names <- paste(core$country, core$pf_name)
  bad <- aliases |>
    filter(
      paste(pf_iso3[cntry], alias) %in% core_names | alias == name |
        duplicated(paste(cntry, alias))
    )
  if (nrow(bad) > 0) {
    print(bad)
    stop("pf_check_aliases: an alias must not be a Party Facts name, must differ from its name, and is listed once")
  }
  invisible(aliases)
}
