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
   FOREIGN KEY: SELLERS → GEOLOCATION
   PURPOSE: Link sellers with geographic coordinates
   ========================================================= */
------------------------------------------------------------
-- 1. CHECK ZIP CODES THAT DO NOT EXIST IN GEOLOCATION
------------------------------------------------------------
SELECT seller_zip_code_prefix, COUNT(*) AS total_sellers
FROM dbo.olist_sellers_clean_dataset
WHERE seller_zip_code_prefix NOT IN (
    SELECT geolocation_zip_code_prefix
    FROM dbo.geolocation_avg
)
GROUP BY seller_zip_code_prefix;
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
seller_zip_code_prefix,
NULL,
NULL,
'unknown',
'unknown'
FROM dbo.olist_sellers_clean_dataset
WHERE seller_zip_code_prefix NOT IN (
    SELECT geolocation_zip_code_prefix
    FROM dbo.geolocation_avg
);
------------------------------------------------------------
-- 3. ADD FOREIGN KEY: SELLERS → GEOLOCATION
------------------------------------------------------------
ALTER TABLE dbo.olist_sellers_clean_dataset
ADD CONSTRAINT FK_sellers_geolocation
FOREIGN KEY (seller_zip_code_prefix)
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
customer_zip_code_prefix,
g.avg_lat,
g.avg_lng
INTO dim_customers
FROM olist_customers_clean_dataset c
LEFT JOIN geolocation_avg g
ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;

-- 2. PRODUCT DIMENSION
SELECT
p.product_id,

t.product_category_name_english AS product_category,

p.product_name_length,
p.product_description_length,

p.product_photos_qty,

p.product_weight_g,

p.product_length_cm,
p.product_height_cm,
p.product_width_cm

INTO dim_products

FROM dbo.olist_products_clean_dataset p
LEFT JOIN dbo.product_category_name_translation t
ON p.product_category_name = t.product_category_name;

-- 3. SELLER DIMENSION
SELECT
s.seller_id,
s.seller_zip_code_prefix,
s.seller_city,
s.seller_state,

g.avg_lat AS seller_lat,
g.avg_lng AS seller_lng

INTO dim_sellers

FROM dbo.olist_sellers_clean_dataset s
LEFT JOIN dbo.geolocation_avg g
ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix;

-- 4. DATE DIMENSION
SELECT DISTINCT

CAST(order_purchase_timestamp AS DATE) AS order_date,

YEAR(order_purchase_timestamp)  AS year,
MONTH(order_purchase_timestamp) AS month,

DATENAME(month, order_purchase_timestamp) AS month_name,

DATEPART(quarter, order_purchase_timestamp) AS quarter,

DAY(order_purchase_timestamp) AS day_of_month,

DATEPART(week, order_purchase_timestamp) AS week_of_year,

DATENAME(weekday, order_purchase_timestamp) AS weekday_name,

CASE 
    WHEN DATENAME(weekday, order_purchase_timestamp) IN ('Saturday','Sunday')
    THEN 1
    ELSE 0
END AS is_weekend

INTO dim_date

FROM dbo.olist_orders_clean_dataset;
-- CUSTOMER
ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_customers
FOREIGN KEY (customer_key)
REFERENCES dim_customers(customer_key);

-- PRODUCT
ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_products
FOREIGN KEY (product_key)
REFERENCES dim_products(product_key);

-- SELLER
ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_sellers
FOREIGN KEY (seller_key)
REFERENCES dim_sellers(seller_key);

-- DATE
ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_date
FOREIGN KEY (date_key)
REFERENCES dim_date(date_key);

ALTER TABLE dim_customers
ADD CONSTRAINT PK_dim_customers PRIMARY KEY (customer_key);

ALTER TABLE dim_products
ADD CONSTRAINT PK_dim_products PRIMARY KEY (product_key);

ALTER TABLE dim_sellers
ADD CONSTRAINT PK_dim_sellers PRIMARY KEY (seller_key);

ALTER TABLE dim_date
ADD CONSTRAINT PK_dim_date PRIMARY KEY (date_key);

## -- FACT TABLES

---

