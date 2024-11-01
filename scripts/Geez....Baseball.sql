select *
from people

-- Q1.


select min(year) as start_year, max(year) as latest_year
from homegames

--Q2.



-- Q2 final query with


SELECT p.playerid,	 				   CONCAT(p.namefirst ,p.namelast), 	
		p.height, t.name, a.g_all
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
INNER JOIN teams AS t
ON t.teamid = a.teamid
ORDER BY height
LIMIT 1;

--Q3




--Q3 subqeury version final-- add names 

SELECT  CONCAT(p.namefirst,' ',p.namelast),
	   SUM(s.salary::DECIMAL)::MONEY as 					total_salary
FROM
	(select  DISTINCT playerid, schoolid
	FROM collegeplaying
	Where schoolid ILIKE '%Vandy%') as 		collegeplaying
JOIN people as p
ON collegeplaying.playerid=p.playerid
join salaries as s
on s.playerid=p.playerid
GROUP BY 1
order by total_salary DESC



















--Q4
-- how do you get the year??
SELECT   
SUM(f.po) as putouts, 

  Case When f.pos = 'OF' THEN 'Outfield'
	 WHEN f.pos IN ('SS','1B','2B','3B') THEN 'Infield'
	 WHEN f.pos IN ('P','C') THEN 'Battery'
     END as position_category
FROM fielding as f
Join people as p
on f.playerid=p.playerid
Where yearid = '2016'
GROUP BY  position_category 
	-- Case When f.pos = 'OF' THEN 'Outfield'
	--  WHEN f.pos IN ('SS','1B','2B','3B') THEN 'Infield'
	--  WHEN f.pos IN ('P','C') THEN 'Battery'
 --     END


--Q5

Select 
	FLOOR(yearid/10)*10 as decade,

ROUND(sum(so)/sum(g)::Numeric,2) as AVG_strikeouts_game,

	ROUND(sum (hr)/sum(g)::NUMERIC, 2) as avg_HR_game
FROM teams
where yearid >= 1920
GROUP BY decade
ORDER BY decade
	 

--Q6
-- SELECT playerid, 
-- FROM (SELECT DISTINCT playerid
-- FROM people) as people
-- JOIN appearances as a
-- on people.playerid=a.playerid
-- join teams as t
-- on a.teamid=t.teamid
-- where t.yearid = 2016
SELECT 
		--p.playerid
		CONCAT(p.namefirst,' ',p.namelast) as name
	,	round(SUM(b.sb)*1.0/ (SUM(b.sb)+SUM(b.cs))*100,2) as Percentage

from batting as b
join people as p
on b.playerid=p.playerid
WHERE yearid = 2016 

AND p.playerid IS NOT NULL
GROUP BY CONCAT(p.namefirst,' ',p.namelast)
HAVING SUM(b.sb)+SUM(b.cs) >= 20
ORDER BY percentage DESC

-- in a CTE or subquery

SELECT playerid, sum(sb) as sum_sb, sum(cs) as sum_cs
From batting
WHere yearid = 2016
GROUP BY 1

--Q7a
Select w,yearid,teamid,wswin 
from teams
where yearid BETWEEN 1970 AND 2016 and wswin = 'N'
Order BY w DESC

--7b
Select w,yearid,teamid,wswin 
from teams
where yearid BETWEEN 1970 AND 2016 and wswin = 'Y'
Order BY w 

-- checking specific year for total games to find discrepencies
select sum(G) as games_total,yearid,wswin
from teams
WHERE yearid BETWEEN 1970 AND 2016 and wswin='Y'
group by 2,3
order by games_total

--7c
Select w,yearid,teamid,wswin 
from teams
where yearid BETWEEN 1970 AND 2016 and wswin = 'Y' AND yearid <> 1981
Order BY w 

--7d
select max(w), yearid,
from teams
where yearid BETWEEN 1970 and 2016  and yearid <> 1981
group by yearid
order by yearid


select MAX(w)
from teams 


With MAX_scores as
	(select max(w), yearid
		from teams
		GROUP BY yearid)
		
select t.wswin,t.yearid, t.w
from teams as t
JOIN max_scores as ms
on t.yearid=ms.yearid
WHERE t.yearid BETWEEN 1970 and 2016  and t.yearid <> 1981
order by t.yearid



SELECT yearid,wswin,max(w)
from teams
WHERE yearid BETWEEN 1970 and 2016  and yearid <> 1981
group by 1,2
order by yearid 


--Q7 query before percentage output

with max_wins as 
	(SELECT MAX(w)as max_wins,yearid
	from teams
	WHERE yearid BETWEEN 1970 and 2016  and yearid <> 1981
	group by yearid)
 
