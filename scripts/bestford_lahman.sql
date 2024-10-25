

--1. What range of years for baseball games played does the provided database cover? 

SELECT MAX(year) AS last_year, MIN(year) AS first_year --used home_games for table, used alias to create columns to help identify
FROM homegames

--2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played? --- EddieGaedel 43 St. Louis Browns 1

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
SELECT DISTINCT player_name, SUM(salary::integer)::MONEY AS total_salary_earned --double perception had to change to decimale then to money
FROM vanderbilt_players
INNER JOIN salaries 
ON salaries.playerid=vanderbilt_players.playerid
WHERE salary IS NOT NULL
GROUP BY player_name
ORDER BY total_salary_earned DESC;



--4. Using the fielding table, group players into three groups based on their position: label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield", and those with position "P" or "C" as "Battery". Determine the number of putouts made by each of these three groups in 2016.

SELECT 
	CASE     ----using case statement, IF WHEN to identify abrvs and rename them
		WHEN pos = 'OF' THEN 'Outfield'  ---using = because single abrv
		WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield'  ----able to put multi abrvs in parenthesis. Have to use IN because of multiple abrv
		WHEN pos IN ('P','C') THEN 'Battery'
END AS positions_played---naming column
,COUNT(*)AS putouts_count
FROM fielding
WHERE yearid = '2016'
GROUP BY 
	CASE 
		WHEN pos = 'OF' THEN 'Outfield'  
		WHEN pos IN ('SS','1B','2B','3B') THEN 'Infield' 
		WHEN pos IN ('P','C') THEN 'Battery'
		END;


--5. Find the average number of strikeouts per game by decade since 1920. Round the numbers you report to 2 decimal places. Do the same for home runs per game. Do you see any trends?

SELECT G AS games, ROUND(AVG(SO),2) AS avg_strikeouts, (yearid)/10*10 AS decade, ROUND(AVG(HR),2) AS avg_homeruns
FROM teams
WHERE yearid >= 1920
GROUP BY games, decade
ORDER BY decade DESC;






