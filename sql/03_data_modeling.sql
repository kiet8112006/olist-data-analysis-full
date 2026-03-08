/* =========================================================
   FOREIGN KEY CONSTRAINTS
   TABLE: olist_order_items_clean_dataset
   PURPOSE: Define relationships with related tables
   ========================================================= */
------------------------------------------------------------
-- Order Items → Products
------------------------------------------------------------
ALTER TABLE dbo.olist_order_items_clean_dataset
ADD CONSTRAINT FK_order_items_products
FOREIGN KEY (product_id)
REFERENCES dbo.olist_products_clean_dataset(product_id);
------------------------------------------------------------
-- Order Items → Sellers
------------------------------------------------------------
ALTER TABLE dbo.olist_order_items_clean_dataset
ADD CONSTRAINT FK_order_items_sellers
FOREIGN KEY (seller_id)
REFERENCES dbo.olist_sellers_clean_dataset(seller_id);
------------------------------------------------------------
-- Order Items → Orders
------------------------------------------------------------
ALTER TABLE dbo.olist_order_items_clean_dataset
ADD CONSTRAINT FK_order_items_orders
FOREIGN KEY (order_id)
REFERENCES dbo.olist_orders_clean_dataset(order_id);
/* =========================================================
   DATA MODELING - RELATIONSHIP CONSTRAINTS
   PURPOSE: Enforce relational integrity between tables
   ========================================================= */
------------------------------------------------------------
-- 1. VALIDATE PRODUCT CATEGORY BEFORE ADDING FOREIGN KEY
-- Ensure all product categories exist in translation table
------------------------------------------------------------
SELECT product_category_name, COUNT(*) AS total_products
FROM dbo.olist_products_clean_dataset
WHERE product_category_name NOT IN (
    SELECT product_category_name
    FROM dbo.product_category_name_translation
)
GROUP BY product_category_name;
------------------------------------------------------------
-- 2. FIX ORPHAN PRODUCT CATEGORIES
-- Replace categories that do not exist with 'unknown'
------------------------------------------------------------
UPDATE dbo.olist_products_clean_dataset
SET product_category_name = 'unknown'
WHERE product_category_name NOT IN (
    SELECT product_category_name
    FROM dbo.product_category_name_translation
);
------------------------------------------------------------
-- 3. ADD FOREIGN KEY: PRODUCTS → CATEGORY TRANSLATION
------------------------------------------------------------
ALTER TABLE dbo.olist_products_clean_dataset
ADD CONSTRAINT FK_products_category
FOREIGN KEY (product_category_name)
REFERENCES dbo.product_category_name_translation(product_category_name);
/* =========================================================
   FOREIGN KEY: ORDER REVIEWS → ORDERS
   ========================================================= */
ALTER TABLE dbo.olist_order_reviews_clean_dataset
ADD CONSTRAINT FK_reviews_orders
FOREIGN KEY (order_id)
REFERENCES dbo.olist_orders_clean_dataset(order_id);
/* =========================================================
   FOREIGN KEY: CUSTOMERS → GEOLOCATION
   PURPOSE: Link customers with geographic coordinates
   ========================================================= */
------------------------------------------------------------
-- 1. CHECK ZIP CODES THAT DO NOT EXIST IN GEOLOCATION
------------------------------------------------------------
SELECT customer_zip_code_prefix, COUNT(*) AS total_customers
FROM dbo.olist_customers_clean_dataset
WHERE customer_zip_code_prefix NOT IN (
    SELECT geolocation_zip_code_prefix
    FROM dbo.geolocation_avg
)
GROUP BY customer_zip_code_prefix;
------------------------------------------------------------
-- 2. INSERT MISSING ZIP CODES INTO GEOLOCATION TABLE
-- Use placeholder coordinates for missing values
------------------------------------------------------------
INSERT INTO dbo.geolocation_avg
(
geolocation_zip_code_prefix,
avg_lat,
avg_lng,
city,
state
)
SELECT DISTINCT
customer_zip_code_prefix,
NULL,
NULL,
'unknown',
'unknown'
FROM dbo.olist_customers_clean_dataset
WHERE customer_zip_code_prefix NOT IN (
    SELECT geolocation_zip_code_prefix
    FROM dbo.geolocation_avg
);
------------------------------------------------------------
-- 3. ADD FOREIGN KEY: CUSTOMERS → GEOLOCATION
------------------------------------------------------------
ALTER TABLE dbo.olist_customers_clean_dataset
ADD CONSTRAINT FK_customers_geolocation
FOREIGN KEY (customer_zip_code_prefix)
REFERENCES dbo.geolocation_avg(geolocation_zip_code_prefix);

/* =========================================================
DATA MODELING - STAR SCHEMA
OLIST E-COMMERCE DATASET
PURPOSE: Create dimension tables and fact tables
for business analytics
========================================================= */

---

## -- DIMENSION TABLES

-- 1. CUSTOMER DIMENSION
SELECT
customer_id,
customer_city,
customer_state,
customer_zip_code_prefix
INTO dim_customers
FROM dbo.olist_customers_clean_dataset;

-- 2. PRODUCT DIMENSION
SELECT
p.product_id,
p.product_category_name,
t.product_category_name_english
INTO dim_products
FROM dbo.olist_products_clean_dataset p
LEFT JOIN dbo.product_category_name_translation t
ON p.product_category_name = t.product_category_name;

