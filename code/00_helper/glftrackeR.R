# R Script to find files larger than 100 MB in a directory
# and automatically add them to the .gitattributes file for Git LFS tracking.

# 1. Configuration ---------------------------------------------------------
target_dir <- "." # "." means current working directory
size_threshold_bytes <- 100 * 1024 * 1024 # 100 MB
gitattributes_path <- file.path(target_dir, ".gitattributes")
lfs_command <- " filter=lfs diff=lfs merge=lfs -text"

# 2. Get file information -------------------------------------------------
# Get relative file paths (important for Git attributes!)
all_files <- list.files(
  path = target_dir,
  recursive = TRUE,
  full.names = FALSE,
  include.dirs = FALSE
)

# Exclude .git directory and .gitattributes itself
all_files <- all_files[!grepl("^\\.git|\\.gitattributes$", all_files)]

# Get detailed info for those files
file_info <- file.info(all_files)

# 3. Filter for large files -----------------------------------------------
large_files_info <- file_info[
  file_info$size > size_threshold_bytes & !is.na(file_info$size),
]

# 4. Write to .gitattributes ----------------------------------------------
if (nrow(large_files_info) > 0) {
  large_file_paths <- rownames(large_files_info)

  # Normalize to Unix-style forward slashes (important on Windows)
  large_file_paths <- gsub("\\\\", "/", large_file_paths)

  # Remove leading "./" if any (precautionary)
  large_file_paths <- sub("^\\./", "", large_file_paths)

  # Build correct LFS entries
  lfs_entries <- paste0(large_file_paths, lfs_command)

  # Append to .gitattributes (avoid duplicates)
  existing_lines <- if (file.exists(gitattributes_path)) {
    readLines(gitattributes_path)
  } else {
    character(0)
  }
  new_entries <- setdiff(lfs_entries, existing_lines)

  if (length(new_entries) > 0) {
    con <- file(gitattributes_path, open = "a")
    writeLines(new_entries, con = con, sep = "\n")
    close(con)

    cat(
      "\n✅ Added",
      length(new_entries),
      "new large file(s) to .gitattributes:\n"
    )
    cat(paste(large_file_paths, collapse = "\n"), "\n\n")
    cat("Next steps:\n")
    cat("  git add .gitattributes\n")
    cat("  git add <your large files>\n")
    cat("  git commit -m 'Track large files with Git LFS'\n")
  } else {
    cat("ℹ️  All large files are already tracked by LFS.\n")
  }
} else {
  cat("\nNo files larger than 100 MB found in:", target_dir, "\n")
}
