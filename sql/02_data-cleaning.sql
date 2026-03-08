/* =========================================================
   DATA CLEANING - OLIST DATASET
   TABLE: olist_customers_dataset
   PURPOSE: Create cleaned version of customers table
   ========================================================= */
------------------------------------------------------------
-- 1. CREATE CLEAN TABLE
-- Create a copy of the original customers table
------------------------------------------------------------
SELECT *
INTO dbo.olist_customers_clean_dataset
FROM dbo.olist_customers_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_customers_clean_dataset;
------------------------------------------------------------
-- 2. STANDARDIZE ZIP CODE
-- Ensure ZIP codes have 5 digits (pad with leading zeros)
------------------------------------------------------------
UPDATE dbo.olist_customers_clean_dataset
SET customer_zip_code_prefix = RIGHT('00000' + customer_zip_code_prefix, 5)
WHERE customer_zip_code_prefix IS NOT NULL;
------------------------------------------------------------
-- 3. STANDARDIZE TEXT FORMAT
-- Remove extra spaces and convert text to uppercase
------------------------------------------------------------
-- Standardize city names
UPDATE dbo.olist_customers_clean_dataset
SET customer_city = UPPER(LTRIM(RTRIM(customer_city)))
WHERE customer_city IS NOT NULL;
-- Standardize state names
UPDATE dbo.olist_customers_clean_dataset
SET customer_state = UPPER(LTRIM(RTRIM(customer_state)))
WHERE customer_state IS NOT NULL;
------------------------------------------------------------
-- 4. CHECK PRIMARY KEY UNIQUENESS
-- Ensure customer_id is unique
------------------------------------------------------------
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_id
FROM dbo.olist_customers_clean_dataset;
------------------------------------------------------------
-- 5. ADD PRIMARY KEY CONSTRAINT
------------------------------------------------------------
ALTER TABLE dbo.olist_customers_clean_dataset
ADD CONSTRAINT PK_customers PRIMARY KEY (customer_id);
/* =========================================================
   DATA CLEANING - OLIST DATASET
   TABLE: olist_sellers_dataset
   PURPOSE: Create cleaned version of sellers table
   ========================================================= */
------------------------------------------------------------
-- 2. CREATE CLEAN TABLE
------------------------------------------------------------
SELECT *
INTO dbo.olist_sellers_clean_dataset
FROM dbo.olist_sellers_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_sellers_clean_dataset;
------------------------------------------------------------
-- 2.1 STANDARDIZE TEXT FORMAT
-- Remove extra spaces and convert to uppercase
------------------------------------------------------------
-- Standardize seller city
UPDATE dbo.olist_sellers_clean_dataset
SET seller_city = UPPER(LTRIM(RTRIM(seller_city)))
WHERE seller_city IS NOT NULL;
-- Standardize seller state
UPDATE dbo.olist_sellers_clean_dataset
SET seller_state = UPPER(LTRIM(RTRIM(seller_state)))
WHERE seller_state IS NOT NULL;
------------------------------------------------------------
-- 2.2 STANDARDIZE ZIP CODE
-- Ensure ZIP codes always have 5 digits
------------------------------------------------------------
UPDATE dbo.olist_sellers_clean_dataset
SET seller_zip_code_prefix = RIGHT('00000' + seller_zip_code_prefix, 5)
WHERE seller_zip_code_prefix IS NOT NULL;
------------------------------------------------------------
-- 2.3 CHECK PRIMARY KEY UNIQUENESS
------------------------------------------------------------
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT seller_id) AS unique_seller_id
FROM dbo.olist_sellers_clean_dataset;
------------------------------------------------------------
-- 2.4 ADD PRIMARY KEY
------------------------------------------------------------
ALTER TABLE dbo.olist_sellers_clean_dataset
ADD CONSTRAINT PK_sellers PRIMARY KEY (seller_id);
/* =========================================================
   DATA CLEANING - OLIST DATASET
   TABLE: olist_products_dataset
   PURPOSE: Create cleaned version of products table
   ========================================================= */
------------------------------------------------------------
-- 3. CREATE CLEAN TABLE
------------------------------------------------------------
SELECT *
INTO dbo.olist_products_clean_dataset
FROM dbo.olist_products_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_products_clean_dataset;
------------------------------------------------------------
-- 3.1 ADD PRIMARY KEY
------------------------------------------------------------
ALTER TABLE dbo.olist_products_clean_dataset
ADD CONSTRAINT PK_products PRIMARY KEY (product_id);
------------------------------------------------------------
-- 3.2 HANDLE MISSING PRODUCT CATEGORY
-- Replace NULL category with 'unknown'
------------------------------------------------------------
UPDATE dbo.olist_products_clean_dataset
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL;
------------------------------------------------------------
-- 3.3 HANDLE INVALID TEXT LENGTH VALUES
-- Replace 0 with NULL
------------------------------------------------------------
UPDATE dbo.olist_products_clean_dataset
SET product_name_lenght = NULL
WHERE product_name_lenght = 0;

