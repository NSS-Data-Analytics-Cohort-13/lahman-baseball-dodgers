SELECT *
FROM allstarfull

-- 1. What range of years for baseball games played does the provided database cover? 
/*
- does table matter?
- MIN, MAX
*/

--FIRST ATTEMPT:
SELECT
	MIN(year) AS earliest_year
,	MAX(year) AS latest_year
FROM homegames
--ANS: 1871-2016


-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?
/*
- people, teams
- g_all
*/ 

SELECT *
FROM people

SELECT * 
FROM teams

SELECT *
FROM appearances 

--INITIAL ATTEMPT w/ SUBQUERY:
-- SELECT
-- 	CONCAT(namefirst, ' ', namelast) AS combined_name
-- -- ,	MIN(height)
-- FROM people
-- WHERE --subquery
-- 	(
-- 	SELECT MIN(height) AS shorty
-- 	FROM people
-- 	)

-- --CROSSJOIN (MISSING GAME COUNT)
-- SELECT
-- 	height
-- ,	CONCAT(namefirst, ' ', namelast) AS combined_name
-- ,	t.name
-- FROM people as p
-- CROSS JOIN teams as t
-- ORDER BY height
-- LIMIT 1;
-- --ANS: Eddie Gaedel, 43, Boston Red Stockings
-- --COMPUTATION: 31.106 


/*De-duplicate Strategies:
(1) Subquery + SELECT DISTINCT
(2) Window Fxns
*/

--FINAL QUERY (3 TABLES JOIN):
SELECT
	p.height
,	CONCAT(namefirst, ' ', namelast) AS full_name
,	t.name
, 	a.g_all
FROM people as p
	INNER JOIN appearances AS a
		ON p.playerid = a.playerid
	INNER JOIN teams AS t
		ON t.teamid = a.teamid
ORDER BY 
	p.height
LIMIT 1;
--ANS: 43	"Eddie Gaedel", "St. Louis Browns", 1 game

--SOBIA QUERY
SELECT p.playerid, CONCAT(p.namefirst ,' ',p.namelast), p.height, t.name, a.g_all
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
INNER JOIN teams AS t
ON t.teamid = a.teamid
ORDER BY height
LIMIT 1;


-- 3. Find all players in the database who played at Vanderbilt University. Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues. Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
/*
- tables: people, collegeplaying, schools, salaries (INNER JOIN bc need exact match based on criteria)
- return: first name, last name, total salary (sum(salary))
- ORDER BY sum salary DESC
- LIMIT 1 
- Correct: 15 records, David Price
- consider duplicates
-- :: = cast
*/

SELECT *
FROM people;

SELECT *
FROM collegeplaying;

SELECT *
FROM schools;

SELECT *
FROM salaries;

--INTIAL QUERY:
--**WHY CTE? pulling from collegeplaying and playerid to avoid astronomical salary calculations (repeat playerids, so duplicates will skew calculation)
WITH salary_list AS --CTE 1 
	(
	SELECT
		playerid
	,	SUM(salary)::int::money AS total_salary
	FROM salaries 
	GROUP BY
		playerid
	)
,	vanderbilt AS --CTE 2
	(
	SELECT
		schoolid --'vandy'
	,	schoolname
	FROM schools 
	WHERE schoolname ILIKE '%Vanderbilt University%'
	)
SELECT --main query
	DISTINCT CONCAT(namefirst ,' ',namelast) AS full_name
,	total_salary
FROM salary_list 
	INNER JOIN people 
		USING(playerid)
	INNER JOIN collegeplaying 
		USING(playerid)
	INNER JOIN vanderbilt 
		USING(schoolid)
ORDER BY
	total_salary DESC
LIMIT 1;
-- "David Price"	"$81,851,296.00"

--SUBQUERY ALT ANS:
--**WHY SUBQUERY? pulling from collegeplaying and playerid to avoid astronomical salary calculations (repeat playerids, so duplicates will skew calculation)
SELECT namefirst
	  , namelast
	  , SUM(salary) as total_salary
      FROM people
      INNER JOIN salaries AS salary
      USING (playerid)
      WHERE playerid IN (SELECT DISTINCT(playerid)
      FROM collegeplaying
      WHERE schoolid = 'vandy')
      GROUP BY namefirst, namelast
      ORDER BY total_salary DESC;

-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
/*
- fielding
- 3 groups = CASE WHEN
- COUNT putouts
- Filter by yearid = 2-16
*/

SELECT *
FROM fielding

--REVISED QUERY:
SELECT
	CASE 
	WHEN pos = 'OF' THEN 'Outfield'
	WHEN pos IN ('SS','1B','2B', '3B') THEN 'Infield'
	WHEN pos IN ('P','C') THEN 'Battery'
	END AS position		
-- ,	COUNT(po) --not count but SUM**
,	SUM(po) AS putouts_count
FROM fielding
WHERE yearid = '2016'
GROUP BY position;
/* ANS:
"Battery"	41424
"Infield"	58934
"Outfield"	29560
*/

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
/*
- teams, batting, or pitching post?
- sum HR and HRA --> don't do bc it'd be "doubledipping" columns and throwing off calculation 
- sum SO and SOA --> don't do bc it'd be "doubledipping" columns and throwing off calculation 
- use numeric for more accuracy w/ decimals*
*/

