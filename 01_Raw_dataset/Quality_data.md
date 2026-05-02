Kiểm tra chất lượng dữ liệu để đánh giá, đề xuất hành động làm sạch.

A. olist_orders_dataset.csv: bảng orders.

1. Kiểm tra null.
   
python'
   import pandas as pd
orders=pd.read_csv("olist_orders_dataset.csv")
print(orders.isnull().sum())'

Kết quả: order_approved_at có 160 giá trị null, order_delivered_carrier_date có 1783 giá trị null, order_delivered_customer_date có 2965 giá trị null.

2. Kiểm tra kiểu dữ liệu.
   
python'
import pandas as pd
orders=pd.read_csv("olist_orders_dataset.csv")
orders.info()
'

Kết quả: Các cột như order_id, customer_id, order_status có kiểu dữ liệu là object và các cột order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date đều có kiểu dữ liệu là object chứ không phải là datetime.

3. Kiểm tra các giá trị trùng lặp.
   
python'
import pandas as pd
orders=pd.read_csv("olist_orders_dataset.csv")
print(orders.duplicated(subset="order_id").sum())
'

Kết quả: Cột order_id không có giá trị trùng.

python'
import pandas as pd
orders=pd.read_csv("olist_orders_dataset.csv")
print(orders.duplicated(subset="customer_id").sum())
'

Kết quả: Cột customer_id không có giá trị trùng.

4. Kiểm tra những giá khác của cột order_status.
   
python'
import pandas as pd
orders=pd.read_csv("olist_orders_dataset.csv")
counts=orders['order_status'].value_counts()
pct=orders['order_status'].value_counts(normalize=True)

result=pd.concat([counts, pct], axis=1)
result.columns=['count', 'percentage']
print(result)
'

Kết quả: order_status gôm những giá trị như: delivered có 96478 (97.02%), shipped có 1107 (1.11%), canceled có 625 (0.63%) và các giá trị khác như unavailable, invoiced, processing, created, approved. Không có phát hiện những giá trị khác bất thường.

5. Kiểm tra logic về thời gian.
   
Cụ thể như sau: order_purchase_timestamp < order_approved_at <  order_delivered_carrier_date < order_delivered_customer_date < order_estimated_delivery_date.
5.1. order_purchase_timestamp > order_approved_at.

python'
import pandas as pd
orders=pd.read_csv("olist_orders_dataset.csv")
orders['order_purchase_timestamp']=pd.to_datetime(orders['order_purchase_timestamp'])
orders['order_approved_at']=pd.to_datetime(orders['order_approved_at'])

print(orders['order_purchase_timestamp'].agg(['min','max']))
print(orders['order_approved_at'].agg(['min', 'max']))
print('logic_num:', (orders['order_approved_at'] > orders['order_purchase_timestamp']).sum())
'

Kết quả: Min, max của hai cột order_purchase_timestamp, order_approved_at đều hợp lệ. Có tổng cộng là 97985 dòng bị lỗi logic thời gian.

5.2. order_approved_at > order_delivered_carrier_date.

python'
import pandas as pd
orders=pd.read_csv("olist_orders_dataset.csv")
orders[' order_delivered_carrier_date']=pd.to_datetime(orders['order_purchase_timestamp'])
orders['order_approved_at']=pd.to_datetime(orders['order_approved_at'])

print(orders[' order_delivered_carrier_date'].agg(['min','max']))
print(orders['order_approved_at'].agg(['min', 'max']))
print('logic_num:', (orders['order_approved_at'] > orders[' order_delivered_carrier_date']).sum())
'

Kết quả: Min, max của hai cột order_approved_at, order_delivered_carrier_date đều hợp lệ. Có tổng cộng là 97985 dòng bị lỗi logic thời gian.

5.3. order_delivered_carrier_date > order_delivered_customer_date.

