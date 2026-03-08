-- =====================================================
-- CUSTOMER RATING OVERVIEW
-- =====================================================

SELECT

AVG(review_score) AS avg_rating,

COUNT(*) AS total_reviews

FROM fact_reviews;

-- =====================================================
-- RATING DISTRIBUTION
-- =====================================================

SELECT

review_score,

COUNT(*) AS number_of_reviews

FROM fact_reviews

GROUP BY review_score

ORDER BY review_score;

-- =====================================================
-- RATING BY PRODUCT CATEGORY
-- =====================================================

SELECT

p.product_category,

AVG(r.review_score) AS avg_rating,

COUNT(*) AS total_reviews

FROM fact_reviews r

JOIN dim_products p
ON r.product_key = p.product_key

GROUP BY
p.product_category

ORDER BY
avg_rating DESC;


-- =====================================================
-- SELLER RATING PERFORMANCE
-- =====================================================

SELECT

s.seller_id,

AVG(r.review_score) AS avg_rating,

COUNT(*) AS total_reviews

FROM fact_reviews r

JOIN dim_sellers s
ON r.seller_key = s.seller_key

GROUP BY
s.seller_id

ORDER BY
avg_rating DESC;

-- =====================================================
-- RATING VS DELIVERY TIME
-- =====================================================

SELECT

AVG(d.delivery_days) AS avg_delivery_days,

AVG(r.review_score) AS avg_rating

FROM fact_reviews r

JOIN fact_delivery d
ON r.order_id = d.order_id;

