Review KPI
1. Good reviews by category
sql```
with cte_a as (
  select 
  pt.product_category_name_english, 
  avg(r.review_score) as avg_score, 
  sum( case when r.review_score >= 4 then 1 else 0 end ) as total_review_good 
  from dbo.olist_orders_clean_dataset o
  join dbo.olist_reviews_clean_dataset r 
  on o.order_id = r.order_id 
  join dbo.olist_order_items_clean_dataset oi
  on o.order_id = oi.order_id 
  join dbo.olist_products_clean_dataset p
  on oi.product_id = p.product_id 
  join dbo.Product_category_name_translation pt
  on p.product_category_name = pt.product_category_name 
  where o.order_status = 'delivered'
  group by product_category_name_english ), 
cte_b as (
  select *, 
  rank() over ( order by avg_score, total_review_good desc) as rnk
  from cte_a )
select product_category_name_english, 
avg_score,
total_review_
from cte_b 
where rnk = 1
order by avg_score desc , total_review_good desc 
```
2. Rating by year, month
sql```
with cte_a as (
  select 
  year(o.order_purchase_timestamp) as year, 
  month(o.order_purchase_timestamp) as month, 
  avg(r.review_score) as avg_score
  from dbo.olist_orders_clean_dataset o
  join dbo.olist_reviews_clean_dataset r
  on o.order_id = r.order_id 
  group by year(o.order_purchase_timestamp), month(o.order_purchase_timestamp)
  )
, cte_b as (
  select *, 
  rank() over( order by avg_score desc ) as rnk 
  from cte_a )
select 
year, month, avg_score from cte_b where rnk = 1
order by year, month, avg_score desc 
```
3. Rating and delivery
sql```
with cte_a as (
  select 
  year(order_purchase_timestamp) as year, 
  month(order_purchase_timestamp) as month, 
  review_score,
  datediff(day, order_estimated_delivery_date, order_delivered_customer_date) as delay_days
  from dbo.olist_orders_clean_dataset o
  join dbo.olist_reviews_clean_dataset r
  on o.order_id = r.order_id 
  where order_status = 'delivered'
   )
, cte_b as (
  select 
  year, 
  month, avg(review_score) as avg_score,count(*) as total_orders,
  sum(case when delay_days > 0 then 1 else 0 end ) as delay_counts from cte_a 
  group by year, month )
select 
year, 
month, 
avg_score,
delay_counts * 100.0 / total_orders as delay_rate
from cte_b 
```
4. Rating and price
sql```
with cte_a as (
  select 
  pt.product_category_name_english as product_name,
  oi.price, 
  r.review_score
  from dbo.olist_orders_clean_dataset o
  join dbo.olist_order_items_clean_dataset oi
  on o.order_id = oi.order_id
  join dbo.olist_reviews_clean_dataset r
  on o.order_id = r.order_id 
  join dbo.olist_products_clean_dataset p
  on oi.product_id = p.product_id 
  join dbo.Product_category_name_translation pt
  on p.product_category_name=pt.product_category_name
  )
select product_name, avg(price) as price , avg(review_score) as avg_score from cte_a 
group by product_name 
order by price desc 
```
  
  

