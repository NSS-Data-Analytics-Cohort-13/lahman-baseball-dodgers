-- 1. What range of years for baseball games played does the provided database cover? 


     SELECT MAX(yearid), MIN(yearid)
     FROM teams;


-- 2. Find the name and height of the shortest player in the database. How many games did he play in? What is the name of the team for which he played?



     SELECT p.playerid
	 , CONCAT(p.namefirst, ' ', p.namelast) as FullName
	 , p.height
	 , t.name
	 , a.g_all
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

   SELECT *
   FROM people;


  SELECT *
  FROM salaries;

  SELECT *
  FROM collegeplaying;
   

    SELECT DISTINCT(playerid)
    FROM collegeplaying
    WHERE schoolid = 'vandy';




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




-- 4. Using the fielding table, group players into three groups based on their position:
--  label players with position OF as "Outfield", those with position "SS", "1B", "2B", and "3B" as "Infield",
-- and those with position "P" or "C" as "Battery".
--  Determine the number of putouts made by each of these three groups in 2016.


    SELECT *
    FROM fielding;



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




SELECT *
FROM homegames

SELECT *
FROM teams;


 -- SELECT 
 -- WITH decade AS
 --      (SELECT *, 
	--   CASE WHEN yearid >= 1920 AND yearid < 1930 THEN '1920'
	--        WHEN yearid >= 1930 AND yearid < 1940 THEN '1930'
	-- 	   WHEN yearid >= 1940 AND yearid < 1950 THEN '1940'
	-- 	   WHEN yearid >= 1950 AND yearid < 1960 THEN '1950'
	-- 	   WHEN yearid >= 1960 AND yearid < 1970 THEN '1960'
	-- 	   WHEN yearid >= 1970 AND yearid < 1980 THEN '1970'
	-- 	   WHEN yearid >= 1980 AND yearid < 1990 THEN '1980'
	-- 	   WHEN yearid >= 1990 AND yearid < 2000 THEN '1990'
	-- 	   WHEN yearid >= 2000 AND yearid < 2010 THEN '2000'
	-- 	   WHEN yearid >= 2010 AND yearid < 2020 THEN '2010'
	-- 	   END AS decades
	-- 	   FROM teams
	-- 	   WHERE yearid >= '1920'
	--  )

SELECT 
     FLOOR(yearid/10)*10 AS decade
   , ROUND(SUM(SO)/SUM(g)::numeric, 2) AS avg_strikeouts_game
   , ROUND(SUM(HR)/SUM(g)::numeric, 2) AS avg_homeruns_game
FROM teams
WHERE yearid >= 1920
GROUP BY decade
ORDER BY decade;
	
    


	