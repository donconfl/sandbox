CREATE TEMP TABLE player_lookups 
DISTSTYLE EVEN 
SORTKEY (date_val, event_name) AS
SELECT '2024-09-14'::DATE as date_val, 'Brighton v Ipswich' as event_name, 'BART VERBRUGGEN' as player_name, 'Brighton' as team
UNION ALL SELECT '2024-09-28'::DATE, 'Brentford v West Ham', 'ANDY IRVING', 'West Ham'
UNION ALL SELECT '2024-10-27'::DATE, 'Arsenal v Liverpool', 'GABRIEL JESUS', 'Arsenal'
UNION ALL SELECT '2024-10-30'::DATE, 'Liverpool v Brighton', 'BART VERBRUGGEN', 'Brighton'
UNION ALL SELECT '2024-12-04'::DATE, 'Newcastle United v Liverpool', 'NICK POPE', 'Newcastle United'
UNION ALL SELECT '2025-02-12'::DATE, 'Everton v Liverpool', 'ABDOULAYE DOUCOURE', 'Everton'
UNION ALL SELECT '2025-02-12'::DATE, 'Everton v Liverpool', 'CURTIS JONES', 'Liverpool'
UNION ALL SELECT '2024-12-09'::DATE, 'West Ham v Wolves', 'JARROD BOWEN', 'West Ham'
UNION ALL SELECT '2024-12-09'::DATE, 'West Ham v Wolves', 'MARIO LEMINA', 'Wolves'
UNION ALL SELECT '2024-12-15'::DATE, 'Chelsea v Brentford', 'MARC CUCURELLA', 'Chelsea'
UNION ALL SELECT '2024-12-15'::DATE, 'Chelsea v Brentford', 'KEVIN SCHADE', 'Brentford'
UNION ALL SELECT '2024-12-14'::DATE, 'Wolves v Ipswich', 'RAYAN AIT-NOURI', 'Wolves'
UNION ALL SELECT '2024-12-14'::DATE, 'Wolves v Ipswich', 'JACK TAYLOR', 'Ipswich'
UNION ALL SELECT '2024-12-30'::DATE, 'Ipswich v Chelsea', 'SAM MORSY', 'Ipswich'
UNION ALL SELECT '2025-01-14'::DATE, 'West Ham v Fulham', 'RAUL JIMENEZ', 'Fulham'
UNION ALL SELECT '2025-01-25'::DATE, 'Brighton v Everton', 'JAKE OBRIEN', 'Everton'
UNION ALL SELECT '2025-01-25'::DATE, 'Brighton v Everton', 'YANKUBA MINTEH', 'Brighton'
UNION ALL SELECT '2025-02-22'::DATE, 'Bournemouth v Wolves', 'KEPA ARRIZABALAGA', 'Bournemouth'
UNION ALL SELECT '2025-02-22'::DATE, 'Everton v Man Utd', 'IDRISSA GUEYE', 'Everton'
UNION ALL SELECT '2025-04-01'::DATE, 'Arsenal v Fulham', 'ANDREAS PEREIRA', 'Fulham'
UNION ALL SELECT '2025-04-13'::DATE, 'Liverpool v West Ham', 'LUCAS PAQUETA', 'West Ham'
UNION ALL SELECT '2025-05-03'::DATE, 'Aston Villa v Fulham', 'ADAMA TRAORE', 'Fulham';

