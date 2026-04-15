import pandas as pd
#1. Load to data
orders = pd.read_csv('olist_orders_dataset.csv')
orders_clean = orders.copy()
print("Shape:", orders_clean.shape)
orders_clean.info()
#2. Connvert to datetime
date_cols = [
    'order_purchase_timestamp',
    'order_approved_at',
    'order_delivered_carrier_date',
    'order_delivered_customer_date',
    'order_estimated_delivery_date'
]
#3. Validate logic 
for col in date_cols:
    orders_clean[col] = pd.to_datetime(orders_clean[col], errors='coerce')
orders_clean['is_invalid_date'] = 0

# Helper function 
def invalid_condition(cond):
    return cond.fillna(False)

# Purchase <= Delivered
orders_clean.loc[
    invalid_condition(
        orders_clean['order_purchase_timestamp'] > orders_clean['order_delivered_customer_date']
    ),
    'is_invalid_date'
] = 1

#  Purchase <= Approved
orders_clean.loc[
    invalid_condition(
        orders_clean['order_purchase_timestamp'] > orders_clean['order_approved_at']
    ),
    'is_invalid_date'
] = 1

#  Approved <= Carrier
orders_clean.loc[
    invalid_condition(
        orders_clean['order_approved_at'] > orders_clean['order_delivered_carrier_date']
    ),
    'is_invalid_date'
] = 1

#  Carrier <= Customer
orders_clean.loc[
    invalid_condition(
        orders_clean['order_delivered_carrier_date'] > orders_clean['order_delivered_customer_date']
    ),
    'is_invalid_date'
] = 1
# Delivered nhưng thiếu ngày giao
missing_delivered = (
    (orders_clean['order_status'] == 'delivered') &
    (orders_clean['order_delivered_customer_date'].isna())
)
#5. Null flag 
print("Missing delivered date:", missing_delivered.sum())
orders_clean['flag_approved_null'] = orders_clean['order_approved_at'].isna().astype(int)
orders_clean['flag_carrier_null'] = orders_clean['order_delivered_carrier_date'].isna().astype(int)
orders_clean['flag_customer_null'] = orders_clean['order_delivered_customer_date'].isna().astype(int)
#6. Duplicate 
print("Duplicate order_id:", orders_clean['order_id'].duplicated().sum())
print("Duplicate customer_id:", orders_clean['customer_id'].duplicated().sum())
#7. check order_status
print(orders_clean['order_status'].value_counts(normalize=True))
#8. Check range of date
for col in date_cols:
    print(f"{col}: {orders_clean[col].min()} → {orders_clean[col].max()}")
#9. Save 
orders_clean.to_csv('orders_clean.csv', index=False)
