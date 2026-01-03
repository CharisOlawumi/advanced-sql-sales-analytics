CREATE SCHEMA Shp;


-- CHANGE OVER TIME (TREND)
SELECT 
YEAR(order_date) as order_year,
MONTH(order_date) as order_month,
SUM(total_price) as total_sales,
COUNT(DISTINCT customer_id) as total_customers,
SUM(quantity) as total_quantity
FROM shp.orders
RIGHT JOIN shp.sales
ON shp.orders.order_id = shp.sales.order_id
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);

SELECT 
DATETRUNC(month, order_date) as order_date,
SUM(total_price) as total_sales,
COUNT(DISTINCT customer_id) as total_customers,
SUM(quantity) as total_quantity
FROM shp.orders
RIGHT JOIN shp.sales
ON shp.orders.order_id = shp.sales.order_id
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date);

-- CUMULATIVE ANALYSIS
-- Total sales per month, running total of sales over time and Moving Average of price

SELECT 
order_date,
total_sales,
SUM(total_sales) OVER (ORDER BY order_date) as running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date) as moving_average_price
FROM
(
SELECT 
DATETRUNC(month, order_date) as order_date,
SUM(total_price) as total_sales,
AVG(price_per_unit) as avg_price
FROM shp.sales
LEFT JOIN shp.orders
ON shp.orders.order_id = shp.sales.order_id
GROUP BY DATETRUNC(month, order_date)
) t;

-- PERFORMANCE ANALYSIS
/* Analysing the yearly performance of products by comparing their sales
to both the average sales performance of the product and the previous year's sales (month-over-month analysis) */

WITH monthly_product_sales as (

SELECT
MONTH(o.order_date) as order_month,
p.product_name,
SUM(s.total_price) as current_sales
FROM shp.sales s
LEFT JOIN shp.orders o
ON s.order_id = o.order_id
LEFT JOIN shp.products p
ON p.product_id = s.product_id
WHERE o.order_date IS NOT NULL
GROUP BY
MONTH(o.order_date),
p.product_name
)

SELECT
order_month,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) as diff_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
     WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0 THEN 'Below Avg'
     ELSE 'Avg'
END avg_change,
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) as py_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) as diff_py,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) > 0 THEN 'Increase'
     WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) < 0 THEN 'Decrease'
     ELSE 'No Change'
END py_change
FROM monthly_product_sales
ORDER BY product_name, order_month;


-- PART-TO-WHOLE (PROPORTIONAL) ANALYSIS 
-- Categories that contribute the most to the overall sales
WITH product_type_sales as (
SELECT
product_type,
SUM(total_price) total_sales
FROM shp.sales s
LEFT JOIN shp.products p
ON s.product_id = p.product_id
GROUP BY product_type)

