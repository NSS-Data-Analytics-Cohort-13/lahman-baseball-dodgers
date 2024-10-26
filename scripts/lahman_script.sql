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

--FINAL QUERY (3 TABLES JOIN):
SELECT
	p.height
,	CONCAT(namefirst, ' ', namelast) AS full_name
,	t.name
, 	g_all
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

--INITIAL QUERY:
SELECT
		CASE 
		WHEN pos = 'OF' THEN 'Outfield'
		WHEN pos IN ('SS','1B','2B', '3B') THEN 'Infield'
		WHEN pos IN ('P','C') THEN 'Battery'
		END AS position		
,	COUNT(po) AS putouts_count
FROM fielding
WHERE yearid = '2016'
GROUP BY position
/* ANS:
"Battery"	938
"Infield"	661
"Outfield"	354
*/

-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
/*
- teams, batting, or pitching post?
- sum HR and HRA
- sum SO and SOA
- use numeric for more accuracy w/ decimals*
*/

SELECT *
FROM batting

SELECT *
FROM teams

SELECT so
from teams;

--INITIAL QUERY:
SELECT
	(yearid/10)*10 AS decade
,	ROUND(AVG(SO+SOA), 2) AS avg_strikeouts_game
,	ROUND(AVG(HR+HRA), 2) AS avg_homeruns_game
-- ,	ROUND(AVG(SO+SOA),2) OVER() AS avg_strikeouts --windows fxn
-- ,	ROUND(AVG(HR+HRA),2) OVER() AS avg_homeruns
FROM teams
WHERE yearid >= 1920
GROUP BY 
	decade
ORDER BY
	avg_strikeouts_game
,	avg_homeruns_game

--
SELECT
		ROUND(AVG(so),2) AS avg_so
	,	FLOOR(yearid/10)*10) AS decade
	,	ROUND(AVG(batting.hr),2) AS avg_hr
FROM batting
WHERE yearid>1920
GROUP BY decade
ORDER by decade

--
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