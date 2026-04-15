#1. Load to data
import pandas as pd
import numpy as np
Order_reviews= pd.read_csv("olist_order_reviews_dataset.csv")
Order_reviews_clean=Order_reviews.copy()
#2. Clean basic
for col in Order_reviews_clean.select_dtypes(include='object').columns:
    Order_reviews_clean[col] = Order_reviews_clean[col].str.strip()
Order_reviews_clean = Order_reviews_clean.drop_duplicates()
#3. Clean date
date_cols = [
    'review_creation_date',
    'review_answer_timestamp'
]

for col in date_cols:
    Order_reviews_clean[col] = pd.to_datetime(Order_reviews_clean[col], errors='coerce')
#4. Data quality flag
Order_reviews_clean['flag_missing_date'] = Order_reviews_clean[date_cols].isnull().any(axis=1).astype(int)
Order_reviews_clean['is_invalid_date'] = (
    Order_reviews_clean['review_answer_timestamp'] < Order_reviews_clean['review_creation_date']
).astype(int)
Order_reviews_clean['flag_valid_review'] = (
    (Order_reviews_clean['review_score'].between(1, 5))
).astype(int)
#4. Clean score 
Order_reviews_clean['review_score'] = pd.to_numeric(Order_reviews_clean['review_score'], errors='coerce')
Order_reviews_clean = Order_reviews_clean[Order_reviews_clean['review_score'].between(1, 5)]
#5. clean text
Order_reviews_clean['review_comment_message'] = Order_reviews_clean['review_comment_message'].replace('', np.nan)
Order_reviews_clean['review_length'] = Order_reviews_clean['review_comment_message'].str.len()
#6. Response time
Order_reviews_clean['response_time_hours'] = (
    Order_reviews_clean['review_answer_timestamp'] - Order_reviews_clean['review_creation_date']
).dt.total_seconds() / 3600
#7. Sentiment đơn giản
Order_reviews_clean['sentiment'] = Order_reviews_clean['review_score'].apply(
    lambda x: 'negative' if x <= 2 else ('neutral' if x == 3 else 'positive')
)
#8. Save file
Order_reviews_clean.to_csv("Order_reviews_clean.csv", index=False)