SELECT
product_type,
total_sales,
SUM(total_sales) OVER () overall_sales,
CONCAT(ROUND((CAST (total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') as percentage_of_total
FROM product_type_sales
ORDER BY total_sales DESC

-- DATA SEGMENTATION
/* Segment products into cost ranges and count
how many products fall into each segment */

WITH product_segments as (
SELECT
product_id,
product_name,
price,
CASE WHEN price < 100 THEN 'Below 100'
     ELSE '100 & Above'
END price_range
FROM shp.products)

SELECT 
price_range,
COUNT(product_id) as total_products
FROM product_segments
GROUP BY price_range
ORDER BY total_products DESC;

/* Grouping customers into three segments based on their spending behavior */
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
     CASE WHEN lifespan >= 6 AND total_spending > 3000 THEN 'VIP'
          WHEN lifespan >= 6 AND total_spending <= 3000 THEN 'Regular'
          ELSE 'NEW'
     END customer_segment
     FROM customer_spending) t
GROUP BY customer_segment
ORDER BY total_customers DESC


-- REPORTING 
--CUSTOMER REPORT
CREATE VIEW shp.report_customers as
WITH base_query as (
-- 1) Base Query: Retrieves core columns from tables
SELECT
s.order_id,
s.product_id,
o.order_date,
s.total_price,
s.quantity,
c.customer_id,
c.customer_name,
c.age
FROM shp.sales s
LEFT JOIN shp.orders o
ON s.order_id = o.order_id
LEFT JOIN shp.customers c
ON c.customer_id = o.customer_id
WHERE order_date IS NOT NULL)

, customer_aggregation as (
-- 2) Customer Aggregation: Summarizes key metrics at the customer level
SELECT
    customer_id,
    customer_name,
    age,
    COUNT(DISTINCT order_id) as total_orders,
    SUM(total_price) as total_sales,
    SUM(quantity) as total_quantity,
    COUNT(DISTINCT product_id) as total_products,
    MAX(order_date) as last_order_date,
    DATEDIFF (month, MIN(order_date), MAX(order_date)) as lifespan
FROM base_query
GROUP BY 
    customer_id,
    customer_name,
    age
)
SELECT 
customer_id,
customer_name,
age,
CASE 
     WHEN age < 20 THEN 'under 20'
     WHEN age between 20 and 29 THEN '20-29'
     WHEN age between 30 and 39 THEN '30-39'
     WHEN age between 40 and 49 THEN '40-49'
     ELSE '50 and above'
END as age_group,
CASE 
      WHEN lifespan >= 6 AND total_sales > 3000 THEN 'VIP'
      WHEN lifespan >= 6 AND total_sales <= 3000 THEN 'Regular'
      ELSE 'NEW'
END as customer_segment,
last_order_date,
DATEDIFF(month, last_order_date, GETDATE()) as recency,
total_orders,
total_sales,
total_quantity,
total_products,
lifespan,
-- Compute average order value (AVO)
CASE WHEN total_sales = 0 THEN 0
     ELSE total_sales / total_orders
END as avg_order_value,
-- Compute average monthly spend
CASE WHEN lifespan = 0 THEN total_sales
     ELSE total_sales / lifespan
END as avg_monthly_spend
FROM customer_aggregation;

--PRODUCT REPORT
CREATE VIEW shp.report_products as
WITH base_query as (
-- 1) Base Query: Retrieves core columns from sales and products
   SELECT
       s.order_id,
       o.order_date,
       o.customer_id,
       s.total_price,
       s.quantity,
       p.product_id,
       p.product_name,
       p.product_type,
       p.price
       
   FROM shp.sales s
   LEFT JOIN shp.orders o
       ON s.order_id = o.order_id
   LEFT JOIN shp.products p
       ON s.product_id = p.product_id
   WHERE order_date IS NOT NULL

),

product_aggregations as (
-- 2) Product Aggregations: Summarizes key metrics at the product level
SELECT
    product_id,
    product_name,
    product_type,
    price,
    DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) as lifespan,
    MAX(order_date) as last_sale_date,
    COUNT(DISTINCT order_id) as total_orders,
    COUNT(DISTINCT customer_id) as total_customers,
    SUM(total_price) as total_sales,
    SUM(quantity) as total_quantity,
    ROUND(AVG(CAST(total_price as FLOAT) / NULLIF(quantity, 0)),1) as avg_selling_price
FROM base_query

GROUP BY
    product_id,
    product_name,
    product_type,
    price
)
-- 3) Final Query: Combine all product results into one output
SELECT
    product_id,
    product_name,
    product_type,
    price,
    last_sale_date,
    DATEDIFF(MONTH, last_sale_date, GETDATE()) as recency_in_months,
    CASE
        WHEN total_sales > 1000 THEN 'High-Performer'
        WHEN total_sales >= 500 THEN 'Mid-Range'
        ELSE 'Low-Performer'
    END as product_segment,
    lifespan,
    total_orders,
    total_sales,
    total_quantity,
    total_customers,
    avg_selling_price,
    -- Average Order Revenue (AOR)
    CASE
       WHEN total_orders = 0 THEN 0
       ELSE total_sales / total_orders
    END as avg_order_revenue,
    -- Average Monthly Revenue
    CASE
        WHEN lifespan = 0 THEN total_sales
        ELSE total_sales / lifespan
    END as avg_monthly_revenue

FROM product_aggregations;



















