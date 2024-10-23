select *
from people

-- Q1.


select min(year) as start_year, max(year) as latest_year
from homegames

--Q2.

--select Concat(p.namefirst,'',p.namelast), p.height 
from people as p
inner join managershalf as m
on p.playerid=m.playerid
inner join teams as t
on m.yearid=t.yearid
group by p.playerid
order by  height 
limit 1

-- Q2 final query with

select p.height, concat(namefirst,' ',namelast) as full_name, t.name as Team, a.g_all as Games_Played 
from people as p
inner join appearances as a
on p.playerid=a.playerid
inner join teams as t
on a.teamid=t.teamid
order by height
limit 1

SELECT p.playerid, CONCAT(p.namefirst ,p.namelast), p.height, t.name, a.g_all
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
INNER JOIN teams AS t
ON t.teamid = a.teamid
ORDER BY height
LIMIT 1;