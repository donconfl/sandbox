CREATE TEMP TABLE woodwork_hit (
    event_scheduled_start_datetime DATE,
    event_name VARCHAR(255),
    sportex_selection_name VARCHAR(255)
);

INSERT INTO woodwork_hit (event_scheduled_start_datetime, event_name, sportex_selection_name) VALUES
('2023-12-30', 'Luton v Chelsea', 'Elijah Adebayo'),
('2024-05-15', 'Brighton v Chelsea', 'Simon Adingra'),
('2024-01-30', 'Crystal Palace v Sheff Utd', 'Anel Ahmedhodzic'),
('2023-12-23', 'Liverpool v Arsenal', 'Trent Alexander-Arnold'),
('2023-12-03', 'Liverpool v Fulham', 'Trent Alexander-Arnold'),
('2024-01-01', 'Liverpool v Newcastle', 'Trent Alexander-Arnold'),
('2023-08-27', 'Newcastle v Liverpool', 'Miguel Almiron'),
('2023-12-03', 'Man City v Tottenham', 'Julian Alvarez'),
('2023-09-16', 'West Ham v Man City', 'Julian Alvarez'),
('2023-09-23', 'Burnley v Man Utd', 'Zeki Amdouni'),
('2023-10-21', 'Sheff Utd v Man Utd', 'Sofyan Amrabat'),
('2023-08-19', 'Tottenham v Man Utd', 'Antony'),
('2023-09-02', 'Sheff Utd v Everton', 'Cameron Archer'),
('2024-04-06', 'Crystal Palace v Man City', 'Jordan Ayew'),
('2024-02-17', 'Fulham v Aston Villa', 'Leon Bailey'),
('2024-02-18', 'Luton v Man Utd', 'Ross Barkley'),
('2023-12-23', 'Luton v Newcastle', 'Ross Barkley'),
('2024-03-16', 'Luton v Nottm Forest', 'Ross Barkley'),
('2024-03-16', 'Fulham v Tottenham', 'Calvin Bassey'),
('2024-05-19', 'Sheff Utd v Tottenham', 'Bentancur'),
('2024-05-05', 'Chelsea v West Ham', 'Jarrod Bowen'),
('2024-05-05', 'Chelsea v West Ham', 'Jarrod Bowen'),
('2024-05-11', 'West Ham v Luton', 'Jarrod Bowen'),
('2023-12-17', 'West Ham v Wolves', 'Jarrod Bowen'),
('2024-05-19', 'Sheff Utd v Tottenham', 'Brereton'),
('2023-12-06', 'Man Utd v Chelsea', 'Armando Broja'),
('2023-12-23', 'Nottm Forest v Bournemouth', 'David Brooks'),
('2023-09-16', 'Fulham v Luton', 'Jacob Brown'),
('2023-12-23', 'Luton v Newcastle', 'Jacob Brown'),
('2024-03-30', 'Newcastle v West Ham', 'Bruno Guimaraes'),
('2023-12-31', 'Tottenham v Bournemouth', 'Bryan Gil'),
('2024-03-02', 'Fulham v Brighton', 'Facundo Buonanotte'),
('2023-10-07', 'Fulham v Sheff Utd', 'Tom Cairney'),
('2024-05-19', 'Arsenal v Everton', 'Dominic Calvert-Lewin'),
('2023-10-07', 'Everton v Bournemouth', 'Dominic Calvert-Lewin'),
('2024-01-30', 'Fulham v Everton', 'Dominic Calvert-Lewin'),
('2024-01-30', 'Fulham v Everton', 'Castagne'),
('2023-12-27', 'Brentford v Wolves', 'Matheus Cunha'),
('2023-08-14', 'Man Utd v Wolves', 'Matheus Cunha'),
('2024-02-24', 'Man Utd v Fulham', 'Diogo Dalot'),
('2023-08-19', 'Fulham v Brentford', 'Bobby De Cordova-Reid'),
('2024-04-24', 'Everton v Liverpool', 'Luis Diaz'),
('2024-05-19', 'Liverpool v Wolves', 'Luis Diaz'),
('2024-04-27', 'West Ham v Liverpool', 'Luis Diaz'),
('2024-03-10', 'Liverpool v Man City', 'Jeremy Doku'),
('2023-12-03', 'Man City v Tottenham', 'Jeremy Doku'),
('2023-09-23', 'Brentford v Everton', 'Abdoulaye Doucoure'),
('2023-12-06', 'Aston Villa v Man City', 'Douglas Luiz'),
('2023-10-29', 'Brighton v Fulham', 'Lewis Dunk'),
('2024-02-24', 'Crystal Palace v Burnley', 'Odsonne Edouard'),
('2024-03-09', 'Crystal Palace v Luton', 'Odsonne Edouard'),
('2024-05-06', 'Crystal Palace v Man Utd', 'Odsonne Edouard'),
('2024-04-27', 'West Ham v Liverpool', 'Harvey Elliott'),
('2024-04-14', 'Liverpool v Crystal Palace', 'Wataru Endo'),
('2023-12-02', 'Nottm Forest v Everton', 'Felipe'),
('2023-08-12', 'Brighton v Luton', 'Evan Ferguson'),
('2024-04-13', 'Bournemouth v Man Utd', 'Bruno Fernandes'),
('2024-04-27', 'Man Utd v Burnley', 'Bruno Fernandes'),
('2023-10-21', 'Sheff Utd v Man Utd', 'Bruno Fernandes'),
('2023-12-27', 'Everton v Man City', 'Phil Foden'),
('2024-01-13', 'Chelsea v Fulham', 'Conor Gallagher'),
('2024-04-04', 'Chelsea v Man Utd', 'Conor Gallagher'),
('2024-05-05', 'Chelsea v West Ham', 'Conor Gallagher'),
('2024-04-27', 'Everton v Brentford', 'James Garner'),
('2023-09-30', 'Everton v Luton', 'James Garner'),
('2024-04-02', 'Newcastle v Everton', 'James Garner'),
('2023-12-23', 'Tottenham v Everton', 'James Garner'),
('2023-10-07', 'Crystal Palace v Nottm Forest', 'Morgan Gibbs-White'),
('2024-05-11', 'Nottm Forest v Chelsea', 'Morgan Gibbs-White'),
('2024-04-03', 'Man City v Aston Villa', 'Sergio Gomez'),
('2023-10-21', 'Newcastle v Crystal Palace', 'Anthony Gordon'),
('2023-12-16', 'Newcastle v Fulham', 'Anthony Gordon'),
('2023-10-08', 'Brighton v Liverpool', 'Gravenberch'),
('2023-12-28', 'Brighton v Tottenham', 'Pierre-Emile Hojbjerg'),
('2023-08-27', 'Sheff Utd v Man City', 'Erling Haaland'),
('2024-05-19', 'Arsenal v Everton', 'Kai Havertz'),
('2023-12-31', 'Fulham v Arsenal', 'Andreas Pereira'),
('2024-04-21', 'Fulham v Liverpool', 'Andreas Pereira'),
('2023-12-06', 'Fulham v Nottm Forest', 'Andreas Pereira'),
('2024-04-27', 'Newcastle v Sheff Utd', 'Mason Holgate'),
('2024-05-04', 'Sheff Utd v Nottm Forest', 'Hudson-Odoi'),
('2023-11-27', 'Fulham v Wolves', 'Hwang Hee-Chan'),
('2024-03-10', 'West Ham v Burnley', 'Danny Ings'),
('2023-10-08', 'West Ham v Newcastle', 'Alexander Isak'),
('2024-05-04', 'Brentford v Fulham', 'Alex Iwobi'),
('2024-04-27', 'Aston Villa v Chelsea', 'Nicolas Jackson'),
('2023-09-17', 'Bournemouth v Chelsea', 'Nicolas Jackson'),
('2024-03-02', 'Brentford v Chelsea', 'Vitaly Janelt'),
('2024-03-30', 'Brentford v Man Utd', 'Jorgensen'),
('2023-09-30', 'Bournemouth v Arsenal', 'Gabriel Jesus'),
('2024-01-30', 'Nottm Forest v Arsenal', 'Gabriel Jesus'),
('2023-08-12', 'Everton v Fulham', 'Raul Jimenez'),
('2024-04-20', 'Sheff Utd v Burnley', 'Johann Gudmundsson'),
('2023-12-10', 'Tottenham v Newcastle', 'Brennan Johnson'),
('2023-12-10', 'Tottenham v Newcastle', 'Brennan Johnson'),
('2023-10-29', 'Liverpool v Nottm Forest', 'Anthony Elanga'),
('2024-04-02', 'Nottm Forest v Fulham', 'Anthony Elanga'),
('2024-05-15', 'Brighton v Chelsea', 'Joao Pedro'),
('2023-12-16', 'Burnley v Everton', 'Michael Keane'),
('2024-04-13', 'Bournemouth v Man Utd', 'Milos Kerkez'),
('2024-04-06', 'Luton v Bournemouth', 'Justin Kluivert'),
('2023-12-02', 'Burnley v Sheff Utd', 'Luca Koleosho'),
('2023-11-04', 'Brentford v West Ham', 'Kudus'),
('2024-05-11', 'West Ham v Luton', 'Kudus'),
('2023-11-26', 'Tottenham v Aston Villa', 'Dejan Kulusevski'),
('2023-08-19', 'Wolves v Brighton', 'Mario Lemina'),
('2023-12-06', 'Crystal Palace v Bournemouth', 'Jefferson Lerma'),
('2023-11-25', 'Luton v Crystal Palace', 'Jefferson Lerma'),
('2023-09-02', 'Brentford v Bournemouth', 'Keane Lewis-Potter'),
('2024-01-20', 'Brentford v Nottm Forest', 'Keane Lewis-Potter'),
('2023-10-02', 'Fulham v Chelsea', 'Ian Maatsen'),
('2023-10-28', 'Chelsea v Brentford', 'Noni Madueke'),
('2023-12-02', 'Arsenal v Wolves', 'Martinelli'),
('2023-12-30', 'Crystal Palace v Brentford', 'Neal Maupay'),
('2024-03-30', 'Brentford v Man Utd', 'Bryan Mbeumo'),
('2024-04-20', 'Luton v Brentford', 'Bryan Mbeumo'),
('2024-04-27', 'Everton v Brentford', 'Dwight McNeil'),
('2023-12-30', 'Wolves v Everton', 'Dwight McNeil'),
('2023-12-28', 'Brighton v Tottenham', 'James Milner'),
('2023-09-30', 'Everton v Luton', 'Carlton Morris'),
('2024-04-06', 'Luton v Bournemouth', 'Carlton Morris'),
('2023-09-23', 'Luton v Wolves', 'Carlton Morris'),
('2023-12-06', 'Man Utd v Chelsea', 'Mykhailo Mudryk'),
('2024-02-24', 'Man Utd v Fulham', 'Rodrigo Muniz'),
('2024-03-30', 'Sheff Utd v Fulham', 'Rodrigo Muniz'),
('2023-11-11', 'Crystal Palace v Everton', 'Vitalii Mykolenko'),
('2023-11-26', 'Everton v Man Utd', 'Vitalii Mykolenko'),
('2023-09-03', 'Liverpool v Aston Villa', 'Darwin Nunez'),
('2023-09-03', 'Liverpool v Aston Villa', 'Darwin Nunez'),
('2024-01-31', 'Liverpool v Chelsea', 'Darwin Nunez'),
('2024-01-31', 'Liverpool v Chelsea', 'Darwin Nunez'),
('2023-12-03', 'Liverpool v Fulham', 'Darwin Nunez'),
('2023-09-24', 'Liverpool v West Ham', 'Darwin Nunez'),
('2023-11-05', 'Luton v Liverpool', 'Darwin Nunez'),
('2023-10-21', 'Bournemouth v Wolves', 'Pedro Neto'),
('2023-12-02', 'Arsenal v Wolves', 'Eddie Nketiah'),
('2024-04-13', 'Man City v Luton', 'Matheus Nunes'),
('2024-03-09', 'Wolves v Fulham', 'Adarabioyo'),
('2024-05-02', 'Chelsea v Tottenham', 'Cole Palmer'),
('2023-08-26', 'Brighton v West Ham', 'Emerson'),
('2023-08-12', 'Bournemouth v West Ham', 'Lucas Paqueta'),
('2023-08-12', 'Brighton v Luton', 'Pascal Gross'),
('2023-08-12', 'Everton v Fulham', 'Nathan Patterson'),
('2023-11-26', 'Tottenham v Aston Villa', 'Pedro Porro'),
('2023-08-19', 'Tottenham v Man Utd', 'Pedro Porro'),
('2024-03-02', 'Brentford v Chelsea', 'Sergio Reguilon'),
('2024-03-09', 'Arsenal v Brentford', 'Declan Rice'),
('2024-03-30', 'Chelsea v Burnley', 'Jay Rodriguez'),
('2024-01-14', 'Man Utd v Tottenham', 'Cristian Romero'),
('2024-04-28', 'Tottenham v Arsenal', 'Cristian Romero'),
('2023-08-12', 'Bournemouth v West Ham', 'Joe Rothwell'),
('2023-12-28', 'Arsenal v West Ham', 'Bukayo Saka'),
('2024-03-04', 'Sheff Utd v Arsenal', 'Bukayo Saka'),
('2023-12-26', 'Burnley v Liverpool', 'Mohamed Salah'),
('2023-08-13', 'Chelsea v Liverpool', 'Mohamed Salah'),
('2024-04-28', 'Nottm Forest v Man City', 'Murillo'),
('2024-03-30', 'Bournemouth v Everton', 'Antoine Semenyo'),
('2024-04-24', 'Wolves v Bournemouth', 'Marcos Senesi'),
('2024-05-11', 'Nottm Forest v Chelsea', 'Thiago Silva'),
('2023-11-11', 'Bournemouth v Newcastle', 'Sinisterra'),
('2024-05-19', 'Arsenal v Everton', 'Emile Smith Rowe'),
('2024-05-19', 'Chelsea v Bournemouth', 'Dominic Solanke'),
('2023-11-04', 'Man City v Bournemouth', 'Dominic Solanke'),
('2023-12-09', 'Man Utd v Bournemouth', 'Dominic Solanke'),
('2024-03-02', 'Tottenham v Crystal Palace', 'Son Heung-Min'),
('2024-03-30', 'Tottenham v Luton', 'Son Heung-Min'),
('2023-11-12', 'West Ham v Nottm Forest', 'Tomas Soucek'),
('2023-09-17', 'Bournemouth v Chelsea', 'Raheem Sterling'),
('2024-01-13', 'Chelsea v Fulham', 'Raheem Sterling'),
('2023-08-12', 'Brighton v Luton', 'Danny Welbeck'),
('2024-04-06', 'Luton v Bournemouth', 'Marcus Tavernier'),
('2024-04-02', 'Nottm Forest v Fulham', 'Kenny Tete'),
('2024-04-14', 'Arsenal v Aston Villa', 'Youri Tielemans'),
('2024-02-24', 'Aston Villa v Nottm Forest', 'Youri Tielemans'),
('2023-08-20', 'West Ham v Chelsea', 'Lucas Paqueta'),
('2024-03-30', 'Brentford v Man Utd', 'Ivan Toney'),
('2024-04-02', 'Nottm Forest v Fulham', 'Adama Traore'),
('2023-11-25', 'Newcastle v Chelsea', 'Kieran Trippier'),
('2023-12-02', 'Newcastle v Man Utd', 'Kieran Trippier'),
('2023-12-26', 'Sheff Utd v Luton', 'Auston Trusty'),
('2024-02-17', 'Brentford v Liverpool', 'Virgil van Dijk'),
('2023-08-19', 'Liverpool v Bournemouth', 'Virgil van Dijk'),
('2023-12-28', 'Brighton v Tottenham', 'Jan Paul van Hecke'),
('2023-12-07', 'Tottenham v West Ham', 'James Ward-Prowse'),
('2024-04-14', 'Arsenal v Aston Villa', 'Ollie Watkins'),
('2023-09-16', 'Aston Villa v Crystal Palace', 'Ollie Watkins'),
('2024-03-02', 'Luton v Aston Villa', 'Ollie Watkins'),
('2023-10-08', 'Wolves v Aston Villa', 'Ollie Watkins'),
('2023-12-15', 'Nottm Forest v Tottenham', 'Neco Williams'),
('2023-10-07', 'Fulham v Sheff Utd', 'Harry Wilson'),
('2024-05-19', 'Luton v Fulham', 'Harry Wilson'),
('2023-12-16', 'Newcastle v Fulham', 'Callum Wilson'),
('2023-09-02', 'Brentford v Bournemouth', 'Yoane Wissa'),
('2024-03-30', 'Brentford v Man Utd', 'Yoane Wissa'),
('2024-05-04', 'Sheff Utd v Nottm Forest', 'Chris Wood'),
('2024-04-07', 'Tottenham v Nottm Forest', 'Chris Wood'),
('2024-04-13', 'Man City v Luton', 'Cauley Woodrow'),
('2024-05-11', 'Nottm Forest v Chelsea', 'Ryan Yates');;

