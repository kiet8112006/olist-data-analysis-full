-- =====================================================
-- CUSTOMER OVERVIEW
-- =====================================================

SELECT

COUNT(*) AS total_customers,

AVG(total_spent) AS avg_customer_value,

AVG(total_orders) AS avg_orders_per_customer,

AVG(customer_lifetime_days) AS avg_customer_lifetime_days

FROM fact_customer_orders;

-- =====================================================
-- TOP 10 CUSTOMERS BY SPENDING
-- =====================================================

SELECT TOP 10

customer_key,

total_orders,

total_spent

FROM fact_customer_orders

ORDER BY total_spent DESC;

-- =====================================================
-- CUSTOMER PURCHASE FREQUENCY
-- =====================================================

SELECT

total_orders,

COUNT(*) AS number_of_customers

FROM fact_customer_orders

GROUP BY total_orders

ORDER BY total_orders;

-- =====================================================
-- REPEAT CUSTOMER RATE
-- =====================================================

SELECT

SUM(CASE WHEN total_orders > 1 THEN 1 ELSE 0 END) * 1.0
/ COUNT(*) AS repeat_customer_rate

FROM fact_customer_orders;

-- =====================================================
-- CUSTOMER VALUE SEGMENT
-- =====================================================

SELECT

CASE
WHEN total_spent < 100 THEN 'Low Value'
WHEN total_spent < 500 THEN 'Medium Value'
ELSE 'High Value'
END AS customer_segment,

COUNT(*) AS customers

FROM fact_customer_orders

GROUP BY

CASE
WHEN total_spent < 100 THEN 'Low Value'
WHEN total_spent < 500 THEN 'Medium Value'
ELSE 'High Value'
END;


