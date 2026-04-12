KPI Revenue
1. Revenue
sql```
select sum(price+ freight_value) as total_revenue from dbo.olist_order_items_clean_dataset
```
2. Delivery Revenue
  Tính doanh thu từng order sau đó mới sum lại.
sql```
SELECT SUM(order_total) AS total_revenue
FROM (
    SELECT 
        oi.order_id,
        SUM(oi.price + oi.freight_value) AS order_total
    FROM dbo.olist_order_items_clean_dataset oi
    JOIN dbo.olist_orders_clean_dataset o
    ON oi.order_id = o.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY oi.order_id
) t
```
3. Revenue by category
sql```
WITH item_level AS (
    SELECT 
        oi.order_id,
        pt.product_category_name_english,
        oi.price,
        oi.freight_value,
        SUM(oi.price) OVER (PARTITION BY oi.order_id) AS order_total_price
    FROM dbo.olist_order_items_clean_dataset oi
    JOIN dbo.olist_orders_clean_dataset o
        ON oi.order_id = o.order_id
    JOIN dbo.olist_products_clean_dataset p
        ON oi.product_id = p.product_id 
    JOIN dbo.Product_category_name_translation pt
        ON p.product_category_name = pt.product_category_name 
    WHERE o.order_status = 'delivered'
)

SELECT 
    product_category_name_english,
    SUM(price + freight_value * price / order_total_price) AS total_revenue
FROM item_level
GROUP BY product_category_name_english
ORDER BY total_revenue DESC
  ```
4. Revenue by year and month 
sql ```
WITH order_level AS (
    SELECT 
        oi.order_id,
        SUM(oi.price) AS total_price,
        SUM(oi.freight_value) AS total_freight
    FROM dbo.olist_order_items_clean_dataset oi
    GROUP BY oi.order_id
)

SELECT 
    YEAR(o.order_purchase_timestamp) AS year, 
    MONTH(o.order_purchase_timestamp) AS month,
    SUM(total_price + total_freight) AS total_revenue
FROM order_level ol
JOIN dbo.olist_orders_clean_dataset o
    ON ol.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY 
    YEAR(o.order_purchase_timestamp),
    MONTH(o.order_purchase_timestamp)
ORDER BY year, month
```
5. Top revenue month by year
sql```
WITH order_level AS (
    SELECT 
        oi.order_id,
        SUM(oi.price) AS total_price,
        SUM(oi.freight_value) AS total_freight
    FROM dbo.olist_order_items_clean_dataset oi
    GROUP BY oi.order_id
),

monthly_revenue AS (
    SELECT 
        YEAR(o.order_purchase_timestamp) AS year, 
        MONTH(o.order_purchase_timestamp) AS month, 
        SUM(total_price + total_freight) AS total_revenue
    FROM order_level ol
    JOIN dbo.olist_orders_clean_dataset o 
        ON ol.order_id = o.order_id 
    WHERE o.order_status = 'delivered'
    GROUP BY 
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
),

ranked_revenue AS (
    SELECT *, 
        ROW_NUMBER() OVER (
            PARTITION BY year 
            ORDER BY total_revenue DESC
        ) AS rank_number
    FROM monthly_revenue
)

SELECT *
FROM ranked_revenue 
WHERE rank_number = 1;
```
6. Revenue growth over time
sql ```
  WITH order_level AS (
    SELECT 
        oi.order_id,
        SUM(oi.price) AS total_price,
        SUM(oi.freight_value) AS total_freight
    FROM dbo.olist_order_items_clean_dataset oi
    GROUP BY oi.order_id
),

monthly_revenue AS (
    SELECT 
        YEAR(o.order_purchase_timestamp) AS year, 
        MONTH(o.order_purchase_timestamp) AS month, 
        SUM(total_price + total_freight) AS total_revenue
    FROM order_level ol
    JOIN dbo.olist_orders_clean_dataset o
        ON ol.order_id = o.order_id 
    WHERE o.order_status = 'delivered'
    GROUP BY 
        YEAR(o.order_purchase_timestamp),
        MONTH(o.order_purchase_timestamp)
),

monthly_growth AS (
    SELECT 
        *,
        LAG(total_revenue) OVER (ORDER BY year, month) AS prev_month
    FROM monthly_revenue
)

SELECT *,
    CASE 
        WHEN prev_month IS NULL OR prev_month = 0 THEN NULL
        ELSE (total_revenue - prev_month) * 100.0 / prev_month
    END AS growth_monthly
FROM monthly_growth;
```
7.  Average Order Value
sql```
WITH order_level AS (
    SELECT 
        oi.order_id,
        SUM(oi.price) AS total_price,
        SUM(oi.freight_value) AS total_freight
    FROM dbo.olist_order_items_clean_dataset oi
    JOIN dbo.olist_orders_clean_dataset o
        ON oi.order_id = o.order_id 
    WHERE o.order_status = 'delivered'
    GROUP BY oi.order_id
)

SELECT 
    AVG(total_price + total_freight) AS AOV
FROM order_level;
```
8. Revenue by State
sql ```
WITH order_level AS (
    SELECT 
        oi.order_id,
        SUM(oi.price) AS total_price,
        SUM(oi.freight_value) AS total_freight
    FROM dbo.olist_order_items_clean_dataset oi
    GROUP BY oi.order_id
)

SELECT 
    c.customer_state AS state,
    SUM(total_price + total_freight) AS total_revenue
FROM order_level ol
JOIN dbo.olist_orders_clean_dataset o
    ON ol.order_id = o.order_id
JOIN dbo.olist_customers_clean_dataset c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;
```
9. Revenue by each customer
sql ```
WITH order_level AS (
    SELECT 
        oi.order_id,
        SUM(oi.price) AS total_price,
        SUM(oi.freight_value) AS total_freight
    FROM dbo.olist_order_items_clean_dataset oi
    GROUP BY oi.order_id
),

revenue_per_customer AS (
    SELECT 
        c.customer_unique_id, 
        SUM(total_price + total_freight) AS total_revenue
    FROM order_level ol
    JOIN dbo.olist_orders_clean_dataset o
        ON ol.order_id = o.order_id
    JOIN dbo.olist_customers_clean_dataset c
        ON o.customer_id = c.customer_id 
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
)

SELECT *
FROM revenue_per_customer 
ORDER BY total_revenue DESC;
```
10. Revenue by seller 
sql ```
WITH revenue_per_seller AS (
    SELECT 
        s.seller_id, 
        SUM(oi.price) AS total_revenue
    FROM dbo.olist_order_items_clean_dataset oi
    JOIN dbo.olist_orders_clean_dataset o
        ON oi.order_id = o.order_id
    JOIN dbo.olist_sellers_clean_dataset s
        ON oi.seller_id = s.seller_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_id
)

SELECT *
FROM revenue_per_seller 
ORDER BY total_revenue DESC;
```
11. Shipping cost to Revenue ratio
sql ```
  WITH order_level AS (
    SELECT 
        oi.order_id,
        SUM(oi.price) AS total_price,
        SUM(oi.freight_value) AS total_freight
    FROM dbo.olist_order_items_clean_dataset oi
    GROUP BY oi.order_id
),

cte_ship_revenue AS (
    SELECT 
        SUM(total_freight) AS ship, 
        SUM(total_price + total_freight) AS total_revenue
    FROM order_level ol
    JOIN dbo.olist_orders_clean_dataset o
        ON ol.order_id = o.order_id 
    WHERE o.order_status = 'delivered'
)

SELECT 
    ship * 100.0 / total_revenue AS shipping_rate
FROM cte_ship_revenue;
```



  


