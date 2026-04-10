CUSTOMER EXPERIENCE KPI – OLIST DATASET
Objective:
This script analyzes customer satisfaction using review data,
and its relationship with delivery performance and pricing.

I. KPI Coverage:
1. Best Rated Product Categories
2. Rating Trend Over Time
3. Rating vs Delivery Delay
4. Rating vs Product Price
   
II. Data Source:
- olist_orders_clean_dataset
- olist_order_reviews_clean_dataset
- olist_order_items_clean_dataset
- olist_products_clean_dataset
- product_category_name_translation
  
III. Business Logic:
- Review score ranges from 1 to 5
- Good reviews defined as score ≥ 4
- Delay = delivered_date - estimated_delivery_date
- Only delivered orders are considered
- Aggregation at category and time level
  
IV. Analytical Purpose:
- Identify high-performing product categories
- Understand factors affecting customer satisfaction
- Measure impact of delivery delays on reviews
- Analyze price vs perceived quality
  
V. Notes:
- Missing reviews are excluded
- Delay > 0 indicates late delivery
- Use cleaned dataset for consistency

