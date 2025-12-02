/* ============================================================
   1. Top 10 happiest countries (by Ladder Score)
============================================================ */
SELECT *
FROM world_happiness
ORDER BY `Ladder score` DESC
LIMIT 10;


/* ============================================================
   2. Least happy country in each region
============================================================ */
WITH cte AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY `Regional indicator`
            ORDER BY `Ladder score` ASC
        ) AS rnk
    FROM world_happiness
)
SELECT *
FROM cte
WHERE rnk = 1;


/* ============================================================
   3. Rank all countries in each region by Ladder Score
============================================================ */
SELECT 
    Country,
    `Regional indicator`,
    `Ladder score`,
    RANK() OVER (
        PARTITION BY `Regional indicator`
        ORDER BY `Ladder score` DESC
    ) AS rnk
FROM world_happiness;


/* ============================================================
   4. Countries with GDP per capita above global average
============================================================ */
SELECT Country
FROM world_happiness
WHERE `GDP per capita` > (
        SELECT AVG(`GDP per capita`)
        FROM world_happiness
    );


/* ============================================================
   5. Social support < 0.5 but Ladder Score > 5
============================================================ */
SELECT 
    Country,
    `Social support`,
    ROUND(`Ladder score`, 2) AS ladder_score
FROM world_happiness
WHERE `Social support` < 0.5
  AND `Ladder score` > 5;


/* ============================================================
   6. Top 5 countries by Healthy life expectancy
============================================================ */
SELECT 
    Country, 
    `Healthy life expectancy`
FROM world_happiness
ORDER BY `Healthy life expectancy` DESC
LIMIT 5;


/* ============================================================
   7. Correlation: GDP per capita vs Ladder Score
============================================================ */
SELECT
    (
        AVG(`GDP per capita` * `Ladder score`)
        - AVG(`GDP per capita`) * AVG(`Ladder score`)
    )
    /
    (STDDEV_POP(`GDP per capita`) * STDDEV_POP(`Ladder score`))
        AS gdp_ladder_correlation
FROM world_happiness;


/* ============================================================
   8. Regions sorted by highest avg Ladder Score
============================================================ */
SELECT 
    `Regional indicator`,
    AVG(`Ladder score`) AS avg_ladder_score
FROM world_happiness
GROUP BY `Regional indicator`
ORDER BY avg_ladder_score DESC;


/* ============================================================
   9. Countries with lowest corruption (Top 10)
============================================================ */
SELECT 
    Country,
    `Perceptions of corruption`
FROM world_happiness
ORDER BY `Perceptions of corruption` ASC
LIMIT 10;


/* ============================================================
   10. Countries where Generosity > regional average
============================================================ */
SELECT
    Country,
    `Regional indicator`,
    Generosity,
    avg_generosity
FROM (
    SELECT 
        Country,
        `Regional indicator`,
        Generosity,
        AVG(Generosity) OVER (
            PARTITION BY `Regional indicator`
        ) AS avg_generosity
    FROM world_happiness
) AS t
WHERE Generosity > avg_generosity
ORDER BY `Regional indicator`, Generosity DESC;


/* ============================================================
   11. Count of countries below Ladder Score < 4 in each region
============================================================ */
SELECT 
    `Regional indicator`,
    COUNT(*) AS countries_below_4
FROM world_happiness
WHERE `Ladder score` < 4
GROUP BY `Regional indicator`
ORDER BY countries_below_4 DESC;


/* ============================================================
   12. Top 3 countries per region by Freedom score
============================================================ */
SELECT 
    Country,
    `Regional indicator`,
    `Freedom to make life choices`,
    rnk
FROM (
    SELECT
        Country,
        `Regional indicator`,
        `Freedom to make life choices`,
        RANK() OVER (
            PARTITION BY `Regional indicator`
            ORDER BY `Freedom to make life choices` DESC
        ) AS rnk
    FROM world_happiness
) AS t
WHERE rnk <= 3
ORDER BY `Regional indicator`, rnk;


/* ============================================================
   14. Countries where life expectancy > GDP rank suggests
   (Requires GDP ranking + expectancy ranking)
============================================================ */
-- GDP Rank
WITH gdp_rank AS (
    SELECT 
        Country,
        `Healthy life expectancy`,
        `GDP per capita`,
        RANK() OVER (ORDER BY `GDP per capita` DESC) AS gdp_rank,
        RANK() OVER (ORDER BY `Healthy life expectancy` DESC) AS health_rank
    FROM world_happiness
)
SELECT *
FROM gdp_rank
WHERE health_rank < gdp_rank;


/* ============================================================
   15. Region-wise total & avg GDP per capita
============================================================ */
SELECT 
    `Regional indicator`,
    SUM(`GDP per capita`) AS total_gdp,
    AVG(`GDP per capita`) AS avg_gdp
FROM world_happiness
GROUP BY `Regional indicator`;


/* ============================================================
   16. Highest Social support in each region
============================================================ */
SELECT 
    Country,
    `Regional indicator`,
    `Social support`
FROM (
    SELECT 
        *,
        RANK() OVER (
            PARTITION BY `Regional indicator`
            ORDER BY `Social support` DESC
        ) AS rnk
    FROM world_happiness
) t
WHERE rnk = 1;


/* ============================================================
   17. Countries with largest gap between Generosity & Corruption
============================================================ */
SELECT 
    Country,
    Generosity,
    `Perceptions of corruption`,
    ABS(Generosity - `Perceptions of corruption`) AS gap
FROM world_happiness
ORDER BY gap DESC
LIMIT 10;


/* ============================================================
   18. Countries above global average in 
       GDP, Social support, Freedom
============================================================ */
WITH global_avg AS (
    SELECT 
        AVG(`GDP per capita`) AS avg_gdp,
        AVG(`Social support`) AS avg_support,
        AVG(`Freedom to make life choices`) AS avg_freedom
    FROM world_happiness
)
SELECT 
    wh.Country,
    wh.`GDP per capita`,
    wh.`Social support`,
    wh.`Freedom to make life choices`
FROM world_happiness wh, global_avg g
WHERE wh.`GDP per capita` > g.avg_gdp
  AND wh.`Social support` > g.avg_support
  AND wh.`Freedom to make life choices` > g.avg_freedom;


/* ============================================================
   19. Region with highest spread in Ladder Score
============================================================ */
SELECT 
    `Regional indicator`,
    MAX(`Ladder score`) - MIN(`Ladder score`) AS ladder_spread
FROM world_happiness
GROUP BY `Regional indicator`
ORDER BY ladder_spread DESC;


/* ============================================================
   20. Outliers: Countries ±2 points from regional Ladder average
============================================================ */
WITH region_avg AS (
    SELECT
        `Regional indicator`,
        AVG(`Ladder score`) AS avg_score
    FROM world_happiness
    GROUP BY `Regional indicator`
)
SELECT 
    wh.Country,
    wh.`Regional indicator`,
    wh.`Ladder score`,
    ra.avg_score,
    wh.`Ladder score` - ra.avg_score AS deviation
FROM world_happiness wh
JOIN region_avg ra
    ON wh.`Regional indicator` = ra.`Regional indicator`
WHERE ABS(wh.`Ladder score` - ra.avg_score) > 2
ORDER BY wh.`Regional indicator`, deviation DESC;
