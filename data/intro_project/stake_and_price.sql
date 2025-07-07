CREATE TEMPORARY TABLE top_10_sports AS
WITH sbk_totals AS (
    SELECT
        sport_name,
        SUM(volume_gbp)                         AS total_volume
    FROM
        omni_sportsbook.vw_sportsbook_summary
    WHERE
        settled_datetime >= '2023-01-01'
        AND settled_datetime <= '2023-12-31'
    GROUP BY
        sport_name 
    ORDER BY
        total_volume DESC
    LIMIT 10 
),
ranked_sports AS (
    SELECT
        SUM(ss.revenue_gbp)                           AS total_revenue,      
        SUM(ss.volume_gbp)                            AS total_volume,         
        (SUM(ss.revenue_gbp) / SUM(ss.volume_gbp))    AS margin_pct,
        ss.sport_name,
        ss.brand,
        DATE_TRUNC('year', ss.settled_datetime)       AS year_number
    FROM
        omni_sportsbook.vw_sportsbook_summary ss
    JOIN 
        sbk_totals sbk ON ss.sport_name = sbk.sport_name
    WHERE
        1=1
        AND ss.settled_datetime >= '2023-01-01'
        AND ss.settled_datetime <= '2023-12-31'
    GROUP BY
        ss.sport_name,
        DATE_TRUNC('year', ss.settled_datetime),
        ss.brand
    ORDER BY 
        total_volume DESC
)
SELECT
    sport_name,
    brand,
    EXTRACT(YEAR FROM year_number)              AS  year_number,
    total_revenue,
    total_volume,
    margin_pct
FROM
    ranked_sports;

CREATE TEMPORARY TABLE football_margin AS
With market_group AS (
    SELECT
        SUM(ss.revenue_gbp)                           AS total_revenue,      
        SUM(ss.volume_gbp)                            AS total_volume,         
        (SUM(ss.revenue_gbp) / SUM(ss.volume_gbp))    AS margin_pct,
        ss.market_group,
        DATE_TRUNC('year', ss.settled_datetime)       AS year_number,
        ss.in_play_yn
    FROM
        omni_sportsbook.vw_sportsbook_summary ss
    WHERE
        1=1
        AND ss.settled_datetime >= '2024-01-01'
        AND ss.settled_datetime <= '2024-12-31'
        AND ss.sport_name = 'Soccer'
        AND ss.brand = 'PP'
    GROUP BY
        DATE_TRUNC('year', ss.settled_datetime),
        ss.market_group,
        ss.in_play_yn
    ORDER BY 
        total_volume DESC
)
SELECT
    market_group,
    EXTRACT(YEAR FROM year_number)              AS  year_number,
    total_revenue,
    total_volume,
    margin_pct,
    in_play_yn
FROM
    market_group
WHERE
    market_group NOT IN ('One minute', 'Match Betting', 'Manually Loaded', 'Commercial Specials', 'Penalty', 'Interval', 'Transfer & Manager Specials')
ORDER BY
    total_volume;


SELECT * FROM football_margin;
-- CREATE TEMPORARY TABLE buckets AS
-- SELECT
--     sport_name,
--     brand,
--     bet_type,
--     market_group,
--     CASE
--         WHEN stake < 1 THEN '< £1'
--         WHEN stake >= 1 AND stake <= 5 THEN '£1 - £5'
--         WHEN stake > 5 AND stake <= 25 THEN '>£5 - £25'
--         WHEN stake > 25 AND stake <= 100 THEN '>£25 - £100'
--         WHEN stake > 100 THEN '£100+'
--         ELSE 'Other Stake' -- Optional: for any NULL or unexpected stake values
--     END AS stake_size,
--     CASE
--         WHEN leg_price_actual <= 1.1233 THEN 'Decile 1 (<= 1.1233)'
--         WHEN leg_price_actual > 1.1233 AND leg_price_actual <= 1.3333 THEN 'Decile 2 (>1.1233 - 1.3333)'
--         WHEN leg_price_actual > 1.3333 AND leg_price_actual <= 1.5333 THEN 'Decile 3 (>1.3333 - 1.5333)'
--         WHEN leg_price_actual > 1.5333 AND leg_price_actual <= 1.7500 THEN 'Decile 4 (>1.5333 - 1.7500)'
--         WHEN leg_price_actual > 1.7500 AND leg_price_actual <= 2.0000 THEN 'Decile 5 (>1.7500 - 2.0000)'
--         WHEN leg_price_actual > 2.0000 AND leg_price_actual <= 2.2500 THEN 'Decile 6 (>2.0000 - 2.2500)'
--         WHEN leg_price_actual > 2.2500 AND leg_price_actual <= 2.8700 THEN 'Decile 7 (>2.2500 - 2.8700)'
--         WHEN leg_price_actual > 2.8700 AND leg_price_actual <= 4.2000 THEN 'Decile 8 (>2.8700 - 4.2000)'
--         WHEN leg_price_actual > 4.2000 AND leg_price_actual <= 8.0000 THEN 'Decile 9 (>4.2000 - 8.0000)'
--         WHEN leg_price_actual > 8.0000 THEN 'Decile 10 (> 8.0000)'
--         ELSE 'Other Price' -- Optional: for any NULL or unexpected leg_price_actual values
--     END AS price_range,
--     COUNT(bet_id) AS num_bets,
--     SUM(revenue_gbp)                        AS total_revenue,      
--     SUM(volume_gbp)                         AS total_volume,         
--     (SUM(revenue_gbp) / SUM(volume_gbp))    AS margin_pct,
--     (SUM(volume_gbp) - SUM(revenue_gbp))    AS total_margin
-- FROM
--     omni_sportsbook.vw_sportsbook_summary
-- WHERE
--     placed_datetime >= '2023-01-01'
--     AND placed_datetime < '2023-02-28'
-- GROUP BY
--     1,2,3,4;
