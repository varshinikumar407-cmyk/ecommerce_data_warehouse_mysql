-- Database
CREATE DATABASE IF NOT EXISTS ecommerce_warehouse;
USE ecommerce_warehouse;

-- category_translation
CREATE TABLE category_translation (
  product_category_name VARCHAR(100),
  product_category_name_english VARCHAR(100)
);

-- dim_customer
CREATE TABLE dim_customer (
  customer_id VARCHAR(100) NOT NULL,
  customer_unique_id VARCHAR(100),
  customer_zip_code_prefix INT,
  customer_city VARCHAR(100),
  customer_state VARCHAR(20),
  PRIMARY KEY (customer_id)
);

-- dim_date
CREATE TABLE dim_date (
  date_key DATE NOT NULL,
  year_no INT,
  quarter_no INT,
  month_no INT,
  month_name VARCHAR(12),
  day_name VARCHAR(12),
  PRIMARY KEY (date_key)
);

-- dim_product_new
CREATE TABLE dim_product_new (
  product_id VARCHAR(100) NOT NULL,
  product_category_name VARCHAR(100),
  product_name_lenght VARCHAR(10),
  product_description_lenght VARCHAR(10),
  product_photos_qty VARCHAR(10),
  product_weight_g VARCHAR(10),
  product_length_cm VARCHAR(10),
  product_height_cm VARCHAR(10),
  product_width_cm VARCHAR(10),
  PRIMARY KEY (product_id)
);

-- fact_order_items
CREATE TABLE fact_order_items (
  order_id VARCHAR(100) NOT NULL,
  order_item_id INT NOT NULL,
  product_id VARCHAR(100),
  seller_id VARCHAR(100),
  price DECIMAL(10,2),
  freight_value DECIMAL(10,2),
  customer_id VARCHAR(100),
  order_date DATE,
  order_status VARCHAR(30),
  PRIMARY KEY (order_id, order_item_id),
  KEY idx_fact_order (order_id),
  CONSTRAINT fk_fact_product  FOREIGN KEY (product_id)  REFERENCES dim_product_new (product_id),
  CONSTRAINT fk_fact_customer FOREIGN KEY (customer_id) REFERENCES dim_customer (customer_id),
  CONSTRAINT fk_fact_date     FOREIGN KEY (order_date)  REFERENCES dim_date (date_key)
);
