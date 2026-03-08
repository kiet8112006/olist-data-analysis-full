-- =====================================================
-- PRODUCT PERFORMANCE OVERVIEW
-- =====================================================

SELECT

COUNT(DISTINCT product_key) AS total_products,

SUM(units_sold) AS total_units_sold,

SUM(total_revenue) AS total_revenue,

AVG(avg_product_price) AS avg_product_price

FROM agg_product_sales;

-- =====================================================
-- REVENUE BY PRODUCT CATEGORY
-- =====================================================

SELECT

p.product_category,

SUM(a.units_sold) AS units_sold,

SUM(a.total_revenue) AS revenue,

AVG(a.avg_product_price) AS avg_price

FROM agg_product_sales a

JOIN dim_products p
ON a.product_key = p.product_key

GROUP BY
p.product_category

ORDER BY
revenue DESC;

-- =====================================================
-- TOP 10 BEST SELLING PRODUCTS
-- =====================================================

SELECT TOP 10

p.product_id,

p.product_category,

SUM(a.units_sold) AS units_sold,

SUM(a.total_revenue) AS revenue

FROM agg_product_sales a

JOIN dim_products p
ON a.product_key = p.product_key

GROUP BY

p.product_id,
p.product_category

ORDER BY

revenue DESC;

-- =====================================================
-- AVERAGE PRODUCT PRICE BY CATEGORY
-- =====================================================

SELECT

p.product_category,

AVG(a.avg_product_price) AS avg_price

FROM agg_product_sales a

JOIN dim_products p
ON a.product_key = p.product_key

GROUP BY
p.product_category

ORDER BY
avg_price DESC;

-- =====================================================
-- CATEGORY REVENUE SHARE
-- =====================================================

SELECT

p.product_category,

SUM(a.total_revenue) AS revenue,

SUM(a.total_revenue) * 100.0 /
SUM(SUM(a.total_revenue)) OVER() AS revenue_share_percent

FROM agg_product_sales a

JOIN dim_products p
ON a.product_key = p.product_key

GROUP BY
p.product_category

ORDER BY
revenue DESC;


