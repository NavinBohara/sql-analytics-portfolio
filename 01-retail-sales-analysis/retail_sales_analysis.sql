USE analysis;

-- View complete data
SELECT * FROM sale;

-------------------------------------------------------------
-- DATA CLEANING
-------------------------------------------------------------

-- Convert sale_date from TEXT to DATE
ALTER TABLE sale
MODIFY COLUMN sale_date DATE;

-- Check NULL values
SELECT *
FROM sale
WHERE transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantiy IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

-- Delete NULL records
SET SQL_SAFE_UPDATES = 0;

DELETE FROM sale
WHERE transactions_id IS NULL
   OR sale_date IS NULL
   OR sale_time IS NULL
   OR customer_id IS NULL
   OR gender IS NULL
   OR age IS NULL
   OR category IS NULL
   OR quantiy IS NULL
   OR price_per_unit IS NULL
   OR cogs IS NULL
   OR total_sale IS NULL;

-- Check total rows after deletion
SELECT COUNT(*) FROM sale;

-------------------------------------------------------------
-- DATA EXPLORATION
-------------------------------------------------------------

-- Total sales count
SELECT COUNT(*) AS total_sales
FROM sale;

-- Unique customers count
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM sale;

-- Total categories
SELECT COUNT(DISTINCT category) AS total_categories
FROM sale;

-- List of categories
SELECT DISTINCT category
FROM sale;

-- Quantity values
SELECT DISTINCT quantiy
FROM sale;

-------------------------------------------------------------
-- BUSINESS QUESTIONS & ANSWERS
-------------------------------------------------------------

-- Q1: All sales made on 2022-11-05
SELECT *
FROM sale
WHERE sale_date = '2022-11-05';

-- Q2: Clothing category, quantity > 10, in Nov-2022
SELECT *
FROM sale
WHERE category = 'Clothing'
  AND DATE_FORMAT(sale_date, '%Y-%m') = '2022-11'
  AND quantiy > 10;

-- Q3: Total sales per category
SELECT category,
       SUM(total_sale) AS total_sales,
       COUNT(*) AS total_transactions
FROM sale
GROUP BY category;

-- Q4: Average age of Beauty customers
SELECT ROUND(AVG(age), 2) AS avg_age
FROM sale
WHERE category = 'Beauty';

-- Q5: Transactions with total sale > 1000
SELECT *
FROM sale
WHERE total_sale > 1000;

-- Q6: Transactions count by gender and category
SELECT gender,
       category,
       COUNT(*) AS total_transactions
FROM sale
GROUP BY gender, category
ORDER BY category;

-- Q7: Best selling month (highest avg sale) for each year
SELECT *
FROM (
        SELECT YEAR(sale_date)  AS year,
               MONTH(sale_date) AS month,
               AVG(total_sale)  AS avg_sale,
               RANK() OVER (PARTITION BY YEAR(sale_date)
                            ORDER BY AVG(total_sale) DESC) AS rnk
        FROM sale
        GROUP BY YEAR(sale_date), MONTH(sale_date)
     ) AS t
WHERE t.rnk = 1;

-- Q8: Top 5 customers based on total sales
SELECT customer_id,
       SUM(total_sale) AS total_sales
FROM sale
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;

-- Q9: Unique customers per category
SELECT category,
       COUNT(DISTINCT customer_id) AS unique_customers
FROM sale
GROUP BY category;

-- Q10: Create shifts & count orders (Morning, Afternoon, Evening)
WITH hourly_shift AS (
        SELECT *,
               CASE 
                    WHEN HOUR(sale_time) <= 12 THEN 'Morning'
                    WHEN HOUR(sale_time) BETWEEN 13 AND 17 THEN 'Afternoon'
                    ELSE 'Evening'
               END AS shift
        FROM sale
)
SELECT shift,
       COUNT(*) AS total_orders
FROM hourly_shift
GROUP BY shift;

-- Final data
SELECT * FROM sale;
