
-- ================================================
-- FUEL PRICE ANALYSIS - SQL QUERIES
-- Database: fuel_analysis.db (SQLite)
-- Author: Anasua Mazumder
-- Date: 2026
-- ================================================

-- Query 1: Total Records
SELECT COUNT(*) AS total_rows 
FROM fuel_prices;

-- Query 2: Average Price by Fuel Type
SELECT product_type,
       ROUND(AVG(price), 2) AS avg_price,
       COUNT(*) AS total_records
FROM fuel_prices
GROUP BY product_type
ORDER BY avg_price DESC;

-- Query 3: Average Price by Region
SELECT region,
       ROUND(AVG(price), 2) AS avg_price,
       COUNT(*) AS total_records
FROM fuel_prices
GROUP BY region
ORDER BY avg_price DESC;

-- Query 4: Monthly Price Trend
SELECT SUBSTR(publish_date, 1, 7) AS year_month,
       ROUND(AVG(price), 2) AS avg_price
FROM fuel_prices
GROUP BY year_month
ORDER BY year_month;

-- Query 5: Top 10 Expensive Brands
SELECT brand,
       ROUND(AVG(price), 2) AS avg_price,
       COUNT(*) AS total_records
FROM fuel_prices
GROUP BY brand
ORDER BY avg_price DESC
LIMIT 10;

-- Query 6: Price by Day of Week
SELECT CASE CAST(strftime('%w', publish_date) AS INTEGER)
           WHEN 0 THEN 'Sunday'
           WHEN 1 THEN 'Monday'
           WHEN 2 THEN 'Tuesday'
           WHEN 3 THEN 'Wednesday'
           WHEN 4 THEN 'Thursday'
           WHEN 5 THEN 'Friday'
           WHEN 6 THEN 'Saturday'
       END AS day_of_week,
       ROUND(AVG(price), 2) AS avg_price
FROM fuel_prices
GROUP BY day_of_week
ORDER BY avg_price ASC;

-- Query 7: Yearly Summary
SELECT SUBSTR(publish_date, 1, 4) AS year,
       ROUND(AVG(price), 2) AS avg_price,
       ROUND(MIN(price), 2) AS min_price,
       ROUND(MAX(price), 2) AS max_price
FROM fuel_prices
GROUP BY year
ORDER BY year;

-- Query 8: Price Gap vs Metro
SELECT region,
       ROUND(AVG(price), 2) AS avg_price,
       ROUND(AVG(price) - (
           SELECT AVG(price)
           FROM fuel_prices
           WHERE region = 'Metro'
       ), 2) AS diff_from_metro
FROM fuel_prices
GROUP BY region
ORDER BY avg_price DESC;

-- Advanced Query 9: Window Function - Region Rankings
SELECT region,
       ROUND(AVG(price), 2) AS avg_price,
       RANK() OVER (
           ORDER BY AVG(price) DESC
       ) AS price_rank
FROM fuel_prices
GROUP BY region;

-- Advanced Query 10: CTE - Most Expensive Fuel per Region
WITH regional_avg AS (
    SELECT region,
           product_type,
           ROUND(AVG(price), 2) AS avg_price,
           ROW_NUMBER() OVER (
               PARTITION BY region
               ORDER BY AVG(price) DESC
           ) AS rn
    FROM fuel_prices
    GROUP BY region, product_type
)
SELECT region, product_type, avg_price
FROM regional_avg
WHERE rn = 1
ORDER BY avg_price DESC;

-- Advanced Query 11: Year over Year Price Change
WITH yearly AS (
    SELECT SUBSTR(publish_date,1,4) AS year,
           ROUND(AVG(price),2) AS avg_price
    FROM fuel_prices
    GROUP BY year
)
SELECT year,
       avg_price,
       LAG(avg_price) OVER (ORDER BY year) AS prev_year,
       ROUND(avg_price - LAG(avg_price)
             OVER (ORDER BY year), 2) AS price_change
FROM yearly;
