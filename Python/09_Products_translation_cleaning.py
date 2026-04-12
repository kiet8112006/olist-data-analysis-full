import pandas as pd 
Product_translation=pd.read_csv('product_category_name_translation.csv')
# Check the size of Produc_translation 
Product_translation_clean=Product_translation.copy()
Product_translation_clean.info()
# Check duplicates
print(Product_translation_clean['product_category_name'].duplicated().sum())
print(Product_translation_clean['product_category_name_english'].duplicated().sum())
# standardize text
Product_translation_clean['product_category_name'] =Product_translation_clean['product_category_name'].str.strip()
Product_translation_clean['product_category_name_english'] =Product_translation_clean['product_category_name_english'].str.strip()
# Save cleaned file
Product_translation_clean=pd.to_csv('Product_translation_clean.csv')
