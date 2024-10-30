

--1. What range of years for baseball games played does the provided database cover? 

SELECT MAX(year) AS last_year, MIN(year) AS first_year --used home_games for table, used alias to create columns to help identify
FROM homegames

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played? 

--- EddieGaedel 43 St. Louis Browns 1
--A lot of duplicates, would use DISTINCT AND subquery to remove duplicates
SELECT p.playerid, CONCAT(p.namefirst,p.namelast), p.height, t.name, a.g_all  ----CONCAT names, joining ON tables is important and reflects in your answers
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
INNER JOIN teams AS t
ON t.teamid = a.teamid
ORDER BY height
LIMIT 1;


--3.Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors? 
---David Price 81851296
----College playing table has duplicates with every year having different salary, reason we have to create CTE and DISTINCT to eliminate duplicates from showing up.

WITH vanderbilt_players AS  ---creating CTE, not necessary BUT helpful to organize query and breakdown question. Give CTE valuable reference
(
	SELECT DISTINCT CONCAT(namefirst, ' ',namelast) AS player_name, 
	schoolname, 
	cp.playerid
	FROM schools
	INNER JOIN collegeplaying AS cp
	ON schools.schoolid=cp.schoolid
	INNER JOIN people
	ON cp.playerid=people.playerid
	WHERE schoolname ILIKE 'Vanderbilt University'
	GROUP BY schoolname, cp.playerid,namefirst,namelast
	)
SELECT DISTINCT player_name, SUM(salary::integer)::MONEY AS total_salary_earned --double perception had to change to decimal then to money
FROM vanderbilt_players
INNER JOIN salaries 
ON salaries.playerid=vanderbilt_players.playerid
WHERE salary IS NOT NULL
GROUP BY player_name
ORDER BY total_salary_earned DESC
LIMIT 1;



--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

--need to use sum NOT count, double check work by looking at data and able to see that the put_out_count will be high just by looking at PO column
SELECT *  ---checking data for this with the year filter
FROM fielding
WHERE yearid = 2016

SELECT 
	CASE     ----using case statement, IF WHEN to identify abrvs and rename them
		WHEN pos = 'OF' THEN 'Outfield'  ---using = because single abrv
		WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'  ----able to put multi abrvs in parenthesis. Have to use IN because of multiple abrv
		WHEN pos IN ('P','C') THEN 'Battery'
END AS positions_played---naming column
,SUM(po) AS putouts_count
FROM fielding
WHERE yearid = '2016'
GROUP BY ---OR can use positions_played to refer to the case statement
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'  
		WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield' 
		WHEN pos IN ('P','C') THEN 'Battery'
		END;




--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

 ---Converting the round functions to numeric BECAUSE, interger isnt as precise and we want to ensure that we're pulling the actual numbers (will round down if not used/ can test out by removing numeric to see difference) initially wanted to use AVG function, but need to divide strikeouts by games (g) THEN round to nearest 2nd decimal

SELECT DISTINCT(yearid)/10*10 AS decade, 
	ROUND(SUM(SO)/SUM(g)::numeric, 2) AS avg_strikeouts, --getting AVG by dividing 
	ROUND(SUM(HR)/SUM(g)::numeric, 2) AS avg_homeruns
FROM teams
WHERE yearid >= 1920   ---every decade including 1920 AND afterwards
GROUP BY decade
ORDER BY decade;


--6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

SELECT 
		CONCAT(p.namefirst,' ',p.namelast) as name
	,	round(SUM(b.sb)*1.0/ --*1.0 is for percentage
	(SUM(b.sb)+SUM(b.cs))*100,2) as Percentage --*100 for percentage

FROM batting as b
JOIN people as p
ON b.playerid=p.playerid
WHERE yearid = 2016 

AND p.playerid IS NOT NULL
GROUP BY CONCAT(p.namefirst,' ',p.namelast)
HAVING SUM(b.sb)+SUM(b.cs) >= 20
ORDER BY percentage DESC

--7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?

--7A
SELECT w,yearid,teamid,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 and wswin = 'N'
ORDER BY w DESC
--7B
SELECT w,yearid,teamid,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 and wswin = 'Y'
ORDER BY w

--7C --Player strike in 1981, not as many games
SELECT w,yearid,teamid,wswin
FROM teams
WHERE yearid BETWEEN 1970 AND 2016 and wswin = 'Y' AND yearid <> 1981
ORDER BY w


--Finding percentage
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


--8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.

SELECT team, park, attendance  --checking columns
FROM homegames



SELECT attendance/games AS average_attendance, 
park AS park_name ,
team AS team_name
FROM homegames
WHERE year = 2016 AND games >= 10
ORDER BY average_attendance DESC --remove DESC for lowest attendance for last part of question
LIMIT 5;

--9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.


--Using CTE to pull information from both criterias into one table. Finding out the individual information and forming own CTE, then coming together and joining a different table to find final answer. 

SELECT *
FROM awardsmanagers

--TSN Manager of the Year award in AL
SELECT playerid, teamid AS alteam, yearid AS al_year
FROM awardsmanagers
INNER JOIN managers
USING (playerid, yearid)  --by using, using, removing the syntax error of ambigous terms, joining on two terms
WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'AL' --ambiguous lgid term

-- TSN Manager of the year in NL
SELECT playerid, teamid AS nlteam, yearid AS nl_yearid
FROM awardsmanagers
INNER JOIN managers
USING (playerid, yearid)
WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL'

--Forming CTE, joining top two querys to form large query 

WITH AL_awards AS (
	SELECT playerid, 
	       teamid AS alteam, 
	       yearid AS al_year
	FROM awardsmanagers
	INNER JOIN managers
	USING (playerid, yearid)  --by using, using, removing the syntax error of ambigous terms, joining on two terms
	WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'AL'), 

NL_awards AS (
	SELECT playerid, 
	       teamid AS nlteam, 
		   yearid AS nl_year
	FROM awardsmanagers
	INNER JOIN managers
	USING (playerid, yearid)
	WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL'
)  --Taking both CTEs and joining on people. First have to join together THEN join people table. Pull Name info from people and aliases from queries before
SELECT namefirst,
	   namelast, 
	   al_year, 
	   nl_year, 
	   alteam,nlteam
FROM AL_awards
INNER JOIN NL_awards
USING (playerid)
INNER JOIN people
USING (playerid)



--10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.


SELECT CONCAT(p.namefirst, ' ', p.namelast) AS name, 
		batt.hr AS home_runs_2016
	FROM people AS p
	INNER JOIN batting AS batt
	ON p.playerid = batt.playerid
	INNER JOIN ( --joining subquery back into main query
    SELECT playerid, MAX(hr) AS max_hr  ------ Subquery to find each player's career-high home run count, want to join people and batting to specific subquery that i'm making, referring to that as career_duration
    FROM batting AS batt
    GROUP BY playerid
) AS career_high 
ON p.playerid = career_high.playerid  ---- Subquery to count years a player appeared in the league
JOIN (--creating second "table" to join in on, referred to as career_duration
    SELECT playerid, COUNT(DISTINCT yearid) AS years_played --counting the number of years player was apart of a team
    FROM batting
    GROUP BY playerid
) AS career_duration
ON p.playerid = career_duration.playerid 
WHERE batt.yearid = 2016
  AND batt.hr > 0
  AND batt.hr = career_high.max_hr
  AND career_duration.years_played >= 10;


