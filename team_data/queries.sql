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