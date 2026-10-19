# Partisan composition trees ---------------------------------------------------
#
# Shared helpers for the composition notebooks in code/02_composition/.
# Every source is first harmonised to one row per respondent with these columns:
#
#   att        "yes" / "no" / "dk"                 reports a party attachment?
#   vote       "yes" / "no" / "not_fielded"        reports a party vote?
#   match      "same" / "different" / "unmatchable" / NA
#                                                  only where a vote is reported
#                                                  and a party is named (attached
#                                                  or leaner)
#
# and, optionally,
#
#   lean       "yes" / "no" / "dk" / "not_fielded" / NA
#                                                  leaner probe, only where
#                                                  att != "yes"; NA where the
#                                                  probe was not fielded
#   vote_first TRUE / FALSE                        vote asked before attachment?
#
# plus any grouping columns (country, period). The tree follows the question
# order: vote -> attachment -> probe -> match where the vote came first,
# attachment -> probe -> vote -> match otherwise. Where a group mixes orders,
# the order of most of its respondents is used. The helpers below turn that
# frame into node counts, Mermaid flowcharts, tabsets and leaf-share plots.

# The 25 democracies ------------------------------------------------------------

countries_25 <- c(
  "AT",
  "BE",
  "BG",
  "CZ",
  "DE",
  "DK",
  "EE",
  "ES",
  "FI",
  "FR",
  "GB",
  "GR",
  "HR",
  "HU",
  "IE",
  "IT",
  "LT",
  "LV",
  "NL",
  "PL",
  "PT",
  "RO",
  "SE",
  "SI",
  "SK"
)

# Node definitions --------------------------------------------------------------

# Short codes used inside node ids
tree_att_code <- c(yes = "yes", no = "no", dk = "dk")
tree_vote_code <- c(yes = "yes", no = "no", not_fielded = "nf")
tree_lean_code <- c(yes = "yes", no = "no", dk = "dk", not_fielded = "nf")
tree_match_code <- c(same = "same", different = "diff", unmatchable = "unm")

# One path step per node: id segment, box label, sibling rank
tree_steps <- tibble::tribble(
  ~step     , ~label                                      , ~rank ,
  "v_yes"   , "Vote reported"                             ,     1 ,
  "v_no"    , "No vote reported"                          ,     2 ,
  "v_nf"    , "Vote item not fielded"                     ,     3 ,
  "a_yes"   , "Attachment reported"                       ,     1 ,
  "a_no"    , "No attachment"                             ,     2 ,
  "a_dk"    , "Attachment DK / refused / missing"         ,     3 ,
  "l_yes"   , "Leaner"                                    ,     1 ,
  "l_no"    , "Not leaning"                               ,     2 ,
  "l_dk"    , "Probe DK / refused / missing"              ,     3 ,
  "l_nf"    , "Probe not fielded"                         ,     4 ,
  "m_same"  , "Same party"                                ,     1 ,
  "m_diff"  , "Different party"                           ,     2 ,
  "m_unm"   , "Party not matchable<br>(other / unlisted)" ,     3
)

# Grey boxes: DK and not fielded
tree_muted <- c("a_dk", "v_nf", "l_dk", "l_nf")

# Leaf categories for the share plots
leaf_levels <- c(
  "Attached: same party",
  "Attached: different party",
  "Attached: vote not matchable",
  "Attached: no vote",
  "Leaner: same party",
  "Leaner: different party",
  "Leaner: vote not matchable",
  "Leaner: no vote",
  "No attachment: vote",
  "No attachment: no vote",
  "Attachment DK / missing",
  "Vote item not fielded"
)

# Blues for attached, greens for leaners, oranges for neither
leaf_colours <- c(
  "#08306b",
  "#2171b5",
  "#6baed6",
  "#c6dbef",
  "#00441b",
  "#238b45",
  "#74c476",
  "#c7e9c0",
  "#a63603",
  "#fd8d3c",
  "#737373",
  "#d9d9d9"
) |>
  rlang::set_names(leaf_levels)

# Leaves in tree order: vote first groups the leaves by vote
leaf_order <- function(vote_first = FALSE) {
  if (!vote_first) {
    return(leaf_levels)
  }
  c(
    "Attached: same party",
    "Attached: different party",
    "Attached: vote not matchable",
    "Leaner: same party",
    "Leaner: different party",
    "Leaner: vote not matchable",
    "No attachment: vote",
    "Attached: no vote",
    "Leaner: no vote",
    "No attachment: no vote",
    "Attachment DK / missing",
    "Vote item not fielded"
  )
}

