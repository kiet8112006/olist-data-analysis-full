Customer KPI
1. Customers by Year, Month 
sql```
select 
year(o.order_purchase_timestamp) as year, 
month(o.order_purchase_timestamp) as year,
count(distinct c.customer_unique_id) as total_customers
from dbo.olist_orders_clean_dataset o
join dbo.olist_customers_clean_dataset c
on o.customer_id=c.customer_id 
group by year(o.order_purchase_timestamp),
month(o.order_purchase_timestamp)
order by year, month;
```
2. Customer Growth by Year, Month
sql```
with cte_customer as (
  select 
  year(o.order_purchase_timestamp) as year, 
  month(o.order_purchase_timestamp) as month,
  count(distinct c.customer_unique_id) as total_customers
  from dbo.olist_orders_clean_dataset o
  join dbo.olist_customers_clean_dataset c 
  on o.customer_id=c.customer_id
  group by year(o.order_purchase_timestamp), 
  month(o.order_purchase_timestamp)
  )
select *, 
lag(total_customers) over(order by year, month ) as customers_prev, 
(total_customers-lag(total_customers) over(order by year, month) )*100.0/ lag(total_customers) over(order by year, month) as customers_growth
from cte_customer order by year, month 
```
3. New customers and Returning customers 
sql```
with first_order_date as (
  select 
  c.customer_unique_id,
  min(o.order_purchase_timestamp) as first_date
  from dbo.olist_orders_clean_dataset o
  join dbo.olist_customers_clean_dataset c 
  on o.customer_id=c.customer_id 
  group by c.customer_unique_id )
select 
year(o.order_purchase_timestamp) as year, 
month(o.order_purchase_timestamp) as month,
count(distinct 
  case when 
  year(o.order_purchase_timestamp)=year(f.first_date) and month(o.order_purchase_timestamp)=month(f.first_date) then f.customer_unique_id end ) as new_customers,
count(distinct 
  case when 
  o.order_purchase_timnestamp > f.first_date then c.customer_unique_id  end) as Returning_customers
from dbo.olist_orders_clean_dataset o join dbo.olist_customers_clean_dataset c 
on o.customer_id=c.customer_id 
join first_order_date f 
on f.customer_unique_id =c.customer_unique_id 
group by year(o.order_purchase_timestamp), 
  month(o.order_purchase_timestamp)
order by year, month 
```
4. Total Customers Growth 
sql```
with cte_customers_monthly as (
  select 
  year(order_purchase_timestamp) as year, 
  month(order_purchase_timestamp) as month, 
  count(distinct customer_unique_id ) as total_customers 
  from dbo.olist_orders_clean_dataset o
  join dbo.olist_customers_clean_dataset c 
  on o.customer_id=c.customer_id 
  group by year(o.order_purchase_timestamp), month(o.order_purchase_timestamp)),
   cte_a as (
select *, 
lag(total_customers) over(order by year, month ) as prev_customers
from cte_customers_monthly )
select year, month, 
total_customers, 
prev_customers, 
(total_customers-prev_customers)*100.0 / prev_customers as customers_growth 
from cte_a 
order by year, month 
```
5. New Customers Growth 
sql```
  with cte_a as(
  select 
  c.customer_unique_id,
  min(o.order_purchase_timestamp) as first_date
  from dbo.olist_orders_clean_dataset o 
  join dbo.olist_customers_clean_dataset c 
  on o.customer_id = c.customer_id 
  group by c.customer_unique_id 
  ),
 cte_b as (
  select 
  year(order_purchase_timestamp) as year, 
  month(order_purchase_timestamp) as month, 
  count(distinct
  case when year(o.order_purchase_timestamp)= year(f.first_date) and month(o.order_purchase_timestamp)=month(f.first_date) then c.customer_unique_id end ) as new_customers
  from dbo.olist_orders_clean_dataset o 
  join dbo.olist_customers_clean_dataset c 
  on o.customer_id=c.customer_id 
  join cte_a f 
  on f.customer_unique_id = c.customer_unique_id
  group by year(o.order_purchase_timestamp), month(o.order_purchase_timestamp)), 
cte_c as (
  select *, 
  lag(new_customers) over(order by year, month) as prev_new_customers
  from cte_b )
select year, month, 
new_customers,
(new_customers - prev_new_customers) * 100.0 / prev_new_customers as new_customers_growth
from cte_c 
order by year, month 
```
6. Returing Customers Growth 
sql```
with cte_a as (
  select 
  c.customer_unique_id, 
  min(o.order_purchase_timestamp) as first_date
  from dbo.olist_orders_clean_dataset o 
  join dbo.olist_customers_clean_dataset c 
  on o.customer_id = c.customer_id 
  group by c.customer_unique_id 
  ),
cte_b as (
  select 
  year(o.order_purchase_timestamp) as year, 
  month(o.order_purchase_timestamp) as month, 
  count(distinct case when datediff(day, first_date, order_purchase_timestamp) > 0  then customer_unique_id end) as returning_customers 
  from dbo.olist_orders_clean_dataset o 
  join dbo.olist_customers_clean_dataset c 
  on o.customer_id=c.customer_id 
  join cte_a f 
  on f.customer_unique_id =c.customer_unique_id 
  group by year(o.order_purchase_timestamp),
  month(o.order_purchase_timestamp)
  )
, cte_c as (
  select *, 
  lag(returning_customers) over( order by year, month) as prev_returning_customers
  from cte_b )
select 
year, month, returning_customers, 
(returning_customers - prev_returning_customers ) * 100.0 / prev_returning_customers as returning_customers_growth 
from cte_c
order by year, month 
```
7. Customer Lifetime Value 
sql```
select 
c.customer_unique_id, 
count(distinct o.order_id) as total_orders, 
sum(p.payment_value) as total_revenue
from dbo.olist_orders_clean_dataset o 
join dbo.olist_customers_clean_dataset c
on o.customer_id = c.customer_id 
join dbo.olist_payments_clean_dataset p 
on o.order_id = p.order_id 
group by c.customer_unique_id 
order by total_revenue 
```
sql```
with customer_orders as (
  select 
  c.customer_unique_id, 
  o.order_id, 
  sum(oi.price + oi.freight_value) as total_revenue, 
  o.order_purchase_timestamp
  from dbo.olist_orders_clean_dataset o 
  join dbo.olist_customers_clean_dataset c 
  on o.customer_id = c.customer_id 
  join dbo.olist_order_items_clean_dataset oi
  join o.order_id = oi.order_id 
  group by c.customer_unique_id, 
  o.order_id, o.order_purchase_timestamp )
  , customer_stats as (
  select 
  customer-unique_id, 
  count(distinct order_id) as total_orders, 
  sum(total_revenue) as revenue, 
  avg(total_revenue) as AOV, 
  datediff(day, min(order_purchase_timestamp), max(order_purchase_timestamp)) as lifespan
  from customer_orders
  group by customer_unique_id )
  select 
  customer_unique_id, 
  AOV * total_orders *(lifespan / 30) as CLV
  from customer_stats
  order by CLV desc
  ```
8. RFM
with rfm_base as (
  select 
  c.customer_unique_id, 
  max(o.order_purchase_timestamp) as last_purchase_date, 
  count(distinct order_id) as frequency, 
  sum(p.payment_value) as monetary
  from dbo.olist_orders_clean_dataset o 
  join dbo.olist_customers_clean_dataset c
  on o.customer_id=c.customer_id 
  join dbo.olist_order_payments_clean_dataset p
  on o.order_id = p.order_id 
  group by c.customer_unique_id ),
rfm as (
  select
  *, 
  datediff(day, last_purchase_date, (select max(order_purchase_timestamp) from dbo.olist_orders_clean_dataset )) as reccency from rfm_base )
, rfm_score as (
  select *, 
  ntile(5) over ( order by recency asc ) as r_score, 
  ntile(5) over( order by frequency desc ) as f_score, 
  ntile(5) over( order by monetary desc ) as m_score
  from rfm )
  select *, 
  case when r_score >=4 and f_score >= 4 and f_score >=4 then 'Champions'
  when  r_score >= 3 and f_score >= 3 then 'loyal customers'
  when r_score = 5 then 'New customers'
  when r_score <=2 and f_score >= 3 then 'At risk'
  else 'Others'
  end as segment from rfm_score
  ```





