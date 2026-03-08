### 1. Customers Table
#### Data Completeness
sql query:
```sql
SELECT
SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS null_customer_id,
SUM(CASE WHEN customer_unique_id IS NULL THEN 1 ELSE 0 END) AS null_customer_unique_id,
SUM(CASE WHEN customer_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip,
SUM(CASE WHEN customer_city IS NULL THEN 1 ELSE 0 END) AS null_city,
SUM(CASE WHEN customer_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM dbo.olist_customers_dataset;
```
#### Duplicate Check
SQL query used:
```sql
SELECT customer_id, COUNT(*) AS duplicated_customer_id
FROM dbo.olist_customers_dataset
GROUP BY customer_id
HAVING COUNT(*) > 1;
```
#### Customer Unique ID Analysis
To understand customer purchasing behavior, the number of orders associated with each `customer_unique_id` was analyzed.
SQL query used:
```sql
select count(distinct customer_id) as order_counts, customer_unique_id
from dbo.olist_customers_dataset
group by customer_unique_id
having count(distinct customer_id) > 1
order by order_counts desc;
```
#### Check for Invalid ZIP Code Values
Brazilian ZIP code prefixes should generally fall within a 5-digit numeric range.
sql query:
```sql
SELECT *
FROM olist_customers_dataset
WHERE customer_zip_code_prefix < 10000
   OR customer_zip_code_prefix > 99999;
```
#### Check Distribution of Customers by ZIP Code
Identify which geographic regions have the highest number of customers.
sql query:
```sql
SELECT 
    customer_zip_code_prefix,
    COUNT(*) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_zip_code_prefix
ORDER BY total_customers DESC;
```
#### 1. distribution check and Data Consistency: customer_city
sql query:
```sql
SELECT 
    customer_city,
    COUNT(*) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_city
ORDER BY total_customers DESC;
```
#### 2. distribution check and Data Consistency: customer_state 
The purpose of this query is to analyze the distribution of customers across Brazilian states and verify the consistency of the customer_state column.
sql query:
```sql
SELECT 
    customer_state,
    COUNT(*) AS total_customers
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY total_customers DESC;
```
#### Geolocation Validation
To verify that customer ZIP codes can be linked to geographic coordinates,  
the `customer_zip_code_prefix` column was compared with the geolocation dataset.
The geolocation table was previously aggregated to create an average latitude and longitude for each ZIP code prefix (`geolocation_avg`).
SQL query used:
```sql
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

#### Geolocation Validation Impact Analysis
To measure the impact of unmatched ZIP codes, the proportion of customers whose ZIP codes could not be linked to the geolocation dataset was calculated.
SQL query used:
```sql
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN flag_missing_geo = 1 THEN 1 ELSE 0 END) AS missing_geo_count,
    ROUND(
        100.0 * SUM(CASE WHEN flag_missing_geo = 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS missing_geo_percentage
FROM dbo.olist_customers_geo_check_dataset;
```
### 2. Geolocation Data Aggregation
SQL query used:
```sql
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
#### Data Completeness Check
To verify the completeness of the geolocation dataset, a check was performed to identify missing ZIP code prefixes.
SQL query used:
```sql
SELECT 
SUM(CASE WHEN geolocation_zip_code_prefix IS NULL THEN 1 ELSE 0 END) 
AS null_geolocation_zip_code_prefix
FROM dbo.olist_geolocation_dataset;
```
#### Coordinate Completeness Check
To verify the completeness of geographic coordinates, a check was performed to identify missing latitude and longitude values in the aggregated geolocation table.
SQL query used:
```sql
SELECT 
SUM(CASE WHEN avg_lat IS NULL THEN 1 ELSE 0 END) AS null_geolocation_lat,
SUM(CASE WHEN avg_lng IS NULL THEN 1 ELSE 0 END) AS null_geolocation_lng
FROM dbo.geolocation_avg;
```
#### City and State Completeness Check
To verify the completeness of location attributes, a check was performed to identify missing values in the `city` and `state` columns of the aggregated geolocation table.
SQL query used:

```sql
SELECT 
    COUNT(*) AS null_geo_city,
    COUNT(*) AS null_geo_state
FROM dbo.geolocation_avg
WHERE city IS NULL OR state IS NULL;
```
Result:
| Metric | Value |
|------|------|
| NULL city | 0 |
| NULL state | 0 |
#### Duplicate ZIP Code Check

```sql
SELECT 
    geolocation_zip_code_prefix,
    COUNT(geolocation_zip_code_prefix) AS duplicated_geo_zip_code_prefix
FROM geolocation_avg
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(*) > 1;
```
Result:
The query returned **0 rows**, indicating that no ZIP code prefixes appear more than once in the `geolocation_avg` table.
Conclusion:
No duplicate values were found in the `geolocation_zip_code_prefix` column.  
This confirms that each ZIP code prefix appears only once in the `geolocation_avg` table, meaning the aggregation process successfully produced a **unique geographic reference table** that can be safely used for joins with other datasets.
#### City Distribution Check
```sql
SELECT city, COUNT(*) AS city_counts
FROM dbo.geolocation_avg
GROUP BY city;
```
#### State Distribution Check
```sql
SELECT state, COUNT(*) AS state_counts
FROM dbo.geolocation_avg
GROUP BY state;
```
### 3. Order Items Table
#### Data Completeness Check
To evaluate data completeness, all columns in the olist_order_items_dataset table were checked for missing values.
SQL query used:
```sql
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
#### Check Duplicate Records
Check whether (order_id, order_item_id) has duplicated records in the olist_order_items_dataset table.
sql query:
```sql
SELECT 
    order_id, 
    order_item_id, 
    COUNT(*) AS duplicated_counts
FROM dbo.olist_order_items_dataset
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
```
#### Check Range of shipping_limit_date
```sql
SELECT
    MIN(shipping_limit_date) AS min_shipping_limit_date,
    MAX(shipping_limit_date) AS max_shipping_limit_date
FROM dbo.olist_order_items_dataset;
```
#### Check for Negative Price Values
Verify that the price column does not contain negative values, since product prices should not be below zero.
sql query:
```sql
SELECT price
FROM dbo.olist_order_items_dataset
WHERE price < 0;
```
#### Check for Zero Price Values
Identify records where the price equals zero, which could indicate free items, discounts, or potential data quality issues.
sql query:
```sql
SELECT price
FROM dbo.olist_order_items_dataset
WHERE price = 0;
```
#### Detect High Price Outliers
Identify the most expensive items in the dataset.
sql query:
```sql
SELECT TOP 20
    order_id,
    product_id,
    price
FROM dbo.olist_order_items_dataset
ORDER BY price DESC;
```
#### Price Distribution Overview
Analyze the overall distribution of the price column by computing key descriptive statistics.
sql query:
```sql
SELECT
    COUNT(*) AS total_rows,
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    STDEV(price) AS std_price
FROM dbo.olist_order_items_dataset;
```
#### Freight Cost vs Product Price Check
Identify order items where the shipping cost (freight_value) exceeds the product price (price).
sql query:
```sql
SELECT *
FROM dbo.olist_order_items_dataset
WHERE freight_value > price;
```
#### Freight Value Distribution Overview
Analyze the overall distribution of the freight_value column to understand shipping cost patterns.
sql query:
```sql
SELECT
    COUNT(*) AS total_rows,
    MIN(freight_value) AS min_freight,
    MAX(freight_value) AS max_freight,
    AVG(freight_value) AS avg_freight,
    STDEV(freight_value) AS std_freight
FROM dbo.olist_order_items_dataset;
```
#### Detect Highest Shipping Costs
sql query:
```sql
SELECT TOP 20
    order_id,
    price,
    freight_value
FROM dbo.olist_order_items_dataset
ORDER BY freight_value DESC;
```
### 4. Order Payments table 
To assess data completeness, a query was executed to count the number of NULL values in each column.
sql query:
```sql
SELECT 
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS null_payment_sequential,
SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS null_payment_type,
SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS null_payment_installments,
SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS null_payment_value
FROM dbo.olist_order_payments_dataset;
```
#### Duplicate Check
sql query:
```sql
SELECT 
    order_id, 
    payment_sequential, 
    COUNT(*) AS dup_counts
FROM dbo.olist_order_payments_dataset
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;
```
#### Payment Type Distribution
sql query:
```
SELECT
    payment_type,
    COUNT(*) AS payment_type_counts,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percentage
FROM dbo.olist_order_payments_dataset
GROUP BY payment_type
ORDER BY percentage DESC;
```
#### Invalid Installments Check
sql query:
```sql
SELECT *
FROM dbo.olist_order_payments_dataset
WHERE payment_installments <= 0;
```
#### Installment Outlier Check
To detect potential anomalies, a query was performed to identify records where the installment count is unusually high (payment_installments > 24).
sql query:
```sql
SELECT payment_installments
FROM dbo.olist_order_payments_dataset
WHERE payment_installments > 24;
```
#### Negative Payment Value Check
Since payment_value represents an amount of money paid by the customer, it should logically always be greater than or equal to zero. Negative values would indicate data corruption, input errors, or invalid transactions.
sql query:
```sql
SELECT *
FROM dbo.olist_order_payments_dataset
WHERE payment_value < 0;
```
#### Zero Payment Value Check
The column payment_value represents the amount of money paid by a customer for a specific payment transaction.
Therefore, a validation check was performed to identify records where payment_value = 0.
sql query:
```sql
SELECT *
FROM dbo.olist_order_payments_dataset
WHERE payment_value = 0;
```
#### Payment Value Summary Statistics
sql query:
```sql
SELECT
COUNT(*) AS total_rows,
MIN(payment_value) AS min_payment,
MAX(payment_value) AS max_payment,
AVG(payment_value) AS avg_payment,
STDEV(payment_value) AS std_payment
FROM dbo.olist_order_payments_dataset;
```
#### High Payment Value Inspection
sql query:
```sql
SELECT TOP 20
order_id,
payment_type,
payment_value
FROM dbo.olist_order_payments_dataset
ORDER BY payment_value DESC;
```
#### Logical Validation – Installments vs High Payment Value
sql query:
```sql
SELECT *
FROM dbo.olist_order_payments_dataset
WHERE payment_installments = 1
AND payment_value > 5000;
```
### 5. Order reviews table 
#### Missing Value Check
Before performing any analysis on customer satisfaction, it is necessary to verify whether the dataset contains missing values, as NULL values could affect statistical analysis or downstream modeling.
sql query:
```sql
SELECT
SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS null_review_id,
SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS null_order_id,
SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS null_review_score,
SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS null_review_creation_date,
SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS null_review_answer_timestamp
FROM dbo.olist_order_reviews_dataset;
```
#### Duplicate Review Check
sql query:
```sql
SELECT review_id, COUNT(*) AS dup_counts
FROM dbo.olist_order_reviews_dataset
GROUP BY review_id
HAVING COUNT(*) > 1;
```
#### Review Score Distribution
sql query:
```sql
SELECT 
review_score,
COUNT(*) AS total_review_score,
COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS percentage
FROM dbo.olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;
```
#### Review Comment Title Distribution
The column review_comment_title represents the title of the customer review, which usually summarizes the feedback provided by the customer.
sql query:
```sql
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
#### Review Comment Message Distribution
The review dataset includes both structured ratings and optional text fields such as review_comment_title and review_comment_message, which can be useful for deeper customer experience analysis.
sql query:
```sql
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
#### Review Timestamp Validation
#### 1. Timestamp Range Check
sql query:
```sql
SELECT
MIN(review_creation_date) AS min_creation,
MAX(review_creation_date) AS max_creation,
MIN(review_answer_timestamp) AS min_answer,
MAX(review_answer_timestamp) AS max_answer
FROM dbo.olist_order_reviews_dataset;
```
#### 2.Logical Consistency Check
sql query:
```sql
SELECT *
FROM dbo.olist_order_reviews_dataset
WHERE review_answer_timestamp < review_creation_date;
```
### 6. Order table
#### Data Completeness Check
sql query:
```sql
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
#### Duplicate Order ID Check
sql query:
```sql
SELECT 
order_id,
COUNT(*) AS dup_order_id
FROM dbo.olist_orders_dataset
GROUP BY order_id
HAVING COUNT(*) > 1;
```
#### Order Status Distribution
sql query:
```sql
SELECT 
order_status,
COUNT(*) AS counts,
CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS percentage_order_status
FROM dbo.olist_orders_dataset
GROUP BY order_status;
```
#### Delivery Time Logical Validation
#### 1.Approval Before Purchase Check
sql query:
```sql
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_approved_at < order_purchase_timestamp;
```
#### 2.Delivered to Customer Before Carrier Check
sql query:
```sql
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_delivered_customer_date < order_delivered_carrier_date;
```
#### Delivered Before Purchase Check
sql query:
```sql
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_delivered_customer_date < order_purchase_timestamp;
```
#### Late Delivery Detection
sql query:
```sql
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_delivered_customer_date > order_estimated_delivery_date;
```
#### Delivered Orders Without Delivery Date
sql query:
```sql
SELECT *
FROM dbo.olist_orders_dataset
WHERE order_status = 'delivered'
AND order_delivered_customer_date IS NULL;
```
### 7. Products table
#### Data Completeness Check
sql query:
```sql
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
#### Duplicate Product ID Check
sql query:
```sql
SELECT 
product_id,
COUNT(*) AS dup_product_id
FROM dbo.olist_products_dataset
GROUP BY product_id
HAVING COUNT(*) > 1;
```
#### Product Category Distribution
```sql
SELECT 
product_category_name,
COUNT(*) AS total_product,
CAST(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() AS DECIMAL(5,2)) AS percentage_products
FROM dbo.olist_products_dataset
GROUP BY product_category_name;
```
#### Missing Category Name Check
sql query:
```sql
SELECT *
FROM dbo.olist_products_dataset
WHERE product_category_name IS NULL;
```
#### Category Name Format Check
sql query:
```sql
SELECT DISTINCT product_category_name
FROM dbo.olist_products_dataset
```
#### Product Dimension Range Check
sql query:
```sql
SELECT
MIN(product_weight_g), MAX(product_weight_g),
MIN(product_length_cm), MAX(product_length_cm),
MIN(product_height_cm), MAX(product_height_cm),
MIN(product_width_cm), MAX(product_width_cm)
FROM dbo.olist_products_dataset;
```
#### Zero Dimension Check
sql query:
```sql
SELECT *
FROM dbo.olist_products_dataset
WHERE product_length_cm = 0
   OR product_height_cm = 0
   OR product_width_cm = 0;
```
#### Zero Weight Check
sql query:
```sql
SELECT *
FROM dbo.olist_products_dataset
WHERE product_weight_g = 0;
```
#### Product Text Attribute Validation
sql query:
```sql
SELECT
MIN(product_name_lenght), MAX(product_name_lenght),
MIN(product_description_lenght), MAX(product_description_lenght),
MIN(product_photos_qty), MAX(product_photos_qty)
FROM dbo.olist_products_dataset;
```
#### Empty Product Name or Description Check
sql query:
```sql
SELECT *
FROM dbo.olist_products_dataset
WHERE product_name_lenght = 0
OR product_description_lenght = 0;
```
#### Excessive Product Photo Check
sql query:
```sql
SELECT *
FROM dbo.olist_products_dataset
WHERE product_photos_qty > 10;
```
### 8. Sellers table
#### Data Completeness Check
sql query:
```sql
SELECT
COUNT(*) AS total_rows,
SUM(CASE WHEN seller_id IS NULL THEN 1 ELSE 0 END) AS null_seller_id,
SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS null_zip,
SUM(CASE WHEN seller_city IS NULL THEN 1 ELSE 0 END) AS null_city,
SUM(CASE WHEN seller_state IS NULL THEN 1 ELSE 0 END) AS null_state
FROM dbo.olist_sellers_dataset;
```
#### Duplicate Seller ID Check
sql query:
```sql
SELECT 
seller_id,
COUNT(*) AS dup_counts
FROM dbo.olist_sellers_dataset
GROUP BY seller_id
HAVING COUNT(*) > 1;
```
#### Seller Distribution by State
To understand how sellers are distributed geographically across Brazilian states, a query was executed to count the number of sellers per state.
sql query:
```sql
SELECT 
seller_state,
COUNT(*) AS total_sellers
FROM dbo.olist_sellers_dataset
GROUP BY seller_state
ORDER BY total_sellers DESC;
```
#### Seller City Validation
sql query:
```sql
SELECT DISTINCT seller_city
FROM dbo.olist_sellers_dataset
ORDER BY seller_city;
```
#### ZIP Code Standardization
sql query:
```sql:
UPDATE dbo.olist_sellers_dataset
SET seller_zip_code_prefix = RIGHT('00000' + seller_zip_code_prefix, 5)
WHERE seller_zip_code_prefix IS NOT NULL;
```
#### Seller Geolocation Validation
```sql
SELECT s.*
FROM dbo.olist_sellers_dataset s
LEFT JOIN dbo.geolocation_avg g
ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix
WHERE g.geolocation_zip_code_prefix IS NULL;
```
### 9. Product Category Translation Table
#### Data Completeness Check
sql query:
```sql
SELECT
SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS null_category,
SUM(CASE WHEN product_category_name_english IS NULL THEN 1 ELSE 0 END) AS null_category_eng
FROM dbo.product_category_name_translation;
```
sql query:
```sql
SELECT 
product_category_name,
COUNT(*) AS dup_counts
FROM dbo.product_category_name_translation
GROUP BY product_category_name
HAVING COUNT(*) > 1;
```
#### Category Name Validation
To examine all unique category names stored in the translation table.
sql query:
```sql
SELECT DISTINCT product_category_name
FROM dbo.product_category_name_translation
GROUP BY product_category_name;
```
#### Category Mapping Validation
sql query:
```sql
SELECT p.product_category_name
FROM dbo.olist_products_dataset p
LEFT JOIN dbo.product_category_name_translation t
ON p.product_category_name = t.product_category_name
WHERE t.product_category_name IS NULL;
```