CREATE TEMP TABLE non_active_cards_team
DISTSTYLE KEY 
DISTKEY (ramp_selection_id)
SORTKEY (event_scheduled_start_datetime) AS
WITH date_filtered_bets AS (
    -- Pre-filter by date range first (most selective)
    SELECT
        sportex_selection_name,
        ramp_selection_id,
        ramp_event_id,
        ramp_selection_id,
        event_name,
        TRIM(SPLIT_PART(s.event_name, ' v ', 1)) AS home_team,
        TRIM(SPLIT_PART(s.event_name, ' v ', 2)) AS away_team,
        market_name,
        event_scheduled_start_datetime,
        placed_datetime,
        total_number_legs,
        sgm_leg_yn,
        in_play_yn,
        sgm_multiple_yn,
        bet_id,
        leg_id,
        supersub_possible_leg_yn,
        supersub_activated_leg_yn,
        CASE
            WHEN REGEXP_SUBSTR(TRIM(market_name), '\\d+\\.?\\d*') IS NOT NULL THEN
                CAST(NULLIF(TRIM(REGEXP_SUBSTR(TRIM(market_name), '\\d+\\.?\\d*')), '') AS DECIMAL(10, 1))
            WHEN REGEXP_SUBSTR(TRIM(selection_name), '\\d+\\.?\\d*') IS NOT NULL THEN
                CAST(NULLIF(TRIM(REGEXP_SUBSTR(TRIM(selection_name), '\\d+\\.?\\d*')), '') AS DECIMAL(10, 1))
            ELSE NULL
        END AS card_level,

        -- Classify market names into broader categories
        CASE
            WHEN TRIM(market_name) LIKE '%Total Cards%' THEN 'Total'
            -- REGEXP_LIKE is used for 'Over/Under' to handle variations like 'Over/Under' or 'Over-Under' and ensures case-insensitivity ('i')
            WHEN REGEXP_LIKE(TRIM(market_name), '(Over|Under)\\/?\\s*Cards', 'i') THEN 'Over/Under'
            WHEN TRIM(market_name) LIKE '%Most Cards%' THEN 'Most Cards'
            WHEN TRIM(market_name) LIKE '%Each Team Cards%' THEN 'Each Team Cards'
            ELSE 'Other' -- Catches any market names that don't fit the above categories
        END AS card_market_type,

        -- Classify selection names as 'Over' or 'Under' if applicable, otherwise keep the original name
        CASE
            WHEN REGEXP_LIKE(TRIM(sportex_selection_name), 'Over', 'i') THEN 'Over'
            WHEN REGEXP_LIKE(TRIM(sportex_selection_name), 'Under', 'i') THEN 'Under'
            ELSE TRIM(sportex_selection_name) -- If neither 'Over' nor 'Under' is found, keep the original selection_name
    END AS selection,
    FROM omni_sportsbook.vw_sportsbook_summary
    WHERE
        1=1
        AND market_group = 'Cards'
        AND market_name NOT LIKE '%Red%'
        AND market_name != 'To Score Or To Be Shown A Card'
        AND market_name != '|Shown a Card|'
        AND market_name != '|To Score Or Be Shown A Card|'
        AND competition = 'English Premier League'
        AND placed_datetime >= '2024-08-01'::DATE
        AND placed_datetime <  '2025-06-01'::DATE
)
SELECT
        dfb.bet_id,
        dfb.leg_id,
        dfb.placed_datetime,
        dfb.total_number_legs,
        dfb.sgm_leg_yn,
        dfb.in_play_yn,
        dfb.sgm_multiple_yn,
        dfb.sportex_selection_name,
        dfb.ramp_selection_id,
        dfb.event_name,
        dfb.market_name,
        dfb.event_scheduled_start_datetime,
        dfb.card_level,
        dfb.card_market_type,
        dfb.selection
FROM 
        date_filtered_bets dfb
JOIN 
        player_lookups p ON (
        dfb.event_scheduled_start_datetime::DATE = p.date_val
        AND dfb.event_name = p.event_name  
        AND UPPER(dfb.sportex_selection_name) = p.team
);



CREATE TEMP TABLE all_legs_with_nac_player 
DISTSTYLE KEY 
DISTKEY (ramp_selection_id)
SORTKEY (event_scheduled_start_datetime) AS
SELECT
        bet_id,
        leg_id,
        placed_datetime,
        total_number_legs,
        sgm_leg_yn,
        in_play_yn,
        sgm_multiple_yn,
        sportex_selection_name,
        ramp_selection_id,
        event_name,
        market_name,
        event_scheduled_start_datetime
FROM 
        omni_sportsbook.vw_sportsbook_summary
WHERE
        1=1
        AND bet_id in (SELECT bet_id FROM non_active_cards_player)
        AND placed_datetime >= '2024-08-01'::DATE
        AND placed_datetime < '2025-06-01'::DATE;

create temp table selection_results as
        -- get Paddy Power bets, legs and results
        select
                'PP' as brand,
                pp.settled_datetime,
                pp.mult_id,
                pp.mult_ref,
                pp.mult_bet_type,
                pp.ob_selection_id,
                pp.ramp_selection_id,
                ppr.outcome_desc,
                ppr.result,
                case
                   when ppr.result = 'W' then 'Y'
                   when ppr.result = 'P' and nvl(pp.ew_places, 1) >= ppr.place then 'Y'
                   when ppr.result = 'H' and pp.leg_bet_type = 'Higher/Lower' and ppr.outcome_type = 'H' and (ppr.hcap_makeup > (pp.handicap::float)) then 'Y'
                   when ppr.result = 'H' and pp.leg_bet_type = 'Higher/Lower' and ppr.outcome_type = 'L' and (ppr.hcap_makeup < (pp.handicap::float)) then 'Y'
                   when ppr.result = 'H' and pp.leg_bet_type = 'Western Handicap' and ppr.outcome_type = 'H' and ((pp.handicap::float) + ppr.hcap_makeup > 0) then 'Y'
                   when ppr.result = 'H' and pp.leg_bet_type = 'Western Handicap' and ppr.outcome_type = 'H' and ((pp.handicap::float) - ppr.hcap_makeup > 0) then 'Y'
                   when ppr.result = 'H' and pp.leg_bet_type = 'Match Handicap' and ppr.outcome_type = 'H' and ((pp.handicap::float) + ppr.hcap_makeup > 0) then 'Y'
                   when ppr.result = 'H' and pp.leg_bet_type = 'Match Handicap' and ppr.outcome_type = 'A' and ((pp.handicap::float) - ppr.hcap_makeup > 0) then 'Y'
                   when ppr.result = 'H' and pp.leg_bet_type = 'Match Handicap' and ppr.outcome_type = 'L' and ((pp.handicap::float) + ppr.hcap_makeup = 0) then 'Y'
                   else 'N'
                   end as leg_winner_yn
        from 
                omni_sportsbook.pp_vw_bet_selection pp
        left join (
                select distinct
                        outcome_id,
                        outcome_desc,
                        outcome_type,
                        hcap_makeup,
                        place,
                        result
                from
                        omni_betevent.pp_vw_selection_outcome
                ) ppr
        on
                ppr.outcome_id = pp.ob_selection_id
        where
                pp.mult_id IN (SELECT bet_id FROM all_legs_with_nac_player)
                AND pp.settled_datetime > '2024-08-01'::DATE;


