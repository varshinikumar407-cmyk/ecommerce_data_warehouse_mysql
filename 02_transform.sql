USE ecommerce_warehouse;

-- Backup of the fact table
CREATE TABLE fact_order_items_backup AS SELECT * FROM fact_order_items;

-- Staging table for the orders file
CREATE TABLE stg_orders (
  order_id VARCHAR(100),
  customer_id VARCHAR(100),
  order_status VARCHAR(30),
  order_purchase_timestamp VARCHAR(30),
  order_approved_at VARCHAR(30),
  order_delivered_carrier_date VARCHAR(30),
  order_delivered_customer_date VARCHAR(30),
  order_estimated_delivery_date VARCHAR(30)
);

-- Indexes
CREATE INDEX idx_stg_order ON stg_orders(order_id);
CREATE INDEX idx_fact_order ON fact_order_items(order_id);

-- New columns in the fact table
ALTER TABLE fact_order_items
  ADD COLUMN customer_id VARCHAR(100),
  ADD COLUMN order_date DATE,
  ADD COLUMN order_status VARCHAR(30);

-- Fill customer, date and status from the staging table
SET SQL_SAFE_UPDATES = 0;
UPDATE fact_order_items f
JOIN stg_orders o ON f.order_id = o.order_id
SET f.customer_id = o.customer_id,
    f.order_date = DATE(STR_TO_DATE(o.order_purchase_timestamp, '%Y-%m-%d %H:%i:%s')),
    f.order_status = o.order_status;
SET SQL_SAFE_UPDATES = 1;

-- Date dimension
CREATE TABLE dim_date (
  date_key DATE PRIMARY KEY,
  year_no INT,
  quarter_no INT,
  month_no INT,
  month_name VARCHAR(12),
  day_name VARCHAR(12)
);

INSERT INTO dim_date
WITH RECURSIVE d AS (
  SELECT DATE('2016-09-01') AS dt
  UNION ALL
  SELECT dt + INTERVAL 1 DAY FROM d WHERE dt < '2018-12-31'
)
SELECT dt, YEAR(dt), QUARTER(dt), MONTH(dt), MONTHNAME(dt), DAYNAME(dt) FROM d;

-- Category translation table
CREATE TABLE category_translation (
  product_category_name VARCHAR(100),
  product_category_name_english VARCHAR(100)
);

-- Foreign keys
ALTER TABLE fact_order_items
  ADD CONSTRAINT fk_fact_product  FOREIGN KEY (product_id)  REFERENCES dim_product_new(product_id),
  ADD CONSTRAINT fk_fact_customer FOREIGN KEY (customer_id) REFERENCES dim_customer(customer_id),
  ADD CONSTRAINT fk_fact_date     FOREIGN KEY (order_date)  REFERENCES dim_date(date_key);
