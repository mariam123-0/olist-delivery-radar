-- 1. Orders + Customers
-- Get customer information for each order
SELECT
    o.order_id,
    o.customer_id,
    c.customer_city,
    c.customer_state
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id;


-- 2. Orders + Order Items
-- Get products included in each order
SELECT
    o.order_id,
    oi.order_item_id,
    oi.product_id,
    oi.price
FROM orders o
JOIN order_items oi
    ON o.order_id = oi.order_id;


-- 3. Order Items + Products
-- Get product details for each order item
SELECT
    oi.order_id,
    oi.product_id,
    p.product_category_name,
    p.product_weight_g
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id;


-- 4. Products + Category Translation
-- Get the English category name
SELECT
    p.product_id,
    p.product_category_name,
    ct.product_category_name_english
FROM products p
JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name;


-- 5. Order Items + Sellers
-- Get seller information for each product
SELECT
    oi.order_id,
    oi.product_id,
    oi.seller_id,
    s.seller_city,
    s.seller_state
FROM order_items oi
JOIN sellers s
    ON oi.seller_id = s.seller_id;


-- 6. Orders + Payments
-- Get payment information for each order
SELECT
    o.order_id,
    o.customer_id,
    op.payment_type,
    op.payment_value
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id;


-- 7. Orders + Reviews
-- Get customer reviews for each order
SELECT
    o.order_id,
    o.customer_id,
    r.review_score,
    r.review_comment_title
FROM orders o
JOIN order_reviews r
    ON o.order_id = r.order_id;


-- 8. Customers + Geolocation
-- Get geographical information for customers
SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    g.geolocation_lat,
    g.geolocation_lng
FROM customers c
JOIN geolocation g
    ON c.customer_zip_code_prefix = g.geolocation_zip_code_prefix;


-- 9. Sellers + Geolocation
-- Get geographical information for sellers
SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    g.geolocation_lat,
    g.geolocation_lng
FROM sellers s
JOIN geolocation g
    ON s.seller_zip_code_prefix = g.geolocation_zip_code_prefix;