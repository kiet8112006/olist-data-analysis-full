import pandas as pd 
Customers=pd.read_csv('olist_customers_dataset.csv')
# Check the size of Customers dataset 
Customers_clean=Customers.copy()
print(Customers_clean.shape)
# Check null for all columns
cols =['customer_id', 'customer_unique_id', 'customer_state', 'customer_city', 'customer_zip_code_prefix']
for i in cols:
    print(f"{i} : {Customers_clean[i].isnull().sum()}")
# Check duplicates
print('customer_id : ',Customers_clean['customer_id'].duplicated().sum())
print('customer_unique_id : ',Customers_clean['customer_unique_id'].duplicated().sum())
# standardize customer_state
Customers_clean['customer_state']=Customers_clean['customer_state'].str.strip().str.upper()
print(Customers_clean['customer_state'].value_counts(normalize=True))
for letter in sorted(Customers_clean['customer_state'].str[0].unique()):
    print(f"\n--- {letter} ---")
    print(sorted(Customers_clean[Customers_clean['customer_state'].str.startswith(letter)]['customer_state'].unique()))
# standardize customer_city 
print(Customers_clean['customer_city'].value_counts(normalize=True))
import unicodedata
def remove_accent(text):
    return ''.join(
        c for c in unicodedata.normalize('NFKD', text)
        if unicodedata.category(c) != 'Mn'
    )
Customers_clean['customer_city'] = Customers_clean['customer_city'].apply(remove_accent)
Customers_clean['customer_city'] = (
    Customers_clean['customer_city']
    .str.strip()                         
    .str.upper()                       
    .apply(remove_accent)                
    .str.replace(r'\s+', ' ', regex=True) 
)
# Check customer_zip_code_prefix
Customers_clean['customer_zip_code_prefix'].info()
Customers_clean['customer_zip_code_prefix'] = (
    Customers_clean['customer_zip_code_prefix']
    .astype(str)
    .str.zfill(5))
# Save cleaned file
Customers_clean=pd.to_csv('Customers_clean.csv')
