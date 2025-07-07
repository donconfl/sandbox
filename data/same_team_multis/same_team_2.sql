CREATE TEMP TABLE unpivoted_teams_temp(
    bet_id BIGINT,
    leg_id VARCHAR(500),
    event_off_datetime TIMESTAMP,
    sgm_leg_yn CHAR(1),
    team_name VARCHAR(500)
)
DISTKEY(bet_id)     
SORTKEY(bet_id, team_name); 

-- Insert statement
INSERT INTO unpivoted_teams_temp
WITH processed_events AS (
    SELECT
        bet_id,
        leg_id,
        event_off_datetime,
        sgm_leg_yn,
        event_name,
        CASE
            WHEN LOWER(event_name) LIKE '% v %' THEN ' v '
            ELSE ' vs '
        END AS delimiter
    FROM
        omni_sportsbook.vw_sportsbook_summary
    WHERE
        1=1
        AND placed_datetime >= '2022-01-01'::DATE
        aND placed_datetime < '2023-01-01'::DATE
        AND bet_type        = 'Multiple'
        AND vertical_id     = 1
        AND (LOWER(event_name) LIKE '% v %' OR LOWER(event_name) LIKE '% vs %')
)
SELECT
    bet_id,
    leg_id,
    event_off_datetime,
    sgm_leg_yn,
    TRIM(SPLIT_PART(LOWER(event_name), delimiter, 1)) AS team_name
FROM
    processed_events
UNION ALL
SELECT
    bet_id,
    leg_id,
    event_off_datetime,
    sgm_leg_yn,
    TRIM(SPLIT_PART(LOWER(event_name), delimiter, 2)) AS team_name
FROM
    processed_events;

-- results of the analysis
CREATE TEMP TABLE bet_team_analysis_temp
DISTKEY(bet_id)
SORTKEY(bet_id)
AS
SELECT
    bet_id,
    leg_id,
    team_name,
    COUNT(DISTINCT CASE WHEN sgm_leg_yn = 'Y' THEN event_off_datetime::VARCHAR ELSE leg_id::VARCHAR END) as same_multi_occurences
FROM
    unpivoted_teams_temp 
GROUP BY
    bet_id,
    leg_id,
    team_name
HAVING
    COUNT(DISTINCT CASE WHEN sgm_leg_yn = 'Y' THEN event_off_datetime::VARCHAR ELSE leg_id::VARCHAR END) > 1;

-- lookup table of leg_ids
CREATE TEMP TABLE qualifying_leg_ids_temp
DISTKEY(leg_id)
SORTKEY(leg_id)
AS
SELECT
    leg_id,
    MAX(same_multi_occurences) AS max_occurrences_for_bet,
    SUM(same_multi_occurences) AS total_occurrences_in_bet
FROM
    bet_team_analysis_temp
GROUP BY
    leg_id;

-- Final query
SELECT
    EXTRACT(YEAR FROM ss.placed_datetime) AS bet_year,
    COUNT(DISTINCT ss.bet_id) AS num_bets_with_same_team,
    SUM(ss.revenue_gbp) AS total_revenue,
    SUM(ss.volume_gbp) AS total_volume,
    SUM(ss.revenue_gbp) / NULLIF(SUM(ss.volume_gbp), 0) AS margin,
    SUM(qbi.total_occurrences_in_bet) AS total_unique_same_team_occurences,
    COUNT(DISTINCT CASE WHEN qbi.max_occurrences_for_bet = 2 THEN ss.bet_id END) AS same_team_2_occurrences,
    COUNT(DISTINCT CASE WHEN qbi.max_occurrences_for_bet = 3 THEN ss.bet_id END) AS same_team_3_occurrences,
    COUNT(DISTINCT CASE WHEN qbi.max_occurrences_for_bet = 4 THEN ss.bet_id END) AS same_team_4_occurrences,
    COUNT(DISTINCT CASE WHEN qbi.max_occurrences_for_bet >= 5 THEN ss.bet_id END) AS same_team_5_plus_occurrences
FROM
    omni_sportsbook.vw_sportsbook_summary ss
JOIN
    qualifying_leg_ids_temp qbi ON ss.leg_id = qbi.leg_id
WHERE
    1=1
    AND ss.placed_datetime >= '2022-01-01'::DATE
    AND placed_datetime     < '2023-01-01'::DATE
    AND ss.bet_type         = 'Multiple'
    AND ss.vertical_id      = 1
GROUP BY
    bet_year
ORDER BY
    bet_year;