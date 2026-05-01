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
   
   2.4.2. Kiểu dữ liệu: Datetime.
   
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
   
   2.1. order_id.
   
   2.1.1. Thông tin: Mã định danh duy nhất của mỗi đơn hàng.
   
   2.1.2. Kiểu dữ liệu: String.
   
   2.1.3. Vai trò: kết hợp với order_item_id làm khóa chính nối với những bảng khác.
   
   2.2. order_item_id.
   
   2.2.1. Thông tin: Số thứ tự của item trong cùng 1 order.
   
   2.2.2. Kiểu dữ liệu: Int.
   
   2.2.3. Vai trò: kết hợp với order_id làm khóa chính trong bảng olist_order_items_dataset.csv.
   
   2.3. product_id.
   
   2.3.1. Thông tin: Mã định danh duy nhất của mỗi sản phẩm.
   
   2.3.2. Kiểu dữ liệu: String.
   
   2.3.3. Vai trò: Dùng làm khóa ngoại để nói với bảng olist_products_dataset.csv.
   
   2.4. seller_id.
   
   2.4.1. Thông tin: Mã định danh duy nhất của người bán.
   
   2.4.2. Kiểu dữ liệu: String.
   
   2.4.3. Vai trò: Dùng làm khóa ngoại để nối với bảng olist_sellers_dataset.csv.
   
   2.5. shipping_limit_date.
   
   2.5.1. Thông tin: Thời điểm hạn chót mà người bán phải giao hàng cho đơn vị vận chuyển.
   
   2.5.2. Kiểu dữ liệu: Datetime.
   
   2.5.3. Vai trò: Đo hiệu suất của người bán và sự chậm trễ của hệ thống giao hàng.
   
   2.6. price.
   
   2.6.1. Thông tin: Giá của sản phẩm (item) trong mỗi order.
   
   2.6.2. Kiểu dữ liệu: Float.
   
   2.6.3. Vai trò: Dùng để tính toán doanh thu và phân tích theo nhiều chiều khác nhau.
   
   2.7. freight_value.
   
   2.7.1. Thông tin: Phí vận chuyển của từng item trong order.
   
   2.7.2. Kiểu dữ liệu: Float.
   
   2.7.3. Vai trò: Dùng để tính toán doanh thu và phân tích nhiều chiều khác nhau.


C. olist_order_reviews_dataset.csv: bảng order reviews.
1. Số dòng và cột:
2. Tên các cột:
   
   2.1. review_id.
   
   2.1.1. Thông tin: Mã định danh duy nhất của 1 bài đánh giá.
   
   2.1.2. Kiểu dữ liệu: string.
   
   2.1.3. Vai trò: Dùng để làm khóa chính nối với bảng khác (kết hợp với order_id).
   
   2.2. order_id.
   
   2.2.1. Thông tin: Mã định danh duy nhất của mỗi đơn hàng.
   
   2.2.2. Kiểu dữ liệu: String.
   
   2.2.3. Vai trò: Dùng làm khóa chính nối với bảng khác (kết hợp với review_id).
   
   2.3. review_score.
   
   2.3.1. Thông tin: Điểm đánh giá khách hàng cho đơn hàng.
   
   2.3.2. Kiểu dữ liệu: Int.
   
   2.3.3. Vai trò: Dùng trong phân tích, đánh giá chất lượng dịch vụ, trải nghiệm khách hàng.
   
   2.4. review_comment_title.
   
   2.4.1. Thông tin: Tiêu đề ngắn của review do khách hàng đánh giá viết.
   
   2.4.2. Kiểu dữ liệu: String.
   
   2.4.3. Vai trò: Phân tích cảm xúc khách hàng, có thể kết hợp với review_score.
   
   2.5. review_comment_message.
   
   2.5.1. Thông tin: Nội dung chi tiết review mà khách hàng viết.
   
   2.5.2. Kiểu dữ liệu: String.
   
   2.5.3. Vai trò: Dùng để phâ tích cảm xúc và trải nghiệm của khách hàng.

D. olist_order_payments_dataset.csv: bảng order payments.
1. Số dòng và cột:
2. Tên các cột:
   
   2.1. order_id.
   
   2.1.1. Thông tin: Mã định danh duy nhất của mỗi đơn hàng.
   
   2.1.2. Kiểu dữ liệu: String.
   
   2.1.3. Vai trò: Dùng làm khóa chính để nối với bảng khác (kết hợp với payment_sequential).
   
   2.2. payment_sequential.
   
   2.2.1. Thông tin: Số thứ tự của các lần thanh toán trong cùng 1 order.
   
   2.2.2. Kiểu dữ liệu: Int.
   
   2.2.3. Vai trò: Dùng làm khóa chính để nối với mấy bảng khác (kết hợp với order_id).
   
   2.3. payment_type.
   
   2.3.1. Thông tin: Phương thức thanh toán mà khách hàng sử dụng cho đơn hàng.
   
   2.3.2. Kiểu dữ liệu: string.
   
   2.3.3. Vai trò: Dùng để phân tích doanh thu và phân tích hành vi thanh toán của khách hàng.
   
   2.4. payment_installments.
   
   2.4.1. Thông tin: Số kỳ trả góp mà khách hàng chọn cho đơn hàng của họ.
   
   2.4.2. Kiểu dữ liệu: Int.
   
   2.4.3. Vai trò: Dùng để phân tích tài chính và hành vi trả góp.
   
   2.5. payment_value.
   
   2.5.1. Thông tin: Số tiền mà khách hàng thực sự thanh toán cho 1 lần payment.
   
   2.5.2. Kiểu dữ liệu: Float.
   
   2.5.3. Vai trò: Dùng để tính doanh thu chuẩn và phân tích theo nhiều hướng khác.