UPDATE dbo.olist_products_clean_dataset
SET product_description_lenght = NULL
WHERE product_description_lenght = 0;
------------------------------------------------------------
-- 3.4 HANDLE INVALID PRODUCT DIMENSIONS
-- Replace 0 with NULL
------------------------------------------------------------
UPDATE dbo.olist_products_clean_dataset
SET product_weight_g = NULL
WHERE product_weight_g = 0;

UPDATE dbo.olist_products_clean_dataset
SET product_length_cm = NULL
WHERE product_length_cm = 0;

UPDATE dbo.olist_products_clean_dataset
SET product_height_cm = NULL
WHERE product_height_cm = 0;

UPDATE dbo.olist_products_clean_dataset
SET product_width_cm = NULL
WHERE product_width_cm = 0;
------------------------------------------------------------
-- 3.5 CREATE DERIVED COLUMN: PRODUCT VOLUME
------------------------------------------------------------
ALTER TABLE dbo.olist_products_clean_dataset
ADD product_volume_cm3 INT;

UPDATE dbo.olist_products_clean_dataset
SET product_volume_cm3 = 
    product_length_cm * product_width_cm * product_height_cm;
/* =========================================================
   DATA CLEANING - OLIST DATASET
   TABLE: product_category_name_translation
   PURPOSE: Clean product category translation table
   ========================================================= */
------------------------------------------------------------
-- 4. CREATE CLEAN TABLE
------------------------------------------------------------
SELECT *
INTO dbo.product_category_name_translation_clean
FROM dbo.product_category_name_translation;
-- Preview data
SELECT TOP 100 *
FROM dbo.product_category_name_translation_clean;
------------------------------------------------------------
-- 4.1 STANDARDIZE TEXT FORMAT
-- Remove spaces and convert to uppercase
------------------------------------------------------------
UPDATE dbo.product_category_name_translation_clean
SET product_category_name = UPPER(LTRIM(RTRIM(product_category_name)))
WHERE product_category_name IS NOT NULL;

UPDATE dbo.product_category_name_translation_clean
SET product_category_name_english = UPPER(LTRIM(RTRIM(product_category_name_english)))
WHERE product_category_name_english IS NOT NULL;
------------------------------------------------------------
-- 4.2 CHECK PRIMARY KEY UNIQUENESS
------------------------------------------------------------
SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT product_category_name) AS unique_categories
FROM dbo.product_category_name_translation_clean;
------------------------------------------------------------
-- 4.3 ADD PRIMARY KEY
------------------------------------------------------------
ALTER TABLE dbo.product_category_name_translation_clean
ADD CONSTRAINT PK_category PRIMARY KEY (product_category_name);
/* =========================================================
   DATA CLEANING - OLIST DATASET
   TABLE: olist_orders_dataset
   PURPOSE: Clean orders data and fix timeline inconsistencies
   ========================================================= */
------------------------------------------------------------
-- 5. CREATE CLEAN TABLE
------------------------------------------------------------
SELECT *
INTO dbo.olist_orders_clean_dataset
FROM dbo.olist_orders_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_orders_clean_dataset;
------------------------------------------------------------
-- 5.1 ADD PRIMARY KEY
------------------------------------------------------------
ALTER TABLE dbo.olist_orders_clean_dataset
ADD CONSTRAINT PK_orders PRIMARY KEY (order_id);
------------------------------------------------------------
-- 5.2 FIX TIMESTAMP LOGIC
-- Ensure chronological order of events
------------------------------------------------------------
-- approval must not happen before purchase
UPDATE dbo.olist_orders_clean_dataset
SET order_approved_at = order_purchase_timestamp
WHERE order_approved_at < order_purchase_timestamp;
-- delivery to customer must not happen before carrier delivery
UPDATE dbo.olist_orders_clean_dataset
SET order_delivered_customer_date = order_delivered_carrier_date
WHERE order_delivered_customer_date < order_delivered_carrier_date;
-- delivery must not happen before purchase
UPDATE dbo.olist_orders_clean_dataset
SET order_delivered_customer_date = order_purchase_timestamp
WHERE order_delivered_customer_date < order_purchase_timestamp;
------------------------------------------------------------
-- 5.3 FIX INCONSISTENT ORDER STATUS
-- Delivered orders must have delivery date
------------------------------------------------------------
UPDATE dbo.olist_orders_clean_dataset
SET order_status = 'shipped'
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;
------------------------------------------------------------
-- 5.4 STANDARDIZE ORDER STATUS
------------------------------------------------------------
UPDATE dbo.olist_orders_clean_dataset
SET order_status = LOWER(order_status);
/* =========================================================
   DATA CLEANING - OLIST DATASET
   TABLE: olist_order_items_dataset
   PURPOSE: Clean order items data
   ========================================================= */
