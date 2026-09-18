# Partisan composition trees ---------------------------------------------------
#
# Shared helpers for the composition notebooks in code/02_composition/.
# Every source is first harmonised to one row per respondent with four columns:
#
#   att   "yes" / "no" / "dk"             reports a party attachment?
#   vote  "yes" / "no" / "not_fielded"    reports a party vote?
#   match "same" / "different" / "unmatchable" / NA
#                                         only for att == "yes" & vote == "yes"
#
# plus any grouping columns (country, period). The helpers below turn that frame
# into node counts, Mermaid flowcharts, tabsets and a leaf-share plot.

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

# Node id, parent id and box label
tree_nodes <- tibble::tribble(
  ~node         , ~parent       , ~label                                      ,
  "root"        , NA            , "Respondents"                               ,
  "a_yes"       , "root"        , "Attachment reported"                       ,
  "a_no"        , "root"        , "No attachment"                             ,
  "a_dk"        , "root"        , "Attachment DK / refused / missing"         ,
  "a_yes_v_yes" , "a_yes"       , "Vote reported"                             ,
  "a_yes_v_no"  , "a_yes"       , "No vote reported"                          ,
  "a_yes_v_nf"  , "a_yes"       , "Vote item not fielded"                     ,
  "a_no_v_yes"  , "a_no"        , "Vote reported<br>(vote-anchored)"          ,
  "a_no_v_no"   , "a_no"        , "No vote reported<br>(non-partisan)"        ,
  "a_no_v_nf"   , "a_no"        , "Vote item not fielded"                     ,
  "a_dk_v_yes"  , "a_dk"        , "Vote reported"                             ,
  "a_dk_v_no"   , "a_dk"        , "No vote reported"                          ,
  "a_dk_v_nf"   , "a_dk"        , "Vote item not fielded"                     ,
  "m_same"      , "a_yes_v_yes" , "Same party<br>(explicit partisan)"         ,
  "m_diff"      , "a_yes_v_yes" , "Different party"                           ,
  "m_unm"       , "a_yes_v_yes" , "Party not matchable<br>(other / unlisted)"
)

# Short codes used inside node ids
tree_att_code <- c(yes = "yes", no = "no", dk = "dk")
tree_vote_code <- c(yes = "yes", no = "no", not_fielded = "nf")
tree_match_code <- c(same = "same", different = "diff", unmatchable = "unm")

# Leaf categories for the share plot, in stacking order
leaf_levels <- c(
  "Attached: same party",
  "Attached: different party",
  "Attached: vote not matchable",
  "Attached: no vote",
  "No attachment: vote",
  "No attachment: no vote",
  "Attachment DK / missing",
  "Vote item not fielded"
)

# Blues for attached, oranges for not
leaf_colours <- c(
  "#08306b",
  "#2171b5",
  "#6baed6",
  "#c6dbef",
  "#a63603",
  "#fd8d3c",
  "#737373",
  "#d9d9d9"
) |>
  rlang::set_names(leaf_levels)

# Checks -------------------------------------------------------------------------

# Fail loudly on unexpected codes
check_tree_frame <- function(df) {
  stopifnot(
    all(df$att %in% names(tree_att_code)),
    all(df$vote %in% names(tree_vote_code)),
    all(
      is.na(df$match) == !(df$att == "yes" & df$vote == "yes")
    ),
    all(df$match %in% c(names(tree_match_code), NA))
  )
  invisible(df)
}

# Node counts -------------------------------------------------------------------

