CREATE TABLE fact_orders (
    fact_id INT IDENTITY(1,1) PRIMARY KEY,

    order_id VARCHAR(50),
    customer_key INT,

    date_key INT,

    purchase_date DATETIME,
    approved_date DATETIME,
    carrier_date DATETIME,
    delivered_date DATETIME,

    total_price DECIMAL(18,2),
    total_freight DECIMAL(18,2),

    delivery_duration_days INT,
    delivery_delay_days INT
);
INSERT INTO fact_orders
SELECT 
    o.order_id,
    dc.customer_key,

    YEAR(o.order_purchase_timestamp)*10000 
    + MONTH(o.order_purchase_timestamp)*100 
    + DAY(o.order_purchase_timestamp),

    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,

    SUM(oi.price),
    SUM(oi.freight_value),

    DATEDIFF(day, o.order_purchase_timestamp, o.order_delivered_customer_date),

    CASE 
        WHEN o.order_delivered_customer_date IS NOT NULL 
        THEN DATEDIFF(day, o.order_estimated_delivery_date, o.order_delivered_customer_date)
        ELSE NULL
    END

FROM Orders_clean o
JOIN Order_items_clean oi 
    ON o.order_id = oi.order_id
JOIN dim_customer dc 
    ON o.customer_id = dc.customer_id

WHERE o.order_status = 'delivered'

GROUP BY 
    o.order_id,
    dc.customer_key,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date;
---------------------------------------------------------------------------------------
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE,

    year INT,
    quarter INT,
    month INT,
    month_name VARCHAR(20),
    week INT,
    day INT,
    day_name VARCHAR(20),
    is_weekend BIT
);
WITH dates AS (
    SELECT CAST('2016-01-01' AS DATE) AS d
    UNION ALL
    SELECT DATEADD(DAY, 1, d)
    FROM dates
    WHERE d < '2020-12-31'
)
INSERT INTO dim_date
SELECT
    YEAR(d)*10000 + MONTH(d)*100 + DAY(d),
    d,
    YEAR(d),
    DATEPART(QUARTER, d),
    MONTH(d),
    DATENAME(MONTH, d),
    DATEPART(WEEK, d),
    DAY(d),
    DATENAME(WEEKDAY, d),
    CASE WHEN DATENAME(WEEKDAY, d) IN ('Saturday','Sunday') THEN 1 ELSE 0 END
FROM dates
OPTION (MAXRECURSION 0);
--------------------------------------------------------------------------------------------------------
CREATE TABLE fact_order_items (
    fact_item_id INT IDENTITY(1,1) PRIMARY KEY,

    order_id VARCHAR(50),
    product_key INT,
    seller_key INT,
    date_key INT,

    price DECIMAL(18,2),
    freight_value DECIMAL(18,2)
);
INSERT INTO fact_order_items
SELECT 
    oi.order_id,
    dp.product_key,
    ds.seller_key,

    YEAR(o.order_purchase_timestamp)*10000 
    + MONTH(o.order_purchase_timestamp)*100 
    + DAY(o.order_purchase_timestamp),

    oi.price,
    oi.freight_value

FROM Order_items_clean oi
JOIN Orders_clean o 
    ON oi.order_id = o.order_id
JOIN dim_product dp 
    ON oi.product_id = dp.product_id
JOIN dim_seller ds 
    ON oi.seller_id = ds.seller_id;
-------------------------------------------------------------------------------

CREATE TABLE fact_payment (
    payment_id INT IDENTITY(1,1) PRIMARY KEY,

    order_id VARCHAR(50),
    date_key INT,

    payment_type VARCHAR(50),
    payment_value DECIMAL(18,2)
);
INSERT INTO fact_payment
SELECT 
    p.order_id,

    YEAR(o.order_purchase_timestamp)*10000 
    + MONTH(o.order_purchase_timestamp)*100 
    + DAY(o.order_purchase_timestamp),

    p.payment_type,
    p.payment_value

FROM Order_payments_clean p
JOIN Orders_clean o 
    ON p.order_id = o.order_id;
----------------------------------------------------------------------

CREATE TABLE fact_review (
    review_id INT IDENTITY(1,1) PRIMARY KEY,

    order_id VARCHAR(50),
    date_key INT,

    review_score INT
);
INSERT INTO fact_review
SELECT 
    r.order_id,

    YEAR(o.order_purchase_timestamp)*10000 
    + MONTH(o.order_purchase_timestamp)*100 
    + DAY(o.order_purchase_timestamp),

    r.review_score

FROM Order_reviews_clean r
JOIN Orders_clean o 
    ON r.order_id = o.order_id;
-------------------------------------------------------------------------------------------
CREATE TABLE dim_customer (
    customer_key INT IDENTITY(1,1) PRIMARY KEY,
    customer_id VARCHAR(50),
    customer_city VARCHAR(100),
    customer_state VARCHAR(50)
);

INSERT INTO dim_customer
SELECT DISTINCT
    customer_id,
    customer_city,
    customer_state
FROM Customers_clean;
-------------------------------------------------------------------------------
CREATE TABLE dim_product (
    product_key INT IDENTITY(1,1) PRIMARY KEY,
    product_id VARCHAR(50),
    product_category_name VARCHAR(100)
);

INSERT INTO dim_product
SELECT DISTINCT
    product_id,
    product_category_name
FROM Products_clean;
----------------------------------------------------------------------------------
CREATE TABLE dim_seller (
    seller_key INT IDENTITY(1,1) PRIMARY KEY,
    seller_id VARCHAR(50),
    seller_city VARCHAR(100)
);

INSERT INTO dim_seller
SELECT DISTINCT
    seller_id,
    seller_city
FROM Sellers_clean;
-----------------------------------------------------------------------------------
---Indexing 
-- FACT_ORDERS
CREATE CLUSTERED INDEX idx_fact_orders_date
ON fact_orders(date_key);

CREATE INDEX idx_fact_orders_customer
ON fact_orders(customer_key);

CREATE INDEX idx_fact_orders_kpi
ON fact_orders(date_key)
INCLUDE (total_price, total_freight);

-- DIM
CREATE UNIQUE INDEX idx_dim_date_key ON dim_date(date_key);
CREATE INDEX idx_dim_customer_id ON dim_customer(customer_id);
CREATE INDEX idx_dim_product_id ON dim_product(product_id);
CREATE INDEX idx_dim_seller_id ON dim_seller(seller_id);
