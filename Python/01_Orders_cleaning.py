import pandas as pd 
Orders=pd.read_csv('olist_orders_dataset')
# Check the size of the Orders dataset
Orders_clean=Orders.copy()
print('Orders_clean.shape')
Orders_clean.info()
# Convert date columns into datetime format
date_cols=['order_purchase_timestamp', 'order_approved_at', 'order_delivered_carrier_date', 'order_delivered_customer_date', 'order_estmated_delivery_date']
for i in date_cols:
  Orders_clean[i]=pd.to_datetime(Orders_clean[i])
# Check logic date columns
#1. Purchase < Delivered
Orders_clean['is_invalid_date']=0
Orders_clean.loc[Orders_clean['order_purchase_timestamp'] > Orders_clean['order_delivered_customer_date'], 'is_invalid_date']=1
#2. Approved < Shipping
Orders_clean.loc[Orders_clean['order_approved_at'] > Orders_clean['order_delivered_carrier_date'], 'is_invalid_date']=1
#3. Shipping < delivered
Orders_clean.loc[Orders_clean['order_delivered_carried_date'] > Orders_clean['order_deivered_customer_date'], 'is_invalid_date']=1
#4. Missing  date but order_status='delivered'
Orders_clean.loc[(Orders_clean['order_status']=='delivered') and (Orders_clean['order_delivered_customer_date'].isna())]
# check null for all columns
print(Orders_clean.isnull().sum())
Orders_clean['flag_approved']=Orders_clean['order_approved_at'].isnull().astype(int)
Orders_clean['flag_carrier']=Orders_clean['order_delivered_carrier_date'].isnull().astype(int)
Orders_clean['flag_customer']=Orders_clean['order_delivered_customer_date'].isnull().astype(int)
# Chẹck duplicates for order_id and customer_id
print(Orders_clean['order_id'].duplicated.sum())
print(Orders_clean['customer_id'].duplicated.sum())
# Check different values in 'order_status'
print(Orders_clean['order_status'].value_count(normalize=True))
# check range of datetime columns 
for i in date_cols:
  print(f'{i} Min date: {Order_clean[i].min()} and Max date: {Orders_clean[i].max()}')
# Save  cleaned file
Orders_clean.to_csv('Orders_clean.csv', index=false)

