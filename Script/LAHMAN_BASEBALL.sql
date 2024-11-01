
-- 1. What range of years for baseball games played does the provided database cover? 

  SELECT 
  MIN(yearid)
  ,MAX(yearid)
  FROM collegeplaying

  
-- 2. Find the name and height of the shortest player in the database. How many games did he play in? 
-- What is the name of the team for which he played?

   
  
SELECT p.playerid,	 				   
CONCAT(p.namefirst ,p.namelast), 	
		p.height, t.name, a.g_all
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
INNER JOIN teams AS t
ON t.teamid = a.teamid
ORDER BY height
LIMIT 1;
  





-- 3. Find all players in the database who played at Vanderbilt University.
--  Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues.
--  Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
   SELECT *
   FROM collegeplaying

   

  SELECT DISTINCT(playerid)
  FROM collegeplaying
  WHERE schoolid = 'vandy';

  
-- Question 3

    SELECT namefirst, namelast
    , SUM(salary) as total_salary
    FROM people
    INNER JOIN salaries AS salary
    USING (playerid)
    WHERE playerid IN (SELECT DISTINCT(playerid)
    FROM collegeplaying
    WHERE schoolid = 'vandy')
    GROUP BY namefirst, namelast
    ORDER BY total_salary DESC




-- 4. Using the fielding table, group players into three groups based on their position:
--  label players with position OF as "Outfield", those with position "SS", "1B", "2B", 
-- and "3B" as "Infield", and those with position "P" or "C" as "Battery".
--  Determine the number of putouts made by each of these three groups in 2016.




SELECT
	CASE WHEN f.pos = 'OF' THEN 'Outfield'
	     WHEN f.pos = 'SS' OR f.pos = '1B' OR f.pos = '2B' OR f.pos = '3B' THEN 'Infield'
	     WHEN f.pos = 'P' OR f.pos = 'C' THEN 'Battery'
    END as position
	,COUNT(f.po) AS putouts_count
	FROM fielding f
	WHERE yearid = '2016'
	-- GROUP BY CASE WHEN f.pos = 'OF' THEN 'Outfield'
	-- WHEN f.pos = 'SS' OR f.pos = '1B' OR f.pos = '2B' OR f.pos = '3B' THEN 'Infield'
	-- WHEN f.pos = 'P' OR f.pos = 'C' THEN 'Battery'
    -- END
   GROUP BY position



