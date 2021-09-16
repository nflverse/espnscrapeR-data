suppressPackageStartupMessages({
  library(tidyverse)
  library(glue)
  library(espnscrapeR)
})


# Schedule -------------------------------------------------------------


sched_url <- "https://github.com/nflverse/nfldata/blob/master/data/games.rds?raw=true"

raw_sched <- readRDS(url(sched_url))


current_week <- raw_sched %>%
  select(week, gameday) %>%
  filter(gameday >= Sys.Date()) %>%
  distinct(week) %>%
  filter(week == min(week)) %>%
  pull()

current_week


# FPI ---------------------------------------------------------------------

all_fpi <- read_csv("data/fpi-weekly-2021.csv")
all_proj <- read_csv("data/proj-weekly-2021.csv")
all_eff <- read_csv("data/fpi-eff-weekly-2021.csv")

raw_fpi <- espnscrapeR::scrape_fpi(season = 2021) %>%
  mutate(week = current_week, .after = season)
raw_eff <- espnscrapeR::scrape_fpi(season = 2021, stat = "EFF") %>%
  mutate(week = current_week, .after = season)
raw_proj <- espnscrapeR::scrape_fpi(season = 2021, stat = "PROJ") %>%
  mutate(week = current_week, .after = season)

all_proj %>%
  bind_rows(raw_proj) %>%
  write_csv("data/proj-weekly-2021.csv")

all_fpi %>%
  bind_rows(raw_fpi)
  write_csv("data/fpi-weekly-2021.csv")

all_fpi %>%
  bind_rows(raw_eff) %>%
  write_csv("data/fpi-eff-weekly-2021.csv")
