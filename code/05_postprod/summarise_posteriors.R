library(tidyverse)
library(here)

load(
  here(
    "data",
    "03_final",
    "qois",
    "qois_cov_t.RData"
  )
)

qois_cov_t |>
  filter(Quantity == "CATE_OD") |>
  summarise(
    # 1. Median (50th percentile)
    median = median(Estimate),

    # 2. 95% Credible Interval (0.025 and 0.975 quantiles)
    ci_95_low = quantile(Estimate, 0.025),
    ci_95_high = quantile(Estimate, 0.975),

    # 3. 99% Credible Interval (0.005 and 0.995 quantiles)
    ci_99_low = quantile(Estimate, 0.005),
    ci_99_high = quantile(Estimate, 0.995),

    # 4. Probability/Certainty that the estimate is greater than 0
    #    (i.e., percentage of posterior draws > 0)
    prob_gt_0 = mean(Estimate > 0) * 100, # Returns a percentage (0 to 100)

    # Optional: Probability/Certainty that the estimate is less than 0
    prob_lt_0 = mean(Estimate < 0) * 100, # Returns a percentage (0 to 100)

    prob_in_range = mean(Estimate > 0 & Estimate < 0.25) * 100,
    prob_in_range2 = mean(Estimate < 0.1) * 100
  )
