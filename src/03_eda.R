# author: Sam Edwardes (DSCI_522_group_315)
# date: 2020-01-21

"
This script creates EDA plots and tables.

Usage: 03_eda.R --X_train_path=<X_train_path> --y_train_path=<y_train_path> --out_dir=<out_dir>

Options:
--X_train_path=<X_train_path>           Path of the training data features
--y_train_path=<y_train_path>            Path of the training data targets
--out_dir=<out_dir>                     Directory path to export figures

Example: 
Rscript src/03_eda.R --X_train_path=data/02_preprocessed/X_train.csv --y_train_path=data/02_preprocessed/y_train.csv --out_dir=analysis/figures/
" -> doc

suppressPackageStartupMessages(library(docopt))
suppressPackageStartupMessages(library(tidyverse))
suppressPackageStartupMessages(library(GGally))
suppressPackageStartupMessages(library(testthat))

arguments <- docopt(doc)

#////////////////////////////////////
# Helper functions
#////////////////////////////////////

#' EDA script tests
#'
#' @param X_train_path The path to X_training csv file (string)
#' @param y_train_path The path to y_training csv file (string)
eda_tests <- function(X_train_path, y_train_path) {
  test_that("X training data does not exist or wrong path was given", {
    expect_true(file.exists(X_train_path))
  })
  
  test_that("y training data does not exist or wrong path was given", {
    expect_true(file.exists(y_train_path))
  })
  
  X_train <- read_csv(X_train_path, col_types = cols())
  y_train <- read_csv(y_train_path, col_types = cols())
  test_that("X_train and y_train do not have the same number of observations", {
    expect_equal(nrow(X_train), nrow(y_train))
  })
}

#' Create data frame for plots
#'
#' @param X_train_path The path to X_training csv file (string)
#' @param y_train_path The path to y_training csv file (string)
#' 
#' @return tibble of joined X_train and y_train data
#' 
#' @examples get_df("data/X_train.csv", "data/y_train.csv")
get_df <- function(X_train_path, y_train_path) {
  X_train <- read_csv(X_train_path, col_types = cols())
  y_train <- read_csv(y_train_path, col_types = cols())
  
  df <- bind_cols(X_train, y_train) %>%
    mutate(
      blue_win = if_else(winner == "Blue", 1, 0),
      winner = as_factor(winner)
    )
  
  df
}

#' Make correlation plot
#'
#' @param df Dataframe containing features (tibble)
#'
#' @return ggplot object
make_cor_plot <- function(df) {
  df <- select_if(df, is.numeric)
  cor_plot <- GGally::ggcorr(df, size = 3, hjust = 0.85, layout.exp = 2)
  cor_plot
}

#' Make bar plot of outcomes
#'
#' @param df Dataframe containing features (tibble)
#'
#' @return ggplot object
make_class_count_bar_plot <- function(df) {
  df %>%
    ggplot(aes(winner)) +
    geom_bar() +
    labs(title = "Winner Count",
         x = "Winner",
         y = "Count")
}

#' Make box jitter plot
#' 
#' Creates jitter plot overlayed with a box plot. For each feature included in
#' ... the plot is faceted
#'
#' @param df Dataframe containing features (tibble)
#' @param response The target or y value (string or column name)
#' @param ... Additional column names
#'
#' @return ggplot object
make_box_jitter_plot <- function(df, response, ...) {
  df <- df %>%
    select({{ response }}, all_of(...)) %>%
    pivot_longer(cols = -{{ response }}) %>%
    mutate(
      b_value = value,
      r_value = 1 - value,
      blue_win = as.character(blue_win)
    )
  
  df$blue_win <- factor(
    x = df$blue_win,
    levels = c("0", "1"),
    labels = c("Blue Loss", "Blue Win")
  )
  
  df %>%
    ggplot(aes(x = {{ response }}, y = b_value, colour = {{ response }})) +
    geom_jitter(alpha = 1 / 4, width = 1 / 4) +
    geom_boxplot(
      mapping = aes(group = {{ response }}, fill = {{ response }}),
      alpha = 8 / 10,
      width = 1 / 3,
      outlier.shape = NA,
      notch = TRUE
    ) +
    scale_y_continuous(breaks = c(0, 0.5, 1)) +
    facet_wrap(~name, nrow=1) +
    labs(
      x = element_blank(),
      y = "Proportion of feature for Blue"
    ) +
    theme(legend.position = "none") +
    coord_flip()
}