CREATE TEMP TABLE sot_selections
DISTSTYLE KEY 
DISTKEY (selection_id) AS
SELECT
    rs.selection_id,
    rs.market_id,
    rs.event_id,
    s.event_name,
    TRIM(SPLIT_PART(s.event_name, ' v ', 1)) AS home_team,
    TRIM(SPLIT_PART(s.event_name, ' v ', 2)) AS away_team,
    s.market_name,
    rs.selection_name,
    CASE    
        WHEN rs.result_type = 'WIN' THEN 1
        ELSE 0
    END AS result_type,
    -- Extract minimum quantity threshold
    CASE

        WHEN REGEXP_SUBSTR(TRIM(market_name), '\\d+') IS NOT NULL THEN
            CAST(NULLIF(TRIM(REGEXP_SUBSTR(TRIM(market_name), '\\d+')), '') AS INTEGER)
        WHEN REGEXP_SUBSTR(TRIM(selection_name), '\\d+') IS NOT NULL THEN
            CAST(NULLIF(TRIM(REGEXP_SUBSTR(TRIM(selection_name), '\\d+')), '') AS INTEGER)
        ELSE NULL
    END AS sot_level,
    COUNT(DISTINCT leg_id) AS bets_laid
FROM 
        omni_sportsbook.vw_sportsbook_summary s