# Counts and parent shares per node
tree_counts <- function(df, ...) {
  check_tree_frame(df)

  # One row per node and group
  counts <- dplyr::bind_rows(
    df |> dplyr::count(..., node = "root"),
    df |> dplyr::count(..., node = paste0("a_", tree_att_code[att])),
    df |>
      dplyr::count(
        ...,
        node = paste0("a_", tree_att_code[att], "_v_", tree_vote_code[vote])
      ),
    df |>
      dplyr::filter(!is.na(match)) |>
      dplyr::count(..., node = paste0("m_", tree_match_code[match]))
  )

  # Grouping column names
  grp <- purrr::map_chr(rlang::enquos(...), rlang::as_label)

  # Attach parent N and share
  counts <- counts |>
    dplyr::left_join(tree_nodes, by = "node") |>
    dplyr::left_join(
      counts |> dplyr::rename(parent = node, n_parent = n),
      by = c(grp, "parent")
    ) |>
    dplyr::mutate(share = n / n_parent)

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

# Build one flowchart from node counts
mermaid_tree <- function(counts, leaner = NULL) {
  # Boxes, with grey class for DK and not-fielded
  boxes <- counts |>
    dplyr::arrange(match(node, tree_nodes$node)) |>
    dplyr::mutate(
      box = paste0("  ", node, "(\"", label, "<br>N = ", fmt_n(n), "\")"),
      box = dplyr::if_else(
        stringr::str_detect(node, "a_dk|_nf$"),
        paste0(box, ":::muted"),
        box
      )
    )

  # Edges labelled with the parent share
  edges <- counts |>
    dplyr::filter(!is.na(parent)) |>
    dplyr::arrange(match(node, tree_nodes$node)) |>
    dplyr::mutate(
      edge = paste0(
        "  ",
        parent,
        " -->|\"",
        sprintf("%.1f%%", 100 * share),
        "\"| ",
        node
      )
    )

  # Dashed note for an unused leaner probe
  lean <- character()
  if (!is.null(leaner) && "a_no" %in% counts$node) {
    lean <- c(
      paste0(
        "  lean[\"Leaner probe fielded, not used:<br>",
        leaner,
        "\"]:::note"
      ),
      "  a_no -.- lean"
    )
  }

  paste(
    c(
      "flowchart TD",
      boxes$box,
      edges$edge,
      lean,
      "  classDef muted fill:#f2f2f2,stroke:#999,color:#555",
      "  classDef note fill:#fff,stroke:#999,stroke-dasharray:4 3,color:#555"
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
  let busy = Promise.resolve();
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
emit_tree_tabset <- function(counts, by, level = 3, leaner = NULL) {
  cat("\n::: {.panel-tabset}\n\n")
  groups <- counts |>
    dplyr::group_split(.data[[by]])
  for (g in groups) {
    cat(strrep("#", level), " ", as.character(g[[by]][1]), "\n", sep = "")
    emit_lazy_mermaid(mermaid_tree(g, leaner = leaner_for(leaner, g)))
  }
  cat(":::\n\n")
}

# Nested tabs: outer groups, inner groups
emit_nested_tabset <- function(counts, outer, inner, level = 3, leaner = NULL) {
  cat("\n::: {.panel-tabset}\n\n")
  groups <- counts |>
    dplyr::group_split(.data[[outer]])
  for (g in groups) {
    cat(strrep("#", level), " ", as.character(g[[outer]][1]), "\n", sep = "")
    emit_tree_tabset(g, by = inner, level = level + 1, leaner = leaner)
  }
  cat(":::\n\n")
}

# Leaner text: fixed string or lookup function
leaner_for <- function(leaner, counts) {
  if (is.function(leaner)) leaner(counts) else leaner
}

# Leaf shares -------------------------------------------------------------------

# Collapse the tree frame to plot leaves
tree_leaves <- function(df) {
  df |>
    dplyr::mutate(
      leaf = dplyr::case_when(
        vote == "not_fielded" ~ "Vote item not fielded",
        att == "dk" ~ "Attachment DK / missing",
        att == "yes" & match == "same" ~ "Attached: same party",
        att == "yes" & match == "different" ~ "Attached: different party",
        att == "yes" & match == "unmatchable" ~ "Attached: vote not matchable",
        att == "yes" & vote == "no" ~ "Attached: no vote",
        att == "no" & vote == "yes" ~ "No attachment: vote",
        att == "no" & vote == "no" ~ "No attachment: no vote"
      ),
      leaf = factor(leaf, levels = leaf_levels)
    )
}

# Stacked leaf shares, one panel per facet
plot_leaf_shares <- function(df, x, facet, ncol = 5) {
  df |>
    tree_leaves() |>
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
    ggplot2::scale_fill_manual(values = leaf_colours) +
    ggplot2::labs(y = "Share of respondents", fill = NULL) +
    ggplot2::theme_minimal(base_size = 11) +
    ggplot2::theme(
      legend.position = "bottom",
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank()
    ) +
    ggplot2::guides(fill = ggplot2::guide_legend(nrow = 2))
}
