CREATE TEMP TABLE woodwork_hit (
    event_id BIGINT,
    market_id BIGINT,
    selection_id BIGINT,
    home_team VARCHAR(256),
    away_team VARCHAR(256),
    selection_name VARCHAR(256),
    sot_level BIGINT,
    actual_sot BIGINT, 
    total_bets_laid_on_next_sot_level BIGINT,
    next_sot_level_laid BIGINT,
    sim BIGINT
);


COPY woodwork_hit
FROM 's3://edcs3.prod.biads/Sandbox/DC/woodwork/all_sampled_data.parquet' -- Or .csv, depending on your file
IAM_ROLE 'arn:aws:iam::765819017647:role/rs-edcs3.prod.marketing' -- Replace with your IAM Role ARN
FORMAT PARQUET;

-- SELECT * FROM woodwork_sample LIMIT 10;
CREATE TEMP TABLE all_legs_with_ww_in_bet 
DISTSTYLE KEY 
DISTKEY (ramp_selection_id)
SORTKEY (event_scheduled_start_datetime) AS
SELECT
        s.bet_id,
        s.leg_id,
        s.placed_datetime,
        s.total_number_legs,
        s.sgm_leg_yn,
        s.in_play_yn,
        s.sgm_multiple_yn,
        s.sportex_selection_name,
        s.ramp_selection_id,
        s.event_name,
        s.market_name,
        s.event_scheduled_start_datetime,
        wh.sim
FROM 
        omni_sportsbook.vw_sportsbook_summary s
JOIN
        woodwork_hit wh
ON
        s.ramp_selection_id = wh.selection_id
WHERE
        1=1
        AND s.settled_datetime >= '2024-08-01'::DATE
        AND s.settled_datetime < '2025-06-01'::DATE
        AND s.vertical_id = 1;

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
                pp.mult_id IN (SELECT bet_id FROM all_legs_with_ww_in_bet)
                AND pp.settled_datetime > '2024-08-01'::DATE;


CREATE TEMP TABLE bet_leg_stats AS
SELECT 
        mult_id,
        ramp_selection_id,
        SUM(CASE WHEN leg_winner_yn = 'N' THEN 1 ELSE 0 END) OVER (PARTITION BY mult_id) as losing_legs,
        COUNT(*) OVER (PARTITION BY mult_id) as total_legs
FROM selection_results;

CREATE TEMP TABLE woodwork_almosts AS
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
    s.brand,
    s.total_number_legs,
    sr.leg_winner_yn,
    s.supersub_activated_leg_yn,
    wh.sim,
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
        woodwork_hit wh
ON
        wh.selection_id = s.ramp_selection_id
WHERE
        1=1
    AND s.bet_id IN (SELECT bet_id FROM all_legs_with_ww_in_bet)
    AND bs.losing_legs = 1
    AND sr.leg_winner_yn = 'N'
    AND fx.from_currency_code = 'GBP'
    AND fx.to_currency_code = 'EUR'
    AND s.brand = 'PP'
    AND s.settled_datetime >= '2024-08-01'::DATE
    AND s.settled_datetime < '2025-06-01'::DATE;


-- SELECT * FROM all_legs_with_ww_in_bet;

-- SELECT
--         supersub_activated_leg_yn,
--         bet_type,
--         in_play_yn,
--         sim,
--         SUM(stake) AS total_stakes,
--         SUM(potential_payout) AS total_payout
-- FROM
--         woodwork_almosts
-- GROUP BY 
--         1,2,3,4;

-- EXPLAIN
SELECT
        sim,
        COUNT(DISTINCT bet_id)
FROM
        woodwork_almosts
GROUP BY sim;
