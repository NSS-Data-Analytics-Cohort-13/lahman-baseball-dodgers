-- 1. What range of years for baseball games played does the provided database cover? 


SELECT MAX(yearid), MIN(yearid)
FROM teams;


-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?



SELECT p.playerid, CONCAT(p.namefirst, p.namelast), p.height, t.name, a.g_all
FROM people AS p
INNER JOIN appearances AS a
ON p.playerid = a.playerid
INNER JOIN teams AS t
ON t.teamid = a.teamid
ORDER BY height
LIMIT 1;

-- 3. Find all players in the database who played at Vanderbilt University.
--  Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues.
--  -- Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?