------------------------------------------------------------
-- 6. CREATE CLEAN TABLE
------------------------------------------------------------
SELECT *
INTO dbo.olist_order_items_clean_dataset
FROM dbo.olist_order_items_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_order_items_clean_dataset;
------------------------------------------------------------
-- 6.1 ADD PRIMARY KEY
-- Composite key: order_id + order_item_id
------------------------------------------------------------
ALTER TABLE dbo.olist_order_items_clean_dataset
ADD CONSTRAINT PK_order_items
PRIMARY KEY (order_id, order_item_id);
/* =========================================================
   DATA CLEANING - OLIST DATASET
   TABLE: olist_order_payments_dataset
   PURPOSE: Clean payment data
   ========================================================= */
------------------------------------------------------------
-- 7. CREATE CLEAN TABLE
------------------------------------------------------------
SELECT *
INTO dbo.olist_order_payments_clean_dataset
FROM dbo.olist_order_payments_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_order_payments_clean_dataset;
------------------------------------------------------------
-- 7.1 FIX INVALID INSTALLMENTS
-- Installments cannot be 0
------------------------------------------------------------
UPDATE dbo.olist_order_payments_clean_dataset
SET payment_installments = 1
WHERE payment_installments = 0;
------------------------------------------------------------
-- 7.2 STANDARDIZE PAYMENT TYPE
------------------------------------------------------------
UPDATE dbo.olist_order_payments_clean_dataset
SET payment_type = LOWER(payment_type);
/* =========================================================
   DATA CLEANING - OLIST DATASET
   TABLE: olist_order_reviews_dataset
   PURPOSE: Clean order reviews and remove duplicates
   ========================================================= */
------------------------------------------------------------
-- 8. CREATE CLEAN TABLE
------------------------------------------------------------
SELECT *
INTO dbo.olist_order_reviews_clean_dataset
FROM dbo.olist_order_reviews_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_order_reviews_clean_dataset;
------------------------------------------------------------
-- 8.1 REMOVE DUPLICATE REVIEWS
-- Keep the earliest review based on creation date
------------------------------------------------------------
WITH review_cte AS
(
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY review_id
ORDER BY review_creation_date
) AS rn
FROM dbo.olist_order_reviews_clean_dataset
)

DELETE FROM review_cte
WHERE rn > 1;
------------------------------------------------------------
-- 8.2 VALIDATE DUPLICATES REMOVED
------------------------------------------------------------
SELECT review_id, COUNT(*) AS duplicate_count
FROM dbo.olist_order_reviews_clean_dataset
GROUP BY review_id
HAVING COUNT(*) > 1;
------------------------------------------------------------
-- 8.3 ADD PRIMARY KEY
------------------------------------------------------------
ALTER TABLE dbo.olist_order_reviews_clean_dataset
ADD CONSTRAINT PK_reviews PRIMARY KEY (review_id);
/* =========================================================
   DATA CLEANING - OLIST DATASET
   TABLE: olist_geolocation_dataset
   PURPOSE: Clean and aggregate geolocation data
   ========================================================= */
------------------------------------------------------------
-- 9. CREATE AGGREGATED GEOLOCATION TABLE
-- Average latitude and longitude by ZIP code
------------------------------------------------------------
SELECT
geolocation_zip_code_prefix,
AVG(geolocation_lat) AS avg_lat,
AVG(geolocation_lng) AS avg_lng,
MIN(geolocation_city) AS city,
MIN(geolocation_state) AS state
INTO dbo.geolocation_avg
FROM dbo.olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix;
------------------------------------------------------------
-- 9.1 REMOVE INVALID COORDINATES
------------------------------------------------------------
DELETE FROM dbo.geolocation_avg
WHERE avg_lat IS NULL
OR avg_lng IS NULL;
------------------------------------------------------------
-- 9.2 STANDARDIZE CITY NAME
------------------------------------------------------------
UPDATE dbo.geolocation_avg
SET city = LOWER(city);

UPDATE dbo.geolocation_avg
SET city =
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(city,
'ã','a'),'á','a'),'â','a'),'é','e'),'ó','o');

UPDATE dbo.geolocation_avg
SET city = LTRIM(RTRIM(city));
------------------------------------------------------------
-- 9.3 VALIDATE CITY DISTRIBUTION
------------------------------------------------------------
SELECT city, COUNT(*) AS total_zipcodes
FROM dbo.geolocation_avg
GROUP BY city
ORDER BY total_zipcodes DESC;
------------------------------------------------------------
-- 9.4 ADD PRIMARY KEY
------------------------------------------------------------
ALTER TABLE dbo.geolocation_avg
ADD CONSTRAINT PK_geolocation
PRIMARY KEY (geolocation_zip_code_prefix);

