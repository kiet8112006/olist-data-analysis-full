import pandas as pd 
Orders=pd.read_csv('olist_orders_dataset.csv')
# Check the size of the Orders dataset
Orders_clean=Orders.copy()
print(Orders_clean.shape)
Orders_clean.info()
# Convert date columns into datetime format
date_cols=['order_purchase_timestamp', 'order_approved_at', 'order_delivered_carrier_date', 'order_delivered_customer_date', 'order_estimated_delivery_date']
for i in date_cols:
  Orders_clean[i] = pd.to_datetime(Orders_clean[i], errors='coerce')
# Check logic date columns
#1. Purchase < Delivered
Orders_clean['is_invalid_date']=0
Orders_clean.loc[Orders_clean['order_purchase_timestamp'] > Orders_clean['order_delivered_customer_date'], 'is_invalid_date']=1
#2. Approved < Shipping
Orders_clean.loc[Orders_clean['order_approved_at'] > Orders_clean['order_delivered_carrier_date'], 'is_invalid_date']=1
#3. Shipping < delivered
Orders_clean.loc[Orders_clean['order_delivered_carrier_date'] > Orders_clean['order_delivered_customer_date'], 'is_invalid_date']=1
#4. approved < purchase
Orders_clean.loc[Orders_clean['order_approved_at'] < Orders_clean['order_purchase_timestamp'], 'is_invalid_date'] = 1
#5. Missing  date but order_status='delivered'
print(((Orders_clean['order_status']=='delivered') & 
       (Orders_clean['order_delivered_customer_date'].isna())).sum())
#6. Check logic order_purchase_timestamp and shipping_limit_date
df = order_items_clean.merge(
    orders_clean[['order_id', 'order_purchase_timestamp']],
    on='order_id',
    how='left'
)
df['is_valid_shipping'] = df['shipping_limit_date'] >= df['order_purchase_timestamp']
df['shipping_delay_days'] = (
    df['shipping_limit_date'] - df['order_purchase_timestamp']
).dt.days

df = df.merge(
    orders[['order_id', 'order_delivered_carrier_date']],
    on='order_id',
    how='left'
)

df['on_time_shipping'] = (
    df['order_delivered_carrier_date'] <= df['shipping_limit_date']
)
# check null for all columns
print(Orders_clean.isnull().sum())
Orders_clean['flag_approved']=Orders_clean['order_approved_at'].isnull().astype(int)
Orders_clean['flag_carrier']=Orders_clean['order_delivered_carrier_date'].isnull().astype(int)
Orders_clean['flag_customer']=Orders_clean['order_delivered_customer_date'].isnull().astype(int)
# Chẹck duplicates for order_id and customer_id
print(Orders_clean['order_id'].duplicated().sum())
print(Orders_clean['customer_id'].duplicated().sum())
# Check different values in 'order_status'
print(Orders_clean['order_status'].value_counts(normalize=True))
# check range of datetime columns 
for i in date_cols:
  print(f'{i} Min date: {Orders_clean[i].min()} and Max date: {Orders_clean[i].max()}')

# Save  cleaned file
Orders_clean.to_csv('Orders_clean.csv', index=False)