# Checks -------------------------------------------------------------------------

# Fail loudly on unexpected codes
check_tree_frame <- function(df) {
  lean <- if ("lean" %in% names(df)) df$lean else rep(NA, nrow(df))
  named <- df$att == "yes" | lean %in% "yes"
  stopifnot(
    all(df$att %in% names(tree_att_code)),
    all(df$vote %in% names(tree_vote_code)),
    all(lean %in% c(names(tree_lean_code), NA)),
    all(is.na(lean[df$att == "yes"])),
    all(is.na(df$match) == !(named & df$vote == "yes")),
    all(df$match %in% c(names(tree_match_code), NA))
  )
  if ("vote_first" %in% names(df)) stopifnot(is.logical(df$vote_first), !anyNA(df$vote_first))
  invisible(df)
}

# Node counts -------------------------------------------------------------------

# Order and probe level per group
tree_layout <- function(df, grp) {
  if (!"vote_first" %in% names(df)) df$vote_first <- FALSE
  if (!"lean" %in% names(df)) df$lean <- NA_character_
  df |>
    dplyr::mutate(
      # Majority order of the group
      .vf = mean(vote_first) >= 0.5,
      # Probe level only where some respondent got it
      .has_lean = any(!is.na(lean)),
      .by = dplyr::all_of(grp)
    )
}

# Path steps per respondent, in question order
tree_paths <- function(df) {
  s_vote <- paste0("v_", tree_vote_code[df$vote])
  s_att <- paste0("a_", tree_att_code[df$att])
  s_lean <- dplyr::if_else(
    df$.has_lean & df$att != "yes",
    paste0("l_", tree_lean_code[dplyr::coalesce(df$lean, "not_fielded")]),
    NA
  )
  s_match <- dplyr::if_else(
    is.na(df$match),
    NA,
    paste0("m_", tree_match_code[df$match])
  )
  list(
    dplyr::if_else(df$.vf, s_vote, s_att),
    dplyr::if_else(df$.vf, s_att, s_lean),
    dplyr::if_else(df$.vf, s_lean, s_vote),
    s_match
  )
}

# Box label from a node id; leaves carry the typology name
tree_label <- function(node, leaf) {
  purrr::map2_chr(node, leaf, \(id, is_leaf) {
    if (id == "root") {
      return("Respondents")
    }
    seg <- strsplit(id, "__", fixed = TRUE)[[1]][-1]
    last <- seg[length(seg)]
    label <- tree_steps$label[match(last, tree_steps$step)]
    # Typology names on the leaves
    has <- \(s) s %in% seg
    no_party <- has("a_no") && !has("l_yes") && !has("l_dk")
    suffix <- dplyr::case_when(
      last == "m_same" && has("a_yes") ~ "explicit partisan",
      last == "m_same" && has("l_yes") ~ "leaner",
      is_leaf && no_party && has("v_yes") ~ "vote-anchored",
      is_leaf && no_party && has("v_no") ~ "non-partisan",
      .default = NA
    )
    if (is.na(suffix)) label else paste0(label, "<br>(", suffix, ")")
  })
}

# Sibling-ordered sort key of a node id
tree_key <- function(node) {
  purrr::map_chr(node, \(id) {
    seg <- strsplit(id, "__", fixed = TRUE)[[1]][-1]
    paste(sprintf("%02d", tree_steps$rank[match(seg, tree_steps$step)]), collapse = ".")
  })
}

