Olist Data Cleaning Process
Overview
This document describes the data cleaning process applied to the Olist E-commerce dataset after completing data quality assessment.
The objective is to transform raw data into a clean, consistent, and analysis-ready dataset.
I. Cleaning Strategy
The cleaning process follows 4 main principles:
- Standardization (format, text, ZIP code)
- Missing value handling
- Logical correction (timestamps, business rules)
- Data integrity enforcement (primary keys, duplicates)
II. Tables Processed
- Customers
- Sellers
- Products
- Orders
- Order Items
- Order Payments
- Order Reviews
- Geolocation
- Product Category Translation
III. Cleaning Steps
1. Standardization
1.1 Location Data
- Standardized ZIP codes to 5-digit format  
- Trimmed and normalized text fields (city, state)  
- Converted text to consistent casing (UPPER / LOWER)
1.2 Category & Text Fields
- Removed extra spaces  
- Standardized category names  
- Normalized payment types and order status  
2. Missing Value Handling
2.1 Products
- Replaced missing `product_category_name` with `'unknown'`  
- Converted invalid values (0) → NULL:
  - product dimensions  
  - weight  
  - text length fields  
2.2 Payments
- Fixed invalid installments (`0 → 1`)  
3. Logical Data Correction
3.1 Orders
- Ensured:
  - `order_approved_at ≥ order_purchase_timestamp`
  - `order_delivered_customer_date ≥ carrier_date`
  - `delivery ≥ purchase`
- Fixed inconsistent order status:
  - Delivered orders without delivery date → converted to `shipped`
4. Duplicate Handling
4.1 Reviews
- Removed duplicate `review_id`  
- Kept the earliest review using `ROW_NUMBER()`  
5. Data Integrity Enforcement
- Added primary keys to all main tables:
  - `customer_id`, `seller_id`, `product_id`, `order_id`, `review_id`
- Created composite key:
  - `order_id + order_item_id`
- Ensured uniqueness after cleaning  
6. Geolocation Processing
- Aggregated geolocation by ZIP code  
- Removed records with missing coordinates  
- Standardized city names (lowercase, remove accents)  
- Ensured 1 ZIP code → 1 coordinate mapping  
7. Key Improvements After Cleaning
- Eliminated invalid timestamps and logical inconsistencies  
- Standardized all categorical and location data  
- Reduced noise from missing and invalid values  
- Ensured referential and structural integrity  
8. Output
Clean datasets created:
- `olist_customers_clean_dataset`
- `olist_orders_clean_dataset`
- `olist_order_items_clean_dataset`
- `olist_order_payments_clean_dataset`
- `olist_order_reviews_clean_dataset`
- `olist_products_clean_dataset`
- `olist_sellers_clean_dataset`
- `product_category_name_translation_clean`
- `geolocation_avg`
IV. Result
The dataset is now:
- Consistent  
- Structured  
- Ready for analysis and dashboarding  
V. Reference
Detailed SQL scripts: docs/02_data_cleaning.sql
