USE ecommerce_warehouse;

-- Validation checks
SELECT
  (SELECT COUNT(*) FROM dim_date) AS dim_date_rows,
  (SELECT COUNT(*) FROM fact_order_items f
     LEFT JOIN dim_product_new p ON f.product_id = p.product_id
     WHERE p.product_id IS NULL) AS orphan_products,
  (SELECT COUNT(*) FROM fact_order_items f
     LEFT JOIN dim_customer c ON f.customer_id = c.customer_id
     WHERE c.customer_id IS NULL) AS orphan_customers,
  (SELECT COUNT(*) FROM fact_order_items f
     LEFT JOIN dim_date d ON f.order_date = d.date_key
     WHERE d.date_key IS NULL) AS orphan_dates,
  (SELECT COUNT(*) FROM fact_order_items
     WHERE customer_id IS NULL OR order_date IS NULL OR order_status IS NULL) AS missing_values;