JOIN
        omni_betevent.ramp_vw_selection rs
ON
    rs.selection_id = s.ramp_selection_id
    AND rs.market_id = s.ramp_market_id
    AND rs.event_id = s.ramp_event_id
JOIN 
    woodwork_hit wh
ON  
    wh.sportex_selection_name = s.sportex_selection_name
AND wh.event_name = s.event_name
-- AND wh.event_scheduled_start_datetime = s.event_scheduled_start_datetime
WHERE
    1=1
    AND s.market_name LIKE '%Target%'
    AND s.market_name != 'Player Headed Shots On Target'
    AND s.market_group = 'Player Props'
    AND s.market_name NOT LIKE '%Outside%'
    AND brand = 'PP'
    AND s.placed_datetime > '2023-08-01'::DATE
    AND s.placed_datetime < '2024-06-01'::DATE
--     AND competition = 'English Premier League'
GROUP BY 
    1,2,3,4,5,6,7,8,9,10
ORDER BY
    rs.selection_id,
    rs.market_id,
    rs.event_id;


CREATE TEMP TABLE sot_actual AS
SELECT
    ss.event_id,
    ss.home_team,
    ss.away_team,
    ss.selection_name,
    -- calc actual_sot as an aggregate for each group
    CASE
        WHEN MAX(CASE WHEN ss.sot_level = 1 AND ss.result_type = 0 THEN 1 ELSE 0 END) = 1 THEN 0
        WHEN MIN(CASE WHEN ss.result_type = 1 THEN ss.sot_level ELSE NULL END) IS NOT NULL THEN
            MIN(CASE WHEN ss.result_type = 1 THEN ss.sot_level ELSE NULL END)

        ELSE NULL
    END AS actual_sot
