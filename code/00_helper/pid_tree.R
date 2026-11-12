# Partisan composition trees ---------------------------------------------------
#
# Shared helpers for the composition notebooks in code/02_types/ and code/rq1_who/.
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
#   weight     numeric                             survey weight (see data.md,
#                                                  *Weights*); shares and plots
#                                                  are weighted when present,
#                                                  counts N stay unweighted
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

# Weights -----------------------------------------------------------------------

# Weight column, 1 where absent
tree_weight <- function(df) {
  if ("weight" %in% names(df)) df$weight else rep(1, nrow(df))
}

# Rescale weights to mean 1 within each survey cell (e.g. study x country), so
# that pooling cells keeps each cell's own sample size; NA and negative weights
# fail loudly
norm_weight <- function(df, ...) {
  stopifnot(!anyNA(df$weight), all(df$weight >= 0))
  df |>
    dplyr::mutate(weight = weight / mean(weight), .by = c(...))
}

# Kish effective sample size
n_eff <- function(w) sum(w)^2 / sum(w^2)

# Node counts -------------------------------------------------------------------

# Order and probe level per group
tree_layout <- function(df, grp) {
  if (!"vote_first" %in% names(df)) df$vote_first <- FALSE
  if (!"lean" %in% names(df)) df$lean <- NA_character_
  df$.w <- tree_weight(df)
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

# Typology name of a node, for leaves only
tree_type <- function(node, leaf) {
  purrr::map2_chr(node, leaf, \(id, is_leaf) {
    seg <- strsplit(id, "__", fixed = TRUE)[[1]][-1]
    last <- seg[length(seg)]
    has <- \(s) s %in% seg
    no_party <- has("a_no") && !has("l_yes") && !has("l_dk")
    if (id == "root") {
      return(NA_character_)
    }
    dplyr::case_when(
      last == "m_same" && has("a_yes") ~ "explicit partisan",
      last == "m_same" && has("l_yes") ~ "leaner",
      is_leaf && no_party && has("v_yes") ~ "vote-anchored",
      is_leaf && no_party && has("v_no") ~ "non-partisan",
      .default = NA_character_
    )
  })
}

# Box label from a node id; leaves carry the typology name
tree_label <- function(node, type) {
  label <- tree_steps$label[match(stringr::str_extract(node, "[^_]+_[^_]+$"), tree_steps$step)]
  dplyr::case_when(
    node == "root" ~ "Respondents",
    is.na(type) ~ label,
    .default = paste0(label, "<br>(", type, ")")
  )
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
    tibble::tibble(node = "root", parent = NA_character_, .w = df$.w)
  ))
  for (s in steps) {
    nxt <- dplyr::if_else(is.na(s), NA, paste0(cur, "__", s))
    keep <- !is.na(nxt)
    long <- c(
      long,
      list(dplyr::bind_cols(
        df[keep, grp, drop = FALSE],
        tibble::tibble(node = nxt[keep], parent = cur[keep], .w = df$.w[keep])
      ))
    )
    cur <- dplyr::coalesce(nxt, cur)
  }
  # Unweighted n, weighted n_w
  counts <- dplyr::bind_rows(long) |>
    dplyr::summarise(
      n = dplyr::n(),
      n_w = sum(.w),
      .by = dplyr::all_of(c(grp, "node", "parent"))
    )

  # Attach parent N, weighted share and label
  counts <- counts |>
    dplyr::left_join(
      counts |>
        dplyr::select(dplyr::all_of(grp), parent = node, n_parent = n, n_w_parent = n_w),
      by = c(grp, "parent")
    ) |>
    dplyr::mutate(
      share = n_w / n_w_parent,
      leaf = !node %in% parent,
      .by = dplyr::all_of(grp)
    ) |>
    dplyr::mutate(
      type = tree_type(node, leaf),
      label = tree_label(node, type),
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
        type %in% "explicit partisan" ~ ":::explicit",
        type %in% "vote-anchored" ~ ":::anchored",
        last %in% tree_muted ~ ":::muted",
        stringr::str_detect(node, "l_yes") ~ ":::lean",
        .default = ""
      )
    )

  # Boxes: filled for the two groups of interest, grey for DK and not
  # fielded, dashed for leaners
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

  # Edges labelled with the (weighted) parent share
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

  # Thick edges on the paths to the two groups of interest
  on_path <- \(nodes, leaves) {
    purrr::map_lgl(nodes, \(x) any(startsWith(paste0(leaves, "__"), paste0(x, "__"))))
  }
  to_explicit <- on_path(edges$node, counts$node[counts$type %in% "explicit partisan"])
  to_anchored <- on_path(edges$node, counts$node[counts$type %in% "vote-anchored"])
  path_colour <- dplyr::case_when(
    to_explicit & to_anchored ~ "#333333",
    to_explicit ~ "#08306b",
    to_anchored ~ "#a63603"
  )
  links <- paste0(
    "  linkStyle ",
    which(!is.na(path_colour)) - 1,
    " stroke:",
    path_colour[!is.na(path_colour)],
    ",stroke-width:3px"
  )
  if (all(is.na(path_colour))) links <- character()

  paste(
    c(
      "flowchart TD",
      boxes$box,
      edges$edge,
      links,
      "  classDef muted fill:#f2f2f2,stroke:#999,color:#555",
      "  classDef lean fill:#f2f9f2,stroke:#238b45,stroke-dasharray:4 3",
      "  classDef explicit fill:#08306b,stroke:#041a3d,stroke-width:3px,color:#fff",
      "  classDef anchored fill:#a63603,stroke:#5e1f02,stroke-width:3px,color:#fff"
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

# Stacked leaf shares, one panel per facet; blues, greens, oranges, greys
plot_leaf_shares <- function(df, x, facet, ncol = 5) {
  df |>
    dplyr::mutate(.w = tree_weight(df)) |>
    tree_leaves() |>
    dplyr::count({{ facet }}, {{ x }}, leaf, wt = .w) |>
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
    # One legend column per colour family
    ggplot2::guides(fill = ggplot2::guide_legend(nrow = 4))
}

# Composition by country --------------------------------------------------------

# White text on dark fills
leaf_text_colour <- function(fill) {
  rgb <- grDevices::col2rgb(fill) / 255
  lum <- 0.2126 * rgb[1, ] + 0.7152 * rgb[2, ] + 0.0722 * rgb[3, ]
  dplyr::if_else(lum < 0.5, "white", "#003056")
}

# One bar per country, as in the HMS deck (presentation_hms.qmd); blues,
# greens, oranges, greys from the left
plot_country_composition <- function(df) {
  d <- df |>
    dplyr::mutate(.w = tree_weight(df)) |>
    tree_leaves() |>
    dplyr::summarise(n = dplyr::n(), n_w = sum(.w), .by = c(country, leaf)) |>
    dplyr::mutate(
      # Weighted share, unweighted N
      share = n_w / sum(n_w),
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
    # One legend column per colour family
    ggplot2::guides(fill = ggplot2::guide_legend(nrow = 4)) +
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
# knitr would hold printed plots until the end of the chunk, after the
# tabset, so each figure is saved here and linked inside its own tab.
emit_figure_tabset <- function(df, by, level = 2, subtitle = NULL) {
  opts <- knitr::opts_current$get()
  cat("\n::: {.panel-tabset}\n\n")
  groups <- dplyr::group_split(df, .data[[by]])
  for (i in seq_along(groups)) {
    g <- groups[[i]]
    value <- as.character(g[[by]][1])
    path <- knitr::fig_path(".png", number = i)
    dir.create(dirname(path), recursive = TRUE, showWarnings = FALSE)
    ggplot2::ggsave(
      path,
      plot_country_composition(g) +
        ggplot2::labs(title = value, subtitle = subtitle),
      width = opts$fig.width,
      height = opts$fig.height,
      dpi = 192,
      bg = "white"
    )
    cat(strrep("#", level), " ", value, "\n\n", sep = "")
    cat("![](", path, "){width=100%}\n\n", sep = "")
  }
  cat(":::\n\n")
}

# Weighted vs. unweighted -------------------------------------------------------

# Leaf shares per group, unweighted and weighted, with the difference in
# percentage points; largest absolute differences first
weight_check <- function(df, ...) {
  df |>
    dplyr::mutate(.w = tree_weight(df)) |>
    tree_leaves() |>
    dplyr::summarise(n = dplyr::n(), n_w = sum(.w), .by = c(..., leaf)) |>
    dplyr::mutate(
      unweighted = 100 * n / sum(n),
      weighted = 100 * n_w / sum(n_w),
      diff_pp = weighted - unweighted,
      .by = c(...)
    ) |>
    dplyr::select(..., leaf, n, unweighted, weighted, diff_pp) |>
    dplyr::mutate(dplyr::across(c(unweighted, weighted, diff_pp), \(x) round(x, 1))) |>
    dplyr::arrange(dplyr::desc(abs(diff_pp)))
}

# Common composition types --------------------------------------------------------

# The types every source can form. Leaners are folded in as a survey without the
# probe folds them: a leaner says "no" to the base item, so a voting leaner is a
# denier and a non-voting leaner a non-partisan. Attached non-voters are their
# own category. NA: attachment DK, vote item not fielded, or an attached voter
# whose two answers cannot be compared (left out of the denominator).
ctype_levels <- c(
  "explicit",
  "mismatched",
  "denier",
  "attached non-voter",
  "non-partisan"
)

tree_ctype <- function(leaf) {
  leaf <- as.character(leaf)
  factor(
    dplyr::case_when(
      leaf == "Attached: same party" ~ "explicit",
      leaf == "Attached: different party" ~ "mismatched",
      leaf == "Attached: no vote" ~ "attached non-voter",
      leaf %in% c(
        "No attachment: vote",
        "Leaner: same party",
        "Leaner: different party",
        "Leaner: vote not matchable"
      ) ~ "denier",
      leaf %in% c("No attachment: no vote", "Leaner: no vote") ~ "non-partisan",
      .default = NA_character_
    ),
    levels = ctype_levels
  )
}

# Respondent-level type file for notebooks r1.01 and r1.02
# `survey` names the fieldwork cell within a country (study, wave or round),
# `year` its fieldwork year, `vote_ref` which election the vote refers to.
write_types <- function(df, source, survey, year, vote_ref, weight_source, path) {
  lean <- if ("lean" %in% names(df)) df$lean else rep(NA_character_, nrow(df))
  out <- df |>
    tree_leaves() |>
    dplyr::transmute(
      source = source,
      survey = as.character({{ survey }}),
      country,
      year = as.integer(as.character({{ year }})),
      vote_ref = vote_ref,
      weight = tree_weight(df),
      weight_source = {{ weight_source }},
      leaf,
      ctype = tree_ctype(leaf),
      # NA for the attached and where no probe was fielded
      lean = lean
    )
  stopifnot(!anyNA(out$year), !anyNA(out$weight))
  arrow::write_parquet(out, path)
  invisible(out)
}
