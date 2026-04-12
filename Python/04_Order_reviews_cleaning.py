import pandas as pd 
Order_reviews=pd.read_csv('olist_order_reviews_dataset.csv')
# Check the size of the Order_review dataset 
Order_reviews_clean=Order_reviews.copy()
print(Order_reviews_clean.shape)
# Check null for all columns
cols = ['review_id', 'order_id', 'review_score', 'review_comment_message', 'review_creation_date', 'review_answer_timestamp']
for i in cols:
 print(f"{i} : {Order_reviews_clean[i].isnull().sum()}")
Order_reviews_clean['has comment']=Order_reviews_clean['review_comment_message'].notnull().astype(int)
Order_reviews_clean['has title']=Order_reviews_clean['review_comment_title'].notnull().astype(int)
# Check duplicated for all column 
for i in cols:
  print(f"{i} : {Order_reviews_clean[i].duplcated().sum()}")
Order_reviews_clean= Order_reviews_clean.sort_values(by='review_creation_date')
Order_reviews_clean=Order_reviews_clean.drop_duplicates(subset=['review_id'], keep='last')
print(Order_reviews_clean.groupby('order_id')['review_id'].nunique().value_counts())
# Convert some columns into datetime columns
Order_reviews_clean['review_creation_date']=pd.to_datetime(Order_reviews_clean['review_creation_date'])
Order_reviews_clean['review_answer_timestamp']=pd.to_datetime(Order_reviews_clean['review_answer_timestamp'])
# Check review_score
print(Order_reviews_clean['review_score'].describe())
print(Order_reviews_clean['review_score'].value_counts(normalize=True))
# Check min, max review_creation_date, review_answer_timmestamp
a = ['review_creation_date', 'review_answer_timestamp']
for i in a:
  print(f"{i} min : {Order_reviews_clean[i].min()}, max : {Order_reviews_clean[i].max()}")
# Create a column: Response time
Order_reviews_clean['response_time']=( Order_reviews_clean['review_answer_timestamp'] - Order_reviews_clean['review_creation_date']).dt.days 
print(Order_reviews_clean['response_time'].describe())
# Save cleaned file
Order_reviews_clean=pd.to_csv('Order_reviews_clean.csv')


