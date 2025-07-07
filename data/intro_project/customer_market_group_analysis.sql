CREATE TEMPORARY TABLE market_group_totals AS
SELECT
    account_sk,
    account_id,
    market_group,
    SUM(revenue_gbp)                           AS total_revenue,
    SUM(volume_gbp)                            AS total_volume,
    COUNT(DISTINCT leg_id)                     AS total_legs_per_market_group,
    COUNT(DISTINCT bet_id)                     AS total_bets_per_market_group,
    MAX(revenue_gbp)                           AS max_single_bet_revenue,
    -- Calculate if max single bet makes up more than 50% of total revenue
    CASE 
        WHEN SUM(CASE WHEN revenue_gbp < 0 THEN revenue_gbp ELSE 0 END) < 0 
        THEN ABS(MIN(revenue_gbp)) / ABS(SUM(CASE WHEN revenue_gbp < 0 THEN revenue_gbp ELSE 0 END))
        ELSE 0 
    END AS max_bet_win_pct
FROM
    omni_sportsbook.vw_sportsbook_summary
WHERE
    1=1
    AND settled_datetime >= '2024-01-01'
    AND settled_datetime <= '2024-12-31'
    AND sport_name = 'Soccer'
    AND market_group IN ('Player Props')
   -- AND market_group NOT IN ('One minute', 'Match Betting', 'Manually Loaded', 'Commercial Specials', 'Priceboosts', 'Specials', 'PP/OBs', ' PP/OBs', 'PP/OBs '
    --                          'Match Odds', 'WOPs/OOT', 'Request-a-bet', 'Correct Score Live', 'Ante Post SportCast', 'Other', 'Match Performance Treble')
    AND in_play_yn = 'N'
    AND percent_max_bet > 0.5
GROUP BY
    account_sk,
    account_id,
    market_group
HAVING
    -- Filter out cases where single bet makes up more than 50% of revenue
    CASE 
        WHEN SUM(CASE WHEN revenue_gbp < 0 THEN revenue_gbp ELSE 0 END) < 0 
        THEN ABS(MIN(revenue_gbp)) / ABS(SUM(CASE WHEN revenue_gbp < 0 THEN revenue_gbp ELSE 0 END))
        ELSE 0 
    END <= 0.25;

CREATE TEMPORARY TABLE refined_customers AS 
SELECT
    mgt.account_id,
    mgt.account_sk,     
    mgt.total_volume,      
    mgt.total_revenue,   
    (mgt.total_revenue / NULLIF(mgt.total_volume, 0))   AS margin_pct,
    mgt.total_legs_per_market_group,
    mgt.total_bets_per_market_group,
    mgt.max_bet_win_pct,
    CASE 
        WHEN market_group LIKE '%Goal Scorer Market%' THEN 'Goalscorer Markets'
        WHEN market_group LIKE '%Ante Post Outrights' THEN 'Outright markets'
        WHEN market_group LIKE '%Total Over Bookings' THEN 'Cards'
        ELSE market_group
    END AS market_group
FROM
    market_group_totals mgt
WHERE
    1=1
    AND mgt.total_revenue < 0
    AND mgt.total_volume > 500
    AND mgt.total_bets_per_market_group >= 50;

CREATE TEMPORARY TABLE market_group_refined AS 
SELECT    
    SUM(mgt.total_volume) AS total_volume,      
    SUM(mgt.total_revenue) AS total_revenue,   
    (SUM(mgt.total_revenue) / NULLIF(SUM(mgt.total_volume), 0))   AS margin_pct,
    COUNT(account_sk) AS total_marks,
    mgt.market_group
FROM
    refined_customers mgt
GROUP BY
    mgt.market_group;

CREATE TEMPORARY TABLE latest_account_history AS
SELECT 
    account_sk,
    liability_group,
    stake_factor,
    CASE 
        WHEN liability_group IN ('Shrewd', 'shrewd', 'Marks Soccer AT', 'Marks', 'Bots', 'Error Backer', 'Opening Restriction', 'Watchlist') THEN 'sharp'
        ELSE 'blunt'
    END AS liability_parent_group,
    ROW_NUMBER() OVER (
        PARTITION BY account_sk 
        ORDER BY effective_from_datetime DESC
    ) as rn
FROM 
    omni.dim_account_history
WHERE 
    effective_from_datetime >= '2024-01-01'::DATE
    AND effective_to_datetime < '2025-01-01'::DATE;


