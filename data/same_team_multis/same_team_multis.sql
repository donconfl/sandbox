CREATE TEMP TABLE unpivoted_teams_temp(
    bet_id BIGINT,
    leg_id VARCHAR(500),
    event_off_datetime TIMESTAMP,
    sgm_leg_yn CHAR(1),
    team_name VARCHAR(500),
    game_identifier VARCHAR(600) 
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
        sgm_multiple_yn,
        event_name,
        -- Unique game identifiers, to split out betbuilders
        CASE WHEN sgm_multiple_yn = 'Y' 
             THEN 'SGM_' || bet_id::VARCHAR || '_' || event_off_datetime::VARCHAR
             ELSE 'REG_' || leg_id::VARCHAR 
        END AS game_identifier,
        CASE
            WHEN POSITION(' v ' IN LOWER(event_name)) > 0 THEN ' v '
            WHEN POSITION(' vs ' IN LOWER(event_name)) > 0 THEN ' vs '
            WHEN POSITION(' @ ' IN LOWER(event_name)) > 0 THEN ' @ '
            ELSE ' v '
        END AS delimiter
    FROM
        omni_sportsbook.vw_sportsbook_summary
    WHERE
        1=1
        AND placed_datetime >= '2025-01-01'::DATE
        AND placed_datetime < CURRENT_DATE::DATE
        AND bet_type = 'Multiple'
        AND vertical_id = 1
        AND country_of_residence_name IN ('United Kingdom', 'Ireland')
        AND (
            LOWER(event_name) LIKE '% v %' 
            OR LOWER(event_name) LIKE '% vs %'
            OR LOWER(event_name) LIKE '% @ %'
        )
)
-- Extract first team
SELECT
    bet_id,
    leg_id,
    event_off_datetime,
    sgm_multiple_yn,
    TRIM(SPLIT_PART(LOWER(event_name), delimiter, 1)) AS team_name,
    game_identifier
FROM processed_events
WHERE TRIM(SPLIT_PART(LOWER(event_name), delimiter, 1)) != ''

UNION ALL

-- Extract second team  
SELECT
    bet_id,
    leg_id,
    event_off_datetime,
    sgm_multiple_yn,
    TRIM(SPLIT_PART(LOWER(event_name), delimiter, 2)) AS team_name,
    game_identifier
FROM processed_events
WHERE TRIM(SPLIT_PART(LOWER(event_name), delimiter, 2)) != '';

-- Team Occurences
CREATE TEMP TABLE bet_team_analysis_temp
DISTKEY(bet_id)
SORTKEY(bet_id, team_name)
AS
SELECT
    bet_id,
    team_name,
    -- stm = same team multi
    COUNT(DISTINCT game_identifier) as stm_occurrences,
    COUNT(*) as total_team_legs
FROM
    unpivoted_teams_temp 
GROUP BY
    bet_id,
    team_name
HAVING
    COUNT(DISTINCT game_identifier) > 1; 

CREATE TEMP TABLE qualifying_legs_temp
DISTKEY(bet_id)
SORTKEY(bet_id, leg_id)
AS
SELECT DISTINCT
    ut.bet_id,
    ut.leg_id,
    ut.sgm_leg_yn
FROM
    unpivoted_teams_temp ut
INNER JOIN
    bet_team_analysis_temp bta
ON 
    ut.bet_id = bta.bet_id 
AND 
    ut.team_name = bta.team_name;