python'
import pandas as pd
orders=pd.read_csv("olist_orders_dataset.csv")
orders['order_delivered_carrier_date']=pd.to_datetime(orders['order_delivered_carrier_date'])
orders['order_delivered_customer_date']=pd.to_datetime(orders['order_delivered_customer_date'])

print(orders['order_delivered_customer_date'].agg(['min','max']))
print(orders['order_delivered_carrier_date'].agg(['min', 'max']))
print('logic_num:', (orders['order_delivered_carrier_date'] > orders['order_delivered_customer_date']).sum())
'

Kết quả: Min, max của hai cột order_delivered_carrier_date, order_delivered_customer_date đều hợp lệ. Có tổng cộng là 23 dòng bị lỗi logic thời gian.

5.4. order_delivered_customer_date > order_estimated_delivery_date.

python'
import pandas as pd
orders=pd.read_csv("olist_orders_dataset.csv")
orders['order_estimated_delivery_date']=pd.to_datetime(orders['order_estimated_delivery_date'])
orders['order_delivered_customer_date']=pd.to_datetime(orders['order_delivered_customer_date'])

print(orders['order_delivered_customer_date'].agg(['min','max']))
print(orders['order_estimated_delivery_date'].agg(['min', 'max']))
print('logic_num:', (orders['order_estimated_delivery_date'] < orders['order_delivered_customer_date']).sum())
'

Kết quả: Min, max của hai cột order_delivered_customer_date, order_estimated_delivery_date đều hợp lý. Có tổng cộng là 7827 dòng bị lỗi logic về thời gian.

5.5. order_purchase_timestamp > order_delivered_customer_date và order_status='delivered'.

python'
import pandas as pd
orders=pd.read_csv("olist_orders_dataset.csv")
orders['order_delivered_customer_date']=pd.to_datetime(orders['order_delivered_customer_date'])
orders['order_purchase_timestamp']=pd.to_datetime(orders['order_purchase_timestamp'])
print('logic_num:', ((orders['order_purchase_timestamp'] > orders['order_delivered_customer_date']) &(
    orders['order_status']=='delivered'
)).sum())
'
Kết quả: Không ghi nhận số dòng nào bị lỗi logic này.

B. olist_order_items_dataset.csv: bảng order items.
1. Kiểm tra null.
python'
import pandas as pd
order_items=pd.read_csv('olist_order_items_dataset.csv')
print(order_items.isnull().sum())
'

Kết quả: Tất cả các cột đều không có giá trị null.

2. Kiểm tra kiểu dữ liệu.
python'
import pandas as pd
order_items=pd.read_csv('olist_order_items_dataset.csv')
order_items.info()
'

Kết quả: Cột shipping_limit_date có kiểu dữ liệu là object cần chuyển sang datetime.

3. Kiểm tra giá trị trùng lặp.
python'
import pandas as pd
order_items=pd.read_csv('olist_order_items_dataset.csv')
print(order_items.duplicated(subset=['order_id', 'order_item_id']).sum())
'

Kết quả: Không có dòng nào bị trùng lặp dữ liệu.

4. Kiểm tra vùng giá trị của cột shipping_limit_date.
python'
import pandas as pd
order_items=pd.read_csv('olist_order_items_dataset.csv')
order_items['shipping_limit_date']=pd.to_datetime(order_items['shipping_limit_date'])
print(order_items['shipping_limit_date'].agg(['min', 'max']))
'

Kết quả: Min, max ngày hợp lệ.
5. Kiểm tra các giá trị của cột price và freight_value.
python'
import pandas as pd
order_items=pd.read_csv('olist_order_items_dataset.csv')
print(order_items[['price', 'freight_value']].describe())
'

Kết quả: Cả hai cột đều có giá trị cực lớn, nhìn chung không có giá trị nhỏ hơn 0. Nhưng cần xem xét kỹ thêm về vấn đề phân phối do cả hai cột đều không phân phối chuẩn.

