# `espnscrapeR-data`

This is a data-only companion to the [`espnscrapeR` package](https://jthomasmock.github.io/espnscrapeR/).

Data are stored in the data folder, available as `.csv` only for now. Data will be added weekly and accessed via `nflreadR`.

However, they can always be read in manually as so:

```
### Season = 1x row season per QB
### Weekly = 1x row per week per QB in each season

# NFL
nfl_qbr_season <- readr::read_csv("https://raw.githubusercontent.com/nflverse/espnscrapeR-data/master/data/qbr-nfl-season.csv")
nfl_qbr_weekly <- readr::read_csv("https://raw.githubusercontent.com/nflverse/espnscrapeR-data/master/data/qbr-nfl-weekly.csv")

# College
nfl_qbr_season <- readr::read_csv("https://raw.githubusercontent.com/nflverse/espnscrapeR-data/master/data/qbr-college-season.csv")
nfl_qbr_weekly <- readr::read_csv("https://raw.githubusercontent.com/nflverse/espnscrapeR-data/master/data/qbr-college-weekly.csv")
```

### QBR Explainer

Full details on total QBR as told by [ESPN](https://www.espn.com/blog/statsinfo/post/_/id/123701/how-is-total-qbr-calculated-we-explain-our-quarterback-rating). ESPN provides these values publicly on their website at [espn.com/nfl/qbr](https://www.espn.com/nfl/qbr)

> ### Examines all of a quarterback's contributions
>
>ESPN’s Total Quarterback Rating (Total QBR), which was released in 2011, has never claimed to be perfect, but unlike other measures of quarterback performance, it incorporates all of a quarterback’s contributions to winning, including how he impacts the game on passes, rushes, turnovers and penalties. Also, since QBR is built from the play level, it accounts for a team’s level of success or failure on every play to provide the proper context and then allocates credit to the quarterback and his teammate to produce a clearer measure of quarterback efficiency.
>
> ### Efficiency stat, not a value stat
> 
> This process of determining the EPA, dividing credit among the QB and his teammates and then determining the weight of play occurs for every play in which a quarterback is involved. All of these plays are then added together and divided by the total number of clutch-weighted plays to produce a per-play measure of QB efficiency.
> 
> That last piece is important! QBR is an efficiency stat similar to yards per play or yards per attempt.

### Data Dictionary

|variable      |class     |description |
|:-------------|:---------|:-----------|
|season        |double    | Season |
|season_type   |character | Season Type either 'Regular' or 'Playoffs' |
|game_week     |character | Game Week will be "Season Total"" for season data|
|team_abb      |character | Team name abbreviation|
|player_id     |double    | ESPN Player ID |
|short_name    |character | Player Short Name |
|rank          |double    | QBR Rank |
|qbr_total     |double    | QBR Total score - Adjusted Total Quarterback Rating, which values the quarterback on all play types on a 0-100 scale adjusted for the strength of opposing defenses faced. |
|pts_added     |double    | Points added - Number of points contributed by a quarterback, accounting for QBR and how much he plays, above the level of an average quarterback |
|qb_plays      |double    | QB plays - Plays on which the QB has a non-zero expected points contribution. Includes most plays that are not handoffs |
|epa_total     |double    | Expected Points Added - Total expected points added with low leverage plays, according to ESPN Win Probability model, down-weighted. |
|pass          |double    | Pass - Expected points added on pass attempts with low leverage plays down-weighted |
|run           |double    | Run - Clutch-weighted expected points added through rushes |
|exp_sack      |double    | EPA sacks - Expected points added on sacks with low leverage plays down-weighted |
|penalty       |double    | Penalty - Expected points added on penalties with low leverage plays down-weighted |
|qbr_raw       |double    | Raw Total Quarterback Rating, which values quarterback on all play types on a 0-100 scale (not adjusted for opposing defenses faced) |
|sack          |double    | QBR sack EPA |
|first_name    |character | QBs First Name |
|last_name     |character | QBs Last Name |
|name          |character | QBs Full Name |
|headshot_href |character | Headshot URL/href |
|team          |character | Team Full Name | 
