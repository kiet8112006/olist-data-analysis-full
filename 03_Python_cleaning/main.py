import pandas as pd
from data_clean_pipeline import *

# LOAD
tables = {
    'orders': pd.read_csv('olist_orders_dataset.csv'),
    'customers': pd.read_csv('olist_customers_dataset.csv'),
    'sellers': pd.read_csv('olist_sellers_dataset.csv'),
    'products': pd.read_csv('olist_products_dataset.csv'),
    'order_items': pd.read_csv('olist_order_items_dataset.csv'),
    'order_payments': pd.read_csv('olist_order_payments_dataset.csv'),
    'order_reviews': pd.read_csv('olist_order_reviews_dataset.csv'),
    'geolocation': pd.read_csv('olist_geolocation_dataset.csv'),
    'product_translation': pd.read_csv('product_category_name_translation.csv')
}
schemas = {
    'orders': {
        'order_id': 'str',
        'customer_id': 'str',
        'order_status':'str',
        'order_purchase_timestamp': 'datetime',
        'order_delivered_carrier_date':'datetime',
        'order_approved_at': 'datetime',
        'order_delivered_customer_date': 'datetime', 
        'order_estimated_delivery_date':'datetime'
    },
    'customers': {
        'customer_id': 'str',
        'customer_city': 'str', 
        'customer_state':'str'
    }, 
    'sellers':{
        'seller_id':'str', 
        'seller_city':'str', 
        'seller_state':'str'
    }, 
    'products':{
        'product_id':'str', 
        'product_category_name':'str',
        'product_name_lenght':'int', 
        'product_description_lenght':'int', 
        'product_photos_qty':'int', 
        'product_weight_g':'int', 
        'product_length_cm':'int',
        'product_height_cm':'int', 
        'product_width_cm':'int'
    }, 
    'order_items':{
        'order_id':'str',
        'order_item_id':'int', 
        'product_id':'str', 
        'seller_id':'str', 
        'shipping_limit_date':'datetime', 
        'price':'float', 
        'freight_value':'float'
    }, 
    'order_reviews':{
        'review_id':'str', 
        'order_id':'str', 
        'review_score':'float', 
        'review_comment_title':'str',
        'review_comment_message':'str', 
        'review_creation_date':'datetime', 
        'review_answer_timestamp':'datetime'
    }, 
    'order_payments':
    {
        'order_id':'str', 
        'payment_sequential':'int', 
        'payment_type':'str', 
        'payment_installments':'int', 
        'payment_value':'float'    }, 
    'geolocation':{
        'geolocation_zip_code_prefix':'str', 
        'geolocation_lat':'float', 
        'geolocation_lng':'float', 
        'geolocation_city':'str', 
        'geolocation_state':'str'
    }, 
    'product_translation':{
        'product_category_name':'str', 
        'product_category_name_english':'str'
    }
}

# COPY
clean = {k: v.copy() for k, v in tables.items()}


# STEP 1: TYPE
for name in clean:
    clean[name] = check_type(clean[name], schemas[name])

# STEP 2: CLEAN TEXT
clean['orders'] = clean_text_columns(clean['orders'], ['order_status'])
clean['customers'] = clean_text_columns(clean['customers'], ['customer_city', 'customer_state'])
clean['sellers'] = clean_text_columns(clean['sellers'], ['seller_city', 'seller_state'])
clean['products']=clean_text_columns(clean['products'],['product_category_name'])
clean['product_translation']=clean_text_columns(clean['product_translation'], ['product_category_name'])

# STEP 3: NULL
for name in clean:
    clean[name] = check_null(clean[name], clean[name].columns)

# STEP 4: DUPLICATE
clean['orders'] = check_duplicate(clean['orders'], ['order_id'])
clean['customers'] = check_duplicate(clean['customers'], ['customer_id'])
clean['order_items']=check_duplicate(clean['order_items'], ['order_id', 'order_item_id'])
clean['order_payments']=check_duplicate(clean['order_payments'], ['order_id', 'payment_sequential'])
clean['order_reviews']=check_duplicate(clean['order_reviews'], ['order_id', 'review_id'])
clean['sellers']=check_duplicate(clean['sellers'], ['seller_id'])
clean['products']=check_duplicate(clean['products'], ['product_id'])
clean['product_translation']=check_duplicate(clean['product_translation'], ['product_category_name'])

# STEP 5: CHECK COLUMNS
clean['order_items'] = checK_column(
    clean['order_items'],
    'price_positive',
    lambda df: df['price'] >= 0
)
clean['order_items']=checK_column(clean['order_items'], 'freight_value_positive', 
                                  lambda df: df['freight_value'] >=0)

clean['order_reviews'] = checK_column(
    clean['order_reviews'],
    'score_valid',
    lambda df: (df['review_score'] >= 1) & (df['review_score'] <= 5)
)
clean['order_payments']=checK_column(clean['order_payments'], 'payment_value_positive', lambda df: df['payment_value'] > 0)
clean['order_payments']=checK_column(clean['order_payments'], 'payment_installments_positive', lambda df: df['payment_installments'] > 0)
clean['orders']=checK_column(clean['orders'], 'invalid_date', 
                             lambda df: (df['order_purchase_timestamp'] < df['order_approved_at']) & 
                             (df['order_approved_at'] < df['order_delivered_carrier_date']) & (
                                 df['order_delivered_carrier_date'] < df['order_delivered_customer_date']
                             ) &(df['order_delivered_customer_date'] < df['order_estimated_delivery_date'])
                             )
clean['order_reviews']=checK_column(clean['order_reviews'], 'invalid_date', lambda df:
                                    df['review_creation_date'] < df['review_answer_timestamp'])

# STEP 6: FK
clean['orders'] = check_foreign_key(
    clean['orders'],
    clean['customers'],
    'customer_id',
    'customer_id',
    'orders_customers'
)
clean['orders']=check_foreign_key(
    clean['orders'], clean['order_items'], 'order_id', 'order_id', 
    'orders_order_items'
)
clean['order_items']=check_foreign_key(clean['order_items'], clean['products'], 
                                       'product_id', 'product_id', 'order_items_product')
clean['order_items']=check_foreign_key(clean['order_items'], clean['sellers'], 'seller_id', 'seller_id', 'order_items_seller')
clean['order_reviews']=check_foreign_key(clean['order_reviews'], clean['orders'], 'order_id', 'order_id', 'reviews_orders')
clean['order_payments']=check_foreign_key(clean['order_payments'], clean['orders'], 'order_id', 'order_id', 'order_payment_orders')


# STEP 7: OUTLIER
clean['order_items'] = check_outliers_iqr(clean['order_items'], ['price', 'freight_value'])
clean['order_payments']=check_outliers_iqr(clean['order_payments'], ['payment_installments', 'payment_value'])
clean['products']=check_outliers_iqr(clean['products'], ['product_name_lenght', 'product_description_lenght', 'product_photos_qty', 'product_weight_g', 
'product_length_cm','product_height_cm', 'product_width_cm'])

# STEP 8: SUMMARY
summaries = []

for name in clean:
    summaries.append(data_quality_summary(clean[name], name))

final_summary = pd.concat(summaries, ignore_index=True)

# SAVE
for name in clean:
    clean[name].to_csv(f'{name}_clean.csv', index=False)

final_summary.to_csv('data_quality_summary.csv', index=False)

print(final_summary.head())
print("DONE")