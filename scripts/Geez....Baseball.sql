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

--"castrst01"	4	0
select *
from batting 
where yearid =2016 and playerid = 'arciaos01'

