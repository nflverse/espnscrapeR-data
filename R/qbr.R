suppressPackageStartupMessages({
  library(tidyverse)
  library(glue)
  library(espnscrapeR)
  library(nflreadr)
})


# NFL Section -------------------------------------------------------------


raw_sched <- nflreadr::load_schedules()

current_week <- raw_sched %>%
  select(week, gameday) %>%
  filter(gameday >= Sys.Date()) %>%
  distinct(week) %>%
  filter(week == min(week)) %>%
  pull()

current_week

current_season <- nflreadr::most_recent_season()

raw_data_season <- read_rds("data/qbr-nfl-season.rds")
raw_data_week <- readRDS("data/qbr-nfl-weekly.rds")

raw_qbr <- espnscrapeR::get_nfl_qbr(season = current_season, week = current_week - 1)
raw_qbr_season <- espnscrapeR::get_nfl_qbr(season = current_season)

comb_season_qbr <- raw_data_season %>%
  filter(season != current_season) %>%
  bind_rows(raw_qbr_season)

comb_weekly_qbr <- raw_data_week %>%
  bind_rows(raw_qbr)

comb_weekly_qbr %>% write_rds("data/qbr-nfl-weekly.rds")
comb_weekly_qbr %>% write_csv("data/qbr-nfl-weekly.csv")

comb_season_qbr %>% write_rds("data/qbr-nfl-season.rds")
comb_season_qbr %>% write_csv("data/qbr-nfl-season.csv")


# College Section ---------------------------------------------------------

raw_college_season <- read_rds("data/qbr-college-season.rds")
raw_college_week <- readRDS("data/qbr-college-season.rds")

qbr_coll_season <- get_college_qbr(season = current_season, type = "season")
qbr_coll_week <- get_college_qbr(season = current_season, type = "weekly")

comb_coll_season <- raw_college_season %>%
  filter(season != current_season) %>%
  bind_rows(qbr_coll_season)

comb_coll_week <- raw_college_week %>%
  filter(season != current_season) %>%
  bind_rows(qbr_coll_week)

comb_coll_week %>% write_rds("data/qbr-college-weekly.rds")
comb_coll_week %>% write_csv("data/qbr-college-weekly.csv")

comb_coll_season %>% write_rds("data/qbr-college-season.rds")
comb_coll_season %>% write_csv("data/qbr-college-season.csv")