CREATE TEMPORARY TABLE final_market_groups AS
SELECT * FROM market_group_refined 
WHERE
    total_revenue < -100000;

CREATE TEMPORARY TABLE marked_accounts AS
SELECT DISTINCT
    rec.*,
    lah.liability_group,
    lah.liability_parent_group,
    lah.stake_factor
FROM
    refined_customers rec
JOIN
    latest_account_history lah
ON
    rec.account_sk = lah.account_sk
JOIN
    final_market_groups fmg
ON
    rec.market_group = fmg.market_group;

CREATE TEMPORARY TABLE selection_stats_simple AS
    SELECT
        ss.ramp_selection_id,
        ss.sportex_selection_name,
        ss.event_name,
        ss.market_name,
        ss.market_group,

        -- Overall stats for ALL customers, calculated during the single pass
        COUNT(*) as total_bets,
        SUM(ss.volume_gbp) AS total_volume,
        SUM(ss.revenue_gbp) as total_revenue,
        AVG(ss.leg_price_actual) as average_odds,
        MIN(ss.leg_price_actual) as min_odds,
        MAX(ss.leg_price_actual) as max_odds,
        COUNT(DISTINCT ss.account_sk) as total_customers,

        -- Conditional Aggregation: Count a distinct account ONLY IF the LEFT JOIN found a match
        COUNT(DISTINCT CASE WHEN ma.account_sk IS NOT NULL THEN ss.account_sk END) as marks_count

    FROM
        omni_sportsbook.vw_sportsbook_summary ss
    LEFT JOIN
        marked_accounts ma ON ss.account_sk = ma.account_sk AND ss.market_group = ma.market_group
    WHERE
        ss.in_play_yn = 'N'
        AND ss.market_group IN ('Player Props')
    GROUP BY
        ss.ramp_selection_id,
        ss.sportex_selection_name,
        ss.event_name,
        ss.market_name,
        ss.market_group;

CREATE TEMPORARY TABLE selection_stats AS
SELECT
    s.marks_count,
    s.ramp_selection_id,
    s.sportex_selection_name,
    s.event_name,
    s.market_name,
    s.market_group,
    s.total_bets,
    s.total_revenue,
    s.total_volume,
    s.total_revenue / NULLIF(s.total_volume, 0) as total_margin,
    ROUND(s.average_odds, 2) as average_odds,
    s.min_odds,
    s.max_odds,
    s.total_customers,
    -- Added NULLIF to prevent division-by-zero errors
    ROUND(s.total_revenue / NULLIF(s.total_bets, 0), 2) as revenue_per_bet,
    ROUND(s.total_revenue / NULLIF(s.total_customers, 0), 2) as revenue_per_customer
FROM
    selection_stats_simple s
WHERE
    1=1
    AND s.marks_count >= 3
ORDER BY
    s.marks_count DESC;

SELECT * FROM selection_stats;

WITH marked_bets_only AS (
    -- Pre-filter to only marked account bets to reduce dataset size
    SELECT 
        ss.ramp_selection_id,
        ss.sportex_selection_name,
        ss.event_name,
        ss.market_name,
        ss.market_group,
        ss.placed_datetime,
        ss.account_sk,
        ss.leg_price_actual,
        ss.volume_gbp,
        ss.revenue_gbp
    FROM omni_sportsbook.vw_sportsbook_summary ss
    INNER JOIN marked_accounts ma 
        ON ss.account_sk = ma.account_sk 
        AND ss.market_group = ma.market_group
    WHERE ss.in_play_yn = 'N'
    AND placed_datetime > '01-01-2025'::DATE
),

-- Get trigger points and prices in single pass
trigger_points_ranked AS (
    SELECT 
        ramp_selection_id,
        sportex_selection_name,
        event_name,
        market_name,
        market_group,
        placed_datetime as trigger_datetime,
        leg_price_actual as trigger_price,
        ROW_NUMBER() OVER (PARTITION BY ramp_selection_id ORDER BY placed_datetime) as rn
    FROM marked_bets_only
),

trigger_points AS (
    SELECT 
        ramp_selection_id,
        sportex_selection_name,
        event_name,
        market_name,
        market_group,
        trigger_datetime,
        trigger_price
    FROM trigger_points_ranked
    WHERE rn = 5  -- Only keep the 5th marked bet per selection
),