select t.yearid
	,t.w
	,t.wswin
	,t.teamid
	,ROUND(COUNT(CASE WHEN t.wswin = 'Y' THEN 1 END) * 100.0 / NULLIF(count(*),0),0) AS PERCENTAGE
	
	--(COUNT(CASE WHEN t.wswin = 'Y' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) AS wswin_percentage
	       -- (SUM(CASE WHEN t.wswin='Y' THEN 1 ELSE 0 END)/
	-- NULLIF (SUM(CASE WHEN t.wswin='N' THEN 1 ELSE 0 END)*100)) as percentage
from teams as t
 join max_wins as mw
on t.yearid=mw.yearid AND t.w=mw.max_wins

--WHERE wswin IN ('Y','N')
    --t.yearid BETWEEN 1970 AND 2016 AND t.yearid <> 1981
GROUP BY 1,2,3,4,t.yearid


--Q7 query as percentage output

with max_wins as 
	(SELECT MAX(w)as max_wins,yearid
	from teams
	WHERE yearid BETWEEN 1970 and 2016  and yearid <> 1981
	group by yearid)
 
select --t.yearid
	-- ,t.w
	-- ,t.wswin
	-- ,t.teamid
	ROUND(COUNT(CASE WHEN t.wswin = 'Y' THEN 1 END) * 100.0 / NULLIF(count(*),0),0) AS PERCENTAGE
	
	--(COUNT(CASE WHEN t.wswin = 'Y' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) AS wswin_percentage
	       -- (SUM(CASE WHEN t.wswin='Y' THEN 1 ELSE 0 END)/
	-- NULLIF (SUM(CASE WHEN t.wswin='N' THEN 1 ELSE 0 END)*100)) as percentage
from teams as t
 join max_wins as mw
on t.yearid=mw.yearid AND t.w=mw.max_wins

WHERE wswin IN ('Y','N')
    --t.yearid BETWEEN 1970 AND 2016 AND t.yearid <> 1981
--GROUP BY 1,2,3,4


--Q8a
SELECT attendance/games as avg_att, park, team
from homegames
where year =2016 and games >= 10
order by avg_att DESC
LIMIT 5

--
SELECT attendance/games as avg_att, park, team
from homegames
where year =2016 and games >= 10
order by avg_att 
LIMIT 5

9.
SELECT playerid, teamid, m.yearid
from awardsmanagers as AM
join managers as m
USING (playerid,yearid) 
WHERE awardid = 'TSN Manager of the Year' and AM.lgid = 'NL'


SELECT playerid, teamid, m.yearid
from awardsmanagers as AM
join managers as m
USING (playerid,yearid) 
WHERE awardid = 'TSN Manager of the Year' and AM.lgid = 'AL'

With NL_awards AS
(SELECT playerid, teamid as nl_team, m.yearid as nl_year
from awardsmanagers as AM
join managers as m
USING (playerid,yearid) 
WHERE awardid = 'TSN Manager of the Year' and AM.lgid = 'NL' ),

 AL_awards AS (SELECT playerid , m.teamid as AL_team,  m.yearid as AL_year 
from awardsmanagers as AM
join managers as m
USING (playerid,yearid) 
WHERE awardid = 'TSN Manager of the Year' and AM.lgid = 'AL')

SElECT namelast, namefirst, AL_year,AL_team, NL_year, NL_team
from NL_awards
JOIn AL_awards
USING (playerid)
JOIN people 
using (playerid)

--10

SELECT CONCAT(namelast,' ', namefirst) as NAME, hr    
FROM people as p
JOIN batting as b
ON p.playerid=b.playerid 
JOIN appearances as a
on p.playerid=a.playerid
WHERE a.yearid >= 10 


SELECT CONCAT(p.namefirst, ' ', p.namelast) AS NAME, b2016.hr AS Home_Runs_2016
FROM people AS p
JOIN batting AS b2016 ON p.playerid = b2016.playerid
JOIN (
    -- Subquery to find each player's career-high home run count
    SELECT playerid, MAX(hr) AS max_hr
    FROM batting
    GROUP BY playerid
) AS career_high ON p.playerid = career_high.playerid
JOIN (
    -- Subquery to count years a player appeared in the league
    SELECT playerid, COUNT(DISTINCT yearid) AS years_played
    FROM batting
    GROUP BY playerid
) AS career_duration ON p.playerid = career_duration.playerid
WHERE b2016.yearid = 2016
  AND b2016.hr > 0
  AND b2016.hr = career_high.max_hr
  AND career_duration.years_played >= 10;

--10 final answer!
SELECT CONCAT(namefirst,' ',namelast) as name, b.hr
from people as p
join batting as b
ON p.playerid=b.playerid
JOIN 
	(SELECT playerid, MAX(hr) as max_hr
	 FROM batting
	 GROUP BY playerid) as max_homerun On p.playerid=max_homerun.playerid
JOIN 
	(select playerid, COUNT(DISTINCT yearid) as years_played
	 FROM batting
	 GROUP BY playerid) as career_years ON p.playerid=career_years.playerid
WHERE b.yearid = 2016
	AND career_years.years_played >= 10 
	AND b.hr = max_homerun.max_hr
	AND b.hr >0
	 