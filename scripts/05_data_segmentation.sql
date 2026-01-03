/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For segmenting products by price ranges and customers by spending behavior.
    - Helps identify patterns and differences across segments.

Techniques & SQL Functions Used:
    - CASE: Custom logic for defining segments
    - GROUP BY: Aggregates data by segment
    - Aggregate Functions: SUM(), COUNT()
    - Date Functions: DATEDIFF() for customer lifespan
===============================================================================
*/


/* Segment products into cost ranges and count
how many products fall into each segment */
WITH product_segments as (
    SELECT
        product_id,
        product_name,
        price,
        CASE 
            WHEN price < 100 THEN 'Below 100'
            ELSE '100 & Above'
        END price_range
     FROM shp.products
)
SELECT 
    price_range,
    COUNT(product_id) as total_products
FROM product_segments
GROUP BY price_range
ORDER BY total_products DESC;

-- Grouping customers into three segments based on their spending behavior 
WITH customer_spending as (
    SELECT
        c.customer_id,
        SUM(s.total_price) as total_spending,
        MIN(order_date) as first_order,
        MAX(order_date) as last_order,
        DATEDIFF (month, MIN(order_date), MAX(order_date)) as lifespan
    FROM shp.sales s
    LEFT JOIN shp.orders o
        ON s.order_id = o.order_id
    LEFT JOIN shp.customers c
        ON o.customer_id = c.customer_id
    GROUP BY c.customer_id
)
SELECT 
    customer_segment,
    COUNT(customer_id) as total_customers
FROM (
    SELECT 
        customer_id,
        CASE 
            WHEN lifespan >= 6 AND total_spending > 3000 THEN 'VIP'
            WHEN lifespan >= 6 AND total_spending <= 3000 THEN 'Regular'
            ELSE 'NEW'
        END customer_segment
     FROM customer_spending
) as segmented_customers
GROUP BY customer_segment
ORDER BY total_customers DESC;