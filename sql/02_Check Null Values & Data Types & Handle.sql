-- overview tables
select * from category_translation
select * from customers
select * from geolocation
select * from order_items
select * from order_payments
select * from order_reviews
select * from orders
select * from products
select * from sellers

-- CHECK NULLS  &  DATA TYPES 

-- 1. CUSTOMERS
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'customers'
ORDER BY ORDINAL_POSITION;

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(customer_id) AS NonNull_customer_id,
    COUNT(*) - COUNT(customer_id) AS Null_customer_id,
    COUNT(customer_unique_id) AS NonNull_customer_unique_id,
    COUNT(*) - COUNT(customer_unique_id) AS Null_customer_unique_id,
    COUNT(customer_zip_code_prefix) AS NonNull_zip_code,
    COUNT(*) - COUNT(customer_zip_code_prefix) AS Null_zip_code,
    COUNT(customer_city) AS NonNull_city,
    COUNT(*) - COUNT(customer_city) AS Null_city,
    COUNT(customer_state) AS NonNull_state,
    COUNT(*) - COUNT(customer_state) AS Null_state
FROM customers;


-- 2. SELLERS
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'sellers'
ORDER BY ORDINAL_POSITION;

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(seller_id) AS NonNull_seller_id,
    COUNT(*) - COUNT(seller_id) AS Null_seller_id,
    COUNT(seller_zip_code_prefix) AS NonNull_zip_code,
    COUNT(*) - COUNT(seller_zip_code_prefix) AS Null_zip_code,
    COUNT(seller_city) AS NonNull_city,
    COUNT(*) - COUNT(seller_city) AS Null_city,
    COUNT(seller_state) AS NonNull_state,
    COUNT(*) - COUNT(seller_state) AS Null_state
FROM sellers;


-- 3. PRODUCTS
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'products'
ORDER BY ORDINAL_POSITION;

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(product_id) AS NonNull_product_id,
    COUNT(*) - COUNT(product_id) AS Null_product_id,
    COUNT(product_category_name) AS NonNull_category,
    COUNT(*) - COUNT(product_category_name) AS Null_category,
    COUNT(product_name_length) AS NonNull_name_length,
    COUNT(*) - COUNT(product_name_length) AS Null_name_length,
    COUNT(product_description_length) AS NonNull_description_length,
    COUNT(*) - COUNT(product_description_length) AS Null_description_length,
    COUNT(product_photos_qty) AS NonNull_photos_qty,
    COUNT(*) - COUNT(product_photos_qty) AS Null_photos_qty,
    COUNT(product_weight_g) AS NonNull_weight,
    COUNT(*) - COUNT(product_weight_g) AS Null_weight,
    COUNT(product_length_cm) AS NonNull_length,
    COUNT(*) - COUNT(product_length_cm) AS Null_length,
    COUNT(product_height_cm) AS NonNull_height,
    COUNT(*) - COUNT(product_height_cm) AS Null_height,
    COUNT(product_width_cm) AS NonNull_width,
    COUNT(*) - COUNT(product_width_cm) AS Null_width
FROM products;

-- 4. ORDERS
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'orders'
ORDER BY ORDINAL_POSITION;

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(order_id) AS NonNull_order_id,
    COUNT(*) - COUNT(order_id) AS Null_order_id,
    COUNT(customer_id) AS NonNull_customer_id,
    COUNT(*) - COUNT(customer_id) AS Null_customer_id,
    COUNT(order_status) AS NonNull_status,
    COUNT(*) - COUNT(order_status) AS Null_status,
    COUNT(order_purchase_timestamp) AS NonNull_purchase_date,
    COUNT(*) - COUNT(order_purchase_timestamp) AS Null_purchase_date,
	COUNT(order_approved_at) AS NonNull_approved_at,
    COUNT(*) - COUNT(order_approved_at) AS Null_approved_at,
    COUNT(order_delivered_carrier_date) AS NonNull_carrier_date,
    COUNT(*) - COUNT(order_delivered_carrier_date) AS Null_carrier_date,
    COUNT(order_delivered_customer_date) AS NonNull_customer_date,
    COUNT(*) - COUNT(order_delivered_customer_date) AS Null_customer_date,
    COUNT(order_estimated_delivery_date) AS NonNull_estimated_date,
    COUNT(*) - COUNT(order_estimated_delivery_date) AS Null_estimated_date
FROM orders;


-- 5. ORDER ITEMS
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'order_items'
ORDER BY ORDINAL_POSITION;

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(order_id) AS NonNull_order_id,
    COUNT(*) - COUNT(order_id) AS Null_order_id,
    COUNT(order_item_id) AS NonNull_item_id,
    COUNT(*) - COUNT(order_item_id) AS Null_item_id,
    COUNT(product_id) AS NonNull_product_id,
    COUNT(*) - COUNT(product_id) AS Null_product_id,
    COUNT(seller_id) AS NonNull_seller_id,
    COUNT(*) - COUNT(seller_id) AS Null_seller_id,
    COUNT(shipping_limit_date) AS NonNull_shipping_date,
    COUNT(*) - COUNT(shipping_limit_date) AS Null_shipping_date,
    COUNT(price) AS NonNull_price,
    COUNT(*) - COUNT(price) AS Null_price,
    COUNT(freight_value) AS NonNull_freight,
    COUNT(*) - COUNT(freight_value) AS Null_freight