FROM
    sot_selections ss
WHERE
    LENGTH(ss.selection_name) - LENGTH(REPLACE(ss.selection_name, '|', '')) < 2
GROUP BY
    ss.event_id,
    ss.home_team,
    ss.away_team,
    ss.selection_name
ORDER BY
    ss.event_id,
    ss.home_team,
    ss.away_team,
    ss.selection_name;

CREATE TEMP TABLE sot_with_next_laid AS
SELECT DISTINCT
    ss2.event_id,
    ss2.market_id,
    ss2.selection_id,
    ss2.home_team,
    ss2.away_team,
    ss2.event_name,
    ss1.selection_name,
    sa.actual_sot,
    ss2.sot_level,
    ss1.bets_laid,
    ss2.bets_laid AS total_bets_laid_on_next_sot_level,
    ss2.result_type,
    ss2.sot_level AS next_sot_level_laid
FROM
    sot_actual sa
JOIN
    sot_selections ss1
ON
    sa.event_id = ss1.event_id
    AND sa.home_team = ss1.home_team
    AND sa.away_team = ss1.away_team
    AND sa.selection_name = ss1.selection_name
JOIN
    sot_selections ss2
    ON ss1.event_name = ss2.event_name
    AND ss1.home_team = ss2.home_team
    AND ss1.away_team = ss2.away_team
    AND ss1.selection_name = ss2.selection_name 
    AND sa.actual_sot + 1 = ss2.sot_level
