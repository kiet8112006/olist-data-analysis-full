Olist Data Quality Analysis
Project Overview
This project focuses on assessing the data quality of the Olist E-commerce dataset before conducting analysis and building dashboards.
The goal is to ensure data reliability by identifying issues related to:
- Missing values
- Duplicates
- Data inconsistencies
- Outliers
- Logical errors
*Dataset Scope
The following tables were analyzed:
- Customers
- Geolocation
- Orders
- Order Items
- Order Payments
- Order Reviews
- Products
- Sellers
- Product Category Translation
I. Data Quality Checks
1. Data Completeness
- Checked NULL values across all key columns
- Most primary keys are complete
- Missing data mainly found in:
  - Product attributes (dimensions, descriptions)
  - Review comments (optional)
  - Delivery timestamps
2. Duplicate Detection
- Verified uniqueness of:
  - `customer_id`, `order_id`, `product_id`, `seller_id`
- No major duplication issues detected
- Composite keys also validated (e.g., `order_id + order_item_id`)
3. Data Consistency
3.1 Location Data
- ZIP codes validated within valid range
- Joined with geolocation data to check mapping
- Some records missing geolocation → potential gaps
3.2 Geolocation Table
- Aggregated by ZIP code for consistency
- Checked missing coordinates and duplicates
4. Numerical Validation & Outliers
4.1 Order Items
- No negative prices
- Detected:
  - High price outliers
  - Cases where `freight_value > price`
4.2 Payments
- Checked:
  - Negative / zero values
  - Invalid installments (≤0 or too high)
- Found minor anomalies
5. Temporal Validation
5.1 Orders
- Validated timeline logic:
  - `approved_at ≥ purchase_timestamp`
  - `delivered ≥ carrier ≥ purchase`
- Issues found:
  - Invalid delivery sequences
  - Missing delivery dates
  - Late deliveries
5.2 Reviews
- Checked timestamp consistency
- Minor inconsistencies detected
6. Product Data Issues
- Missing category names
- Missing or zero dimensions
- Incomplete product descriptions
- Unmapped categories in translation table
II. Key Data Quality Issues

- Missing geolocation mapping
- Incomplete product information
- Invalid order timestamps
- Outliers in price and freight
- Minor inconsistencies in payment data
III. Impact on Analysis
- Delivery KPIs may be biased due to timestamp issues  
- Location analysis affected by missing geolocation  
- Revenue analysis mostly stable but requires outlier handling  
- Product insights impacted by missing categories  
IV. Recommendations
- Remove or flag invalid timestamp records  
- Handle outliers using statistical methods (IQR, percentile)  
- Clean or impute missing product data  
- Improve ZIP code standardization  
- Validate business logic (freight vs price, installments)  
V. Conclusion
The dataset is **generally clean and suitable for analysis**, with strong integrity in core transactional data.  
However, addressing **missing values, inconsistencies, and outliers** is essential to ensure accurate insights and reliable dashboards.
VI. Tools Used
- SQL Server
- T-SQL (Data validation queries)
VII. Reference
Detailed SQL queries are available in: docs/01_data_quality.sql
