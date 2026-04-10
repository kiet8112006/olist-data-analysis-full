Product KPI 
1. Revenue by category 
sql```
select pt.product_category_name_english,
sum( oi.price ) as total_revenue
from dbo.olist_products_clean_dataset p 
join olist_order_items_clean_dataset oi
on p.product_id =oi.product_id 
join Product_category_name_translation pt
on p.product_category_name = pt.product_category_name 
join dbo.olist_orders_clean_dataset o
on oi.order_id = o.order_id
where o.order_status = 'delivered'
group by pt.product_category_name_english 
order by total_revenue desc 
```
2. Top category 
sql```
with cte_category_revenue as (
  select 
    pt.product_category_name_english, 
    sum(oi.price + oi.freight_value) as total_revenue
  from dbo.olist_products_clean_dataset p
  join dbo.olist_order_items_clean_dataset oi 
    on p.product_id = oi.product_id 
  join dbo.olist_orders_clean_dataset o
    on o.order_id = oi.order_id 
  join dbo.product_category_name_translation pt
    on p.product_category_name = pt.product_category_name
  where o.order_status = 'delivered'
  group by pt.product_category_name_english
)
select top 1 *
from cte_category_revenue
order by total_revenue desc;
```
3. Top category by % total revenue 
sql```
with cte_a as (
  select 
  pt.product_category_name_english, 
  sum(oi.price) as total_revenue
  from dbo.olist_products_clean_dataset p
  join dbo.olist_order_items_clean_dataset oi 
  on p.product_id = oi.product_id 
  join dbo.olist_orders_clean_dataset o
  on o.order_id = oi.order_id 
  join Product_category_name_translation pt
  on p.product_category_name = pt.product_category_name
  where o.order_status = 'delivered'
  group by pt.product_category_name_english ), 
cte_b as (
  select *, 
  total_revenue * 100.0 / sum(total_revenue) over() as revenue_rate,
  sum(total_revenue) over( order by total_revenue desc) * 100.0 / sum(total_revenue) over() as cumulative_pct 
  from cte_a)
select top 5 * from cte_b order by total_revenue desc 
```
4. Top category by year, month 
sql```
with revenue_monthly as (
  select  
  year(o.order_purchase_timestamp) as year, 
  month(o.order_purchase_timestamp) as month , 
  pt.product_category_name_english,
  sum(oi.price ) as total_revenue, 
  rank() over( partition by year(o.order_purchase_timestamp), month(o.order_purchase_timestamp) order by sum(oi.price) desc ) as top_rank 
  from dbo.olist_orders_clean_dataset o 
  join dbo.olist_order_items_clean_dataset oi 
  on o.order_id = oi.order_id 
  join dbo.olist_products_clean_dataset p
  on oi.product_id = p.product_id 
  join Product_category_name_translation pt
  on p.product_category_name = pt.product_category_name 
  where o.order_status = 'delivered'
  group by year(o.order_purchase_timestamp), 
  month(o.order_purchase_timestamp), 
  pt.product_category_name_english 
  )
select * from revenue_monthly  where top_rank =1;
```
5. Top category growth by year, month 
sql```
with growth_revenue_monthly as (
  select 
  year(o.order_purchase_timestamp) as year, 
  month(o.order_purchase_timestamp) as month, 
  pt.product_category_name_english,
  sum(oi.price) as total_revenue, 
  lag(sum(oi.price)) over (partition by pt.product_category_name_english order by year(o.order_purchase_timestamp), month(o.order_purchase_timestamp) ) as prev_revenue
  from dbo.olist_orders_clean_dataset o 
  join dbo.olist_order_items_clean_dataset oi 
  on o.order_id = oi.order_id 
  join dbo.olist_products_clean_dataset p
  on oi.product_id = p.product_id 
  join Product_category_name_translation pt
  on p.product_category_name = pt.product_category_name 
  where o.order_status = 'delivered'
  group by year(o.order_purchase_timestamp), 
  month(o.order_purchase_timestamp), 
  pt.product_category_name_english 
  )
, cte_a as (
  select *, 
  (total_revenue - prev_revenue ) * 100.0 / prev_revenue as growth_revenue from growth_revenue_monthly)
select 
*, 
growth_revenue from cte_a 
  
  
  
  
  

