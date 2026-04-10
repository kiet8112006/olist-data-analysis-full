PRODUCT KPI ANALYSIS – OLIST DATASET
Objective:
This script analyzes product performance and revenue contribution
across categories to support business decision-making.

KPI Coverage:
1. Revenue by Category
2. Top Category (by revenue)
3. Top Categories Contribution (% revenue)
4. Top Category by Month
5. Category Revenue Growth (MoM)
   
II. Data Source:
- olist_orders_clean_dataset
- olist_order_items_clean_dataset
- olist_products_clean_dataset
- product_category_name_translation
  
III. Business Logic:
- Revenue = price (optionally include freight_value)
- Only "delivered" orders are considered
- Category based on English translation table
- Growth calculated using Month-over-Month (MoM)
  
IV. Analytical Purpose:
- Identify top-performing product categories
- Understand revenue concentration (Pareto)
- Track category trends over time
- Support product strategy & inventory decisions

V. Notes:
- Some products may have 'unknown' category
- Outliers may affect top category ranking
- Ensure cleaned dataset is used