CREATE TEMP TABLE bet_leg_stats AS
SELECT 
        mult_id,
        ramp_selection_id,
        SUM(CASE WHEN leg_winner_yn = 'N' THEN 1 ELSE 0 END) OVER (PARTITION BY mult_id) as losing_legs,
        COUNT(*) OVER (PARTITION BY mult_id) as total_legs
FROM selection_results;

CREATE TEMP TABLE non_active_cards_player_almosts AS
SELECT
    s.account_sk,
    s.market_name,
    s.sportex_selection_name,
    s.sportex_selection_id,
    s.leg_price_actual,
    s.winnings,
    s.volume_gbp,
    s.revenue_gbp,
    s.bet_type,
    s.bet_type_detail,
    s.bet_id,
    s.leg_id,
    s.sgm_leg_yn,
    s.in_play_yn,
    s.total_number_legs,
    s.supersub_activated_leg_yn,
    s.supersub_possible_leg_yn,
    sr.leg_winner_yn,
    CASE 
        WHEN iso_currency_code = 'EUR' 
        AND s.potential_payout <> 0
        THEN (s.potential_payout * fx.exchange_rate)
        ELSE s.potential_payout
    END AS potential_payout,
    CASE 
        WHEN iso_currency_code = 'EUR' 
        AND s.stake <> 0
        THEN (s.stake * fx.exchange_rate)
        ELSE s.stake
     END AS stake
FROM 
    omni_sportsbook.vw_sportsbook_summary s
JOIN 
        selection_results sr
ON
        s.ramp_selection_id = sr.ramp_selection_id
AND     
        s.bet_id = sr.mult_id
JOIN
        bet_leg_stats bs
ON
        s.bet_id = bs.mult_id
        AND s.ramp_selection_id = bs.ramp_selection_id
JOIN
        omni.fact_exchange_rates fx
ON 
        CAST(s.placed_datetime AS DATE) = CAST(fx.date_nk AS DATE)
JOIN 
        player_lookups p ON 
        UPPER(s.sportex_selection_name) = p.player_name
WHERE
        1=1
    AND s.bet_id IN (SELECT bet_id FROM non_active_cards_player)
    AND (market_name LIKE '%Player to be carded%'
        OR market_name LIKE '%Player Shown a Card%'
        OR market_name LIKE '%|Player to be carded|%'
        OR market_name LIKE '%|Player Shown a Card|%')
    AND bs.losing_legs = 1
    AND sr.leg_winner_yn = 'N'
    AND fx.from_currency_code = 'GBP'
    AND fx.to_currency_code = 'EUR';


CREATE TEMP TABLE results AS
SELECT
        supersub_activated_leg_yn,
        in_play_yn,
        bet_type,
        SUM(stake) AS total_stakes,
        SUM(potential_payout) AS total_payout
FROM
        non_active_cards_player_almosts
GROUP BY 
        1,2,3
ORDER BY total_payout DESC;

CREATE TEMP TABLE market_level AS
SELECT 
        supersub_activated_leg_yn,
        in_play_yn,
        bet_type,
        SUM(volume_gbp) AS total_volume,
        SUM(revenue_gbp) AS total_revenue,
        (SUM(volume_gbp) - SUM(revenue_gbp)) AS margin,
        SUM(revenue_gbp)/SUM(volume_gbp) AS margin_pcnt
FROM 
        omni_sportsbook.vw_sportsbook_summary
WHERE
        vertical_id = 1
AND 
        placed_datetime > '2024-08-01'::DATE
AND 
        (market_name LIKE '%Player to be carded%'
        OR market_name LIKE '%Player Shown a Card%'
        OR market_name LIKE '%|Player to be carded|%'
        OR market_name LIKE '%|Player Shown a Card|%') 
        AND market_group = 'Player Props'
        AND competition = 'English Premier League'
GROUP BY 1,2,3
ORDER BY bet_type, in_play_yn
LIMIT 100;


SELECT
        r.supersub_activated_leg_yn,
        r.in_play_yn,
        r.bet_type,
        r.total_stakes,
        r.total_payout,
        (r.total_payout/ml.margin) AS cost_to_margin_pcnt
FROM
        results r
JOIN
        market_level ml
ON
        r.supersub_activated_leg_yn = ml.supersub_activated_leg_yn
AND
        r.in_play_yn = ml.in_play_yn
AND
        r.bet_type = ml.bet_type
ORDER BY r.bet_type, r.in_play_yn, r.supersub_activated_leg_yn;