WHERE 
    ss1.sot_level IS NOT NULL;

CREATE TEMP TABLE wood_liable_sots AS
SELECT DISTINCT
    sl.event_id,
    sl.market_id,
    sl.selection_id,
    sl.home_team,
    sl.away_team,
    sl.selection_name,
    sl.sot_level,
    sl.actual_sot,
    sl.total_bets_laid_on_next_sot_level,
    sl.next_sot_level_laid
FROM
    sot_with_next_laid sl;

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
        s.event_scheduled_start_datetime
FROM 
        omni_sportsbook.vw_sportsbook_summary s
JOIN
        wood_liable_sots sl
ON
        s.ramp_selection_id = sl.selection_id
AND 
        s.ramp_event_id = sl.event_id
WHERE
        1=1
        AND s.placed_datetime > '2023-08-01'::DATE
        AND s.placed_datetime < '2024-06-01'::DATE
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
                AND pp.settled_datetime > '2023-08-01'::DATE
                AND pp.settled_datetime < '2024-06-01'::DATE;

CREATE TEMP TABLE bet_leg_stats AS
SELECT 
        mult_id,
        ramp_selection_id,
        SUM(CASE WHEN leg_winner_yn = 'N' THEN 1 ELSE 0 END) OVER (PARTITION BY mult_id) as losing_legs,
        COUNT(*) OVER (PARTITION BY mult_id) as total_legs
FROM selection_results;

-- CREATE TEMP TABLE woodwork_almosts AS
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
    s.event_scheduled_start_datetime,
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
        wood_liable_sots sl
ON
        sl.selection_id = s.ramp_selection_id
WHERE
        1=1
    AND s.bet_id IN (SELECT bet_id FROM all_legs_with_ww_in_bet)
    AND bs.losing_legs = 1
    AND sr.leg_winner_yn = 'N'
    AND fx.from_currency_code = 'GBP'
    AND fx.to_currency_code = 'EUR'
    AND s.brand = 'PP';


-- SELECT * FROM sot_actual;

-- SELECT
--         sportex_selection_name,
--         -- bet_type,
--         -- in_play_yn,
--         SUM(stake) AS total_stakes,
--         SUM(potential_payout) AS total_payout
-- FROM
--         woodwork_almosts
-- GROUP BY 
--         1
-- ORDER BY total_payout DESC;