-- Trading figures, split as we need to aggregate BBs and leave normal legs alone
CREATE TEMP TABLE financial_data_temp
DISTKEY(bet_id)
SORTKEY(bet_id)
AS
WITH sgm_games_aggregated AS (
    SELECT
        ss.bet_id,
        'SGM_' || ss.bet_id::VARCHAR || '_' || ss.event_off_datetime::VARCHAR as game_identifier,
        SUM(ss.volume_gbp) as volume_gbp,
        SUM(ss.revenue_gbp) as revenue_gbp,
        MAX(ss.placed_datetime) as placed_datetime,
        ss.brand
    FROM
        omni_sportsbook.vw_sportsbook_summary ss
    JOIN
        qualifying_legs_temp qlt 
    ON 
        ss.leg_id = qlt.leg_id 
    AND 
        ss.bet_id = qlt.bet_id 
    WHERE
        1=1
        AND ss.sgm_multiple_yn  = 'Y'
        AND ss.placed_datetime >= '2025-01-01'::DATE
        AND ss.placed_datetime  < CURRENT_DATE::DATE
        AND ss.bet_type         = 'Multiple'
        AND ss.vertical_id      = 1
        AND country_of_residence_name IN ('United Kingdom', 'Ireland')
    GROUP BY
        ss.bet_id,
        ss.event_off_datetime,
        ss.brand
),
regular_legs AS (
    -- Regular legs - no aggregation needed
    SELECT
        ss.bet_id,
        'REG_' || ss.leg_id::VARCHAR as game_identifier,
        ss.volume_gbp,
        ss.revenue_gbp,
        ss.placed_datetime,
        ss.brand
    FROM
        omni_sportsbook.vw_sportsbook_summary ss
    INNER JOIN
        qualifying_legs_temp qlt 
    ON 
        ss.leg_id = qlt.leg_id 
    AND 
        ss.bet_id = qlt.bet_id
    WHERE
        1=1
        AND ss.sgm_leg_yn != 'Y'
        AND ss.placed_datetime >= '2025-01-01'::DATE
        AND ss.placed_datetime < CURRENT_DATE::DATE
        AND ss.bet_type = 'Multiple'
        AND ss.vertical_id = 1
        AND country_of_residence_name IN ('United Kingdom', 'Ireland')
)
-- Combine BB's and regular legs
SELECT 
    bet_id, 
    volume_gbp, 
    revenue_gbp, 
    placed_datetime,
    brand
FROM 
    sgm_games_aggregated
UNION ALL
SELECT 
    bet_id, 
    volume_gbp, 
    revenue_gbp, 
    placed_datetime, 
    brand 
FROM regular_legs;

-- Final analysis
SELECT
    EXTRACT(YEAR FROM fd.placed_datetime) AS bet_year,
    brand,
    -- core
    COUNT(DISTINCT fd.bet_id) AS num_stm_bets,
    SUM(fd.revenue_gbp) AS total_revenue,
    SUM(fd.volume_gbp) AS total_volume,
    CASE 
        WHEN SUM(fd.volume_gbp) != 0 
        THEN SUM(fd.revenue_gbp) / SUM(fd.volume_gbp) 
        ELSE 0 
    END AS margin,
    
    -- Distribution of maximum team occurrences across games per bet
    COUNT(DISTINCT CASE WHEN bta.stm_occurrences = 2 THEN fd.bet_id END) AS occurences_2,
    COUNT(DISTINCT CASE WHEN bta.stm_occurrences = 3 THEN fd.bet_id END) AS occurences_3,
    COUNT(DISTINCT CASE WHEN bta.stm_occurrences = 4 THEN fd.bet_id END) AS occurences_4,
    COUNT(DISTINCT CASE WHEN bta.stm_occurrences >= 5 THEN fd.bet_id END) AS occurences_5_plus

FROM
    financial_data_temp fd
INNER JOIN
    bet_team_analysis_temp bta 
ON 
    fd.bet_id = bta.bet_id
GROUP BY
    EXTRACT(YEAR FROM fd.placed_datetime),
    brand
ORDER BY
    bet_year;

-- -- Optional: Team-level insights for teams appearing across multiple games
-- SELECT
--     bta.team_name,
--     COUNT(*) as total_team_occurrences,
--     COUNT(DISTINCT bta.bet_id) as bets_where_team_in_multiple_games,
--     AVG(bta.stm_occurrences) as avg_occurences,
--     MAX(bta.stm_occurrences) as max_occurences,
--     COUNT(DISTINCT bta.team_name) AS total_teams,
--     COUNT(bta.team_name) AS total_teams,

-- FROM
--     bet_team_analysis_temp bta
-- GROUP BY
--     bta.team_name
-- HAVING
--     COUNT(DISTINCT bta.bet_id) >= 5  -- Teams with at least 5 qualifying bets
-- ORDER BY
--     bets_where_team_in_multiple_games DESC
-- LIMIT 30;