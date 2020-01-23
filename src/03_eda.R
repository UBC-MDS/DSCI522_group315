suppressPackageStartupMessages(library(tidyverse))

out_dir <- "analysis/figures/"

main <- function(){
  
}

X_train <- read_csv("data/02_preprocessed/X_train.csv", col_types = cols())
y_train <- read_csv("data/02_preprocessed/y_train.csv", col_types = cols())

df <- bind_cols(X_train, y_train) %>%
  mutate(
    blue_win = if_else(winner == "Blue", 1, 0),
    winner = as_factor(winner)
  )

# explore the correlation between features and the response
cor_plot <- GGally::ggcorr(df, size = 3, hjust = 0.85, layout.exp = 2)
ggsave(paste0(out_dir, "fig_eda_01_corplot.png"))

# check if there is any class inbalance
df %>%
  ggplot(aes(winner)) +
  geom_bar()



plot_feature_vs_response <- function(df, response, ...) {
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

striking_features <- c(
  "sig_str_att",
  "sig_str_landed",
  "sig_str_pct",
  "total_str_att",
  "total_str_landed"
)

ground_features <- c(
  "td_att",
  "td_landed",
  "td_pct",
  "sub_att",
  "pass",
  "rev"
)

attacks_to_features <- c(
  "head_att",
  "head_landed",
  "body_att",
  "body_landed",
  "leg_att",
  "leg_landed"
)

attacks_from_features <- c(
  "distance_att",
  "distance_landed",
  "clinch_att",
  "clinch_landed",
  "ground_att",
  "ground_landed"
)

striking_feature_plot <- plot_feature_vs_response(
  df = df,
  response = blue_win,
  striking_features
)


ground_feature_plot <- plot_feature_vs_response(
  df = df,
  response = blue_win,
  ground_features
)


attacks_to_plot <- plot_feature_vs_response(
  df = df,
  response = blue_win,
  attacks_to_features
)


attacks_from_plot <- plot_feature_vs_response(
  df = df,
  response = blue_win,
  attacks_from_features
)


df_summary <- function(df) {
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

df_summary(df)
