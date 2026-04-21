-- tạo primary key 
sql```
alter table dbo.customers_clean 
add constraint  PK_customers primary key (customer_id)

alter table dbo.order_items_clean 
add constraint PK_order_items primary key (order_id, order_item_id)

alter table dbo.order_payments_clean 
add constraint PK_order_payments primary key (order_id, payment_sequential)

alter table dbo.order_reviews_clean 
add constraint PK_order_reviews primary key (review_id, order_id)

alter table dbo.orders_clean 
add constraint PK_orders primary key (order_id)

alter table dbo.sellers_clean 
add constraint PK_sellers primary key (seller_id)

alter table dbo.products_clean 
add constraint PK_products primary key (product_id)

alter table dbo.product_translation_clean 
add constraint PK_product_translation primary key (product_category_name)
```
--tạo foreign key 
--1 order items 
sql```
alter table dbo.order_items_clean
add constraint FK_order_items_product
foreign key (product_id)
references dbo.products_clean (product_id)

alter table dbo.order_items_clean 
add constraint FK_order_items_seller
foreign key (seller_id) 
references dbo.sellers_clean (seller_id)
```
--2.order_reviews
sql```
alter table dbo.order_reviews_clean 
add constraint FK_order_reviews_orders
foreign key (order_id)
references dbo.orders_clean (order_id)
```
--3.orders
sql```
alter table dbo.orders_clean 
add constraint FK_orders_customers
foreign key (customer_id)
references dbo.customers_clean (customer_id)
```
--4.products
sql```
UPDATE dbo.products_clean
SET product_category_name = NULL
WHERE product_category_name NOT IN (
    SELECT product_category_name FROM dbo.product_translation_clean
)
alter table dbo.products_clean 
add constraint FK_products_product_translation 
foreign key (product_category_name)
references dbo.product_translation_clean (product_category_name)
```
--5.order_payments
sql```
alter table dbo.order_payments_clean 
add constraint FK_order_payments_orders
foreign key (order_id)
references dbo.orders_clean (order_id)
```
