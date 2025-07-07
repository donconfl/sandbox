CREATE TEMP TABLE player_lookups 
DISTSTYLE EVEN 
SORTKEY (date_val, event_name) AS
SELECT '2023-08-26'::DATE as date_val, 'Arsenal v Fulham' as event_name, 'MAREK RODAK' as player_name
UNION ALL SELECT '2023-09-30'::DATE, 'Wolves v Man City', 'NELSON SEMEDO'
UNION ALL SELECT '2023-09-30'::DATE, 'Wolves v Man City', 'JACK GREALISH'
UNION ALL SELECT '2023-10-08'::DATE, 'Wolves v Aston Villa', 'SASA KALAJDZIC'
UNION ALL SELECT '2023-10-28'::DATE, 'Chelsea v Brentford', 'NEAL MAUPAY'
UNION ALL SELECT '2023-11-11'::DATE, 'Crystal Palace v Everton', 'AMADOU ONANA'
UNION ALL SELECT '2023-11-11'::DATE, 'Wolves v Tottenham', 'JOAO GOMES'
UNION ALL SELECT '2023-11-11'::DATE, 'Wolves v Tottenham', 'RAYAN AIT-NOURI'
UNION ALL SELECT '2023-12-03'::DATE, 'Bournemouth v Aston Villa', 'MILOS KERKEZ'
UNION ALL SELECT '2023-12-07'::DATE, 'Tottenham v West Ham', 'DEJAN KULUSEVSKI'
UNION ALL SELECT '2023-12-23'::DATE, 'Luton v Newcastle United', 'BRUNO GUIMARAES'
UNION ALL SELECT '2023-12-24'::DATE, 'Wolves v Chelsea', 'MARCUS BETTINELLI'
UNION ALL SELECT '2023-12-31'::DATE, 'Tottenham v Bournemouth', 'GIOVANI LO CELSO'
UNION ALL SELECT '2024-02-01'::DATE, 'Wolves v Man Utd', 'ALEJANDRO GARNACHO'
UNION ALL SELECT '2024-02-12'::DATE, 'Crystal Palace v Chelsea', 'NICOLAS JACKSON'
UNION ALL SELECT '2024-03-02'::DATE, 'Luton Town v Aston Villa', 'MORGAN ROGERS'
UNION ALL SELECT '2024-03-02'::DATE, 'Nottm Forest v Liverpool', 'FELIPE'
UNION ALL SELECT '2024-03-09'::DATE, 'Bournemouth v Sheff Utd', 'BRERETON'
UNION ALL SELECT '2024-03-30'::DATE, 'Tottenham v Luton', 'YVES BISSOUMA'
UNION ALL SELECT '2024-04-02'::DATE, 'Nottm Forest v Fulham', 'MATTHEW TURNER'
UNION ALL SELECT '2024-04-04'::DATE, 'Chelsea v Man Utd', 'MOISES CAICEDO'
UNION ALL SELECT '2024-04-04'::DATE, 'Chelsea v Man Utd', 'HARRY MAGUIRE'
UNION ALL SELECT '2024-04-06'::DATE, 'Wolves v West Ham', 'PABLO SARABIA'
UNION ALL SELECT '2024-04-27'::DATE, 'Aston Villa v Chelsea', 'BENOIT BADIASHILE'
UNION ALL SELECT '2024-04-27'::DATE, 'Aston Villa v Chelsea', 'NONI MADUEKE';



