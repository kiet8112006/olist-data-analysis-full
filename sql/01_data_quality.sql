1. Customers Table
1.1 Data Completeness
sql```
SELECT
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS null_customer_unique_id,
SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip,
SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_city,
SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM dbo.olist_customers_dataset;
```
1.2 Duplicate Check
sql```
SELECT customer_id, COUNT(*) AS duplicated_customer_id
FROM dbo.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;
```
1.3 Customer Unique ID Analysis
sql```
select count(distinct customer_id) as order_counts, customer_unique_id
from dbo.olist_customers_dataset
group by customer_unique_id
having count(distinct customer_id) > 1
order by order_counts desc;
```
1.4 Check for Invalid ZIP Code Values
sql```
SELECT *
FROM olist_customers_dataset
WHERE customer_zip_code_prefix < 10000
   OR customer_zip_code_prefix > 99999;
```
1.5 Check Distribution of Customers by ZIP Code
sql```
SELECT 
    customer_zip_code_prefix,
    COUNT(*) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_zip_code_prefix
ORDER BY total_customers DESC;
```
1.6 distribution check and Data Consistency: customer_city
sql```
SELECT 
    customer_city,
    COUNT(*) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_city
ORDER BY total_customers DESC;
```
1.7 distribution check and Data Consistency: customer_state 
sql```
SELECT 
    customer_state,
    COUNT(*) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY total_customers DESC;
```
1.8 Geolocation Validation
sql```
select 
    c.customer_id,
    c.customer_unique_id,
    c.customer_zip_code_prefix,
    c.customer_city,
    c.customer_state,
    g.avg_lat,
    g.avg_lng,
    case 
        when g.geolocation_zip_code_prefix is null then 1
        else 0
    end as flag_missing_geo
into dbo.olist_customers_geo_check_dataset
from dbo.olist_customers_dataset c
left join dbo.geolocation_avg g
    on c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;
```

