select rusher_player_id, rusher_player_name, ydstogo, yards_gained
from plays
where rush_attempt = 1;

select avg(yards_gained) as average_rushing_yards, ydstogo
from plays
where rush_attempt = 1
group by ydstogo;

/*finding the expected yards for a player to gain vs what they gained*/
select rusher_player_id, rusher_player_name, yards_gained, 0.12588674*ydstogo + 3.4733651 as yards_expected
from plays
where rush_attempt = 1;

/*finding yards a player gained over/under their expected amount*/
select rusher_player_id, rusher_player_name, yards_gained, 0.12588674*ydstogo + 3.4733651 as yards_expected, yards_gained - (0.12588674*ydstogo + 3.4733651) as yards_over_expected
from plays
where rush_attempt = 1;

/*finding a player's avg RYOE*/
select rusher_player_id, rusher_player_name, yards_gained, 0.12588674*ydstogo + 3.4733651 as yards_expected, avg(yards_gained - (0.12588674*ydstogo + 3.4733651)) as avg_ryoe
from plays
where rush_attempt = 1
group by rusher_player_id
order by avg_ryoe desc;

/*finding a player's avg RYOE and considering their number of carries*/
select count(rush_attempt), rusher_player_id, rusher_player_name, yards_gained, 0.12588674*ydstogo + 3.4733651 as yards_expected, avg(yards_gained - (0.12588674*ydstogo + 3.4733651)) as avg_ryoe
from plays
where rush_attempt = 1
group by rusher_player_id
having count(rush_attempt) >= 100
order by avg_ryoe desc;

/*looking at down and distance*/
select 
    rusher_player_id, 
    rusher_player_name, 
    yards_gained, 
    ydstogo, 
    down
from plays
where rush_attempt = 1;

/*creating separate columns for second, third, and fourth down*/
SELECT 
    rusher_player_id, 
    rusher_player_name, 
    yards_gained, 
    ydstogo, 
    case 
        when down = 2 then 1 
        else 0 
        end as second_down,
    case 
        when down = 3 then 1 
        else 0 
        end as third_down,
    case 
        when down = 4 then 1 
        else 0 
        end as fourth_down
FROM plays
WHERE rush_attempt = 1;

/*Coefficients: [0.199273   0.73200072 1.12417315 0.82187461]*/
/*Intercept: 2.471750805961095*/

WITH rush_data AS (
    SELECT 
        rusher_player_id, 
        rusher_player_name, 
        yards_gained, 
        ydstogo, 
        down,  -- ✅ include this so we can use it later
        (
            0.7320007 * CASE WHEN down = 2 THEN 1 ELSE 0 END +
            1.12417315 * CASE WHEN down = 3 THEN 1 ELSE 0 END +
            0.82187461 * CASE WHEN down = 4 THEN 1 ELSE 0 END +
            0.199273 * ydstogo +
            2.471750805961095
        ) AS yards_expected
    FROM plays
    WHERE rush_attempt = 1
)
SELECT
    rusher_player_id, 
    rusher_player_name, 
    yards_gained, 
    ydstogo, 
    down,
    yards_gained - yards_expected AS ryoe
FROM rush_data;

/*averaging RYOE*/
WITH rush_data AS (
    SELECT 
        rusher_player_id, 
        rusher_player_name, 
        yards_gained, 
        ydstogo, 
        down,  -- ✅ include this so we can use it later
        (
            0.7320007 * CASE WHEN down = 2 THEN 1 ELSE 0 END +
            1.12417315 * CASE WHEN down = 3 THEN 1 ELSE 0 END +
            0.82187461 * CASE WHEN down = 4 THEN 1 ELSE 0 END +
            0.199273 * ydstogo +
            2.471750805961095
        ) AS yards_expected
    FROM plays
    WHERE rush_attempt = 1
)
SELECT
    rusher_player_id, 
    rusher_player_name, 
    yards_gained, 
    ydstogo, 
    down,
    avg(yards_gained - yards_expected) AS ryoe
FROM rush_data
GROUP BY rusher_player_id
having count(*) >= 100
order by ryoe desc
limit 10;