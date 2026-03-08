-- =====================================================
-- DELIVERY PERFORMANCE OVERVIEW
-- =====================================================

SELECT

AVG(delivery_days) AS avg_delivery_days,

AVG(delivery_delay) AS avg_delivery_delay,

AVG(processing_days) AS avg_processing_time,

AVG(shipping_days) AS avg_shipping_time

FROM fact_delivery;

-- =====================================================
-- DELIVERY TIME DISTRIBUTION
-- =====================================================

SELECT

delivery_days,

COUNT(*) AS number_of_orders

FROM fact_delivery

GROUP BY delivery_days

ORDER BY delivery_days;

-- =====================================================
-- DELIVERY DELAY RATE
-- =====================================================

SELECT

SUM(CASE WHEN delivery_delay > 0 THEN 1 ELSE 0 END) * 1.0
/ COUNT(*) AS delay_rate

FROM fact_delivery;

-- =====================================================
-- SELLER DELIVERY PERFORMANCE
-- =====================================================

SELECT

s.seller_id,

AVG(f.delivery_days) AS avg_delivery_days,

AVG(f.delivery_delay) AS avg_delay

FROM fact_delivery f

JOIN fact_sales fs
ON f.order_id = fs.order_id

JOIN dim_sellers s
ON fs.seller_key = s.seller_key

GROUP BY
s.seller_id

ORDER BY
avg_delay DESC;

-- =====================================================
-- DELIVERY PERFORMANCE BY REGION
-- =====================================================

SELECT

c.customer_state,

AVG(f.delivery_days) AS avg_delivery_days,

AVG(f.delivery_delay) AS avg_delay

FROM fact_delivery f

JOIN fact_sales fs
ON f.order_id = fs.order_id

JOIN dim_customers c
ON fs.customer_key = c.customer_key

GROUP BY
c.customer_state

ORDER BY
avg_delivery_days DESC;



