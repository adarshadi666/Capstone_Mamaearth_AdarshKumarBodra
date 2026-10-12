-- sql/seed_data.sql
-- Set import mode to CSV
.mode csv

-- Import the CSV files, skipping row 1 (the header names)
.import --skip 1 data/customers.csv customers
.import --skip 1 data/products.csv products
.import --skip 1 data/orders.csv orders

-- Convert empty imported text strings into true SQL NULL values
UPDATE orders SET discount_pct = NULL WHERE discount_pct = '';
UPDATE orders SET rating = NULL WHERE rating = '';

-- Verification row counts (Must return: 45, 16, 180)
SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_products FROM products;
SELECT COUNT(*) AS total_orders FROM orders;