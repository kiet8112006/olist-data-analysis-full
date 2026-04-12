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
sellers_clean['seller_state']=Sellers_clean['seller_state'].str.strip().str.upper()

print(Sellers_clean['Seller_state'].value_counts(normalize=True))
print(sorted(Sellers_clean['Seller_state'].unique()))
for letter in sorted(Sellers_clean['Seller_state'].str[0].unique()):
    print(f"\n--- {letter} ---")
    print(sorted(Sellers_clean[
        Sellers_clean['seller_state'].str.startswith(letter)
    ]['seller_state'].unique()))
# standardize seller_city





