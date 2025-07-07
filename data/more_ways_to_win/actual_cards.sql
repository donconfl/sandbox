CREATE TEMP TABLE actual_cards_selections AS
SELECT DISTINCT
    ramp_selection_id,
    event_name,
    market_name,
    event_scheduled_start_datetime
FROM omni_sportsbook.vw_sportsbook_summary
WHERE 
    1=1
    AND (market_name LIKE '%Player to be carded%'
        OR market_name LIKE '%Player Shown a Card%'
        OR market_name LIKE '%|Player to be carded|%'
        OR market_name LIKE '%|Player Shown a Card|%')
    AND placed_datetime >= '2024-08-01'::DATE
    AND placed_datetime < '2025-06-01'::DATE
    AND vertical_id = 1
    AND competition = 'English Premier League'
    AND revenue_gbp < 0;

CREATE TEMP TABLE actual_cards_winners AS
SELECT 
    -- ss.sportex_selection_id,
    -- ss.sportex_selection_name,
    ss.in_play_yn,
    ss.brand,
    SUM(ss.revenue_gbp) AS total_revenue,
    SUM(ss.volume_gbp) AS total_volume,
    (SUM(ss.revenue_gbp) / SUM(ss.volume_gbp)) AS margin_pct
FROM
    omni_sportsbook.vw_sportsbook_summary ss
JOIN
    actual_cards_selections acs
    ON acs.ramp_selection_id = ss.ramp_selection_id
WHERE
    1=1
    AND ss.placed_datetime >= '2024-08-01'::DATE
    AND ss.placed_datetime < '2025-06-01'::DATE
    AND ss.vertical_id = 1
    AND ss.competition = 'English Premier League'
GROUP BY
    -- ss.sportex_selection_id,
    -- ss.sportex_selection_name,
    ss.in_play_yn,
    ss.brand;

SELECT * FROM actual_cards_winners;