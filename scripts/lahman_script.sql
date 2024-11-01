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
     -- Classify each attempt as successful or unsuccessful w/ CASE & disregard <0 and NULL values
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
,	(p.namefirst||' '||p.namelast) AS full_name
		--multiply by 1.0 to make the data type into floating, so it isn't just a whole number after dividing
,   ROUND(successful_attempts * 1.00 / (successful_attempts + unsuccessful_attempts), 3)*100::numeric || '%'  AS success_rate	
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


--ALT QUERY:
SELECT 
		--p.playerid
		CONCAT(p.namefirst,' ',p.namelast) as name
	,	round(SUM(b.sb)*1.0/ (SUM(b.sb)+SUM(b.cs))*100,2) as Percentage

from batting as b
join people as p
on b.playerid=p.playerid
WHERE yearid = 2016 

AND p.playerid IS NOT NULL
GROUP BY CONCAT(p.namefirst,' ',p.namelast)
HAVING SUM(b.sb)+SUM(b.cs) >= 20
ORDER BY percentage DESC

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
--Hidden date/year: 2 total (1981 and 1994)** 
- WS lose DESC vs. win ASC
- 1st query >> filter: yearid BETWEEN 1970 and 2016
- 2nd query >> no year filter, COUNT(w), COUNT(WSWin)
- maybe CASE for wins, WSWins, and both wins and WSWin
- % of time = ROUND((both column ('Y')/wins), 3)::numeric *100 ||%
**Correct return: one row w/ percentage or one return w/ 5 columns 
*/

--EXPLORATION:
SELECT 
	w
,	wswin --lots of null values, make sure to account for filter
FROM teams;

--WINS (ASC ORDER)
Select --46 wswins
	w
,	yearid
,	teamid
,	wswin
from teams
where yearid BETWEEN 1970 AND 2016 
and wswin = 'Y'
Order BY w;

--LOSS (DESC)
Select --1220 wswin
	w
,	yearid 
,	teamid
,	wswin
from teams
where yearid BETWEEN 1970 AND 2016 
and wswin = 'N'
Order BY w DESC

--QUERY MINUS 1981 YEAR:
Select --46 wswins
	w
,	yearid
,	teamid
,	wswin
from teams
where yearid BETWEEN 1970 AND 2016 
and wswin = 'Y'
and yearid <> 1981
Order BY w;

--QUERY 1--:
SELECT
	CASE WHEN wswin = 'Y' THEN 'WS Win'
		WHEN wswin = 'N' THEN 'WS Loss'
		ELSE 'N/A' END AS ws_win_loss
,	teamid
,	yearid
,	w
,	wswin
FROM teams
WHERE
	wswin 
	IS NULL
	-- IS NOT NULL
-- WHERE 
-- 	yearid BETWEEN 1970 AND 2016
ORDER BY
	wswin 
,	w
,	ws_win_loss
,	yearid ASC
LIMIT 10;

--ID years w/ low wins:--
SELECT 
    yearID,
    teamID,
    w AS win_count,
    wswin
FROM teams
WHERE wswin = 'Y'
    AND yearID BETWEEN 1872 AND 2016 --1981 bc of player strike
ORDER BY w ASC 
LIMIT 10;       


-- --CTE for maximum wins by a non-champion and minimum wins by a champion
-- WITH max_min_wins AS (
--     SELECT
--         CASE 
--             WHEN wswin = 'N' THEN MAX(w) --116
--             WHEN wswin = 'Y' THEN MIN(w) --63
--         	END AS win_count
-- 		,	wswin
--     FROM teams
--     WHERE 
-- 		yearID BETWEEN 1970 AND 2016
-- 		AND wswin IS NOT NULL
-- 		AND w IS NOT NULL
--     GROUP BY wswin 
-- ),

-- -- CTE to rank teams by wins for each year and check if top-win team won WS
-- yearly_top_teams AS (
--     SELECT
--         yearID
-- 		,
--         teamID
-- 		,
--         w
-- 		,
--         wswin
-- 		,
--         RANK() OVER (PARTITION BY yearID ORDER BY w DESC) AS win_rank
--     FROM teams
--     WHERE 
-- 		yearID BETWEEN 1970 AND 2016
-- 		AND wswin IS NOT NULL
-- 		AND w IS NOT NULL
-- )

-- -- Main query to select distinct teamID, win counts, and frequency calculation
-- SELECT 
--     DISTINCT teamID,
--     yearID,
--     w,
--     wswin,
    