C. olist_order_reviews_dataset.csv: bảng order reviews.

1. Kiểm tra giá trị null.
python'
import pandas as  pd
order_reviews=pd.read_csv('olist_order_reviews_dataset.csv')
print(order_reviews.isna().sum())
'

Kết quả: Tất cả các cột tương đối sạch, không có giá trị null ngoại trừ hai cột review_comment_title và review_comment_message có nhiều giá trị null có thể chấp nhận được.

2. Kiểm tra kiểu dữ liệu.
python'
import pandas as  pd
order_reviews=pd.read_csv('olist_order_reviews_dataset.csv')
order_reviews.info()
'

Kết quả: Hai cột review_creation_date và review_answer_timestamp đều có kiểu dữ liệu là object cần chuyển sang datetime.

3. Kiểm tra trùng lặp.
python'
import pandas as  pd
order_reviews=pd.read_csv('olist_order_reviews_dataset.csv')
print(order_reviews.duplicated(subset=['review_id', 'order_id']).sum())
'

Kết quả: Không có dòng nào bị trùng lặp dữ liệu.

4. Kiểm tra review_score.
python'
import pandas as  pd
order_reviews=pd.read_csv('olist_order_reviews_dataset.csv')
counts=order_reviews['review_score'].value_counts()
pct=order_reviews['review_score'].value_counts(normalize=True)

result=pd.concat([counts, pct], axis=1)
result.columns=['count', 'percentage']
print(result)
'
Kết quả: Không có giá trị nào phi logic của cột review_score.

5. Kiểm tra khoảng giá trị của hai cột review_creation_date, review_answer_timestamp.
python'
import pandas as  pd
order_reviews=pd.read_csv('olist_order_reviews_dataset.csv')
print(order_reviews[['review_creation_date', 'review_answer_timestamp']].agg(['min', 'max']))
'

Kết quả: Min, max của hai cột có giá trị hợp lệ.

D. olist_order_payments_dataset.csv: bảng order payments.

1. Kiểm tra giá trị null.
python'
import pandas as pd
order_payments=pd.read_csv('olist_order_payments_dataset.csv')
print(order_payments.isna().sum())
'
Kết quả: Không có cột nào có giá trị bị thiếu.

2. Kiểm tra kiểu dữ liệu.
python'
import pandas as pd
order_payments=pd.read_csv('olist_order_payments_dataset.csv')
order_payments.info()
'
Kết quả: Tất cả các cột đều đúng dữ liệu.

3. Kiểm tra trùng lặp.
python'
import pandas as pd
order_payments=pd.read_csv('olist_order_payments_dataset.csv')
print(order_payments.duplicated(subset=['order_id', 'payment_sequential']).sum())
'

Kết quả: Không có dòng bị trùng dữ liệu.

4. Kiểm tra các giá trị của các cột như: payment_sequential, payment_value, payment_installments.
python'
import pandas as pd
order_payments=pd.read_csv('olist_order_payments_dataset.csv')
counts=order_payments['payment_sequential'].value_counts()
pct=order_payments['payment_sequential'].value_counts(normalize=True)
result=pd.concat([counts, pct], axis=1)
result.columns=['count', 'percentage']
print(result)
'

Kết quả: Xuất hiện vài giá trị khả nghi đối với cột payment_sequential, cần kiểm tra kỹ.

python'
import pandas as pd
order_payments=pd.read_csv('olist_order_payments_dataset.csv')
counts=order_payments['payment_installments'].value_counts()
pct=order_payments['payment_installments'].value_counts(normalize=True)
result=pd.concat([counts, pct], axis=1)
result.columns=['count', 'percentage']
print(result)
'

Kết quả: Nhìn chung số kì trả góp từ 0 đến 24, cần kiểm tra kỹ với số kỳ trả góp là 0 và các giá trị lớn để phát hiện kịp thời ra những điểm bất thường.

python'

'

Kết quả:

