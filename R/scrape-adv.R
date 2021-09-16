suppressPackageStartupMessages({
  library(tidyverse)
  library(dplyr)
  library(stringr)
  library(tidyr)
  library(glue)
  library(rvest)
  library(janitor)
  library(readr)
})

get_game_ids <- function(){
  raw_url_adv <- glue::glue("https://www.pro-football-reference.com/boxscores/")

  raw_html <- read_html(raw_url_adv)

  game_week <<- raw_html %>%
    html_node("#content > div.section_heading > h2") %>%
    html_text()

  all_urls <- raw_html %>%
    html_node("#content") %>%
    html_nodes("a") %>%
    html_attr("href") %>%
    str_subset("boxscores") %>%
    str_remove("boxscores") %>%
    str_remove_all("/") %>%
    str_subset("[0-9]+") %>%
    str_remove(".htm")

  all_urls

}

all_urls <- get_game_ids()

adv_stats <- function(game_id){

  cat(game_id, "\n")

  raw_boxscores <- read_html(glue::glue("https://www.pro-football-reference.com/boxscores/{game_id}.htm"))

  read_advanced <- function(adv_stat){

    raw_adv_html <- raw_boxscores %>%
      html_nodes(xpath = '//comment()') %>%
      html_text() %>%
      paste(collapse = '') %>%
      read_html() %>%
      html_node(glue::glue("#div_{adv_stat}_advanced"))

    raw_table <- html_table(raw_adv_html) %>%
      janitor::clean_names() %>%
      filter(tm != "Tm")

    raw_players <- raw_adv_html %>%
      html_nodes("a") %>%
      html_attr("href") %>%
      str_subset("players") %>%
      str_remove("/players/[A-Z]/") %>%
      str_remove(".htm")

    suppressMessages(
      raw_table %>%
        mutate(player_id = raw_players, .after = player) %>%
        mutate(adv_stat = adv_stat, .after = player)
    ) %>%
      mutate(across(5:last_col(), ~str_remove(.x, "%") %>% as.double()))
    # readr::type_convert()
  }

  raw_def <- read_advanced("defense") %>% mutate(game_id = game_id)
  raw_pass <- read_advanced("passing") %>% mutate(game_id = game_id)
  raw_rush <- read_advanced("rushing") %>% mutate(game_id = game_id)
  raw_rec <- read_advanced("receiving") %>% mutate(game_id = game_id)

  list(raw_def = raw_def, raw_pass = raw_pass, raw_rush = raw_rush, raw_rec = raw_rec)

}

all_data <- map(all_urls, adv_stats)


# Defense -----------------------------------------------------------------


def_data <- read_rds("data/adv-def-boxscore-2021.rds")

bind_rows(
  def_data,
  all_data %>%
    map_dfr("raw_def")
) %>%
  mutate(week = game_week) %>%
  write_rds("data/adv-def-boxscore-2021.rds")


# Passing -----------------------------------------------------------------


pass_data <- read_rds("data/adv-pass-boxscore-2021.rds")

bind_rows(
  pass_data,
  all_data %>%
    map_dfr("raw_pass")
) %>%
  mutate(week = game_week) %>%
  write_rds("data/adv-pass-boxscore-2021.rds")

# Rushing -----------------------------------------------------------------


rush_data <- read_rds("data/adv-rush-boxscore-2021.rds")

bind_rows(
  rush_data,
  all_data %>%
    map_dfr("raw_rush")
) %>%
  mutate(week = game_week) %>%
  write_rds("data/adv-rush-boxscore-2021.rds")

# Receiving ---------------------------------------------------------------


rec_data <- read_rds("data/adv-rec-boxscore-2021.rds")

bind_rows(
  rec_data,
  all_data %>%
    map_dfr("raw_rec")
) %>%
  mutate(week = game_week) %>%
  write_rds("data/adv-rec-boxscore-2021.rds")
