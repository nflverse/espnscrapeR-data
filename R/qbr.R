suppressPackageStartupMessages({
  library(tidyverse)
  library(glue)
  library(espnscrapeR)
})


# NFL Section -------------------------------------------------------------


sched_url <- "https://github.com/nflverse/nfldata/blob/master/data/games.rds?raw=true"

raw_sched <- readRDS(url(sched_url))

current_week <- raw_sched %>%
  select(week, gameday) %>%
  filter(gameday >= Sys.Date()) %>%
  distinct(week) %>%
  filter(week == min(week)) %>%
  pull()

current_week

raw_data_season <- read_rds("data/qbr-nfl-season.rds")
raw_data_week <- readRDS("data/qbr-nfl-weekly.rds")

raw_qbr <- espnscrapeR::get_nfl_qbr(season = 2021, week = current_week)
raw_qbr_season <- espnscrapeR::get_nfl_qbr(season = 2021)

comb_season_qbr <- raw_data_season %>%
  filter(season != 2021) %>%
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

qbr_coll_season <- get_college_qbr(season = 2021, type = "season")
qbr_coll_week <- get_college_qbr(season = 2021, type = "weekly")

comb_coll_season <- raw_college_season %>%
  filter(season != 2021) %>%
  bind_rows(qbr_coll_season)

comb_coll_week <- raw_college_week %>%
  filter(season != 2021) %>%
  bind_rows(qbr_coll_week)

comb_coll_week %>% write_rds("data/qbr-college-weekly.rds")
comb_coll_week %>% write_csv("data/qbr-college-weekly.csv")

comb_coll_season %>% write_rds("data/qbr-college-season.rds")
comb_coll_season %>% write_csv("data/qbr-college-season.csv")

