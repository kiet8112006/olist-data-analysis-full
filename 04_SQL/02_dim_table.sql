-tạo dim_customer
sql```
create table dim_customer (
customer_key int identity(1,1) primary key, 
customer_id nvarchar(50), 
customer_state  nvarchar(50), 
customer_city nvarchar(50)
);
insert into dim_customer
select distinct 
customer_id, 
customer_state, 
customer_city from dbo.customers_clean 
```
--tạo dim_product
sql```
create table dim_product(
product_key int identity(1,1) primary key, 
product_id nvarchar(50),
product_category_name_english nvarchar(50)
);
insert into dim_product
select distinct 
product_id, 
product_category_name_english 
from dbo.products_clean p join dbo.product_translation_clean pt
on p.product_category_name=pt.product_category_name
```
--tạo dim seller
sql```
create table dim_seller (
seller_key int identity(1,1) primary key, 
seller_id nvarchar(50), 
seller_state nvarchar(50),
seller_city nvarchar(50) );
insert into dim_seller
select distinct 
seller_id, 
seller_state, 
seller_city from dbo.sellers_clean
```
--tạo dim date 
sql```
create table dim_date (
date_key int primary key, 
full_date date, 
year int, 
quarter int, 
month int, 
month_name nvarchar(20), 
week int, 
day int, 
day_name nvarchar(20), 
is_weekend bit);
with cte_dates as (
select 
cast('2016-01-01' as date) as d union all
select dateadd(day, 1, d) from cte_dates where d < '2020-12-31')
insert into dim_date
select 
year(d) *10000 + month(d) *100 + day(d), 
d, 
year(d), 
datepart(quarter, d),
month(d), 
datename(month, d), 
datepart(week, d), 
day(d), 
datename(weekday, d), 
case when datename(weekday, d) in ('Saturday', 'Sunday') then 1 else 0 end from cte_dates option (maxrecursion 0)
```