-- 3. SELLER DIMENSION
SELECT
seller_id,
seller_city,
seller_state
INTO dim_sellers
FROM dbo.olist_sellers_clean_dataset;

-- 4. DATE DIMENSION
SELECT DISTINCT
CAST(order_purchase_timestamp AS DATE) AS order_date
INTO dim_date
FROM dbo.olist_orders_clean_dataset;

---

## -- FACT TABLES

---

## -- 1. FACT SALES (REVENUE ANALYSIS)

SELECT
oi.order_id,
o.customer_id,
oi.product_id,
oi.seller_id,

CAST(o.order_purchase_timestamp AS DATE) AS order_date,

oi.price,
oi.freight_value,

(oi.price + oi.freight_value) AS total_revenue

INTO fact_sales

FROM dbo.olist_order_items_clean_dataset oi
JOIN dbo.olist_orders_clean_dataset o
ON oi.order_id = o.order_id;

---

## -- 2. FACT CUSTOMER ORDERS (CUSTOMER ANALYTICS)

SELECT
customer_id,

COUNT(order_id) AS total_orders,

MIN(order_purchase_timestamp) AS first_order_date,

MAX(order_purchase_timestamp) AS last_order_date

INTO fact_customer_orders

FROM dbo.olist_orders_clean_dataset
GROUP BY customer_id;

---

## -- 3. FACT PRODUCT SALES (PRODUCT PERFORMANCE)

SELECT
oi.product_id,

COUNT(oi.order_id) AS total_orders,

SUM(oi.price) AS total_sales,

AVG(oi.price) AS avg_product_price

INTO fact_product_sales

FROM dbo.olist_order_items_clean_dataset oi
GROUP BY oi.product_id;

---

## -- 4. FACT REVIEWS (CUSTOMER EXPERIENCE)

SELECT
r.review_id,
r.order_id,
o.customer_id,

r.review_score,
r.review_creation_date

INTO fact_reviews

FROM dbo.olist_order_reviews_clean_dataset r
JOIN dbo.olist_orders_clean_dataset o
ON r.order_id = o.order_id;

---

## -- 5. FACT DELIVERY (OPERATIONS ANALYTICS)

SELECT
order_id,

DATEDIFF(day,
order_purchase_timestamp,
order_delivered_customer_date) AS delivery_days

INTO fact_delivery

FROM dbo.olist_orders_clean_dataset
WHERE order_delivered_customer_date IS NOT NULL;

---

## -- ADD PRIMARY KEYS

ALTER TABLE dim_customers
ADD CONSTRAINT PK_dim_customers PRIMARY KEY (customer_id);

ALTER TABLE dim_products
ADD CONSTRAINT PK_dim_products PRIMARY KEY (product_id);

ALTER TABLE dim_sellers
ADD CONSTRAINT PK_dim_sellers PRIMARY KEY (seller_id);

ALTER TABLE dim_date
ADD CONSTRAINT PK_dim_date PRIMARY KEY (order_date);

---

## -- ADD FOREIGN KEYS FOR FACT SALES

ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_customers
FOREIGN KEY (customer_id)
REFERENCES dim_customers(customer_id);

ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_products
FOREIGN KEY (product_id)
REFERENCES dim_products(product_id);

ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_sellers
FOREIGN KEY (seller_id)
REFERENCES dim_sellers(seller_id);

ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_date
FOREIGN KEY (order_date)
REFERENCES dim_date(order_date);
/* =========================================================
ADDITIONAL DATA MODELING IMPROVEMENTS
PURPOSE: Enhance star schema for analytics
========================================================= */

---

## -- 1. REBUILD DATE DIMENSION WITH TIME ATTRIBUTES

DROP TABLE IF EXISTS dim_date;

SELECT DISTINCT
CAST(order_purchase_timestamp AS DATE) AS order_date,

YEAR(order_purchase_timestamp)  AS year,
MONTH(order_purchase_timestamp) AS month,
DATENAME(month, order_purchase_timestamp) AS month_name,

DATEPART(quarter, order_purchase_timestamp) AS quarter,

DAY(order_purchase_timestamp) AS day_of_month,

DATENAME(weekday, order_purchase_timestamp) AS day_name

INTO dim_date

FROM dbo.olist_orders_clean_dataset;

ALTER TABLE dim_date
ADD CONSTRAINT PK_dim_date
PRIMARY KEY (order_date);

---

## -- 2. ADD SURROGATE KEYS TO DIMENSION TABLES

-- CUSTOMER DIMENSION
ALTER TABLE dim_customers
ADD customer_key INT IDENTITY(1,1);

ALTER TABLE dim_customers
ADD CONSTRAINT PK_dim_customers_key
PRIMARY KEY (customer_key);

-- PRODUCT DIMENSION
ALTER TABLE dim_products
ADD product_key INT IDENTITY(1,1);

ALTER TABLE dim_products
ADD CONSTRAINT PK_dim_products_key
PRIMARY KEY (product_key);

-- SELLER DIMENSION
ALTER TABLE dim_sellers
ADD seller_key INT IDENTITY(1,1);

ALTER TABLE dim_sellers
ADD CONSTRAINT PK_dim_sellers_key
PRIMARY KEY (seller_key);

---

## -- 3. INDEXES FOR PERFORMANCE

CREATE INDEX idx_fact_sales_customer
ON fact_sales(customer_id);

CREATE INDEX idx_fact_sales_product
ON fact_sales(product_id);

CREATE INDEX idx_fact_sales_date
ON fact_sales(order_date);