--     -- Bring in the largest wins for non-champions and smallest wins for champions
--     (SELECT win_count FROM max_min_wins WHERE wswin = 'N') AS largest_win_non_champion,
--     (SELECT win_count FROM max_min_wins WHERE wswin = 'Y') AS smallest_win_champion,

--     -- Calculate frequency and percentage of top-win teams winning the World Series
--     (SELECT COUNT(DISTINCT teamID) FROM yearly_top_teams WHERE win_rank = 1 AND wswin = 'Y') AS top_win_champions,
--     (SELECT COUNT(DISTINCT teamID) FROM yearly_top_teams WHERE win_rank = 1) AS total_top_win_teams,
--     (SELECT COUNT(DISTINCT teamID) * 100.0 / NULLIF((SELECT COUNT(DISTINCT teamID) FROM yearly_top_teams WHERE win_rank = 1), 0)
--      FROM yearly_top_teams WHERE win_rank = 1 AND wswin = 'Y') AS percent_top_win_champions

-- FROM teams
-- WHERE 
-- 	yearID BETWEEN 1970 AND 2016
-- 	AND wswin IS NOT NULL
-- 	AND w IS NOT NULL
-- 	AND yearID <> 1981
-- ORDER BY yearID;

----PHILIP'S QUERY----
with max_wins as
	(SELECT MAX(w)as max_wins,yearid
	from teams
	WHERE yearid BETWEEN 1970 and 2016  and yearid <> 1981
	group by yearid)
select --t.yearid
	-- ,t.w
	-- ,t.wswin
	-- ,t.teamid
	ROUND(COUNT(CASE WHEN t.wswin = 'Y' THEN 1 END) * 100.0 / NULLIF(count(DISTINCT t.yearid),0),2) AS PERCENTAGE --should be 12 wswins/45 seasons
	
	--(COUNT(CASE WHEN t.wswin = 'Y' THEN 1 END) * 100.0 / NULLIF(COUNT(*), 0)) AS wswin_percentage
	       -- (SUM(CASE WHEN t.wswin='Y' THEN 1 ELSE 0 END)/
	-- NULLIF (SUM(CASE WHEN t.wswin='N' THEN 1 ELSE 0 END)*100)) as percentage
from teams as t
 join max_wins as mw
on t.yearid=mw.yearid AND t.w=mw.max_wins
WHERE wswin IN ('Y','N')
    --t.yearid BETWEEN 1970 AND 2016 AND t.yearid <> 1981
--GROUP BY 1,2,3,4


-----ALT QUERY----
WITH max_wins_w AS (SELECT
					yearid, MAX(w) AS m_w
					FROM teams
					WHERE yearid>= 1970 AND wswin='Y'
					GROUP BY yearid)
,	max_wins_l AS (SELECT
					yearid, MAX(w) AS m_w
					FROM teams
					WHERE yearid>= 1970 AND wswin='N'
					GROUP BY yearid)
SELECT --yearid
	--,	m.m_w AS most_win_ws_winner
	--,	m_l.m_w AS most_win_ws_loser
		--COUNT(CASE WHEN m.m_w >= m_l.m_w THEN 'max win win' END),
		SUM(CASE WHEN m.m_w >= m_l.m_w THEN 1 ELSE 0 END) AS sum_max_winner,
		(SUM(CASE WHEN m.m_w >= m_l.m_w THEN 1 ELSE 0 END)*1.0/COUNT(*)) *100 AS percentage
FROM max_wins_w AS m
	INNER JOIN max_wins_l m_l
		USING(yearid)
WHERE m.yearid !=1981
-- GROUP BY  max_wins_y
-- 	 ,	 min_wins_y
-- 	 ,	 max_wins_n
LIMIT 1
--max=114	min=63	max=116 percent_winner=1

-- 8. Using the attendance figures from the homegames table, find the teams and parks which had the top 5 average attendance per game in 2016 (where average attendance is defined as total attendance divided by number of games). Only consider parks where there were at least 10 games played. Report the park name, team name, and average attendance. Repeat for the lowest 5 average attendance.
/*
--**Correct return: 5
*/

--TOP 5 AVG ATTENDANCE:--
SELECT
	park
,	team
,	attendance/games AS avg_attendance
FROM homegames
WHERE year = 2016
ORDER BY
	avg_attendance DESC
LIMIT 5;

--LOWEST 5 ATTENDANCE:--
SELECT
	park_name
