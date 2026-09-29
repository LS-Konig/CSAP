# Post-render copies into _manuscript/ ------------------------------------------
#
# Registered as the project post-render script in _quarto.yml; runs from the
# project root. Two things Quarto does not do on its own:
#
# 1. Frozen figures. A manuscript notebook rendered on its own under
#    `freeze: auto` leaves its figures in _freeze/ only, so the preview page
#    in _manuscript/ shows broken images. Copy
#      _freeze/code/<topic>/<nb>/figure-html/*.png
#      -> _manuscript/code/<topic>/<nb>_files/figure-html/
#    for every notebook that has a preview page.
# 2. Plain pages. The composition notebooks render next to their source (see
#    the comment in _quarto.yml). Copy each page and its _files/ folder to
#    _manuscript/code/02_composition/.

# Frozen figures -----------------------------------------------------------------

fig_dirs <- Sys.glob("_freeze/code/*/*/figure-html")

for (src in fig_dirs) {
  nb_dir <- dirname(src)
  nb <- basename(nb_dir)
  topic <- basename(dirname(nb_dir))
  out <- file.path("_manuscript", "code", topic)

  # Manuscript notebooks only
  if (!file.exists(file.path(out, paste0(nb, "-preview.html")))) next

  dest <- file.path(out, paste0(nb, "_files"), "figure-html")
  dir.create(dest, recursive = TRUE, showWarnings = FALSE)
  file.copy(list.files(src, full.names = TRUE), dest, overwrite = TRUE)
}

# Plain pages --------------------------------------------------------------------

page_src <- file.path("code", "02_composition")
page_out <- file.path("_manuscript", "code", "02_composition")

pages <- list.files(page_src, pattern = "\\.html$", full.names = TRUE)

if (length(pages) > 0) {
  dir.create(page_out, recursive = TRUE, showWarnings = FALSE)
  for (page in pages) {
    file.copy(page, page_out, overwrite = TRUE)
    files_dir <- sub("\\.html$", "_files", page)
    if (dir.exists(files_dir)) {
      file.copy(files_dir, page_out, recursive = TRUE, overwrite = TRUE)
    }
  }
}
