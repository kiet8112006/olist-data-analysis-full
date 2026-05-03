Thiết kế fact để giải quyết các yêu cầu bài toán báo cáo.
A. Fact sale.
sql```
CREATE TABLE fact_sale (
    fact_sale_id INT IDENTITY(1,1) PRIMARY KEY,

    order_id NVARCHAR(50),
    seller_key INT,
    product_key INT,
    customer_key INT,
    date_key INT,

    price DECIMAL(18,2),
    freight_value DECIMAL(18,2),

    delivery_days INT NULL,
    delay_days INT NULL,

    is_delivered BIT,
    is_canceled BIT,
    is_late_delivery BIT,

    purchase_number INT,
    is_new_customer BIT,
    is_repeat_customer BIT
);
WITH customer_orders AS (
    SELECT 
        o.order_id,
        c.customer_unique_id,
        o.customer_id,
        o.order_purchase_timestamp,

        ROW_NUMBER() OVER (
            PARTITION BY c.customer_unique_id
            ORDER BY o.order_purchase_timestamp, o.order_id
        ) AS purchase_number

    FROM dbo.orders_clean o
    JOIN dbo.customers_clean c 
        ON o.customer_id = c.customer_id
)
, fact_base AS (
    SELECT 
        oi.order_id,
        oi.product_id,
        oi.seller_id,
        o.customer_id,
        o.order_purchase_timestamp,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        o.order_status,
        oi.price,
        oi.freight_value
    FROM dbo.order_items_clean oi
    JOIN dbo.orders_clean o 
        ON oi.order_id = o.order_id
)
INSERT INTO fact_sale (
    order_id,
    seller_key,
    product_key,
    customer_key,
    date_key,
    price,
    freight_value,
    delivery_days,
    delay_days,
    is_delivered,
    is_canceled,
    is_late_delivery,
    purchase_number,
    is_new_customer,
    is_repeat_customer
)

SELECT 
    fb.order_id,
    ds.seller_key,
    dp.product_key,
    dc.customer_key,

    -- date key
    YEAR(fb.order_purchase_timestamp) * 10000
    + MONTH(fb.order_purchase_timestamp) * 100
    + DAY(fb.order_purchase_timestamp),

    fb.price,
    fb.freight_value,

    -- delivery days
    CASE 
        WHEN fb.order_delivered_customer_date IS NOT NULL 
        THEN DATEDIFF(DAY, fb.order_purchase_timestamp, fb.order_delivered_customer_date)
    END,

    -- delay days
    CASE 
        WHEN fb.order_delivered_customer_date IS NOT NULL 
         AND fb.order_estimated_delivery_date IS NOT NULL 
        THEN DATEDIFF(DAY, fb.order_estimated_delivery_date, fb.order_delivered_customer_date)
    END,

    -- flags
    CASE WHEN fb.order_status = 'delivered' THEN 1 ELSE 0 END,
    CASE WHEN fb.order_status = 'canceled' THEN 1 ELSE 0 END,

    CASE 
        WHEN fb.order_delivered_customer_date IS NOT NULL 
         AND fb.order_estimated_delivery_date IS NOT NULL
         AND fb.order_delivered_customer_date > fb.order_estimated_delivery_date
        THEN 1 ELSE 0 
    END,

    co.purchase_number,

    CASE WHEN co.purchase_number = 1 THEN 1 ELSE 0 END,
    CASE WHEN co.purchase_number >= 2 THEN 1 ELSE 0 END

FROM fact_base fb

JOIN customer_orders co 
    ON fb.order_id = co.order_id

JOIN dim_customer dc 
    ON fb.customer_id = dc.customer_id

JOIN dim_product dp 
    ON fb.product_id = dp.product_id

JOIN dim_seller ds 
    ON fb.seller_id = ds.seller_id;
```

B. fact payment
  
sql```
create table fact_payment (
fact_payment_id int identity(1,1) primary key, 
order_id nvarchar(50), 
date_key int,
payment_value float,
payment_type nvarchar(50), 
payment_sequential int, 
payment_installments int)
insert into fact_payment
select 
o.order_id, 
year(o.order_purchase_timestamp) * 10000 + month(o.order_purchase_timestamp) *100 + day(o.order_purchase_timestamp),
payment_value,
p.payment_type, 
p.payment_sequential, 
p.payment_installments  from dbo.order_payments_clean p join dbo.orders_clean o
on o.order_id = p.order_id 
```

C. fact review

sql```
create table fact_review (
fact_review_id int identity(1,1) primary key, 
order_id nvarchar(50), 
date_key int, 
review_score int, 
response_time_days int, 
is_positive bit, 
is_negative bit )
insert into fact_review
select 
o.order_id, 
year(o.order_purchase_timestamp) *10000 + month(o.order_purchase_timestamp)* 100 + day(o.order_purchase_timestamp),
review_score, 
case when review_answer_timestamp is not null then 
datediff(day, review_creation_date, review_answer_timestamp) end , 
case when review_score >= 4  then 1 else 0 end, 
case when review_score <=3 then 1 else 0 end
from dbo.order_reviews_clean r join dbo.orders_clean o
on r.order_id = o.order_id 
```

D. fact review detail

sql```
create table fact_review_detail (
    fact_review_detail_id int identity(1,1) primary key,

    order_id nvarchar(50),
    product_key int,
    customer_key int,
    date_key int,

    review_score int,

    -- optional metrics
    is_positive bit,
    is_negative bit
);

insert into fact_review_detail
(
    order_id,
    product_key,
    customer_key,
    date_key,
    review_score,
    is_positive,
    is_negative
)
select 
    r.order_id,
    dp.product_key,
    dc.customer_key,

    year(o.order_purchase_timestamp) *10000 
    + month(o.order_purchase_timestamp) *100 
    + day(o.order_purchase_timestamp),

    r.review_score,

    case when r.review_score >= 4 then 1 else 0 end,
    case when r.review_score <= 3 then 1 else 0 end

from dbo.order_reviews_clean r

join dbo.order_items_clean oi
    on r.order_id = oi.order_id

join dbo.orders_clean o
    on r.order_id = o.order_id

join dim_product dp
    on oi.product_id = dp.product_id

join dim_customer dc
    on o.customer_id = dc.customer_id;
```


