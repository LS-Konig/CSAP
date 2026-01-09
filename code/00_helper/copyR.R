# --- R Script to Copy a File ---

# Define the full path to the file you want to copy (source)
# IMPORTANT: Use forward slashes (/) for paths in R, even on Windows,
# or use double backslashes (\\).
source_file_path <- "C:/R/research/eu25games2019/data/03_final/eu25games2019.RData"
# source_file_path <- "C:/R/logistics/glftrackeR/glftrackeR.R"
# source_file_path <- "C:/R/research/eu25games2019/eu25games2019_codebook.pdf"

# Define the path to the folder where you want to place the copy (destination)
# The destination must be the folder path, not the full file path.
# destination_folder_path <- "C:/R/research/CSAP/code/helper"
destination_folder_path <- "C:/R/research/CSAP/data/01_raw"


# --- Copy Operation ---

# file.copy() attempts to copy the file.
# The 'overwrite = TRUE' argument allows it to replace the file if it already exists.
copy_successful <- file.copy(
  from = source_file_path,
  to = destination_folder_path,
  overwrite = TRUE
)

# --- Status Check ---

if (copy_successful) {
  cat(
    "\n",
    "File ",
    source_file_path,
    "successfully copied to:",
    destination_folder_path,
    "\n"
  )
} else {
  # This usually means the source file doesn't exist or there was a permission issue.
  cat("\n", "ERROR: File copy failed. Check paths and permissions.\n")
}
