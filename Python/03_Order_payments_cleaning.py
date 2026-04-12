import pandas as pd
Order_payments=pd.read_csv('olist_order_payments_dataset.csv')
# Check the size of Order_payments dataset
Order_payments_clean=Order_payments.copy()
print(Order_payments_clean.shape)
Order_payments_clean.info()
# Check null for all columns
cols=['order_id', 'payment_sequential', 'payment_type', 'payment_installments', 'payment_value']
for i in cols:
 print(Order_payments_clean[i].isnull().sum())
# Check duplicate 
print(Order_payments_clean.duplicated(subset=['order_id', 'payment_sequential']).sum())
# Check different values in Payment_type
print(Order_payments_clean['payment_type'].value_counts(normalize=True))
# Check payment_installments <= 0
print((Order_payments_clean['payment_installments'] <=0 ).sum())
print(Order_payments_clean['payment_installments'].describe())
Order_payments_clean['flag_invalid_installments']=(Order_payments_clean['payment_installments'] <= 0 ).astype(int)
# Check  payment_value 
print(Order_payments_clean['payment_value'].describe())
print((Order_payments_clean['payment_value'] ==0).sum())
Order_payments_clean['flag_payment_value']=(Order_payments_clean['payment_value'] ==0).astype(int)
# save cleaned file
Order_payments_clean=to_csv('Order_payments_clean.csv', index= false)

