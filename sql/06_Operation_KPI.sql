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
  with cte_a as (
select 
year(order_purchase_timestamp) as year, 
month(order_purchase_timestamp) as month, 
datediff( day, order_estimated_delivery_date, order_delivered_customer_date)  as delay_days
from dbo.olist_orders_clean_dataset 
where order_status = 'delivered'
  )
select 
year, month, 
avg(delay_days) as delay_days_avg from cte_a group by year(order_purchase_timestamp), month(order_purchase_timestamp) 
order by year, month 
```
4. delay time by prev year, month
sql```
with cte_a as (
  select
  year(order_purchase_timestamp) as year, 
  month(order_purchase_timestamp) as month, 
  datediff(day, order_estimated_delivery_date, order_delivered_customer_date) as delay_days
  from dbo.olist_orders_clean_dataset
  where order_status = 'delivered' ), 
cte_b as (
  select year, month, 
  avg(case when delay_days > 0 then delay_days end ) as delay_days_avg from cte_a group by year, month ), 
cte_c as (
  select 
  *, 
  lag(delay_days_avg) over( order by year, month ) as prev_delay_days from cte_b )
select 
year, month, prev_delay_days, 
(delay_days_avg - prev_delay_days ) * 100.0 / prev_delay_days as delay_rate from cte_c 
order by year, month 
```
5. delay time by prev year, month in somes state
sql```
with cte_a as (
  select 
  customer_state as State, 
  year(order_purchase_timestamp) as year, 
  month(order_purchase_timestamp) as month, 
  datediff( day, order_estimated_delivery_date, order_delivered_customer_date) as delay_days 
  from dbo.olist_orders_clean_dataset o
  join dbo.olist_customers_clean_dataset c
  on o.customer_id = c.customer_id 
  where order_status = 'delivered'
  )
, cte_b as (
  select 
  State, 
  year, month, 
  avg(case when delay_days > 0 then delay_days end ) as delay_days_avg
  from cte_a 
  group by State, year, month )
, cte_c as (
  select 
  *, lag(delay_days_avg) over( partition by State order by year, month ) as prev_delay_days
  from cte_b )
select 
State, year, month, 
(delay_days_avg - prev_delay_days) * 100.0 / prev_delay_days as delay_rate from cte_c order by year, month 
``` 
6. Order status distribution by year, monnth 
sql```
with cte_a as (
  select 
    year(order_purchase_timestamp) as year, 
    month(order_purchase_timestamp) as month,
    order_status
  from dbo.olist_orders_clean_dataset
),

cte_b as (
  select 
    year, 
    month, 
    order_status,
    count(*) as total_orders
  from cte_a 
  group by year, month, order_status
),

cte_c as (
  select 
    *,
    sum(total_orders) over(partition by year, month) as total_month
  from cte_b
)

select 
  year, 
  month, 
  order_status,
  total_orders,
  total_orders * 100.0 / total_month as order_pct
from cte_c
order by year, month, order_status;
```
7. The highets delivery state: 'delivered'
sql```
with cte_a as (
  select 
  c.customer_state as state, 
  year(o.order_purchase_timestamp) as year, 
  month(o.order_purchase_timestamp) as month, 
  count(*) as total_orders 
  from dbo.olist_orders_clean_dataset o
  join dbo.olist_customers_clean_dataset c 
  on o.customer_id = c.customer_id 
  where o.order_status = 'delivered'
  group by c.customer_state, year(o.order_purchase_timestamp), month(o.order_purchase_timestamp) 
  ), 
cte_b as (
  select 
  *, 
  rank() over( partition by year, month order by total_orders desc ) as rnk 
  from cte_a )
select * from cte_b where rnk = 1 order by year, month
```







