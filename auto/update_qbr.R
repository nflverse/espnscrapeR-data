# piggyback::pb_release_create(
#   repo = "nflverse/espnscrapeR-data",
#   tag = "raw_qbr",
#   body = "ESPN QBR Data by week and season"
# )

if(Sys.getenv("NFLVERSE_REBUILD", "false") == "true"){
  seasons_to_scrape <- 2006:nflreadr::most_recent_season()
} else {
  seasons_to_scrape <- nflreadr::most_recent_season()
}

options(nflreadr.verbose = FALSE)

# Helper Functions --------------------------------------------------------

espn_scrape_season_qbr <- function(season = nflreadr::most_recent_season()){
  season_types <- c("Regular", "Playoffs")
  out <- purrr::map(
    season_types,
    purrr::possibly(
      .f = function(stype, season){
        espnscrapeR::get_nfl_qbr(season = season, season_type = stype)
      },
      otherwise = tibble::tibble(),
      quiet = FALSE
    ),
    season = season
  ) |>
    purrr::list_rbind()

  out
}

espn_scrape_weekly_qbr <- function(season = nflreadr::most_recent_season()){
  reg <- tidyr::crossing(season = season, season_type = "Regular", week = 1:18)
  post <- tidyr::crossing(season = season, season_type = "Playoffs", week = 1:4)
  map_over <- rbind(reg, post)
  out <- purrr::pmap(
    map_over,
    purrr::possibly(
      .f = function(season, season_type, week){
        Sys.sleep(1)
        espnscrapeR::get_nfl_qbr(season = season, week = week, season_type = season_type)
      },
      otherwise = tibble::tibble(),
      quiet = FALSE
    )
  ) |>
    purrr::list_rbind()

  out
}


# Save Season QBR and Weekly QBR ------------------------------------------

dir.create(file.path(getwd(), "auto", "upload"))

purrr::walk(
  seasons_to_scrape,
  function(s){
    dat <- espn_scrape_season_qbr(s)
    save_to <- file.path("auto", "upload", paste0("qbr_", s, ".rds"))
    saveRDS(dat, save_to)
  }
)

purrr::walk(
  seasons_to_scrape,
  function(s){
    dat <- espn_scrape_weekly_qbr(s)
    save_to <- file.path("auto", "upload", paste0("qbr_weekly_", s, ".rds"))
    saveRDS(dat, save_to)
  }
)


# Upload QBR Data to raw release ------------------------------------------

to_upload <- list.files(
  path = file.path("auto", "upload"),
  pattern = "qbr",
  full.names = TRUE
)

nflversedata::nflverse_upload(
  repo = "nflverse/espnscrapeR-data",
  tag = "raw_qbr",
  files = to_upload
)


# Combine data and release to nflverse-data -------------------------------

qbr_combined_season_level <-
  paste0(
    "https://github.com/nflverse/espnscrapeR-data/releases/download/raw_qbr/qbr_",
    2006:nflreadr::most_recent_season(),
    ".rds"
  ) |>
  purrr::map(nflreadr::rds_from_url, .progress = TRUE) |>
  purrr::list_rbind()

nflversedata::nflverse_save(
  data_frame = qbr_combined_season_level,
  file_name = "qbr_season_level",
  nflverse_type = "ESPN QBR",
  release_tag = "espn_data"
)

qbr_combined_week_level <-
  paste0(
    "https://github.com/nflverse/espnscrapeR-data/releases/download/raw_qbr/qbr_weekly_",
    2006:nflreadr::most_recent_season(),
    ".rds"
  ) |>
  purrr::map(nflreadr::rds_from_url, .progress = TRUE) |>
  purrr::list_rbind()

nflversedata::nflverse_save(
  data_frame = qbr_combined_week_level,
  file_name = "qbr_week_level",
  nflverse_type = "ESPN QBR",
  release_tag = "espn_data"
)


# Save to git history for compatibility in 2023 ---------------------------
# DELETE THIS AFTER THE 2023 SEASON!

saveRDS(qbr_combined_season_level, "data/qbr-nfl-season.rds")
readr::write_csv(qbr_combined_season_level, "data/qbr-nfl-season.csv")

saveRDS(qbr_combined_week_level, "data/qbr-nfl-weekly.rds")
readr::write_csv(qbr_combined_week_level, "data/qbr-nfl-weekly.csv")