# Counts and parent shares per node
tree_counts <- function(df, ...) {
  check_tree_frame(df)

  # Grouping column names
  grp <- purrr::map_chr(rlang::enquos(...), rlang::as_label)

  df <- tree_layout(df, grp)
  steps <- tree_paths(df)

  # One row per respondent and node, skipping absent levels
  cur <- rep("root", nrow(df))
  long <- list(dplyr::bind_cols(
    df[, grp, drop = FALSE],
    tibble::tibble(node = "root", parent = NA_character_)
  ))
  for (s in steps) {
    nxt <- dplyr::if_else(is.na(s), NA, paste0(cur, "__", s))
    keep <- !is.na(nxt)
    long <- c(
      long,
      list(dplyr::bind_cols(
        df[keep, grp, drop = FALSE],
        tibble::tibble(node = nxt[keep], parent = cur[keep])
      ))
    )
    cur <- dplyr::coalesce(nxt, cur)
  }
  counts <- dplyr::bind_rows(long) |>
    dplyr::count(dplyr::across(dplyr::all_of(c(grp, "node", "parent"))))

  # Attach parent N, share and label
  counts <- counts |>
    dplyr::left_join(
      counts |>
        dplyr::select(dplyr::all_of(grp), parent = node, n_parent = n),
      by = c(grp, "parent")
    ) |>
    dplyr::mutate(
      share = n / n_parent,
      leaf = !node %in% parent,
      .by = dplyr::all_of(grp)
    ) |>
    dplyr::mutate(
      label = tree_label(node, leaf),
      key = tree_key(node)
    )

  # Children must add up to parents
  sums <- counts |>
    dplyr::filter(!is.na(parent)) |>
    dplyr::summarise(
      n = sum(n),
      n_parent = dplyr::first(n_parent),
      .by = dplyr::all_of(c(grp, "parent"))
    )
  stopifnot(all(sums$n == sums$n_parent))

  counts
}

# Mermaid -----------------------------------------------------------------------

# Format a count with thousands separators
fmt_n <- function(n) format(n, big.mark = ",", scientific = FALSE, trim = TRUE)

# Unique node-id prefix per diagram
# Mermaid lays out nodes by element id; trees on one page sharing ids
# ("root", "a_yes") can take each other's positions.
tree_prefix <- function() {
  i <- getOption("pid_tree.counter", 0) + 1
  options(pid_tree.counter = i)
  paste0("t", i, "_")
}

# Build one flowchart from node counts
mermaid_tree <- function(counts) {
  id <- tree_prefix()
  counts <- counts |>
    dplyr::arrange(key) |>
    dplyr::mutate(
      last = stringr::str_extract(node, "[^_]+_[^_]+$"),
      cls = dplyr::case_when(
        last %in% tree_muted ~ ":::muted",
        stringr::str_detect(node, "l_yes") ~ ":::lean",
        .default = ""
      )
    )

  # Boxes, grey for DK and not fielded, dashed for leaners
  boxes <- counts |>
    dplyr::mutate(
      box = paste0(
        "  ",
        id,
        node,
        "(\"",
        label,
        "<br>N = ",
        fmt_n(n),
        "\")",
        cls
      )
    )

  # Edges labelled with the parent share
  edges <- counts |>
    dplyr::filter(!is.na(parent)) |>
    dplyr::mutate(
      edge = paste0(
        "  ",
        id,
        parent,
        " -->|\"",
        sprintf("%.1f%%", 100 * share),
        "\"| ",
        id,
        node
      )
    )

  paste(
    c(
      "flowchart TD",
      boxes$box,
      edges$edge,
      "  classDef muted fill:#f2f2f2,stroke:#999,color:#555",
      "  classDef lean fill:#f2f9f2,stroke:#238b45,stroke-dasharray:4 3"
    ),
    collapse = "\n"
  )
}

# Emitting markdown -------------------------------------------------------------

# Why two kinds of Mermaid block:
# Quarto draws every {mermaid} block in the browser at page load. A diagram in
# a hidden tab has no size then, and its layout collapses. So only diagrams
# that are visible at load go through Quarto (emit_mermaid). Diagrams in tabs
# are written as inert <pre class="mermaid-lazy"> blocks (emit_lazy_mermaid),
# which a small script draws the first time their tab is shown. It reuses the
# Mermaid library Quarto loads for the visible blocks, so every page needs at
# least one emit_mermaid() diagram.

# Print a Mermaid block in an asis chunk
emit_mermaid <- function(code, fig_width = 10) {
  cat(
    "\n```{mermaid}\n%%| echo: false\n%%| fig-width: ",
    fig_width,
    "\n",
    code,
    "\n```\n\n",
    sep = ""
  )
}

# Inert block, drawn when shown
emit_lazy_mermaid <- function(code) {
  # Escape for raw HTML
  code <- code |>
    stringr::str_replace_all("&", "&amp;") |>
    stringr::str_replace_all("<", "&lt;") |>
    stringr::str_replace_all(">", "&gt;")
  emit_lazy_script()
  cat(
    "\n```{=html}\n<pre class=\"mermaid-lazy\">",
    code,
    "</pre>\n```\n\n",
    sep = ""
  )
}

