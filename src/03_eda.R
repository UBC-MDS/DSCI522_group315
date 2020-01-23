# author: Sam Edwardes (DSCI_522_group_315)
# date: 2020-01-21

"
This script creates EDA plots and tables.

Usage: 03_eda.R --input_path=<input_path> --output_path=<output_path> --seed_num=<seed_num>

Options:
--input_path=<input_path>           The path of raw_total_fight_data.csv
--output_path=<output_path>         The path of the directory to save output to
--seed_num=<seed_num>               The seed to set random state

Example: Rscript src/02_preprocess_data.R --input_path=data/01_raw/raw_total_fight_data.csv --output_path=data/02_preprocessed/ --seed_num=1993
" -> doc

suppressPackageStartupMessages(library(tidyverse))

out_dir <- "analysis/figures/"

#////////////////////////////////////
# Feature seleciton
#////////////////////////////////////

striking_features <- c("sig_str_att", "sig_str_landed", "sig_str_pct",
  "total_str_att",  "total_str_landed")

ground_features <- c( "td_att", "td_landed", "td_pct", "sub_att", "pass", "rev")

attacks_to_features <- c("head_att", "head_landed", "body_att", "body_landed",
  "leg_att", "leg_landed")

attacks_from_features <- c("distance_att", "distance_landed", "clinch_att",
  "clinch_landed", "ground_att", "ground_landed")

#////////////////////////////////////
# Helper functions
#////////////////////////////////////

get_df <- function() {
  X_train <- read_csv("data/02_preprocessed/X_train.csv", col_types = cols())
  y_train <- read_csv("data/02_preprocessed/y_train.csv", col_types = cols())
  
  df <- bind_cols(X_train, y_train) %>%
    mutate(
      blue_win = if_else(winner == "Blue", 1, 0),
      winner = as_factor(winner)
    )
  
  df
}

make_cor_plot <- function() {
  cor_plot <- GGally::ggcorr(df, size = 3, hjust = 0.85, layout.exp = 2)
}

make_class_count_bar_plot <- function() {
  df %>%
    ggplot(aes(winner)) +
    geom_bar() +
    labs(title = "Winner Count",
         x = "Winner",
         y = "Count")
}

make_box_jitter_plot <- function(df, response, ...) {
  df <- df %>%
    select({{ response }}, ...) %>%
    pivot_longer(cols = -{{ response }}) %>%
    mutate(
      b_value = value,
      r_value = 1 - value,
      response = as.factor({{ response }})
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
    scale_x_continuous(breaks = c(0, 1)) +
    facet_wrap(~name) +
    labs(
      x = "Blue Winner?",
      y = "Proportion of feature for Blue"
    ) +
    coord_flip()
}

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
    select(stat_name, col_names)
}

main <- function(){
  
  df <- get_df()
  
  #////////////////////////////////////
  # Write plots
  #////////////////////////////////////
  ggsave(paste0(out_dir, "fig_eda_01_corplot.png"),
         make_cor_plot())
  
  ggsave(paste0(out_dir, "fig_eda_02_striking_features_relationship.png"),
         make_box_jitter_plot(df = df, response = blue_win, striking_features))
  
  ggsave(paste0(out_dir, "fig_eda_03_ground_features_relationship.png"),
         make_box_jitter_plot(df = df, response = blue_win, ground_features))
  
  ggsave(paste0(out_dir, "fig_eda_04_attacks_to_features_relationship.png"),
         make_box_jitter_plot(df = df, response = blue_win, attacks_to_features))
  
  ggsave(paste0(out_dir, "fig_eda_05_attacks_from_features_relationship.png"),
         make_box_jitter_plot(df = df, response = blue_win, attacks_from_features))

  #////////////////////////////////////
  # Write tables
  #////////////////////////////////////
  write_csv(make_df_summary(df), paste0(out_dir, "table_eda_01_summary_stats.csv"))
  
  
}

main()

