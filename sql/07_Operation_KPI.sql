Operation KPI 
1. delivery time by year, month
sql```
with cte_base as (
  select 
  year(order_purchase_timestamp) as year, 
  month(order_purchase_timestamp) as month, 
  datediff(day, order_purchase_timestamp, order_delivered_customer_date) as delivery_days
  from dbo.olist_orders_clean_dataset 
  where order_status = 'delivered'
  and order_purchase_timestamp <= order_delivered_customer_date 
  
  )
select year, month, avg(delivery_days) as avg_delivery from cte_base group by year, month order by year, month 
```
2. delivery time by previous year, month 
  sql```
with cte_base as (
  select 
    year(order_purchase_timestamp) as year, 
    month(order_purchase_timestamp) as month,
    datediff(day, order_purchase_timestamp, order_delivered_customer_date) as delivery_days
  from dbo.olist_orders_clean_dataset 
  where order_status = 'delivered'
    and order_purchase_timestamp <= order_delivered_customer_date
),

cte_avg as (
  select 
    year,
    month,
    avg(delivery_days) as avg_delivery
  from cte_base
  group by year, month
)

select 
  year,
  month,
  avg_delivery,
  lag(avg_delivery) over (order by year, month) as prev_month,
  (avg_delivery - lag(avg_delivery) over (order by year, month)) * 100.0 
    / nullif(lag(avg_delivery) over (order by year, month), 0) as growth_pct
from cte_avg
order by year, month
```
3. delay time by year, month 
sql```

