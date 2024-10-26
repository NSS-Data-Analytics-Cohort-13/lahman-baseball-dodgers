SELECT DISTINCT(playerid)
FROM collegeplaying
WHERE schoolid = 'vandy';

SELECT namefirst, namelast, SUM(salary) as total_salary
FROM people
INNER JOIN salaries AS salary
USING (playerid)
WHERE playerid IN (SELECT DISTINCT(playerid)
FROM collegeplaying
WHERE schoolid = 'vandy')
GROUP BY namefirst, namelast
ORDER BY total_salary DESC;