E. olist_customers_dataset.csv: bảng customers.
1. Số dòng và cột:
2. Tên các cột:
   
   2.1. customer_id.
   
   2.1.1. Thông tin: Mã định danh cho khách hàng cho một đơn hàng cụ thể.
   
   2.1.2. Kiểu dữ liệu: String.
   
   2.1.3. Vai trò: Dùng làm khóa chính để nối với các bảng khác.
   
   2.2. customer_unique_id.
   
   2.2.1. Thông tin: Mã định danh duy nhất của một khách hàng thực sự.
   
   2.2.2. Kiểu dữ liệu: String.
   
   2.2.3. Vai trò: Xác định khách hàng thực sự và dùng để phân tích hành vi khách hàng.
   
   2.3. customer_state.
   
   2.3.1. Thông tin: Bang (vị trí địa lý) của khách hàng sinh sống, nhận hàng.
   
   2.3.2. Kiểu dữ liệu: String.
   
   2.3.3. Vai trò: Xác định vị trí của khách hàng với mục đích phục vụ cho phân tích.
   
   2.4. customer_city.
   
   2.4.1. Thông tin: Thành phố (vị trí địa lý) của khách hàng sinh sống, nhận hàng.
   
   2.4.2. Kiểu dữ liệu: String.
   
   2.4.3. Vai trò: Xác định vị trí của khách hàng với mục đích phục vụ cho phân tích.
   
   2.5. customer_zip_code_prefix.
   
   2.5.1. Thông tin: 5 chữ số đầu tiên mã bưu điện của khách hàng.
   
   2.5.2. Kiểu dữ liệu: Int, khi làm thực tế nên chuyển sang string.
   
   2.5.3. Vai trò: Dùng để nối với bảng olist_geolocation_dataset.csv.

F. olist_sellers_dataset.csv: bảng sellers.
1. Số dòng và cột:
2. Tên các cột:
   
   2.1. seller_id.
   
   2.1.1. Thông tin: Mã định danh duy nhất của một người bán.
   
   2.1.2. Kiểu dữ liệu: String.
   
   2.1.3. Vai trò: Dùng làm khóa chính để nối với bảng khác.
   
   2.2. seller_state.
   
   2.2.1. Thông tin: Bang (vị trí địa lý) nơi mà người bán hoạt động.
   
   2.2.2. Kiểu dữ liệu: String.
   
   2.2.3. Vai trò: Dùng để phân tích phân bố người bán và những phân tích sâu, nâng cao khác liên quan đến địa lý.
   
   2.3. seller_city.
   
   2.3.1. Thông tin: Thành phố (vị trí địa lý) nơi mà người bán hoạt động.
   
   2.3.2. Kiểu dữ liệu: String.
   
   2.3.3. Vai trò: Dùng để phân tích phân bố người bán và những phân tích sâu, nâng cao khác liên quan đến địa lý.
   
   2.4. seller_zip_code_prefix.
   
   2.4.1. Thông tin: 5 chữ số đầu tiên mã bưu điện của người bán hàng.
   
   2.4.2. Kiểu dữ liệu: Int, nên chuyển sang string.
   
   2.4.3. Vai trò: Dùng để nối với bảng olist_geolocation_dataset.csv.

G. olist_geolocation_dataset: bảng geolocation.
1. Số dòng và cột:
2. Tên các cột:
   
   2.1. geolocation_zip_code_prefix.
   
   2.1.1. Thông tin: 5 chữ số đầu tiên mã bưu điện của bảng geolocation.
   
   2.1.2. Kiểu dữ liệu: Int, nên chuyển sang string.
   
   2.1.3. Vai trò: Dùng để nối toàn bộ geo analysis phục vụ cho phân tích địa lý.
   
   2.2. geolocation_lat.
   
   2.2.1. Thông tin: Vĩ độ của vị trí tương ứng với zip code.

   2.2.2. Kiểu dữ liệu: Float.
   
   2.2.3. Vai trò: Dùng để xác định vị trí của customer, seller trên bản đồ.
   
   2.3. geolocation_lng.
   
   2.3.1. Thông tin: kinh dộ của vị trí tương ứng với zip code.
   
   2.3.2. Kiểu dữ liệu: Float.
   
   2.3.3. Vai trò: Dùng để xác định vị trí của customer, seller trên bản đồ.
   
   2.4. geolocation_city.
   
   2.4.1. Thông tin: Tên thành phố tương ứng với zip code trong bảng geolocation.
   
   2.4.2. Kiểu dữ liệu: String.
   
   2.4.3. Vai trò: Dùng để phân tích vị trí.
   
   2.5. geolocation_state.
   
   2.5.1. Thông tin: Tên bang tương ứng với zip code trong bảng geolocation.
   
   2.5.2. Kiểu dữ liệu: String.
   
   2.5.3. Vai trò: Dùng để phân tích vị trí.

H. olist_products_dataset.csv: bảng products.
1. Số dòng và cột:
2. Tên các cột:
   
   2.1. product_id.
   
   2.1.1. thông tin:
   
   2.1.2. Kiểu dữ liệu:
   
   2.1.3. Vai trò:
   
   
   
   
   
   
   
   
   
   
    
   
   
   