1.9 Geolocation Validation Impact Analysis
sql```
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN flag_missing_geo = 1 THEN 1 ELSE 0 END) AS missing_geo_count,
    ROUND(
        100.0 * SUM(CASE WHEN flag_missing_geo = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS missing_geo_percentage
FROM dbo.olist_customers_geo_check_dataset;
```
2. Geolocation table 
2.1 Geolocation Data Aggregation
sql```
SELECT 
    geolocation_zip_code_prefix,
    AVG(geolocation_lat) AS avg_lat,
    AVG(geolocation_lng) AS avg_lng,
    MAX(geolocation_city) AS city,
    MAX(geolocation_state) AS state
INTO geolocation_avg
FROM dbo.olist_geolocation_dataset
GROUP BY geolocation_zip_code_prefix;
```
2.2 Data Completeness Check
sql```
SELECT 
SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) 
AS null_geolocation_zip_code_prefix
FROM dbo.olist_geolocation_dataset;
```
2.3 Coordinate Completeness Check
sql```
SELECT 
SUM(CASE WHEN avg_lat IS NULL THEN 1 ELSE 0 END) AS null_geolocation_lat,
SUM(CASE WHEN avg_lng IS NULL THEN 1 ELSE 0 END) AS null_geolocation_lng
FROM dbo.geolocation_avg;
```
2.4 City and State Completeness Check
sql```
SELECT 
    COUNT(*) AS null_geo_city,
    COUNT(*) AS null_geo_state
FROM dbo.geolocation_avg
WHERE city IS NULL OR state IS NULL;
```
2.5 Duplicate ZIP Code Check
sql```
SELECT 
    geolocation_zip_code_prefix,
    COUNT(geolocation_zip_code_prefix) AS duplicated_geo_zip_code_prefix
FROM geolocation_avg
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;
```
2.6 City Distribution Check
sql```
SELECT city, COUNT(*) AS city_counts
FROM dbo.geolocation_avg
GROUP BY city;
```
2.7 State Distribution Check
```sql
SELECT state, COUNT(*) AS state_counts
FROM dbo.geolocation_avg
GROUP BY state;
```
3. Order Items Table
3.1 Data Completeness Check
sql```
SELECT
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
SUM(CASE WHEN order_item_id IS NULL THEN 1 ELSE 0 END) AS null_order_item_id,
SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS null_shipping_limit_date,
SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS null_price,
SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS null_freight_value
FROM dbo.olist_order_items_dataset;
```
3.2 Check Duplicate Records
sql```
SELECT 
    order_id, 
    order_item_id, 
    COUNT(*) AS duplicated_counts
FROM dbo.olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
```
3.3 Check Range of shipping_limit_date
```sql
SELECT
    MIN(shipping_limit_date) AS min_shipping_limit_date,
    MAX(shipping_limit_date) AS max_shipping_limit_date
FROM dbo.olist_order_items_dataset;
```
3.4 Check for Negative Price Values
```sql
SELECT price
FROM dbo.olist_order_items_dataset
WHERE price < 0;
```
3.5 Check for Zero Price Values
sql```
SELECT price
FROM dbo.olist_order_items_dataset
WHERE price = 0;
```
3.6 Detect High Price Outliers
sql```
SELECT TOP 20
    order_id,
    product_id,
    price
FROM dbo.olist_order_items_dataset
ORDER BY price DESC;
```
3.7 Price Distribution Overview
sql```
SELECT
    COUNT(*) AS total_rows,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    STDEV(price) AS std_price
FROM dbo.olist_order_items_dataset;
```
3.8 Freight Cost vs Product Price Check
sql```
SELECT *
FROM dbo.olist_order_items_dataset
WHERE freight_value > price;
```
3.9 Freight Value Distribution Overview
sql```
SELECT
    COUNT(*) AS total_rows,
    MIN(freight_value) AS min_freight,
    MAX(freight_value) AS max_freight,
    AVG(freight_value) AS avg_freight,
    STDEV(freight_value) AS std_freight
FROM dbo.olist_order_items_dataset;
```
3.10 Detect Highest Shipping Costs
sql```
SELECT TOP 20
    order_id,
    price,
    freight_value
FROM dbo.olist_order_items_dataset
ORDER BY freight_value DESC;
```
4. Order Payments table 
4.1 check for null
sql```
SELECT 
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS null_payment_sequential,
SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS null_payment_installments,
SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value
FROM dbo.olist_order_payments_dataset;
```
4.2 Duplicate Check
sql```
SELECT 
    order_id, 
    payment_sequential, 
    COUNT(*) AS dup_counts
FROM dbo.olist_order_payments_dataset
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;
```
4.3 Payment Type Distribution
sql```
SELECT
    payment_type,
    COUNT(*) AS payment_type_counts,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percentage
FROM dbo.olist_order_payments_dataset
GROUP BY payment_type
ORDER BY percentage DESC;
```
4.4 Invalid Installments Check
sql```
SELECT *
FROM dbo.olist_order_payments_dataset
WHERE payment_installments <= 0;
```
4.5 Installment Outlier Check
sql```
SELECT payment_installments
FROM dbo.olist_order_payments_dataset
WHERE payment_installments > 24;
```
4.6 Negative Payment Value Check
sql```
SELECT *
FROM dbo.olist_order_payments_dataset
WHERE payment_value < 0;
```
4.7 Zero Payment Value Check
sql```
SELECT *
FROM dbo.olist_order_payments_dataset
WHERE payment_value = 0;
```
4.8 Payment Value Summary Statistics
sql```
SELECT
COUNT(*) AS total_rows,
MIN(payment_value) AS min_payment,
MAX(payment_value) AS max_payment,
AVG(payment_value) AS avg_payment,
STDEV(payment_value) AS std_payment
FROM dbo.olist_order_payments_dataset;
```
4.9 High Payment Value Inspection
sql```
SELECT TOP 20
order_id,
payment_type,
payment_value
FROM dbo.olist_order_payments_dataset
ORDER BY payment_value DESC;
```
4.10 Logical Validation – Installments vs High Payment Value
sql```
SELECT *
FROM dbo.olist_order_payments_dataset
WHERE payment_installments = 1
AND payment_value > 5000;
```
5. Order reviews table 
5.1 Missing Value Check
sql```
SELECT
SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS null_review_id,
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_review_score,
SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS null_review_creation_date,
SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS null_review_answer_timestamp
FROM dbo.olist_order_reviews_dataset;
```
5.2 Duplicate Review Check
sql```
SELECT review_id, COUNT(*) AS dup_counts
FROM dbo.olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1;
```
5.3 Review Score Distribution
sql```
SELECT 
review_score,
COUNT(*) AS total_review_score,
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percentage
FROM dbo.olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;
```
5.4 Review Comment Title Distribution
sql```
SELECT
CASE 
    WHEN review_comment_title IS NULL THEN NULL
    ELSE 'has_title'
END AS title_status,
COUNT(*) AS total_counts,
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percentage
FROM dbo.olist_order_reviews_dataset
GROUP BY
CASE 
    WHEN review_comment_title IS NULL THEN NULL
    ELSE 'has_title'
END;
```
5.4 Review Comment Message Distribution
sql```
SELECT
CASE 
    WHEN review_comment_message IS NULL THEN NULL
    ELSE 'has_message'
END AS message_status,
COUNT(*) AS total_counts,
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percentage
FROM dbo.olist_order_reviews_dataset
GROUP BY
CASE 
    WHEN review_comment_message IS NULL THEN NULL
    ELSE 'has_message'
END;
```
5.5 Review Timestamp Validation
5.5.1 Timestamp Range Check
sql```
SELECT
MIN(review_creation_date) AS min_creation,
MAX(review_creation_date) AS max_creation,
MIN(review_answer_timestamp) AS min_answer,
MAX(review_answer_timestamp) AS max_answer
FROM dbo.olist_order_reviews_dataset;
```
5.5.2 Logical Consistency Check
sql```
SELECT *
FROM dbo.olist_order_reviews_dataset
WHERE review_answer_timestamp < review_creation_date;
```
6. Order table
6.1 Data Completeness Check
sql```
SELECT
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS null_order_status,
SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS null_order_purchase_timestamp,
SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS null_approved,
SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS null_carrier,
SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS null_delivered
FROM dbo.olist_orders_dataset;
```
6.2 Duplicate Order ID Check
sql```
SELECT 
order_id,
COUNT(*) AS dup_order_id
FROM dbo.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;
```
6.3 Order Status Distribution
sql```
SELECT 
order_status,
COUNT(*) AS counts,
CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS percentage_order_status
FROM dbo.olist_orders_dataset
GROUP BY order_status;
```
6.4Delivery Time Logical Validation
6.4.1 Approval Before Purchase Check
sql```
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_approved_at < order_purchase_timestamp;
```
6.4.2 Delivered to Customer Before Carrier Check
sql```
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_delivered_customer_date < order_delivered_carrier_date;
```
6.4.3 Delivered Before Purchase Check
sql```
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_delivered_customer_date < order_purchase_timestamp;
```
6.4.4 Late Delivery Detection
sql```
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_delivered_customer_date > order_estimated_delivery_date;
```
6.4.5 Delivered Orders Without Delivery Date
sql```
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;
```
7. Products table
7.1 Data Completeness Check
sql```
SELECT
COUNT(*) AS total_rows,
SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS null_product_id,
SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category,
SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS null_name_length,
SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS null_description_length,
SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS null_photos,
SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS null_weight,
SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS null_length,
SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS null_height,
SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS null_width
FROM dbo.olist_products_dataset;
```
7.2 Duplicate Product ID Check
sql```
SELECT 
product_id,
COUNT(*) AS dup_product_id
FROM dbo.olist_products_dataset
GROUP BY product_id
HAVING COUNT(*) > 1;
```
7.3 Product Category Distribution
sql```
SELECT 
product_category_name,
COUNT(*) AS total_product,
CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS percentage_products
FROM dbo.olist_products_dataset
GROUP BY product_category_name;
```
7.4 Missing Category Name Check
sql query:
```sql
SELECT *
FROM dbo.olist_products_dataset
WHERE product_category_name IS NULL;
```
7.5 Category Name Format Check
sql```
SELECT DISTINCT product_category_name
FROM dbo.olist_products_dataset
```
7.6 Product Dimension Range Check
sql```
SELECT
MIN(product_weight_g), MAX(product_weight_g),
MIN(product_length_cm), MAX(product_length_cm),
MIN(product_height_cm), MAX(product_height_cm),
MIN(product_width_cm), MAX(product_width_cm)
FROM dbo.olist_products_dataset;
```
7.7 Zero Dimension Check
sql```
SELECT *
FROM dbo.olist_products_dataset
WHERE product_length_cm = 0
   OR product_height_cm = 0
   OR product_width_cm = 0;
```
7.8 Zero Weight Check
sql```
SELECT *
FROM dbo.olist_products_dataset
WHERE product_weight_g = 0;
```
7.9 Product Text Attribute Validation
sql```
SELECT
MIN(product_name_lenght), MAX(product_name_lenght),
MIN(product_description_lenght), MAX(product_description_lenght),
MIN(product_photos_qty), MAX(product_photos_qty)
FROM dbo.olist_products_dataset;
```
7.10 Empty Product Name or Description Check
sql```
SELECT *
FROM dbo.olist_products_dataset
WHERE product_name_lenght = 0
OR product_description_lenght = 0;
```
7.11 Excessive Product Photo Check
sql```
SELECT *
FROM dbo.olist_products_dataset
WHERE product_photos_qty > 10;
```
8. Sellers table
8.1 Data Completeness Check
sql```
SELECT
COUNT(*) AS total_rows,
SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip,
SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS null_city,
SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM dbo.olist_sellers_dataset;
```
8.2 Duplicate Seller ID Check
sql```
SELECT 
seller_id,
COUNT(*) AS dup_counts
FROM dbo.olist_sellers_dataset
GROUP BY seller_id
HAVING COUNT(*) > 1;
```
8.3 Seller Distribution by State
sql```
SELECT 
seller_state,
COUNT(*) AS total_sellers
FROM dbo.olist_sellers_dataset
GROUP BY seller_state
ORDER BY total_sellers DESC;
```
8.4 Seller City Validation
sql```
SELECT DISTINCT seller_city
FROM dbo.olist_sellers_dataset
ORDER BY seller_city;
```
8.5 ZIP Code Standardization
sql```
UPDATE dbo.olist_sellers_dataset
SET seller_zip_code_prefix = RIGHT('00000' + seller_zip_code_prefix, 5)
WHERE seller_zip_code_prefix IS NOT NULL;
```
8.6 Seller Geolocation Validation
sql```
SELECT s.*
FROM dbo.olist_sellers_dataset s
LEFT JOIN dbo.geolocation_avg g
ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;
```
9. Product Category Translation Table
9.1 Data Completeness Check
sql```
SELECT
SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category,
SUM(CASE WHEN product_category_name_english IS NULL THEN 1 ELSE 0 END) AS null_category_eng
FROM dbo.product_category_name_translation;
```
sql```
SELECT 
product_category_name,
COUNT(*) AS dup_counts
FROM dbo.product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;
```
9.2  Category Name Validation
sql```
SELECT DISTINCT product_category_name
FROM dbo.product_category_name_translation
GROUP BY product_category_name;
```
9.3 Category Mapping Validation
sql```
SELECT p.product_category_name
FROM dbo.olist_products_dataset p
LEFT JOIN dbo.product_category_name_translation t
ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL;
```