-- Single scan of all bets with trigger data joined once
all_bets_enriched AS (
    SELECT 
        ss.ramp_selection_id,
        ss.sportex_selection_name,
        ss.event_name,
        ss.market_name,
        ss.market_group,
        ss.placed_datetime,
        ss.account_sk,
        ss.leg_price_actual,
        ss.volume_gbp,
        ss.revenue_gbp,
        tp.trigger_datetime,
        tp.trigger_price,
        
        -- Single calculation of adjustment flags
        CASE 
            WHEN tp.trigger_datetime IS NULL THEN FALSE
            WHEN ss.placed_datetime <= tp.trigger_datetime THEN FALSE
            WHEN ss.leg_price_actual > tp.trigger_price THEN TRUE
            WHEN ss.leg_price_actual < tp.trigger_price THEN FALSE
            ELSE TRUE
        END as should_adjust,
        
        -- Mark if this is a marked account (for counting)
        CASE WHEN ma.account_sk IS NOT NULL THEN 1 ELSE 0 END as is_marked
        
    FROM omni_sportsbook.vw_sportsbook_summary ss
    LEFT JOIN trigger_points tp USING (ramp_selection_id)
    LEFT JOIN marked_accounts ma 
        ON ss.account_sk = ma.account_sk 
        AND ss.market_group = ma.market_group
    WHERE ss.in_play_yn = 'N'
      AND tp.trigger_datetime IS NOT NULL  -- Only selections with 5+ marked accounts
),

-- Final aggregation with conditional calculations
final_metrics AS (
    SELECT 
        ramp_selection_id,
        MAX(sportex_selection_name) as sportex_selection_name,
        MAX(event_name) as event_name,
        MAX(market_name) as market_name,
        MAX(market_group) as market_group,
        MAX(trigger_datetime) as trigger_datetime,
        MAX(trigger_price) as trigger_price,
        
        -- Counts
        COUNT(*) as total_bets,
        SUM(is_marked) as total_marked_accounts,
        COUNT(CASE WHEN placed_datetime <= trigger_datetime THEN 1 END) as pre_trigger_bets,
        COUNT(CASE WHEN placed_datetime > trigger_datetime THEN 1 END) as post_trigger_bets,
        COUNT(CASE WHEN should_adjust THEN 1 END) as affected_bets,
        
        -- Original totals
        SUM(volume_gbp) as original_volume,
        SUM(revenue_gbp) as original_revenue,
        
        SUM(CASE WHEN should_adjust AND revenue_gbp < 0
            THEN revenue_gbp * 0.9
            ELSE revenue_gbp END) as adjusted_revenue,
        
        -- Affected bet metrics
        SUM(CASE WHEN should_adjust THEN volume_gbp END) as affected_volume,
        SUM(CASE WHEN should_adjust 
            THEN (revenue_gbp / leg_price_actual) * (leg_price_actual * 0.9) END) as affected_adjusted_volume,
        SUM(CASE WHEN placed_datetime > trigger_datetime THEN volume_gbp END) as post_trigger_total_volume
        
    FROM all_bets_enriched
    GROUP BY ramp_selection_id
)

-- Final output with calculated differences
SELECT 
    ramp_selection_id,
    sportex_selection_name,
    event_name,
    market_name,
    market_group,
    trigger_datetime,
    trigger_price as trigger_odds,
    total_marked_accounts,
    (trigger_price * 0.9) AS adjusted_price,
    
    -- Bet distribution
    total_bets,
    pre_trigger_bets,
    post_trigger_bets,
    affected_bets,
    ROUND(post_trigger_bets::DECIMAL / NULLIF(total_bets, 0) * 100, 1) as pct_post_trigger,
    ROUND(affected_bets::DECIMAL / NULLIF(post_trigger_bets, 0) * 100, 1) as pct_affected_of_post,
    original_volume,
    original_revenue,
    adjusted_revenue,
    ROUND(original_revenue - adjusted_revenue, 2) as revenue_difference,
    ROUND((original_revenue - adjusted_revenue) / NULLIF(original_revenue, 0) * 100, 2) as revenue_impact_pct,
    
    -- Targeted impact metrics
    ROUND(post_trigger_total_volume, 2) as post_trigger_total_volume

FROM final_metrics
ORDER BY 
    (original_revenue - adjusted_revenue) DESC,
    total_marked_accounts DESC;