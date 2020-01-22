# author: Sam Edwardes (DSCI_522_group_315)
# date: 2020-01-21

"
This script performs pre-processing on UFC fight data. The script returns four
csv files: X_train, y_train, X_test, and y_test.

Usage: 02_preprocess_data.R --data_path=<data_path> --fight_details_path=<fight_details_path> --output_path=<output_path> --seed_num=<seed_num>

Options:
--data_path=<data_path>
--fight_details_path=<fight_details_path>
--output_path=<output_path>
--seed_num=<seed_num> The seed to set random state [default: 1993]

Example: Rscript src/02_preprocess_data.R --data_path=data/01_raw/data.csv --fight_details_path=data/01_raw/raw_total_fight_data.csv --output_path=data/02_preprocessed/ --seed_num=1993
" -> doc

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(lubridate))
suppressPackageStartupMessages(library(janitor))
suppressPackageStartupMessages(library(docopt))

arguments <- docopt(doc)

main <- function(data_path, fight_details_path, output_path, seed_num) {
  # load the raw fighting data
  print("Reading UFC data...")
  df_fight_details <-
    read_csv(data_path, col_types = cols()) %>%
    clean_names()

  # load additional supporting fight data (contains the required `win_by` column)
  print("Reading fight basics data...")
  df_fight_basics <-
    read_delim(
      fight_details_path,
      delim = ";",
      col_types = cols()
    ) %>%
    clean_names() %>%
    mutate(date = mdy(date)) %>%
    select("r_fighter", "b_fighter", "win_by", "date")

  # Merge the fight data and supporting dataframe
  print("Joining data sets and filtering...")
  df <- left_join(df_fight_details,
    df_fight_basics,
    by = c("r_fighter", "b_fighter", "date")
  ) %>%
    drop_na() %>%
    # only want keep fights that went to the judges score card
    filter(
      win_by == "Decision - Majority" |
        win_by == "Decision - Split" |
        win_by == "Decision - Unanimous",
      winner != "Draw"
    ) %>%
    # In some cases both fighers have 0 for a feature. This will have resulted in an
    # NaN because 0 / 0 evaluates to NaN. However, the correct number should be 0.5
    # as both fighers performed equally on the metric. To correct this a small value
    # is added to each numeric column.
    mutate_if(is.numeric, function(x) {
      x + 0.00001
    })

  # Create one column for each feature numeric feature.
  # This is done by taking the proportion for the blue fighter. For example:
  # avg_body_landed = b_avg_body_landed / (b_avg_body_landed + r_avg_body_landed)
  # This would be a lot of typing, so the code below automaticaly generates this code
  # as a string which is then exected using eval(parse("code"))

  print("Calculating proportions of numeric features...")
  code_helper <- tibble(b = df %>%
    select(starts_with("b_")) %>%
    select_if(is.numeric) %>%
    colnames())
  code_helper <- code_helper %>%
    mutate(
      r = stringr::str_replace(b, "b_", "r_"),
      short = stringr::str_remove(b, "b_"),
      prop = paste0(short, " = ", b, " / (", b, " + ", r, ")")
    )

  code <- paste(code_helper$prop, collapse = ",")
  code <- paste0("X <- df %>% mutate(", code, ")")
  eval(parse(text = code))

  X <- X %>%
    select(
      avg_body_att,
      avg_body_landed,
      avg_clinch_att,
      avg_clinch_landed,
      avg_distance_att,
      avg_distance_landed,
      avg_ground_att,
      avg_ground_landed,
      avg_head_att,
      avg_head_landed,
      avg_kd,
      avg_leg_att,
      avg_leg_landed,
      avg_pass,
      avg_rev,
      avg_sig_str_att,
      avg_sig_str_landed,
      avg_sig_str_pct,
      avg_sub_att,
      avg_td_att,
      avg_td_landed,
      avg_td_pct,
      avg_total_str_att,
      avg_total_str_landed,
      avg_opp_body_att,
      avg_opp_body_landed,
      avg_opp_clinch_att,
      avg_opp_clinch_landed,
      avg_opp_distance_att,
      avg_opp_distance_landed,
      avg_opp_ground_att,
      avg_opp_ground_landed,
      avg_opp_head_att,
      avg_opp_head_landed,
      avg_opp_kd,
      avg_opp_leg_att,
      avg_opp_leg_landed,
      avg_opp_pass,
      avg_opp_rev,
      avg_opp_sig_str_att,
      avg_opp_sig_str_landed,
      avg_opp_sig_str_pct,
      avg_opp_sub_att,
      avg_opp_td_att,
      avg_opp_td_landed,
      avg_opp_td_pct,
      avg_opp_total_str_att,
      avg_opp_total_str_landed
    )

  y <- df$winner

  # split data into training and testing
  print("Splitting data into testing and training...")
  set.seed(seed_num)
  train_index <- caret::createDataPartition(y, p = 0.8, list = FALSE)
  train_index

  X_train <- X[train_index, ]
  y_train <- tibble(winner = y[train_index])
  X_test <- X[-train_index, ]
  y_test <- tibble(winner = y[-train_index])

  # write data to computer
  print("Writing data...")
  write_csv(X_train, paste0(output_path, "X_train.csv"))
  write_csv(y_train, paste0(output_path, "y_train.csv"))
  write_csv(X_test, paste0(output_path, "X_test.csv"))
  write_csv(y_test, paste0(output_path, "y_test.csv"))
  
  print("Training data dimensions:")
  print(dim(X_train))
  print("Testing data dimensions:")
  print(dim(X_test))
  print("Complete data set dimensions:")
  print(dim(bind_rows(X_train, X_test)))
  print("Script complete.")
}

main(
  data_path = arguments$data_path,
  fight_details_path = arguments$fight_details_path,
  output_path = arguments$output_path,
  seed_num = arguments$seed_num
)
