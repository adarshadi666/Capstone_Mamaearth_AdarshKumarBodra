-- sql/reports.sql

-- ==============================================================================
-- a) Order totals (2 marks)
-- Expected Output:
-- total_orders = 180 | total_revenue = 99860.20 | avg_order_value = 554.78
-- ==============================================================================
SELECT 
    COUNT(*) AS total_orders,
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_revenue,
    ROUND(AVG(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS avg_order_value
FROM orders o
JOIN products p ON o.product_id = p.product_id;


-- ==============================================================================
-- b) COUNT(*) vs COUNT(column) (2 marks)
-- Expected Output:
-- (180, 165, 15) — 15 orders have no rating yet.
-- ==============================================================================
SELECT 
    COUNT(*) AS total_orders,
    COUNT(rating) AS rated_orders,
    COUNT(*) - COUNT(rating) AS missing_ratings
FROM orders;


-- ==============================================================================
-- c) LEFT JOIN with a genuine zero-match row (3 marks)
-- Expected Output:
-- Both queries return exactly one row: C045, Vihaan
-- ==============================================================================
-- Method 1: LEFT JOIN + GROUP BY + HAVING
SELECT 
    c.customer_id, 
    c.name
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(o.order_id) = 0;

-- Method 2: Independent subquery via NOT IN
SELECT 
    c.customer_id, 
    c.name
FROM customers c
WHERE c.customer_id NOT IN (
    SELECT DISTINCT customer_id 
    FROM orders 
    WHERE customer_id IS NOT NULL
);


-- ==============================================================================
-- d) GROUP BY + HAVING (3 marks)
-- Expected Output:
-- Jaipur (19, 8, 42.1)
-- Lucknow (49, 15, 30.6)
-- Bangalore (33, 8, 24.2)
-- (Mumbai at 17.9% and Delhi at 17.4% are correctly excluded.)
-- ==============================================================================
SELECT 
    c.city,
    COUNT(o.order_id) AS total_orders,
    SUM(o.returned) AS returned_orders,
    ROUND(AVG(o.returned) * 100.0, 1) AS return_rate_pct
FROM orders o
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.city
HAVING return_rate_pct > 20
ORDER BY return_rate_pct DESC;


-- ==============================================================================
-- e) Ranking with ORDER BY + LIMIT / OFFSET (3 marks)
-- Note: customer_id ASC is included as a tie-breaker for deterministic sorting.
--
-- Expected Output (LIMIT 5):
-- C043 Reyansh 12920.00
-- C026 Isha 8371.60
-- C008 Meera 4564.60
-- C011 Arjun 4111.00
-- C042 Sanya 3785.00
--
-- Expected Output (LIMIT 3 OFFSET 2):
-- C008 Meera 4564.60
-- C011 Arjun 4111.00
-- C042 Sanya 3785.00
-- ==============================================================================
-- Top 5 customers:
SELECT 
    c.customer_id,
    c.name,
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_spend
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 5;

-- Ranks 3 to 5 (OFFSET skips first 2):
SELECT 
    c.customer_id,
    c.name,
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS total_spend
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.name
ORDER BY total_spend DESC, c.customer_id ASC
LIMIT 3 OFFSET 2;


-- ==============================================================================
-- f) Three-table JOIN with GROUP BY (3 marks)
-- Expected Output:
-- Haircare (54, 44956.10)
-- Skincare (60, 27346.00)
-- Babycare (30, 16805.00)
-- PersonalCare (36, 10753.10)
-- ==============================================================================
SELECT 
    p.category,
    COUNT(o.order_id) AS order_count,
    ROUND(SUM(o.quantity * p.price * (1.0 - COALESCE(o.discount_pct, 0) / 100.0)), 2) AS category_revenue
FROM orders o
JOIN products p ON o.product_id = p.product_id
JOIN customers c ON o.customer_id = c.customer_id
GROUP BY p.category
ORDER BY category_revenue DESC;


-- ==============================================================================
-- g) LIKE pattern match (2 marks)
-- Expected Output: Exactly 10 rows
-- ==============================================================================
SELECT customer_id, name, city, city_tier, signup_date, acquisition_source
FROM customers
WHERE name LIKE 'A%';


-- ==============================================================================
-- h) DISTINCT (1 mark)
-- Expected Output: Exactly 4 values — Ad, Organic, Referral, Social
-- ==============================================================================
SELECT DISTINCT acquisition_source
FROM customers
ORDER BY acquisition_source ASC;


-- ==============================================================================
-- i) ALTER TABLE + UPDATE with CASE (1 mark)
-- Expected Output: Gold, 28 and Silver, 17
-- ==============================================================================
ALTER TABLE customers ADD COLUMN loyalty_tier VARCHAR(10);

UPDATE customers
SET loyalty_tier = CASE 
    WHEN city_tier = 1 THEN 'Gold' 
    ELSE 'Silver' 
END;

-- Verification:
SELECT loyalty_tier, COUNT(*) AS count
FROM customers
GROUP BY loyalty_tier;