# Draws lazy blocks once visible
lazy_script <- '
<script>
window.addEventListener("load", () => {
  let n = 0;
  // Start after Quarto has drawn its own blocks
  const quartoDone = () => new Promise((resolve) => {
    const check = () =>
      document.querySelector("pre.mermaid-js") ? setTimeout(check, 100) : resolve();
    check();
  });
  let busy = quartoDone();
  // Draw every lazy block now visible
  const draw = () => {
    busy = busy.then(async () => {
      for (const el of document.querySelectorAll("pre.mermaid-lazy")) {
        if (!el.offsetParent) continue;
        const { svg } = await mermaid.render(`mermaid-lazy-${++n}`, el.textContent);
        const div = document.createElement("div");
        div.className = "mermaid-lazy-svg";
        div.innerHTML = svg;
        el.replaceWith(div);
      }
    });
  };
  draw();
  document.addEventListener("shown.bs.tab", draw);
});
</script>
'

# Emit the script once per page
emit_lazy_script <- function() {
  if (!isTRUE(getOption("pid_tree.lazy_script"))) {
    cat("\n```{=html}", lazy_script, "```\n\n", sep = "\n")
    options(pid_tree.lazy_script = TRUE)
  }
}

# One Mermaid tab per group value
emit_tree_tabset <- function(counts, by, level = 3) {
  cat("\n::: {.panel-tabset}\n\n")
  groups <- counts |>
    dplyr::group_split(.data[[by]])
  for (g in groups) {
    cat(strrep("#", level), " ", as.character(g[[by]][1]), "\n", sep = "")
    emit_lazy_mermaid(mermaid_tree(g))
  }
  cat(":::\n\n")
}

# Nested tabs: outer groups, inner groups
emit_nested_tabset <- function(counts, outer, inner, level = 3) {
  cat("\n::: {.panel-tabset}\n\n")
  groups <- counts |>
    dplyr::group_split(.data[[outer]])
  for (g in groups) {
    cat(strrep("#", level), " ", as.character(g[[outer]][1]), "\n", sep = "")
    emit_tree_tabset(g, by = inner, level = level + 1)
  }
  cat(":::\n\n")
}

# Leaf shares -------------------------------------------------------------------

# Collapse the tree frame to plot leaves
tree_leaves <- function(df, levels = leaf_levels) {
  lean <- if ("lean" %in% names(df)) df$lean else rep(NA_character_, nrow(df))
  df |>
    dplyr::mutate(
      .lean = lean %in% "yes",
      leaf = dplyr::case_when(
        vote == "not_fielded" ~ "Vote item not fielded",
        att == "yes" & match == "same" ~ "Attached: same party",
        att == "yes" & match == "different" ~ "Attached: different party",
        att == "yes" & match == "unmatchable" ~ "Attached: vote not matchable",
        att == "yes" & vote == "no" ~ "Attached: no vote",
        .lean & match == "same" ~ "Leaner: same party",
        .lean & match == "different" ~ "Leaner: different party",
        .lean & match == "unmatchable" ~ "Leaner: vote not matchable",
        .lean & vote == "no" ~ "Leaner: no vote",
        att == "dk" ~ "Attachment DK / missing",
        att == "no" & vote == "yes" ~ "No attachment: vote",
        att == "no" & vote == "no" ~ "No attachment: no vote"
      ),
      leaf = factor(leaf, levels = levels)
    ) |>
    dplyr::select(-".lean")
}

# Majority question order of a tree frame
tree_vote_first <- function(df) {
  "vote_first" %in% names(df) && mean(df$vote_first) >= 0.5
}

