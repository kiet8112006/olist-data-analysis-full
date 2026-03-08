-- ==========================================
-- BUSINESS ANALYSIS
-- OLIST DATASET
-- ==========================================

-- 1 Revenue Overview
-- 2 Revenue by Time
-- 3 Revenue by Category
-- 4 Top Products
-- 5 Top Sellers
-- 6 Revenue by State
-- 7 Monthly Growth

-- =====================================================
-- KPI REVENUE OVERVIEW
-- =====================================================

SELECT

COUNT(DISTINCT order_id) AS total_orders,

SUM(total_revenue) AS total_revenue,

SUM(quantity) AS total_units_sold,

AVG(total_revenue) AS avg_order_value

FROM fact_sales;
-- business insight
--Total Orders
--Total Revenue
--Units Sold
--Average Order Value (AOV)


-- =====================================================
-- REVENUE BY TIME
-- =====================================================

SELECT

d.year,
d.month,
d.month_name,

COUNT(DISTINCT f.order_id) AS total_orders,

SUM(f.total_revenue) AS revenue,

SUM(f.quantity) AS units_sold,

AVG(f.total_revenue) AS avg_order_value

FROM fact_sales f

JOIN dim_date d
ON f.date_key = d.date_key

GROUP BY

d.year,
d.month,
d.month_name

ORDER BY

d.year,
d.month;

-- =====================================================
-- REVENUE BY PRODUCT CATEGORY
-- =====================================================

SELECT

p.product_category,

COUNT(DISTINCT f.order_id) AS total_orders,

SUM(f.total_revenue) AS revenue,

SUM(f.quantity) AS units_sold,

AVG(f.total_revenue) AS avg_order_value

FROM fact_sales f

JOIN dim_products p
ON f.product_key = p.product_key

GROUP BY

p.product_category

ORDER BY

revenue DESC;

--business insight
-- top category
-- top revenue category

-- =====================================================
-- TOP 10 BEST SELLING PRODUCTS
-- =====================================================

SELECT TOP 10

p.product_id,
p.product_category,

SUM(f.quantity) AS units_sold,

SUM(f.total_revenue) AS revenue

FROM fact_sales f

JOIN dim_products p
ON f.product_key = p.product_key

GROUP BY

p.product_id,
p.product_category

ORDER BY

revenue DESC;

-- =====================================================
-- TOP SELLERS BY REVENUE
-- =====================================================

SELECT TOP 10

s.seller_id,

SUM(f.total_revenue) AS revenue,

COUNT(DISTINCT f.order_id) AS total_orders,

SUM(f.quantity) AS units_sold

FROM fact_sales f

JOIN dim_sellers s
ON f.seller_key = s.seller_key

GROUP BY

s.seller_id

ORDER BY

revenue DESC;

-- =====================================================
-- REVENUE BY CUSTOMER STATE
-- =====================================================

SELECT

c.customer_state,

SUM(f.total_revenue) AS revenue,

COUNT(DISTINCT f.order_id) AS total_orders,

SUM(f.quantity) AS units_sold

FROM fact_sales f

JOIN dim_customers c
ON f.customer_key = c.customer_key

GROUP BY

c.customer_state

ORDER BY

revenue DESC;

---- =====================================================
-- MONTHLY REVENUE GROWTH
-- =====================================================

WITH monthly_revenue AS (

SELECT

d.year,
d.month,

SUM(f.total_revenue) AS revenue

FROM fact_sales f

JOIN dim_date d
ON f.date_key = d.date_key

GROUP BY
d.year,
d.month

)

SELECT

year,
month,

revenue,

LAG(revenue) OVER (ORDER BY year, month) AS prev_month_revenue,

(revenue - LAG(revenue) OVER (ORDER BY year, month)) 
AS revenue_growth

FROM monthly_revenue

ORDER BY
year,
month;

--