CREATE TEMP TABLE non_active_cards 
DISTSTYLE KEY 
DISTKEY (ramp_selection_id)
SORTKEY (event_scheduled_start_datetime) AS
WITH date_filtered_bets AS (
    -- Pre-filter by date range first (most selective)
    SELECT
        sportex_selection_name,
        ramp_selection_id,
        event_name,
        market_name,
        event_scheduled_start_datetime,
        placed_datetime,
        total_number_legs,
        sgm_leg_yn,
        in_play_yn,
        sgm_multiple_yn,
        bet_id,
        leg_id
    FROM omni_sportsbook.vw_sportsbook_summary
    WHERE market_name IN ('Player to be carded', 'Player Shown a Card')
        AND placed_datetime >= '2023-08-01'::DATE
        AND placed_datetime < '2024-06-01'::DATE
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
        dfb.event_scheduled_start_datetime
FROM 
        date_filtered_bets dfb
INNER JOIN 
        player_lookups p ON (
        dfb.event_scheduled_start_datetime::DATE = p.date_val
        AND dfb.event_name = p.event_name  
        AND UPPER(dfb.sportex_selection_name) = p.player_name
);

CREATE TEMP TABLE all_legs_with_nac_in_bet 
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
        AND bet_id in (SELECT bet_id FROM non_active_cards)
        AND placed_datetime >= '2023-08-01'::DATE
        AND placed_datetime < '2024-06-01'::DATE;

create temp table selection_results as
(
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
                pp.mult_id IN (SELECT bet_id FROM all_legs_with_nac_in_bet)
                AND pp.settled_datetime > '2023-08-01'::DATE
        union all
        -- get Betfair bets, legs and results
        select distinct
                'BF' as brand,
                bf.settled_datetime,
                bf.mult_id,
                bf.mult_ref,
                bf.mult_bet_type,
                bf.ob_selection_id,
                bf.ramp_selection_id,
                bfr.selection_desc,
                bfr.result,
                case
                   when bfr.result = 'W' then 'Y'
                   when bfr.result = 'P' and nvl(bf.ew_places, 1) >= bfr.place then 'Y'
                   when bfr.result = 'H' and bf.leg_bet_type = 'Higher/Lower' and bfr.selection_type = 'H' and (bfr.hcap_makeup > (bf.handicap::float)) then 'Y'
                   when bfr.result = 'H' and bf.leg_bet_type = 'Higher/Lower' and bfr.selection_type = 'L' and (bfr.hcap_makeup < (bf.handicap::float)) then 'Y'
                   when bfr.result = 'H' and bf.leg_bet_type = 'Western Handicap' and bfr.selection_type = 'H' and ((bf.handicap::float) + bfr.hcap_makeup > 0) then 'Y'
                   when bfr.result = 'H' and bf.leg_bet_type = 'Western Handicap' and bfr.selection_type = 'H' and ((bf.handicap::float) - bfr.hcap_makeup > 0) then 'Y'
                   when bfr.result = 'H' and bf.leg_bet_type = 'Match Handicap' and bfr.selection_type = 'H' and ((bf.handicap::float) + bfr.hcap_makeup > 0) then 'Y'
                   when bfr.result = 'H' and bf.leg_bet_type = 'Match Handicap' and bfr.selection_type = 'A' and ((bf.handicap::float) - bfr.hcap_makeup > 0) then 'Y'
                   when bfr.result = 'H' and bf.leg_bet_type = 'Match Handicap' and bfr.selection_type = 'L' and ((bf.handicap::float) + bfr.hcap_makeup = 0) then 'Y'
                   else 'N'
                   end as leg_winner_yn
        from 
                omni_sportsbook.bf_vw_bet_selection bf
        join (
                select distinct
                        selection_id,
                        selection_desc,
                        selection_type,
                        hcap_makeup,
                        place,
                        result
                from
                        omni_betevent.bf_vw_selection_outcome
                ) bfr
        on
                bfr.selection_id = bf.ob_selection_id
        where
                1=1
                AND bf.mult_id IN (SELECT bet_id FROM all_legs_with_nac_in_bet)
                AND bf.settled_datetime > '2023-08-01'::DATE
        union all
        -- get SKY bets, legs and results
        select distinct
               'SBG' as brand,
                sbg.settled_datetime,
                sbg.mult_id,
                sbg.mult_ref,
                sbg.mult_bet_type,
                sbg.ob_selection_id,
                sbg.ramp_selection_id,
                sbgr.outcome_desc,
                sbgr.result,
                case
                   when sbgr.result = 'W' then 'Y'
                   when sbgr.result = 'P' and nvl(sbg.ew_places, 1) >= sbgr.place then 'Y'
                   when sbgr.result = 'H' and sbg.leg_bet_type = 'Higher/Lower' and sbgr.outcome_type = 'H' and (sbgr.hcap_makeup > (sbg.handicap::float)) then 'Y'
                   when sbgr.result = 'H' and sbg.leg_bet_type = 'Higher/Lower' and sbgr.outcome_type = 'L' and (sbgr.hcap_makeup < (sbg.handicap::float)) then 'Y'
                   when sbgr.result = 'H' and sbg.leg_bet_type = 'Western Handicap' and sbgr.outcome_type = 'H' and ((sbg.handicap::float) + sbgr.hcap_makeup > 0) then 'Y'
                   when sbgr.result = 'H' and sbg.leg_bet_type = 'Western Handicap' and sbgr.outcome_type = 'H' and ((sbg.handicap::float) - sbgr.hcap_makeup > 0) then 'Y'
                   when sbgr.result = 'H' and sbg.leg_bet_type = 'Match Handicap' and sbgr.outcome_type = 'H' and ((sbg.handicap::float) + sbgr.hcap_makeup > 0) then 'Y'
                   when sbgr.result = 'H' and sbg.leg_bet_type = 'Match Handicap' and sbgr.outcome_type = 'A' and ((sbg.handicap::float) - sbgr.hcap_makeup > 0) then 'Y'
                   when sbgr.result = 'H' and sbg.leg_bet_type = 'Match Handicap' and sbgr.outcome_type = 'L' and ((sbg.handicap::float) + sbgr.hcap_makeup = 0) then 'Y'
                   else 'N'
                   end as leg_winner_yn
        from 
                omni_sportsbook.sbg_vw_bet_selection sbg
        join (
                select distinct
                        outcome_id,
                        outcome_desc,
                        outcome_type,
                        hcap_makeup,
                        place,
                        result
                from
                        omni_betevent.sbg_vw_selection_outcome
                ) sbgr
        on
                sbgr.outcome_id = sbg.ob_selection_id
        where
                1=1
                AND sbg.mult_id IN (SELECT bet_id FROM all_legs_with_nac_in_bet)
                AND sbg.settled_datetime > '2023-08-01'::DATE

);

SELECT * FROM selection_results;
-- CREATE TEMP TABLE bet_leg_stats AS
-- SELECT 
--         mult_id,
--         ramp_selection_id,
--         SUM(CASE WHEN leg_winner_yn = 'N' THEN 1 ELSE 0 END) OVER (PARTITION BY mult_id) as losing_legs,
--         COUNT(*) OVER (PARTITION BY mult_id) as total_legs
-- FROM selection_results;

-- CREATE TEMP TABLE non_active_cards_almosts AS
-- SELECT
--     s.account_sk,
--     s.market_name,
--     s.sportex_selection_name,
--     s.sportex_selection_id,
--     s.leg_price_actual,
--     s.winnings,
--     s.volume_gbp,
--     s.revenue_gbp,
--     s.bet_type,
--     s.bet_type_detail,
--     s.bet_id,
--     s.leg_id,
--     s.sgm_leg_yn,
--     s.in_play_yn,
--     s.brand,
--     s.total_number_legs,
--     sr.leg_winner_yn,
--     CASE 
--         WHEN iso_currency_code = 'EUR' 
--         AND s.potential_payout <> 0
--         THEN (s.potential_payout * fx.exchange_rate)
--         ELSE s.potential_payout
--     END AS potential_payout,
--     CASE 
--         WHEN iso_currency_code = 'EUR' 
--         AND s.stake <> 0
--         THEN (s.stake * fx.exchange_rate)
--         ELSE s.stake
--      END AS stake
-- FROM 
--     omni_sportsbook.vw_sportsbook_summary s
-- JOIN 
--         selection_results sr
-- ON
--         s.ramp_selection_id = sr.ramp_selection_id
-- AND     
--         s.bet_id = sr.mult_id
-- JOIN
--         bet_leg_stats bs
-- ON
--         s.bet_id = bs.mult_id
--         AND s.ramp_selection_id = bs.ramp_selection_id
-- JOIN
--         omni.fact_exchange_rates fx
-- ON 
--         CAST(s.placed_datetime AS DATE) = CAST(fx.date_nk AS DATE)
-- WHERE
--         1=1
--     AND s.bet_id IN (SELECT bet_id FROM non_active_cards)
--     AND bs.losing_legs = 1
--     AND sr.leg_winner_yn = 'N'
--     AND fx.from_currency_code = 'GBP'
--     AND fx.to_currency_code = 'EUR';


-- -- SELECT * FROM non_active_cards_almosts;

-- SELECT
--         market_name,
--         sportex_selection_name,
--         bet_type,
--         brand,
--         in_play_yn,
--         SUM(stake) AS total_stakes,
--         SUM(potential_payout) AS total_payout
-- FROM
--         non_active_cards_almosts
-- GROUP BY 
--         1,2,3,4,5;
