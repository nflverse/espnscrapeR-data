library(tidyverse)
library(glue)
library(espnscrapeR)

# Schedule -------------------------------------------------------------

sched_url <- "https://github.com/nflverse/nfldata/blob/master/data/games.rds?raw=true"

raw_sched <- readRDS(url(sched_url))

current_week <- raw_sched %>%
  select(week, gameday) %>%
  filter(gameday >= Sys.Date()) %>%
  distinct(week) %>%
  filter(week == min(week)) %>%
  pull()

cur_season <- raw_sched %>%
  filter(gameday >= Sys.Date()) %>%
  distinct(season) %>%
  pull()

espnscrapeR::scrape_espn_win_rate(season = cur_season) %>%
  mutate(week = 1) %>%
  write_csv("data/weekly-winrate.csv")
