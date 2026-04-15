import pandas as pd

# 1. Load data
Orders = pd.read_csv('olist_orders_dataset.csv')
Orders_clean = Orders.copy()

print("Shape:", Orders_clean.shape)
Orders_clean.info()

# 2. Convert to datetime
date_cols = [
    'order_purchase_timestamp',
    'order_approved_at',
    'order_delivered_carrier_date',
    'order_delivered_customer_date',
    'order_estimated_delivery_date'
]

for col in date_cols:
    Orders_clean[col] = pd.to_datetime(Orders_clean[col], errors='coerce')

# 3. Validate logic
Orders_clean['is_invalid_date'] = 0

# Helper function
def invalid_condition(cond):
    return cond.fillna(False)

# Purchase <= Delivered
Orders_clean.loc[
    invalid_condition(
        Orders_clean['order_purchase_timestamp'] > Orders_clean['order_delivered_customer_date']
    ),
    'is_invalid_date'
] = 1

# Purchase <= Approved
Orders_clean.loc[
    invalid_condition(
        Orders_clean['order_purchase_timestamp'] > Orders_clean['order_approved_at']
    ),
    'is_invalid_date'
] = 1

# Approved <= Carrier
Orders_clean.loc[
    invalid_condition(
        Orders_clean['order_approved_at'] > Orders_clean['order_delivered_carrier_date']
    ),
    'is_invalid_date'
] = 1

# Carrier <= Customer
Orders_clean.loc[
    invalid_condition(
        Orders_clean['order_delivered_carrier_date'] > Orders_clean['order_delivered_customer_date']
    ),
    'is_invalid_date'
] = 1

# 4. Delivered nhưng thiếu ngày giao
missing_delivered = (
    (Orders_clean['order_status'] == 'delivered') &
    (Orders_clean['order_delivered_customer_date'].isna())
)

print("Missing delivered date:", missing_delivered.sum())

# 5. Null flag
Orders_clean['flag_approved_null'] = Orders_clean['order_approved_at'].isna().astype(int)
Orders_clean['flag_carrier_null'] = Orders_clean['order_delivered_carrier_date'].isna().astype(int)
Orders_clean['flag_customer_null'] = Orders_clean['order_delivered_customer_date'].isna().astype(int)

# 6. Duplicate
print("Duplicate order_id:", Orders_clean['order_id'].duplicated().sum())
print("Duplicate customer_id:", Orders_clean['customer_id'].duplicated().sum())

# 7. Check order_status
print(Orders_clean['order_status'].value_counts(normalize=True))

# 8. Check range of date
for col in date_cols:
    print(f"{col}: {Orders_clean[col].min()} → {Orders_clean[col].max()}")

# 9. Save
Orders_clean.to_csv('orders_clean.csv', index=False)
