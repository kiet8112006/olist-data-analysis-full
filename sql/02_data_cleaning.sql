1. Customer table clean
1.1 Create clean table 
sql```
SELECT *
INTO dbo.olist_customers_clean_dataset
FROM dbo.olist_customers_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_customers_clean_dataset;
```
1.2 Standardize zip code 
UPDATE dbo.olist_customers_clean_dataset
SET customer_zip_code_prefix = RIGHT('00000' + customer_zip_code_prefix, 5)
WHERE customer_zip_code_prefix IS NOT NULL;
1.3 standardize text format 
sql```
-- Standardize city names
UPDATE dbo.olist_customers_clean_dataset
SET customer_city = UPPER(LTRIM(RTRIM(customer_city)))
WHERE customer_city IS NOT NULL;
-- Standardize state names
UPDATE dbo.olist_customers_clean_dataset
SET customer_state = UPPER(LTRIM(RTRIM(customer_state)))
WHERE customer_state IS NOT NULL;
```
1.4 check primary key 
sql```
SELECT 
    COUNT(*) AS total_rows,
    COUNT(DISTINCT customer_id) AS unique_customer_id
FROM dbo.olist_customers_clean_dataset;
```
1.5 Add primary key 
sql```
ALTER TABLE dbo.olist_customers_clean_dataset
ADD CONSTRAINT PK_customers PRIMARY KEY (customer_id);
```
2. Seller table clean 
2.1 Create clean table 
sql```
SELECT *
INTO dbo.olist_sellers_clean_dataset
FROM dbo.olist_sellers_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_sellers_clean_dataset;
```
2.2 Standardize text format 
-- Standardize seller city
UPDATE dbo.olist_sellers_clean_dataset
SET seller_city = UPPER(LTRIM(RTRIM(seller_city)))
WHERE seller_city IS NOT NULL;
-- Standardize seller state
UPDATE dbo.olist_sellers_clean_dataset
SET seller_state = UPPER(LTRIM(RTRIM(seller_state)))
WHERE seller_state IS NOT NULL;
2.3 Standardize zip code 
sql```
UPDATE dbo.olist_sellers_clean_dataset
SET seller_zip_code_prefix = RIGHT('00000' + seller_zip_code_prefix, 5)
WHERE seller_zip_code_prefix IS NOT NULL;
```
2.4 Check primary key 
sql```
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT seller_id) AS unique_seller_id
FROM dbo.olist_sellers_clean_dataset;
```
2.5 Add primary key 
sql```
ALTER TABLE dbo.olist_sellers_clean_dataset
ADD CONSTRAINT PK_sellers PRIMARY KEY (seller_id);
```
3. Product table clean 
3.1 Create clean table 
sql```
SELECT *
INTO dbo.olist_products_clean_dataset
FROM dbo.olist_products_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_products_clean_dataset;
```
3.2 Add primary key 
sql```
ALTER TABLE dbo.olist_products_clean_dataset
ADD CONSTRAINT PK_products PRIMARY KEY (product_id);
```
3.3 HANDLE MISSING PRODUCT CATEGORY
sql```
-- Replace NULL category with 'unknown'
UPDATE dbo.olist_products_clean_dataset
SET product_category_name = 'unknown'
WHERE product_category_name IS NULL;
```
3.4 HANDLE INVALID TEXT LENGTH VALUES
sql```
-- Replace 0 with NULL
UPDATE dbo.olist_products_clean_dataset
SET product_name_lenght = NULL
WHERE product_name_lenght = 0;

UPDATE dbo.olist_products_clean_dataset
SET product_description_lenght = NULL
WHERE product_description_lenght = 0;
```
3.5 HANDLE INVALID PRODUCT DIMENSIONS
sql```
-- Replace 0 with NULL
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
```
4. Product category tránlation 
4.1 Create clean table
sql```
SELECT *
INTO dbo.product_category_name_translation_clean
FROM dbo.product_category_name_translation;
-- Preview data
SELECT TOP 100 *
FROM dbo.product_category_name_translation_clean;
```
4.2 STANDARDIZE TEXT FORMAT
sql```
-- Remove spaces and convert to uppercase
UPDATE dbo.product_category_name_translation_clean
SET product_category_name = UPPER(LTRIM(RTRIM(product_category_name)))
WHERE product_category_name IS NOT NULL;

UPDATE dbo.product_category_name_translation_clean
SET product_category_name_english = UPPER(LTRIM(RTRIM(product_category_name_english)))
WHERE product_category_name_english IS NOT NULL;
```
4.3 CHECK PRIMARY KEY UNIQUENESS
sql```
SELECT
COUNT(*) AS total_rows,
COUNT(DISTINCT product_category_name) AS unique_categories
FROM dbo.product_category_name_translation_clean;
```
4.4 ADD PRIMARY KEY
sql```
ALTER TABLE dbo.product_category_name_translation_clean
ADD CONSTRAINT PK_category PRIMARY KEY (product_category_name);
```
5. Order table clean 
5.1 Create clean table
sql```
SELECT *
INTO dbo.olist_orders_clean_dataset
FROM dbo.olist_orders_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_orders_clean_dataset;
```
5.2 Add primary key
sql```
ALTER TABLE dbo.olist_orders_clean_dataset
ADD CONSTRAINT PK_orders PRIMARY KEY (order_id);
```
5.3 FIX TIMESTAMP LOGIC
sql```
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
```
5.4  FIX INCONSISTENT ORDER STATUS
sql```
-- Delivered orders must have delivery date
UPDATE dbo.olist_orders_clean_dataset
SET order_status = 'shipped'
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;
```
5.5 STANDARDIZE ORDER STATUS
sql```
------------------------------------------------------------
UPDATE dbo.olist_orders_clean_dataset
SET order_status = LOWER(order_status);
```
6. Order_items table clean
6.1 Create clean table 
sql```
SELECT *
INTO dbo.olist_order_items_clean_dataset
FROM dbo.olist_order_items_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_order_items_clean_dataset;
```
6.2 ADD PRIMARY KEY
   sql```
-- Composite key: order_id + order_item_id
ALTER TABLE dbo.olist_order_items_clean_dataset
ADD CONSTRAINT PK_order_items
PRIMARY KEY (order_id, order_item_id);
```
7. Order_payment table clean 
7.1 Create clean table 
sql```
SELECT *
INTO dbo.olist_order_payments_clean_dataset
FROM dbo.olist_order_payments_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_order_payments_clean_dataset;
```
7.2 FIX INVALID INSTALLMENTS
sql```
-- Installments cannot be 0
UPDATE dbo.olist_order_payments_clean_dataset
SET payment_installments = 1
WHERE payment_installments = 0;
```
7.3 STANDARDIZE PAYMENT TYPE
sql```
UPDATE dbo.olist_order_payments_clean_dataset
SET payment_type = LOWER(payment_type);
```
8. Order_review table clean 
8.1 Create cvlean table 
sql```
SELECT *
INTO dbo.olist_order_reviews_clean_dataset
FROM dbo.olist_order_reviews_dataset;
-- Preview data
SELECT TOP 100 *
FROM dbo.olist_order_reviews_clean_dataset;
```
8.2 REMOVE DUPLICATE REVIEWS
sql```
-- Keep the earliest review based on creation date
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
```
8.3 VALIDATE DUPLICATES REMOVED
sql```
SELECT review_id, COUNT(*) AS duplicate_count
FROM dbo.olist_order_reviews_clean_dataset
GROUP BY review_id
HAVING COUNT(*) > 1;
```
8.4 ADD PRIMARY KEY
sql```
ALTER TABLE dbo.olist_order_reviews_clean_dataset
ADD CONSTRAINT PK_reviews PRIMARY KEY (review_id);
```
9. Geolocation table clean 
9.1 Create clean table 
sql```
SELECT
geolocation_zip_code_prefix,
AVG(geolocation_lat) AS avg_lat,
AVG(geolocation_lng) AS avg_lng,
MIN(geolocation_city) AS city,
MIN(geolocation_state) AS state
INTO dbo.geolocation_avg
FROM dbo.olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix;
```
9.2  REMOVE INVALID COORDINATES
sql```
DELETE FROM dbo.geolocation_avg
WHERE avg_lat IS NULL
OR avg_lng IS NULL;
```
9.3 STANDARDIZE CITY NAME
sql```
UPDATE dbo.geolocation_avg
SET city = LOWER(city);

UPDATE dbo.geolocation_avg
SET city =
REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(city,
'ã','a'),'á','a'),'â','a'),'é','e'),'ó','o');

UPDATE dbo.geolocation_avg
SET city = LTRIM(RTRIM(city));
```
9.4 VALIDATE CITY DISTRIBUTION
sql```
SELECT city, COUNT(*) AS total_zipcodes
FROM dbo.geolocation_avg
GROUP BY city
ORDER BY total_zipcodes DESC;
```
9.5 Add primary key 
sql``
ALTER TABLE dbo.geolocation_avg
ADD CONSTRAINT PK_geolocation
PRIMARY KEY (geolocation_zip_code_prefix);
``