SELECT *
FROM batting

SELECT *
FROM teams

SELECT so
from teams;

--REVISED QUERY:
SELECT
	FLOOR(yearid/10)*10 AS decade
,	ROUND(SUM(SO)/SUM(g)::numeric, 2) AS avg_strikeouts_game --numeric for precision
,	ROUND(SUM(HR)/SUM(g)::numeric, 2) AS avg_homeruns_game
FROM teams
WHERE yearid >= 1920
GROUP BY
	decade
ORDER BY
	decade;
--ANS: see table, 10 returns starting w/ 1920 - 2.81 - 0.40

--INITIAL QUERY:
-- SELECT
-- 	(yearid/10)*10 AS decade
-- ,	ROUND(AVG(SO+SOA), 2) AS avg_strikeouts_game
-- ,	ROUND(AVG(HR+HRA), 2) AS avg_homeruns_game
-- -- ,	ROUND(AVG(SO+SOA),2) OVER() AS avg_strikeouts --windows fxn
-- -- ,	ROUND(AVG(HR+HRA),2) OVER() AS avg_homeruns
-- FROM teams
-- WHERE yearid >= 1920
-- GROUP BY 
-- 	decade
-- ORDER BY
-- 	avg_strikeouts_game
-- ,	avg_homeruns_game
-- 6. Find the player who had the most success stealing bases in 2016, where __success__ is measured as the percentage of stolen base attempts which are successful. (A stolen base attempt results either in a stolen base or being caught stealing.) Consider only players who attempted _at least_ 20 stolen bases.

--REVISED QUERY:--
WITH sb_attempts AS 
	(
    SELECT 
        playerid
	,
        yearid
     -- Classify each attempt as successful or unsuccessful w/ CASE & disregard <0 and NULL 			values
    ,	SUM(CASE WHEN SB > 0 THEN SB ELSE 0 END) AS successful_attempts
    ,	SUM(CASE WHEN CS > 0 THEN CS ELSE 0 END) AS unsuccessful_attempts
    FROM batting
    WHERE yearID = 2016
    GROUP BY 
		playerid
	,	yearid
	)
SELECT --main query
    p.playerid
,	CONCAT(p.namefirst||' '||p.namelast)
,   ROUND(successful_attempts * 1.00 / (successful_attempts + unsuccessful_attempts), 			3)*100::numeric || '%'  AS success_rate	
FROM sb_attempts AS sb_a
	INNER JOIN people AS p
		ON sb_a.playerid = p.playerid
WHERE 
	(successful_attempts + unsuccessful_attempts) >= 20
	AND yearID = 2016
ORDER BY success_rate DESC
LIMIT 1;
--ANS: Chris Owings, 91.3%

---ALT QUERY (shorter and quicker computation)--
SELECT ROUND((CAST(sb AS NUMERIC) / (CAST(sb+cs AS NUMERIC))),3) *100 || '%' AS percentage_success
	,	CONCAT(namefirst,' ',namelast) AS full_name
	, 	yearid
	--,	sb
	--,	cs
FROM batting
	inner join people
		USING(playerid)
WHERE yearid=2016 AND sb+cs>=20
ORDER BY percentage_success DESC

/*
- batting --> connect via appearances and people tables
- SB, CS
- FILTER: yearid = '2016'
- FILTER: CASE WHEN or WHERE subquery for SB+CS
- FILTER: Nulls
*/

--EXPLORATION:
SELECT *
FROM teams

SELECT --2835 records, lots of nulls for both columns --sb, cs = integer
	sb
,	cs 
,	teamid
FROM teams
WHERE 
	sb IS NOT NULL AND cs IS NOT NULL
	AND yearid = '2016'
ORDER BY sb, cs

SELECT *
FROM batting

--**USE BATTING TABLE--
SELECT  --102816 records, nulls
	playerid
,	sb
,	cs
FROM batting
WHERE 
	-- sb IS NOT NULL AND cs IS NOT NULL AND 
	yearid = '2016'
ORDER BY sb, cs

SELECT sb, cs --136815 records, mostly nulls
FROM fielding

-- --INTIIAL QUERY
-- WITH sb_attempts AS
-- 	(
-- 	SELECT 
-- 			CASE WHEN t.
-- 		THEN 'Successful'
-- 		WHEN t.
-- 		THEN 'Unsuccessful'
-- ,		END AS attempt_status
-- 	FROM teams
	
-- 	)

-- SELECT --Main Query
-- 	DISTINCT playerid
-- ,	DISTINCT teamid
-- FROM teams AS t
-- 	INNER JOIN appearances AS a
-- 		ON t.teamid = a.teamid
-- 	INNER JOIN people AS p
-- 		ON a.playerid = p.playerid
-- WHERE 
-- 	t.yearid = '2016'
-- 	AND 
-- 	>= 20

-- 7.  From 1970 – 2016, what is the largest number of wins for a team that did not win the world series? What is the smallest number of wins for a team that did win the world series? Doing this will probably result in an unusually small number of wins for a world series champion – determine why this is the case. Then redo your query, excluding the problem year. How often from 1970 – 2016 was it the case that a team with the most wins also won the world series? What percentage of the time?
/*
--Hidden date/year: 2 total (just need one)
*/

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
/*

*/

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
/*

*/

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
/*

*/