SELECT
oi.order_id,
dc.customer_key,
dp.product_key,
ds.seller_key,
dd.date_key,
o.order_status,
1 AS quantity,
oi.price,
oi.freight_value,
(oi.price + oi.freight_value) AS total_revenue
INTO fact_sales
FROM olist_order_items_clean_dataset oi
JOIN olist_orders_clean_dataset o
ON oi.order_id = o.order_id
JOIN dim_customers dc
ON o.customer_id = dc.customer_id
JOIN dim_products dp
ON oi.product_id = dp.product_id
JOIN dim_sellers ds
ON oi.seller_id = ds.seller_id
JOIN dim_date dd
ON CAST(o.order_purchase_timestamp AS DATE) = dd.order_date;

ALTER TABLE fact_sales
ADD CONSTRAINT PK_fact_sales
PRIMARY KEY (order_id, product_key, seller_key);

ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_customers
FOREIGN KEY (customer_key)
REFERENCES dim_customers(customer_key);

ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_products
FOREIGN KEY (product_key)
REFERENCES dim_products(product_key);

ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_sellers
FOREIGN KEY (seller_key)
REFERENCES dim_sellers(seller_key);

ALTER TABLE fact_sales
ADD CONSTRAINT FK_sales_date
FOREIGN KEY (date_key)
REFERENCES dim_date(date_key);

## -- 2. FACT CUSTOMER ORDERS (CUSTOMER ANALYTICS)
SELECT
dc.customer_key,

COUNT(o.order_id) AS total_orders,

SUM(p.payment_value) AS total_spent,

AVG(p.payment_value) AS avg_order_value,

MIN(o.order_purchase_timestamp) AS first_order_date,

MAX(o.order_purchase_timestamp) AS last_order_date,

DATEDIFF(day,
MIN(o.order_purchase_timestamp),
MAX(o.order_purchase_timestamp)
) AS customer_lifetime_days

INTO fact_customer_orders

FROM dbo.olist_orders_clean_dataset o

LEFT JOIN dbo.olist_order_payments_dataset p
ON o.order_id = p.order_id

JOIN dim_customers dc
ON o.customer_id = dc.customer_id

GROUP BY dc.customer_key;
---

## -- 3. FACT PRODUCT SALES (PRODUCT PERFORMANCE)
SELECT
dp.product_key,

COUNT(DISTINCT oi.order_id) AS total_orders,

COUNT(*) AS units_sold,

SUM(oi.price) AS product_revenue,

SUM(oi.freight_value) AS total_freight,

SUM(oi.price + oi.freight_value) AS total_revenue,

AVG(oi.price) AS avg_product_price

INTO agg_product_sales

FROM dbo.olist_order_items_clean_dataset oi

JOIN dim_products dp
ON oi.product_id = dp.product_id

GROUP BY dp.product_key;
---

## -- 4. FACT REVIEWS (CUSTOMER EXPERIENCE)

SELECT
r.review_id,
r.order_id,

dp.product_key,
ds.seller_key,
dc.customer_key,

dd.date_key,

r.review_score

INTO fact_reviews

FROM dbo.olist_order_reviews_clean_dataset r

JOIN dbo.olist_orders_clean_dataset o
ON r.order_id = o.order_id

JOIN dbo.olist_order_items_clean_dataset oi
ON r.order_id = oi.order_id

JOIN dim_products dp
ON oi.product_id = dp.product_id

JOIN dim_sellers ds
ON oi.seller_id = ds.seller_id

JOIN dim_customers dc
ON o.customer_id = dc.customer_id

JOIN dim_date dd
ON CAST(r.review_creation_date AS DATE) = dd.order_date;

---

## -- 5. FACT DELIVERY (OPERATIONS ANALYTICS)
SELECT
o.order_id,

dd.date_key,

DATEDIFF(day,
order_purchase_timestamp,
order_delivered_customer_date
) AS delivery_days,

DATEDIFF(day,
order_estimated_delivery_date,
order_delivered_customer_date
) AS delivery_delay,

DATEDIFF(day,
order_purchase_timestamp,
order_delivered_carrier_date
) AS processing_days,

DATEDIFF(day,
order_delivered_carrier_date,
order_delivered_customer_date
) AS shipping_days

INTO fact_delivery

FROM dbo.olist_orders_clean_dataset o

JOIN dim_date dd
ON CAST(o.order_purchase_timestamp AS DATE) = dd.order_date

WHERE order_delivered_customer_date IS NOT NULL;
