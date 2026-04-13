import pandas as pd 
Order_items=pd.read_csv('olist_order_items_dataset.csv')
# Check the size of Order_items dataset 
Order_items_clean=Order_items.copy()
print(Order_items_clean.shape)
Order_items_clean.info()
# Check null for all columns
print(Order_items_clean.isnull().sum())
# Check duplicate for (order_id, order_item_id), product_id, seller_id 
print(Order_items_clean.duplicated(subset=['order_id', 'order_item_id']).sum())
print(Order_items_clean['product_id'].duplicated().sum())
print(Order_items_clean['seller_id'].duplicated().sum())
#  Check price <=0
print(Order_items_clean['price'] <= 0).sum())
print(Order_items_clean['price'].describe())
# Check freight_value  <=0
print((Order_items_clean['freight_value'] <= 0).sum())
print((Order_items_clean['freight_value'] ==0).sum())
Order_items_clean['flag_free_shipping']=(Order_items_clean['freight_value']==0).astype(int)
print(Order_items_clean['freight_value'].describe())
# Check the correlation between price and freight_value
print(Order_items_clean[['price', 'freight_value']].corr())
# Convert shipping_limit_date into datetime column
Order_items_clean['shipping_limit_date']=pd.to_datetime(Order_items_clean['shipping_limit_date'], errors='coerce')
# Check range of shipping_limit_date
print('Max shipping_limit_date :', Order_items_clean['shipping_limit_date'].max(), 'and Min shipping_limit_date :', Order_items_clean['shipping_limit_date'].min())
# Save cleaned file
Order_items_clean.to_csv('Order_items_clean.csv', index= False)