FROM order_items;


-- 6. ORDER PAYMENTS
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'order_payments'
ORDER BY ORDINAL_POSITION;

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(order_id) AS NonNull_order_id,
    COUNT(*) - COUNT(order_id) AS Null_order_id,
    COUNT(payment_sequential) AS NonNull_sequential,
    COUNT(*) - COUNT(payment_sequential) AS Null_sequential,
    COUNT(payment_type) AS NonNull_payment_type,
    COUNT(*) - COUNT(payment_type) AS Null_payment_type,
    COUNT(payment_installments) AS NonNull_installments,
    COUNT(*) - COUNT(payment_installments) AS Null_installments,
    COUNT(payment_value) AS NonNull_payment_value,
    COUNT(*) - COUNT(payment_value) AS Null_payment_value
FROM order_payments;


-- 7. ORDER REVIEWS
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'order_reviews'
ORDER BY ORDINAL_POSITION;

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(review_id) AS NonNull_review_id,
    COUNT(*) - COUNT(review_id) AS Null_review_id,
    COUNT(order_id) AS NonNull_order_id,
    COUNT(*) - COUNT(order_id) AS Null_order_id,
    COUNT(review_score) AS NonNull_score,
    COUNT(*) - COUNT(review_score) AS Null_score,
    COUNT(review_comment_title) AS NonNull_comment_title,
    COUNT(*) - COUNT(review_comment_title) AS Null_comment_title,
    COUNT(review_comment_message) AS NonNull_comment_message,
    COUNT(*) - COUNT(review_comment_message) AS Null_comment_message,
    COUNT(review_creation_date) AS NonNull_creation_date,
    COUNT(*) - COUNT(review_creation_date) AS Null_creation_date,
    COUNT(review_answer_timestamp) AS NonNull_answer_date,
    COUNT(*) - COUNT(review_answer_timestamp) AS Null_answer_date
FROM order_reviews;


-- 8. GEOLOCATION
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'geolocation'
ORDER BY ORDINAL_POSITION;

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(geolocation_zip_code_prefix) AS NonNull_zip_code,
    COUNT(*) - COUNT(geolocation_zip_code_prefix) AS Null_zip_code,
    COUNT(geolocation_lat) AS NonNull_lat,
    COUNT(*) - COUNT(geolocation_lat) AS Null_lat,
    COUNT(geolocation_lng) AS NonNull_lng,
    COUNT(*) - COUNT(geolocation_lng) AS Null_lng,
    COUNT(geolocation_city) AS NonNull_city,
    COUNT(*) - COUNT(geolocation_city) AS Null_city,
    COUNT(geolocation_state) AS NonNull_state,
    COUNT(*) - COUNT(geolocation_state) AS Null_state
FROM geolocation;


-- 9. CATEGORY TRANSLATION
SELECT 
    COLUMN_NAME, 
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'category_translation'
ORDER BY ORDINAL_POSITION;

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(product_category_name) AS NonNull_Character,
    COUNT(*) - COUNT(product_category_name) AS Null_Character,
    COUNT(product_category_name_english) AS NonNull_English,
    COUNT(*) - COUNT(product_category_name_english) AS Null_English
FROM category_translation;


-- HANDLE NULLS & DATA TYPES

-- 1. PRODUCTS
UPDATE products
SET 
    product_category_name = COALESCE(product_category_name, 'unknown'),
    product_name_length = COALESCE(product_name_length, 0),
    product_description_length = COALESCE(product_description_length, 0),
    product_photos_qty = COALESCE(product_photos_qty, 0),
    product_weight_g = COALESCE(product_weight_g, 0),
    product_length_cm = COALESCE(product_length_cm, 0),
    product_height_cm = COALESCE(product_height_cm, 0),
    product_width_cm = COALESCE(product_width_cm, 0)
WHERE 
    product_category_name IS NULL
    OR product_name_length IS NULL
    OR product_description_length IS NULL
    OR product_photos_qty IS NULL
    OR product_weight_g IS NULL
    OR product_length_cm IS NULL
    OR product_height_cm IS NULL
    OR product_width_cm IS NULL;

-- 2.ORDERS
UPDATE orders
SET order_delivered_customer_date = NULL
WHERE order_status = 'canceled';

-- 3.ORDER ITEMS 
-- replace from integer to varchar 
ALTER TABLE order_items
ALTER COLUMN order_item_id TYPE VARCHAR(50)
USING order_item_id::VARCHAR;

--4. ORDER REVIEW
UPDATE order_reviews
SET 
    review_comment_title = COALESCE(review_comment_title, 'unknown'),
    review_comment_message = COALESCE(review_comment_message, 'unknown')
WHERE 
    review_comment_message IS NULL
	OR review_comment_message IS NULL