,	t.name AS team_name
,	h.attendance/games AS avg_attendance
FROM homegames AS h
	INNER JOIN parks AS p
		ON h.park = p.park
	INNER JOIN teams AS t
		ON h.team = t.teamid
		AND h.year = t.yearid
WHERE 
	year = 2016
	AND	games >= 10
ORDER BY
	avg_attendance 
LIMIT 5;

/* ANSWER:
"Tropicana Field"	"Tampa Bay Rays"	15878
"Oakland-Alameda County Coliseum"	"Oakland Athletics"	18784
"Progressive Field"	"Cleveland Indians"	19650
"Marlins Park"	"Miami Marlins"	21405
"U.S. Cellular Field"	"Chicago White Sox"	21559
*/

-- 9. Which managers have won the TSN Manager of the Year award in both the National League (NL) and the American League (AL)? Give their full name and the teams that they were managing when they won the award.
/*
- people, managers (teamid and playerid), awardsmanagers
--Correct returns: 6 rows**
*/

SELECT *
FROM people

SELECT *
FROM managers

SELECT *
FROM awardsmanagers

--AMERICAN LEAGUE AWARD (AL):--
SELECT
	m.playerid
,	teamid
,	m.yearid AS al_year
FROM awardsmanagers AS am
	INNER JOIN managers AS m
		ON am.playerid = m.playerid
		AND am.yearid = m.yearid
WHERE 
	awardid = 'TSN Manager of the Year'
	AND am.lgid = 'AL'

--NATIONAL LEAGUE AWARD (NL):--
SELECT
	m.playerid
,	teamid
,	m.yearid AS nl_year
FROM awardsmanagers AS am
	INNER JOIN managers AS m
		ON am.playerid = m.playerid
		AND am.yearid = m.yearid
WHERE 
	awardid = 'TSN Manager of the Year'
	AND am.lgid = 'NL'

--USE ABOVE QUERIES FOR CTE AND MAIN QUERY:--
--Could also select lgid from awardsmanagers table**
WITH al_awards as
      (SELECT playerid,teamid as alteam, yearid as al_year
       FROM awardsmanagers
       INNER JOIN managers
       USING (playerid, yearid)
       WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'AL')
	   ,
	nl_awards as
	(SELECT playerid, teamid as nlteam, yearid as nl_year
    FROM awardsmanagers
    INNER JOIN managers
    USING (playerid, yearid)
    WHERE awardid = 'TSN Manager of the Year' AND awardsmanagers.lgid = 'NL')
    SELECT 
	  namefirst
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

-- 10. Find all players who hit their career highest number of home runs in 2016. Consider only players who have played in the league for at least 10 years, and who hit at least one home run in 2016. Report the players' first and last names and the number of home runs they hit in 2016.
/*
- batting, people
- EXTRACT(year from debut::date) <= 2016-9
- 9 returns**
*/

-- SELECT
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


-- SELECT playerid, yearid, hr
--    FROM batting
--    WHERE yearid = 2016 AND hr >= 1
--    GROUP BY playerid, yearid, hr
--    HAVING COUNT(hr) >= 10
--    ORDER BY 
--    1,2

--SUBQUERY UNDER WHERE
SELECT
	CONCAT(namefirst, ' ',namelast) AS full_name
,	b.hr AS homerun
FROM batting as b
	INNER JOIN people as p
		ON b.playerid = p.playerid
WHERE 
	yearid = 2016
	AND EXTRACT(year from debut::date) <= 2016-9
	AND hr >= 1
	AND b.hr = 
	(
		SELECT MAX(hr)
		FROM batting
		WHERE b.playerid = playerid --comparing max(hr) across all years vs. 2016 (to find career highest)
	)
ORDER BY
	homerun DESC


--PHILIP'S QUERY--
SELECT CONCAT(namefirst,' ',namelast) as name, b.hr
from people as p
join batting as b
ON p.playerid=b.playerid
JOIN
	(SELECT playerid, MAX(hr) as max_hr
	 FROM batting
	 GROUP BY playerid) as max_homerun On p.playerid=max_homerun.playerid
JOIN
	(select playerid, COUNT(DISTINCT yearid) as years_played
	 FROM batting
	 GROUP BY playerid) as career_years ON p.playerid=career_years.playerid
WHERE b.yearid = 2016
	AND career_years.years_played >= 10
	AND b.hr = max_homerun.max_hr
	AND b.hr >0
ORDER BY
	b.hr DESC
