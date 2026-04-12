Products=pd.read_csv('olist_products_dataset.csv')
# Check the size of Products dataset 
Products_clean=Products.copy()
Print(Products_clean.shape)
Products_clean.info()
# Check null for all columns 
cols = [ 'product_id', 'product_category_name', 'product_name_lenght', 'product_description_lenght', 'product_photos_qty', 'product_weight_g', 'product_length_cm', 
        'product_height_cm', 'product_width_cm']
for i in cols:
  print(f'{i} {Products_clean[i].isnull().sum()}')

for col in cols:
  Products_clean[f'{col}_is_missing'] = Products_clean[col].isnull().astype(int)

# category
Products_clean['product_category_name'] = Products_clean['product_category_name'].fillna('unknown')

# numeric
num_cols = [
    'product_name_lenght',
    'product_description_lenght',
    'product_photos_qty',
    'product_weight_g',
    'product_length_cm',
    'product_height_cm',
    'product_width_cm'
]

for col in num_cols:
    Products_clean[col] = Products_clean[col].fillna(Products_clean[col].median())
# Check duplicates for product_id 
print(Products_clean['product_id'].duplicated().sum())
# check all columns except product_id 
for i in num_cols:
 print(f'{i} {(Products_clean[i] <= 0 ).sum()}')
for col in num_cols:
    Products_clean[f'{col}_invalid_flag'] = (Products_clean[col] <= 0).astype(int)
for col in num_cols:
    Products_clean.loc[Products_clean[col] <= 0, col] = None
    Products_clean[col] = Products_clean[col].fillna(Products_clean[col].median())
Products_clean['long_desc_flag'] = (
    Products_clean['product_description_length'] > 2000
).astype(int)
# Save cleaned file
Products_clean=pd.to_csv('Products_clean.csv')