-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. 
-- Do the same for home runs per game. Do you see any trends?
-- 6. Find the player who had the most success stealing bases in 2016, 
-- where __success__ is measured as the percentage of stolen base attempts which are successful. 
-- (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.


FLOOR(yearid/10)*10 as decade,
ROUND(sum(so)/sum(g)::Numeric,2) as AVG_strikeouts_game,
	ROUND(sum (hr)/sum(g)::NUMERIC, 2) as avg_HR_game
FROM teams
where yearid >= 1920
GROUP BY decade
ORDER BY decade



-- 6. Find the player who had the most success stealing bases in 2016, 
-- where __success__ is measured as the percentage of stolen base attempts which are successful. 
-- (A stolen base attempt results either in a stolen base or being caught stealing.) 
-- Consider only players who attempted _at least_ 20 stolen bases.


SELECT 
		CONCAT(p.namefirst,' ',p.namelast) as name
	,	round(SUM(b.sb)*1.0/ (SUM(b.sb)+SUM(b.cs))*100,2) as Percentage

FROM batting as b
JOIN people as p
ON b.playerid=p.playerid
WHERE yearid = 2016 

AND p.playerid IS NOT NULL
GROUP BY CONCAT(p.namefirst,' ',p.namelast)
HAVING SUM(b.sb)+SUM(b.cs) >= 20
ORDER BY percentage DESC
LIMIT 1;



-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? 
-- What is the smallest number of wins for a team that did win the world series? 
-- Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. 
-- Then redo your query, excluding the problem year.
--  How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?


SELECT w,yearid,teamid,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 and wswin = 'N'
ORDER BY w DESC


SELECT w,yearid,teamid,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'Y'
ORDER BY w


SELECT w,yearid,teamid,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 AND wswin = 'Y' AND yearid <> 1981
ORDER BY w






-- Question 7

WITH max_wins as
	(SELECT MAX(w)as max_wins,yearid
	FROM teams
	WHERE yearid BETWEEN 1970 AND 2016 AND yearid <> 1981
	GROUP BY yearid)
SELECT --t.yearid
	-- ,t.w
	-- ,t.wswin
	-- ,t.teamid
	-- ROUND(COUNT(CASE WHEN t.wswin = 'Y' THEN 1 END) * 100.0 / NULLIF(COUNT (DISTINCT t.yearid)),0),2) AS PERCENTAGE
	COUNT (DISTINCT t.yearid)
	--(COUNT(CASE WHEN t.wswin = 'Y' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) AS wswin_percentage
	       -- (SUM(CASE WHEN t.wswin='Y' THEN 1 ELSE 0 END)/
	-- NULLIF (SUM(CASE WHEN t.wswin='N' THEN 1 ELSE 0 END)*100)) as percentage
FROM teams as t
JOIN max_wins as mw
ON t.yearid=mw.yearid AND t.w=mw.max_wins
WHERE wswin IN ('Y','N')
    --t.yearid BETWEEN 1970 AND 2016 AND t.yearid <> 1981
--GROUP BY 1,2,3,





    -- 8. Using the attendance figures from the homegames table, 
    -- find the teams and parks which had the top 5 average attendance per game in 2016 
    -- (where average attendance is defined as total attendance divided by number of games). 
    -- Only consider parks where there were at least 10 games played. Report the park name,
	-- team name, and average attendance. 
    -- Repeat for the lowest 5 average attendance.
	


	SELECT *
	FROM teams

	
	SELECT team, park, attendance
	FROM homegames

 

   SELECT park as park_name
   , team as teams_name
   , attendance/games as average_attendance
   FROM homegames 



   

-- Question 8

   SELECT p.park_name
   , t.name as teams_name
   , h.attendance/games as average_attendance
   FROM homegames AS h
   JOIN parks AS p
   ON h.park = p.park
   JOIN teams as t
   ON t.teamid = h.team AND t.yearid = h.year
   WHERE year = 2016 AND games >= 10
   ORDER BY average_attendance DESC
   LIMIT 5;



   

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? 
-- Give their full name and the teams that they were managing when they won the award. 

-- TSN Manager of the Year award in AL

  SELECT playerid,teamid as alteam, yearid as al_year
       FROM awardsmanagers
       INNER JOIN managers
       USING (playerid, yearid)
       WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'AL'
	   
-- TSN Manager of the Year award in NL

SELECT playerid, teamid as nlteam, yearid as nl_year
    FROM awardsmanagers 
    INNER JOIN managers
    USING (playerid, yearid)
    WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL'


SELECT *
FROM awardsmanagers



-- Question 9

WITH al_awards as  
      (SELECT playerid
	  ,teamid as alteam
	  , yearid as al_year
       FROM awardsmanagers
       INNER JOIN managers
       USING (playerid, yearid)
       WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'AL')
	   ,
	nl_awards as 
	 (SELECT playerid
	, teamid as nlteam
	, yearid as nl_year
    FROM awardsmanagers 
    INNER JOIN managers
    USING (playerid, yearid)
    WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL')
    SELECT namefirst
	, namelast
	, al_year
	, nl_year
	, alteam
	, nlteam
    FROM al_awards
    INNER JOIN nl_awards
    USING (playerid)
    INNER JOIN people
    USING (playerid)





	


-- 10. Find all players who hit their career highest number of home runs in 2016.
--  Consider only players who have played in the league for at least 10 years,
--  and who hit at least one home run in 2016.
-- Report the players' first and last names and the number of home runs they hit in 2016.

   SELECT *
   FROM batting

   SELECT playerid, MAX(hr) as maxhr
   FROM batting 
   GROUP BY playerid


 SELECT playerid, yearid, MAX(hr)
   FROM batting
   WHERE yearid = 2016 AND hr >= 1
   GROUP BY playerid, yearid, hr

   




-- Question 10

 SELECT CONCAT(namefirst,' ',namelast) as name, b.hr
FROM people as p
JOIN batting as b
ON p.playerid = b.playerid
JOIN
	(SELECT playerid, MAX(hr) as max_hr
	 FROM batting
	 GROUP BY playerid) as max_homerun
	 On p.playerid = max_homerun.playerid
JOIN
	(SELECT playerid, COUNT(DISTINCT yearid) as years_played
	 FROM batting
	 GROUP BY playerid) as career_years
	 ON p.playerid = career_years.playerid
WHERE b.yearid = 2016
	AND career_years.years_played >= 10
	AND b.hr = max_homerun.max_hr
	AND b.hr >0 

   
   
--   SELECT
-- 	playerid
-- ,	yearid
-- ,	SUM(hr) AS total_hr
-- FROM batting
-- WHERE yearid = 2016 and HR >= 1
-- GROUP BY 
-- 	playerid
-- ,	yearid
-- ORDER BY 
-- 	total_hr DESC
  



 