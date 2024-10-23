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
- 
*/


-- 4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.
/*
- 
*/


-- 5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?
/*
- 
*/
