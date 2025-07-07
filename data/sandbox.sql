-- WITH card_markets AS (
SELECT 
        SUM(volume_gbp) AS vol,
        SUM(revenue_gbp) AS rev,
        SUM(revenue_gbp)/ SUM(volume_gbp) AS margin
FROM 
        omni_sportsbook.vw_sportsbook_summary
WHERE
    1=1
--     AND s.market_name LIKE '%Target%'
--     AND s.market_name != 'Player Headed Shots On Target'
--     AND s.market_group = 'Player Props'
--     AND s.market_name NOT LIKE '%Outside%'
    AND brand = 'PP'
        AND (sport_name LIKE '%Gaelic%' or sport_name LIKE '%gaelic%' or sport_name LIKE '%GAA%' or sport_name LIKE '%gaa%')
--     AND settled_datetime > '2024-01-01'::DATE
    AND settled_datetime > '2025-01-01'::DATE;
-- ),
-- supersub AS (
-- SELECT 
--         SUM(volume_gbp),
--         SUM(revenue_gbp)
-- FROM 
--         omni_sportsbook.vw_sportsbook_summary
-- WHERE
--     1=1
--     AND s.market_name LIKE '%Target%'
--     AND s.market_name != 'Player Headed Shots On Target'
--     AND s.market_group = 'Player Props'
--     AND s.market_name NOT LIKE '%Outside%'
--     AND brand = 'PP'
--     AND competition = 'English Premier League'
--     AND s.placed_datetime > '2024-08-01'::DATE
--     AND s.placed_datetime < '2025-06-01'::DATE
-- ),
