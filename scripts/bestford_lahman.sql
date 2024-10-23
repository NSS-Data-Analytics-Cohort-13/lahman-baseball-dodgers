

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



