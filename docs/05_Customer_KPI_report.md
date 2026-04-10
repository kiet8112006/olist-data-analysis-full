CUSTOMER KPI ANALYSIS – OLIST DATASET
Objective:
This script analyzes customer behavior and growth using the 
cleaned Olist dataset to support business insights and segmentation.
I. KPI Coverage:

1. Customers by Year & Month
2. Customer Growth (MoM)
3. New vs Returning Customers
4. Total Customer Growth
5. New Customer Growth
6. Returning Customer Growth
7. Customer Lifetime Value (CLV)
8. RFM Segmentation
II. Data Source:

- olist_orders_clean_dataset
- olist_customers_clean_dataset
- olist_order_items_clean_dataset
- olist_order_payments_clean_dataset
III. Business Logic:

- Customer identity based on `customer_unique_id`
- Growth calculated using Month-over-Month (MoM)
- New customer = first purchase in that month
- Returning customer = has prior purchase history
- CLV approximated using AOV, frequency, and lifespan
- RFM segmentation based on recency, frequency, monetary
IV. Analytical Purpose:

- Understand customer acquisition and retention trends
- Identify high-value customers
- Measure growth dynamics over time
- Enable customer segmentation for marketing strategy
V. Notes:

- Ensure cleaned datasets are used
- Watch out for division by zero in growth calculations
- CLV here is simplified (not predictive model)
