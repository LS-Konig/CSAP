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
      technical
    )
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
