REVENUE KPI ANALYSIS – OLIST DATASET
Objective:
This script calculates key revenue metrics from the cleaned
Olist dataset to support business analysis and dashboarding.

I. KPI Coverage:
1. Total Revenue
2. Delivered Revenue
3. Revenue by Product Category
4. Revenue by Year & Month
5. Top Revenue Month per Year
6. Revenue Growth (MoM)
7. Average Order Value (AOV)
8. Revenue by State
9. Revenue per Customer
10. Revenue per Seller
11. Shipping Cost Ratio
    
II. Data Source:
All queries are based on cleaned datasets:
- olist_orders_clean_dataset
- olist_order_items_clean_dataset
- olist_products_clean_dataset
- olist_customers_clean_dataset
- product_category_name_translation
  
III. Business Logic:
- Revenue = price + freight_value
- Only "delivered" orders are considered for most KPIs
- Time-based analysis uses order_purchase_timestamp
- Customer-level analysis uses customer_unique_id
  
IV. Analytical Purpose:
- Understand revenue distribution across time, category, and region
- Identify top-performing products and periods
- Measure growth trends and customer value
- Support dashboard visualization in Power BI
  
V. Notes:
- Revenue includes shipping cost (freight_value)
- Outliers may affect average-based metrics (e.g., AOV)
- Ensure cleaned datasets are up-to-date before running

