-- 1. What are the top 10 product categories by total revenue?
SELECT
    p.product_category_name,
    SUM(oi.price) AS total_revenue
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_revenue DESC
LIMIT 10;


-- 2. Which customer states have the most orders?
SELECT
    c.customer_state,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- 3. Which payment method is used the most?
SELECT
    payment_type,
    COUNT(*) AS total_payments
FROM order_payments
GROUP BY payment_type
ORDER BY total_payments DESC;


-- 4. What is the average order value?
SELECT
    AVG(order_total) AS average_order_value
FROM (
    SELECT
        order_id,
        SUM(price + freight_value) AS order_total
    FROM order_items
    GROUP BY order_id
) AS orders_total;


-- 5. Who are the top 10 sellers by revenue?
SELECT
    seller_id,
    SUM(price) AS total_revenue
FROM order_items
GROUP BY seller_id
ORDER BY total_revenue DESC
LIMIT 10;


-- 6. Which product categories have the highest average review score?
SELECT
    p.product_category_name,
    AVG(r.review_score) AS average_review_score
FROM order_items oi
JOIN products p
    ON oi.product_id = p.product_id
JOIN order_reviews r
    ON oi.order_id = r.order_id
GROUP BY p.product_category_name
ORDER BY average_review_score DESC;

=
-- 7. How many orders are in each order status?
SELECT
    order_status,
    COUNT(*) AS total_orders
FROM orders
GROUP BY order_status
ORDER BY total_orders DESC;


-- 8. Which sellers have more than 100 orders?
SELECT
    seller_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM order_items
GROUP BY seller_id
HAVING COUNT(DISTINCT order_id) > 100
ORDER BY total_orders DESC;


-- 9. What are the top 10 most expensive products  based on average price?
SELECT
    product_id,
    AVG(price) AS average_price
FROM order_items
GROUP BY product_id
ORDER BY average_price DESC
LIMIT 10;