# Stacked leaf shares, one panel per facet
plot_leaf_shares <- function(df, x, facet, ncol = 5) {
  df |>
    tree_leaves(levels = leaf_order(tree_vote_first(df))) |>
    dplyr::count({{ facet }}, {{ x }}, leaf) |>
    dplyr::mutate(share = n / sum(n), .by = c({{ facet }}, {{ x }})) |>
    ggplot2::ggplot(ggplot2::aes(x = {{ x }}, y = share, fill = leaf)) +
    ggplot2::geom_col(width = 0.85, colour = "white", linewidth = 0.2) +
    ggplot2::facet_wrap(ggplot2::vars({{ facet }}), ncol = ncol, drop = FALSE) +
    ggplot2::scale_y_continuous(
      labels = scales::percent,
      breaks = c(0, 0.5, 1),
      expand = c(0, 0)
    ) +
    ggplot2::scale_fill_manual(values = leaf_colours, drop = TRUE) +
    ggplot2::labs(y = "Share of respondents", fill = NULL) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      legend.position = "bottom",
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    ) +
    ggplot2::guides(fill = ggplot2::guide_legend(nrow = 3))
}

# Composition by country --------------------------------------------------------

# White text on dark fills
leaf_text_colour <- function(fill) {
  rgb <- grDevices::col2rgb(fill) / 255
  lum <- 0.2126 * rgb[1, ] + 0.7152 * rgb[2, ] + 0.0722 * rgb[3, ]
  dplyr::if_else(lum < 0.5, "white", "#003056")
}

# One bar per country, as in the HMS deck (presentation_hms.qmd)
plot_country_composition <- function(df) {
  levels <- leaf_order(tree_vote_first(df))

  d <- df |>
    tree_leaves(levels = levels) |>
    dplyr::count(country, leaf) |>
    dplyr::mutate(
      share = n / sum(n),
      n_country = sum(n),
      attached = sum(share[startsWith(as.character(leaf), "Attached")]),
      .by = country
    ) |>
    dplyr::mutate(
      land = paste0(country, " (N = ", fmt_n(n_country), ")"),
      land = stats::reorder(land, attached)
    )

  # Labels on every segment; under 3% the bare number in smaller type
  seg <- d |>
    dplyr::arrange(land, leaf) |>
    dplyr::mutate(end = cumsum(share), start = end - share, .by = land) |>
    dplyr::mutate(
      txt = leaf_text_colour(leaf_colours[as.character(leaf)]),
      narrow = round(share, 2) < 0.03,
      lab = dplyr::if_else(
        narrow,
        as.character(round(100 * share)),
        scales::percent(share, 1)
      )
    ) |>
    # Nothing in segments that round to zero
    dplyr::filter(round(100 * share) > 0)

  ggplot2::ggplot(d, ggplot2::aes(x = share, y = land, fill = leaf)) +
    ggplot2::geom_col(
      width = 0.8,
      colour = "white",
      linewidth = 0.2,
      position = ggplot2::position_stack(reverse = TRUE)
    ) +
    ggplot2::geom_text(
      data = dplyr::filter(seg, !narrow),
      ggplot2::aes(x = (start + end) / 2, label = lab, colour = txt),
      size = 2.3
    ) +
    ggplot2::geom_text(
      data = dplyr::filter(seg, narrow),
      ggplot2::aes(x = (start + end) / 2, label = lab, colour = txt),
      size = 1.8
    ) +
    ggplot2::scale_colour_identity() +
    ggplot2::scale_fill_manual(values = leaf_colours, drop = TRUE) +
    ggplot2::guides(fill = ggplot2::guide_legend(nrow = 3)) +
    ggplot2::scale_x_continuous(
      labels = scales::percent,
      breaks = seq(0, 1, 0.25),
      expand = c(0, 0)
    ) +
    ggplot2::labs(x = NULL, y = NULL, fill = NULL) +
    ggplot2::theme_minimal(base_size = 10) +
    ggplot2::theme(
      legend.position = "bottom",
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      axis.text.y = ggplot2::element_text(size = 7.5, colour = "#003056"),
      legend.text = ggplot2::element_text(colour = "#003056"),
      plot.margin = ggplot2::margin(6, 12, 2, 2)
    )
}

# One country figure per group value, in tabs (asis chunk)
emit_figure_tabset <- function(df, by, level = 2, subtitle = NULL) {
  cat("\n::: {.panel-tabset}\n\n")
  for (g in dplyr::group_split(df, .data[[by]])) {
    value <- as.character(g[[by]][1])
    cat(strrep("#", level), " ", value, "\n\n", sep = "")
    print(
      plot_country_composition(g) +
        ggplot2::labs(title = value, subtitle = subtitle)
    )
    cat("\n\n")
  }
  cat(":::\n\n")
}
