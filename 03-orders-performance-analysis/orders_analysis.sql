/* =========================================================
   BASIC DATA EXPLORATION
========================================================= */

-- 1. Show all rows
SELECT * FROM orders;

-- 2. List all unique cities
SELECT DISTINCT City FROM orders;

-- 3. Orders shipped using Standard Class
SELECT *
FROM orders
WHERE `Ship Mode` = 'Standard Class';

-- 4. Orders from Consumer segment
SELECT *
FROM orders
WHERE Segment = 'Consumer';

-- 5. Orders where category is Furniture
SELECT *
FROM orders
WHERE Category = 'Furniture';

-- 6. List all distinct regions
SELECT DISTINCT Region FROM orders;

-- 7. Orders where quantity > 3
SELECT *
FROM orders
WHERE Quantity > 3;

-- 8. Orders placed in 2023
SELECT *
FROM orders
WHERE YEAR(`Order Date`) = 2023;

-- 9. Orders where country is not India
SELECT *
FROM orders
WHERE Country <> 'India';

-- 10. Total rows count
SELECT COUNT(*) AS total_rows FROM orders;


/* =========================================================
   SALES, COST & PROFIT CALCULATIONS
========================================================= */

ALTER TABLE orders ADD COLUMN total_sales INT;
ALTER TABLE orders ADD COLUMN total_cost INT;
ALTER TABLE orders ADD COLUMN profit INT;

UPDATE orders
SET total_sales = ROUND(`List Price` * Quantity),
    total_cost  = ROUND(`cost price` * Quantity),
    profit      = (`List Price` - `cost price`) * Quantity;


/* =========================================================
   DISCOUNT & REVENUE ANALYSIS
========================================================= */

-- Total discount per order
SELECT 
    `Order Id`,
    ROUND((`List Price` * Quantity) * (`Discount Percent` / 100), 2) AS total_discount
FROM orders;

-- Total revenue with discount
SELECT 
    ROUND(
        SUM((`List Price` * Quantity) - ((`List Price` * Quantity) * (`Discount Percent` / 100))),
        2
    ) AS total_revenue_discount
FROM orders;

-- Total revenue without discount
SELECT SUM(`List Price` * Quantity) AS total_revenue FROM orders;


/* =========================================================
   GROUPING & AGGREGATES
========================================================= */

-- Orders per ship mode
SELECT `Ship Mode`, COUNT(*) AS total_orders
FROM orders
GROUP BY `Ship Mode`
ORDER BY total_orders DESC;

-- Highest and lowest list price
SELECT 
    MAX(`List Price`) AS highest_price,
    MIN(`List Price`) AS lowest_price
FROM orders;

-- Orders per category
SELECT Category, COUNT(*) AS total_orders
FROM orders
GROUP BY Category
ORDER BY total_orders DESC;


/* =========================================================
   TOP & BOTTOM PERFORMANCE
========================================================= */

-- Top 10 products by revenue
SELECT 
    `Product Id`,
    ROUND(
        SUM((`List Price` * Quantity) - ((`List Price` * Quantity) * (`Discount Percent` / 100))),
        2
    ) AS total_revenue
FROM orders
GROUP BY `Product Id`
ORDER BY total_revenue DESC
LIMIT 10;

-- Top 5 cities by revenue
SELECT 
    City,
    ROUND(
        SUM((`List Price` * Quantity) - ((`List Price` * Quantity) * (`Discount Percent` / 100))),
        2
    ) AS total_revenue
FROM orders
GROUP BY City
ORDER BY total_revenue DESC
LIMIT 5;


/* =========================================================
   TIME-BASED ANALYSIS
========================================================= */

-- Monthly revenue
SELECT 
    YEAR(`Order Date`) AS order_year,
    MONTH(`Order Date`) AS order_month,
    ROUND(
        SUM((`List Price` * Quantity) - ((`List Price` * Quantity) * (`Discount Percent` / 100))),
        2
    ) AS total_revenue
FROM orders
GROUP BY YEAR(`Order Date`), MONTH(`Order Date`)
ORDER BY order_year, order_month;

-- Running total revenue
SELECT 
    `Order Date`,
    ROUND(
        SUM((`List Price` * Quantity) - ((`List Price` * Quantity) * (`Discount Percent` / 100)))
        OVER (ORDER BY `Order Date`),
        2
    ) AS running_total
FROM orders;


/* =========================================================
   ADVANCED ANALYTICS
========================================================= */

-- Quantity greater than category average
SELECT *
FROM (
    SELECT 
        `Order Id`,
        `Sub Category`,
        Quantity,
        AVG(Quantity) OVER (PARTITION BY `Sub Category`) AS avg_qty
    FROM orders
) t
WHERE Quantity > avg_qty;

-- Median List Price per Category
SELECT Category, AVG(`List Price`) AS median_price
FROM (
    SELECT 
        Category,
        `List Price`,
        ROW_NUMBER() OVER (PARTITION BY Category ORDER BY `List Price`) AS rn,
        COUNT(*) OVER (PARTITION BY Category) AS cnt
    FROM orders
) t
WHERE rn IN (FLOOR((cnt + 1) / 2), CEIL((cnt + 1) / 2))
GROUP BY Category;

-- Product segmentation by revenue
SELECT 
    `Product Id`,
    total_revenue,
    CASE
        WHEN total_revenue > 50000 THEN 'High Value'
        WHEN total_revenue BETWEEN 20000 AND 50000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS product_segment
FROM (
    SELECT 
        `Product Id`,
        SUM((`List Price` * Quantity) - ((`List Price` * Quantity) * (`Discount Percent` / 100))) AS total_revenue
    FROM orders
    GROUP BY `Product Id`
) t;
