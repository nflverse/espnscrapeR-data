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

all_fpi <- read_csv("data/fpi-weekly-2022.csv")
all_proj <- read_csv("data/proj-weekly-2022.csv")
all_eff <- read_csv("data/fpi-eff-weekly-2022.csv")

raw_fpi <- espnscrapeR::scrape_fpi(season = 2022) %>%
  mutate(week = current_week - 1, .after = season)
raw_eff <- espnscrapeR::scrape_fpi(season = 2022, stat = "EFF") %>%
  mutate(week = current_week - 1, .after = season)
raw_proj <- espnscrapeR::scrape_fpi(season = 2022, stat = "PROJ") %>%
  mutate(week = current_week - 1, .after = season)

out_proj <- all_proj %>%
  bind_rows(raw_proj)

write_csv(out_proj, "data/proj-weekly-2022.csv")

out_fpi <- all_fpi %>%
  bind_rows(raw_fpi)

write_csv(out_fpi, "data/fpi-weekly-2022.csv")

out_eff <- all_eff %>%
  bind_rows(raw_eff)

write_csv(out_eff, "data/fpi-eff-weekly-2022.csv")
