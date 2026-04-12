import pandas as pd 
Sellers=pd.read_csv('olist_sellers_dataset.csv')
# Check the size of Sellers dataet
Sellers_clean=Sellers.copy()
Sellers_clean.info()
# Check null for all columns
cols =['seller_id', 'seller_zip_code_prefix', 'seller_state', 'seller_city']
for i in cols:
  print(f'{i} {Sellers_clean[i].isnull().sum()}')
# Check duplicates
print(Sellers_clean['seller_id'].duplicated().sum())
# Standardize seller_state
Sellers_clean['seller_state']=Sellers_clean['seller_state'].str.strip().str.upper()

print(Sellers_clean['seller_state'].value_counts(normalize=True))
print(sorted(Sellers_clean['seller_state'].unique()))
for letter in sorted(Sellers_clean['seller_state'].str[0].unique()):
    print(f"\n--- {letter} ---")
    print(sorted(Sellers_clean[
        Sellers_clean['seller_state'].str.startswith(letter)
    ]['seller_state'].unique()))
# standardize seller_city
Sellers_clean['seller_city']=Sellers_clean['seller_city'].str.strip().str.upper()
print(Sellers_clean['seller_city'].value_counts(normalize=True))
Sellers_clean['seller_zip_code_prefix'].info()
Sellers_clean['seller_zip_code_prefix'] = (
    Sellers_clean['seller_zip_code_prefix']
    .astype(str)
    .str.zfill(5)
)
print(Sellers_clean['seller_zip_code_prefix'].nunique())
# Save cleaned file
Sellers_clean.to_csv('Sellers_clean_csv')






