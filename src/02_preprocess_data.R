# author: Sam Edwardes (DSCI_522_group_315)
# date: 2020-01-21

"
This script performs pre-processing on UFC fight data. The script returns four
csv files: X_train, y_train, X_test, and y_test.

Usage: 02_preprocess_data.R --input_path=<input_path> --output_path=<output_path> --seed_num=<seed_num>

Options:
--input_path=<input_path>           The path of raw_total_fight_data.csv
--output_path=<output_path>         The path of the directory to save output to
--seed_num=<seed_num>               The seed to set random state

Example: 
Rscript src/02_preprocess_data.R --input_path=data/01_raw/raw_total_fight_data.csv --output_path=data/02_preprocessed/ --seed_num=1993
" -> doc

suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(janitor))
suppressPackageStartupMessages(library(docopt))
suppressPackageStartupMessages(library(testthat))
suppressPackageStartupMessages(library(stringr))

arguments <- docopt(doc)

#' Preprocessing script tests
#'
#' @param input_path The path to raw data file (string)
preprocessing_tests <- function(input_path) {
  
  df <- read_delim(input_path, delim = ";", col_types = cols()) %>%
    clean_names()

  test_that("Input path does not lead to csv file.", {
    expect_true(str_sub(input_path, -4, -1) == ".csv")
  })
  
  test_that("The file provided was unable to be parsed into a dataframe.", {
    expect_true(sum(class(df) == "data.frame") > 0)
  })
}


#' Main
#' 
#' To run all functions and perform EDA analysis.
#'
#' @param input_path The path to raw data file (string)
#' @param output_path The path to direcotry to output processed data (string)
#' @param seed_num  Set random number seed (int)
#'
#' @return Does not return any object
main <- function(input_path, output_path, seed_num) {
  
  print("Testing inputs...")
  preprocessing_tests(input_path)

  # load the ufc data ----
  print("Reading fight basics data...")
  df <-
    read_delim(
      input_path,
      delim = ";",
      col_types = cols()
    ) %>%
    clean_names()

  # split the columns that contain "of" ----
  cols_to_split <- c(
    "r_sig_str",
    "b_sig_str",
    "r_total_str",
    "b_total_str",
    "r_td",
    "b_td",
    "r_head",
    "b_head",
    "r_body",
    "b_body",
    "r_leg",
    "b_leg",
    "r_distance",
    "b_distance",
    "r_clinch",
    "b_clinch",
    "r_ground",
    "b_ground"
  )

  for (i in cols_to_split) {
    df <- df %>%
      separate(
        col = i,
        into = c(paste0(i, "_att"), paste0(i, "_landed")),
        sep = "of",
        convert = TRUE,
        remove = TRUE
      )
  }

  # remove % sign from columns ----
  df <- df %>%
    mutate(
      r_sig_str_pct = as.numeric(stringr::str_remove(r_sig_str_pct, "%")) / 100,
      b_sig_str_pct = as.numeric(stringr::str_remove(b_sig_str_pct, "%")) / 100,
      r_td_pct = as.numeric(stringr::str_remove(r_td_pct, "%")) / 100,
      b_td_pct = as.numeric(stringr::str_remove(b_td_pct, "%")) / 100
    )

  # change winner to colour instead of name ----
  df <- df %>%
    mutate(
      winner_name = winner,
      winner = if_else(winner == r_fighter, "Red", "Blue")
    )

  # filter out fights that should not be used in model ----
  df <- df %>%
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


  # Create one column for each feature numeric feature. ----
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

  # create variable X
  eval(parse(text = code))

  # select final features ----
  X <- X %>%
    select(
      sig_str_att,
      sig_str_landed,
      sig_str_pct,
      total_str_att,
      total_str_landed,
      td_att,
      td_landed,
      td_pct,
      sub_att,
      pass,
      rev,
      head_att,
      head_landed,
      body_att,
      body_landed,
      leg_att,
      leg_landed,
      distance_att,
      distance_landed,
      clinch_att,
      clinch_landed,
      ground_att,
      ground_landed
    )

  y <- df$winner

  # split data into training and testing ----
  print("Splitting data into testing and training...")
  set.seed(seed_num)
  train_index <- caret::createDataPartition(y, p = 0.8, list = FALSE)

  X_train <- X[train_index, ]
  y_train <- tibble(winner = y[train_index])
  X_test <- X[-train_index, ]
  y_test <- tibble(winner = y[-train_index])

  # write data to computer ----
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
  input_path = arguments$input_path,
  output_path = arguments$output_path,
  seed_num = arguments$seed_num
)
