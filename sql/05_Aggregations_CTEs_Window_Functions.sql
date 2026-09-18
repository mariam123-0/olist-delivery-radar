-- PART 1: AGGREGATIONS


-- 1. Total Orders by Customer State
-- Count the number of orders in each state
SELECT
    c.customer_state,
    COUNT(o.order_id) AS total_orders
FROM customers c
JOIN orders o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- 2. Total Revenue by Payment Type
-- Calculate total payment value for each payment method
SELECT
    payment_type,
    COUNT(*) AS total_payments,
    SUM(payment_value) AS total_revenue,
    AVG(payment_value) AS average_payment
FROM order_payments
GROUP BY payment_type
ORDER BY total_revenue DESC;


-- 3. Product Performance
-- Calculate number of orders and total revenue for products
SELECT
    oi.product_id,
    COUNT(oi.order_id) AS total_orders,
    SUM(oi.price) AS total_revenue,
    AVG(oi.price) AS average_price
FROM order_items oi
GROUP BY oi.product_id
ORDER BY total_revenue DESC;


-- PART 2: CTEs


-- 1. Customers with More Than 3 Orders
-- First calculate orders per customer,
-- then filter the result
WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id) AS total_orders
    FROM orders
    GROUP BY customer_id
)
SELECT
    customer_id,
    total_orders
FROM customer_orders
WHERE total_orders > 3
ORDER BY total_orders DESC;


-- 2. Revenue by Product Category
-- Calculate revenue first,
-- then display the highest categories
WITH category_revenue AS (
    SELECT
        p.product_category_name,
        SUM(oi.price) AS total_revenue
    FROM order_items oi
    JOIN products p
        ON oi.product_id = p.product_id
    GROUP BY p.product_category_name
)
SELECT
    product_category_name,
    total_revenue
FROM category_revenue
ORDER BY total_revenue DESC;


-- 3. Average Review Score by Seller
-- Calculate the average review score for each seller
WITH seller_reviews AS (
    SELECT
        oi.seller_id,
        AVG(r.review_score) AS average_review_score
    FROM order_items oi
    JOIN order_reviews r
        ON oi.order_id = r.order_id
    GROUP BY oi.seller_id
)
SELECT
    seller_id,
    average_review_score
FROM seller_reviews
ORDER BY average_review_score DESC;


-- PART 3: WINDOW FUNCTIONS


-- 1. ROW_NUMBER()
-- Give each product a unique row number
-- based on revenue
SELECT
    product_id,
    SUM(price) AS total_revenue,
    ROW_NUMBER() OVER (
        ORDER BY SUM(price) DESC
    ) AS revenue_position
FROM order_items
GROUP BY product_id;


-- 2. RANK()
-- Rank sellers based on total revenue
SELECT
    seller_id,
    SUM(price) AS total_revenue,
    RANK() OVER (
        ORDER BY SUM(price) DESC
    ) AS seller_rank
FROM order_items
GROUP BY seller_id;


-- 3. DENSE_RANK()
-- Rank products based on their average price
SELECT
    product_id,
    AVG(price) AS average_price,
    DENSE_RANK() OVER (
        ORDER BY AVG(price) DESC
    ) AS price_rank
FROM order_items
GROUP BY product_id;


-- 4. SUM() OVER()
-- Calculate each customer's total spending
-- while keeping individual payments
SELECT
    o.customer_id,
    op.order_id,
    op.payment_value,
    SUM(op.payment_value) OVER (
        PARTITION BY o.customer_id
    ) AS customer_total_spending
FROM orders o
JOIN order_payments op
    ON o.order_id = op.order_id;


-- 5. AVG() OVER()
-- Calculate each seller's average product price
-- while keeping individual products
SELECT
    seller_id,
    product_id,
    price,
    AVG(price) OVER (
        PARTITION BY seller_id
    ) AS seller_average_price
FROM order_items;