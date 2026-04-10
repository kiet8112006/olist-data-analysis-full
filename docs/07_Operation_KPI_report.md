OPERATION KPI ANALYSIS – OLIST DATASET
I. Objective:
This script evaluates operational performance of the e-commerce
system, focusing on delivery efficiency, delays, and order status.

II. KPI Coverage:
1. Delivery Time (Avg)
2. Delivery Time Growth (MoM)
3. Delay Time Analysis
4. Delay Growth (MoM)
5. Delay by State
6. Order Status Distribution
7. Top Performing Delivery States
   
III. Data Source:
- olist_orders_clean_dataset
- olist_customers_clean_dataset
  
IV. Business Logic:
- Delivery Time = delivered_date - purchase_date
- Delay Time = delivered_date - estimated_delivery_date
- Only "delivered" orders are included
- Delay > 0 → late delivery
- Growth calculated Month-over-Month (MoM)

V. Analytical Purpose:
- Measure logistics efficiency
- Identify delivery bottlenecks
- Track delay trends
- Compare operational performance across regions
  
VI. Notes:
- Negative delay = early delivery
- Use NULLIF to avoid division by zero
- Ensure timestamp logic has been cleaned

