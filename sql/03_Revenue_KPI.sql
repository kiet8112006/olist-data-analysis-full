KPI Revenue
1. Revenue
sql'''
select sum(price+ freight_value) as total_revenue from dbo.olist_order_items_clean_dataset
'''
2. Delivery Revenue
sql'''
select sum(price+ freight_value) as total_revenue
from dbo.olist_order_items_clean_dataset oi
join dbo.olist_orders_clean_dataset o
on oi.order_id = o.order_id 
where o.order_status='delivered'
'''
3. Revenue by category
sql'''
select 
  product_category_name_english,
  sum(price+freight_value) as total_revenue
from dbo.olist_order_items_clean_dataset oi
join dbo.olist_orders_clean_dataset o
on oi.order_id=o.order_id 
join dbo.olist_products_clean_dataset p
on oi.product_id=p.product_id 
join dbo.Product_category_name_translation pt
on p.product_category_name = pt.product_category_name 
where o.order_status = 'delivered'
group by pt.product_category_name_english
order by total_revenue desc '''
4. Revenue by year and month 
sql '''
select 
  year(o.order_purchase_timestamp) as year, 
  month(o.order_purchase_timestamp) as month,
  sum(oi.price+ oi.freight_value) as total_revenue
from dbo.olist_order_items_clean_dataset oi
join dbo.olist_orders_clean_dataset o
on oi.order_id = o.order_id 
where o.order_status = 'delivered'
group by year(o.order_purchase_timestamp),
month(o.order_purchase_timestamp)
order by year(o.order_purchase_timestamp), month(o.order_purchase_timestamp)
'''
5. Top revenue month by year
sql'''
with monthly_revenue as(
select 
year(o.order_purchase_timestamp) as year, 
month(o.order_purchase_timestamp) as month, 
sum(oi.price+oi.freight_value) as total_revenue
from dbo.olist_orders_clean_dataset o 
join dbo.olist_order_items_clean_dataset oi
on o.order_id= oi.order_id 
where o.order_status = 'delivered'
group by year(o.order_purchase_timestamp),
month(o.order_purchase_timestamp)
), 
ranked_revenue as(
select *, 
row_number() over(partition by year order by total_revenue desc ) as rank_number
from monthly_revenue )
select * from ranked_revenue where rank_number= 1;
'''
6. Revenue growth over time
sql '''
  with monthly_revenue as (
select year(o.order_purchase_timestamp), 
month(o.order_purchase_timestamp), 
sum(oi.price+ oi.freight_value) as total_revenue
from dbo.olist_orders_clean_dataset o
join dbo.olist_order_items_clean_dataset oi
on o.order_id=oi.order_id 
where o.order_status= 'delivered'
group by year(o.order_purchase_timestamp),
month(o.order_purchase_timestamp) )
, monthly_growth as (
  select *, 
  lag(total_revenue) over( order by year, month ) as prev_month, 
  (total_revenue-lag(total_revenue) over(order by year, month)) *100.0 / lag(total_revenue) over(order by year, month) as growth_monthly 
  from monthly_revenue)
select * from monthly_growth 
'''
7.  Average Order Value
sql'''
with total_revenue_cte as (
select 
oi.order_id,
sum(oi.price+oi.freight_value) as total_revenue
from dbo.olist_order_items_clean_dataset oi
  join dbo.olist_orders_clean_dataset o
  on oi.order_id = o.order_id 
where o.order_status= 'delivered'
  group by oi.order_id )
select avg(total_revenue) as AOV from total_revenue_cte
'''
8. Revenue by State
sql '''
select customer_state as State, 
sum(oi.price+oi.freight_value) as total_revenue
from dbo.olist_order_items_clean_dataset oi
join olist_orders_clean_dataset o
on oi.order_id=o.order_id
join dbo.olist_customers_clean_dataset c
on o.customer_id=c.customer_id
where o.order_status = 'delivered'
group by customer_state 
order by total_revenue desc 
'''
9. Revenue by each customer
sql '''
with revenue_per_customer as (
select 
c.customer_unique_id, 
sum(price+freight_value) as total_revenue
from dbo.olist_order_items_clean_dataset oi
join olist_orders_clean_dataset o
on oi.order_id=o.order_id
join dbo.olist_customers_clean_dataset c
on o.customer_id=c.customer_id 
where o.order_status = 'delivered'
group by customer_unique_id)

select * from revenue_per_customer order by tptal_revenue desc 
'''
10. Revenue by seller 
sql '''
with revenue_per_seller as (
select 
s.seller_id, 
sum(oi.price + oi.freight_value) as total_revenue
from dbo.olist_order_items_clean_dataset oi
join dbo.olist_orders_clean_dataset o
on oi.order_id=o.order_id
where o.order_status = 'delivered'
group by s.seller_id )

select * from revenue_per_seller order by total_revenue desc;
'''
11. Shipping cost to Revenue ratio
sql '''
  with cte_ship_revenue as (
select sum(freight_value) as ship, 
  sum(price+ freight_value) as total_revenue
from dbo.olist_order_items_clean_dataset oi
  join dbo.olist_orders_clean_dataset o
  on oi.order_id=o.order_id 
  where o.order_status = 'delivered' )

select ship *100.0 / total_revenue as shipping_rate from cte_ship_revenue 
'''



  


