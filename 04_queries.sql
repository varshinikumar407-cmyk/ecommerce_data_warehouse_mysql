USE ecommerce_warehouse;

-- Headline numbers
SELECT COUNT(DISTINCT order_id) AS delivered_orders,
       COUNT(*) AS items_sold,
       ROUND(SUM(price),2) AS revenue,
       ROUND(SUM(price)/COUNT(DISTINCT order_id),2) AS avg_order_value,
       MIN(order_date) AS first_order,
       MAX(order_date) AS last_order
FROM fact_order_items
WHERE order_status = 'delivered';

-- Q1. Top 10 product categories by revenue
SELECT COALESCE(t.product_category_name_english, NULLIF(p.product_category_name,''), 'unknown') AS category,
       COUNT(*) AS items_sold,
       ROUND(SUM(f.price),2) AS revenue
FROM fact_order_items f
JOIN dim_product_new p ON f.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE f.order_status = 'delivered'
GROUP BY category
ORDER BY revenue DESC
LIMIT 10;

-- Q2. Orders and revenue by month
SELECT d.year_no, d.month_no, d.month_name,
       COUNT(DISTINCT f.order_id) AS orders,
       ROUND(SUM(f.price),2) AS revenue
FROM fact_order_items f
JOIN dim_date d ON f.order_date = d.date_key
WHERE f.order_status = 'delivered'
GROUP BY d.year_no, d.month_no, d.month_name
ORDER BY d.year_no, d.month_no;

-- Q3. Top 10 customer states by revenue
SELECT c.customer_state,
       COUNT(DISTINCT f.order_id) AS orders,
       ROUND(SUM(f.price),2) AS revenue
FROM fact_order_items f
JOIN dim_customer c ON f.customer_id = c.customer_id
WHERE f.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY revenue DESC
LIMIT 10;

-- Q4. Top 10 sellers by revenue
SELECT seller_id,
       COUNT(*) AS items_sold,
       ROUND(SUM(price),2) AS revenue
FROM fact_order_items
WHERE order_status = 'delivered'
GROUP BY seller_id
ORDER BY revenue DESC
LIMIT 10;

-- Q5. Freight as a percentage of price, by category
SELECT COALESCE(t.product_category_name_english, NULLIF(p.product_category_name,''), 'unknown') AS category,
       COUNT(*) AS items_sold,
       ROUND(SUM(f.freight_value) / SUM(f.price) * 100, 1) AS freight_pct_of_price
FROM fact_order_items f
JOIN dim_product_new p ON f.product_id = p.product_id
LEFT JOIN category_translation t ON p.product_category_name = t.product_category_name
WHERE f.order_status = 'delivered'
GROUP BY category
HAVING COUNT(*) >= 100
ORDER BY freight_pct_of_price DESC
LIMIT 10;

-- Q6. Orders by status
SELECT order_status,
       COUNT(DISTINCT order_id) AS orders,
       ROUND(COUNT(DISTINCT order_id) * 100 / (SELECT COUNT(DISTINCT order_id) FROM fact_order_items), 1) AS pct
FROM fact_order_items
GROUP BY order_status
ORDER BY orders DESC;
