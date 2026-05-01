Thông tin về các cột trong dataset Olist.
A. olist_orders_dataset.csv : bảng orders.
1. Số dòng và cột:
2. Tên các cột: order_id, customer_id, order_status, order_purchase_timestamp, order_approval_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date.
   2.1. order_id.
   2.1.1. Thông tin: Mã định danh duy nhất của mỗi một đơn hàng.
   2.1.2. Kiểu dữ liệu: String.
   2.1.3. Vai trò: order_id đóng vai trò làm khóa chính của bảng olist_orders_dataset và dùng để join các bảng khác lại với nhau.
   2.2. customer_id.
   2.2.1. Thông tin: Mã định danh khách hàng gắn với mỗi đơn hàng, không phải mã định danh thật sự và mỗi order sẽ có 1 customer_id.
   2.2.2. kiểu dữ liệu: String.
   2.2.3. Vai trò: customer_id làm khóa ngoại để nối sang với bảng olist_customers_dataset để lấy các thông tin như: city, state, zip_code.
   2.3. order_status.
   2.3.1. Thông tin: Trạng thái hiện tại của đơn hàng trong vòng đời của nó, bao gồm như: delivered, approved, shipped, invoiced, processing, canceled, unavailable.
   2.3.2. Kiểu dữ liệu: String
   2.3.3. Vai trò: Biến đại diện cho hiệu suất vận hành của toàn bộ hệ thống E-commerce.
   2.4. order_purchase_timestamp.
   2.4.1. Thông tin: Thời điểm khách đặt hàng.
   2.4.2. Kiểu dữ liệu: Datetime
   2.4.3. Vai trò: Đây là cột dùng để phân tích thời gian (vô cùng quan trọng) và kết hợp với các cột khác như order_approval_at, order_delivered_carrier_date để tính các thông số phục vụ cho việc khảo sát, phân tích về vận hành.
   2.5. order_approval_at.
   2.5.1. Thông tin: Thời điểm thanh toán được xác nhận.
   2.5.2. Kiểu dữ liệu: Datetime.
   2.5.3. Vai trò: Đo thời gian xử lý thanh toán và đánh giá hiệu suất hệ thống.
   2.6. order_delivered_carrier_date.
   2.6.1. Thông tin: Thời điểm đơn hàng được giao cho đơn vị vận chuyển.
   2.6.2. Kiểu dữ liệu: Datetime.
   2.6.3. Vai trò: Đây là mốc chuyển giao từ người bán đến phía đơn vị vận chuyển hàng hóa và dùng để tính, đo thời gian người bán xử lý hàng.
   2.7. order_delivered_customer_date.
   2.7.1. Thông tin: Thời điểm đơn hàng được giao thành công đến tay khách hàng.
   2.7.2. Kiểu dữ liệu: Datetime.
   2.7.3. Vai trò: Dùng để đo thời gian giao hàng toàn bộ quá trình và đo hiệu suất logistic.
   2.8. order_estimated_delivery_date.
   2.8.1. Thông tin: Thời điểm hệ thống sẽ dự đoán ngày đơn hàng sẽ đến tay khách hàng.
   2.8.2. Kiểu dữ liệu: Datetime.
   2.8.3. Vai trò: Mốc thời điểm mà khách hàng kỳ, đo độ trễ giao, đánh giá SLA và đánh giá hiệu suất logistic.
B. olist_order_items_dataset.csv: bảng order items.
1. Số dòng và cột:
2. Tên các cột: 
   
