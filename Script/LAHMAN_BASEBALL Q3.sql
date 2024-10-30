
-- 1. What range of years for baseball games played does the provided database cover? 

  SELECT 
  MIN(yearid)
  ,MAX(yearid)
  FROM collegeplaying

  
-- 2. Find the name and height of the shortest player in the database. How many games did he play in? 
-- What is the name of the team for which he played?

   
  

  





-- 3. Find all players in the database who played at Vanderbilt University.
--  Create a list showing each player’s first and last names as well as the total salary they earned in the major leagues.
--  Sort this list in descending order by the total salary earned. Which Vanderbilt player earned the most money in the majors?
   SELECT *
   FROM collegeplaying

  SELECT DISTINCT(playerid)
  FROM collegeplaying
  WHERE schoolid = 'vandy';

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