#' Make dataframe summary
#'
#' @param df Dataframe containing features (tibble)
#'
#' @return Dataframe of summary statistics for each numeric column (tibble)
make_df_summary <- function(df) {
  df <- df %>%
    select_if(is.numeric) %>%
    pivot_longer(everything()) %>%
    group_by(name) %>%
    summarise(
      min = min(value, na.rm = TRUE),
      mean = mean(value, na.rm = TRUE),
      max = max(value, na.rm = TRUE),
      qt_25 = quantile(value, 0.25),
      qt_50 = quantile(value, 0.50),
      qt_75 = quantile(value, 0.75),
      qt_99 = quantile(value, 0.99)
    )
  
  col_names <- df$name
  stat_names <- names(df)
  
  out <- as_tibble(df %>% t())
  names(out) <- col_names
  out$stat_name <- stat_names
  out <- out[-1, ]
  
  out %>%
    select(stat_name, all_of(col_names))
}

#' Main
#' 
#' To run all functions and perform EDA analysis.
#'
#' @param X_train_path The path to X_training csv file (string)
#' @param y_train_path The path to y_training csv file (string)
#' @param out_dir The path to directory to output results
#'
#' @return Does not return any object
main <- function(X_train_path, y_train_path, out_dir){
  
  print("Running eda tests...")
  eda_tests(X_train_path, y_train_path)
  
  print("Loading DataFrame...")
  df <- get_df(X_train_path, y_train_path)
  
  #////////////////////////////////////
  # Feature seleciton
  #////////////////////////////////////
  
  striking_features <- c("sig_str_att", "sig_str_landed",
                         "total_str_att", "total_str_landed")
  
  ground_features <- c("td_att", "td_landed", "sub_att", "pass", "rev")
  
  attacks_to_features <- c("head_att", "head_landed", "body_att", "body_landed",
                           "leg_att", "leg_landed")
  
  attacks_from_features <- c("distance_att", "distance_landed", "clinch_att",
                             "clinch_landed", "ground_att", "ground_landed")
  
  #////////////////////////////////////
  # Write plots
  #////////////////////////////////////
  print("Creating plots...")
  ggsave(paste0(out_dir, "fig_eda_01_corplot.png"),
         make_cor_plot(df = df))
  print("Created correlation plot...")
  
  ggsave(paste0(out_dir, "fig_eda_02_striking_features_relationship.png"),
         height = 4, width = 6, units = "in",
         make_box_jitter_plot(df = df, response = blue_win, striking_features))
  
  ggsave(paste0(out_dir, "fig_eda_03_ground_features_relationship.png"),
         height = 4, width = 6, units = "in",
         make_box_jitter_plot(df = df, response = blue_win, ground_features))
  
  ggsave(paste0(out_dir, "fig_eda_04_attacks_to_features_relationship.png"),
         height = 4, width = 6, units = "in",
         make_box_jitter_plot(df = df, response = blue_win, attacks_to_features))
  
  ggsave(paste0(out_dir, "fig_eda_05_attacks_from_features_relationship.png"),
         height = 4, width = 6, units = "in",
         make_box_jitter_plot(df = df, response = blue_win, attacks_from_features))

  #////////////////////////////////////
  # Write tables
  #////////////////////////////////////
  print("Writing tables...")
  write_csv(make_df_summary(df = df), paste0(out_dir, "table_eda_01_summary_stats.csv"))
  
  
  print("Script complete!")
}

main(arguments$X_train_path, arguments$y_train_path, arguments$out_dir)
