/*
===============================================================================
Customer Insights Report
===============================================================================
Purpose:
    - To consolidate key customer information and metrics in one view.
    - To segment customers by spending behavior (VIP, Regular, New) and age groups.
    - To summarize transactional data at the customer level.

Highlights:
    1. Retrieves core customer and order details (names, ages, order info, quantities).
    2. Aggregates customer-level metrics:
       - Total orders
       - Total sales
       - Total quantity purchased
       - Number of distinct products
       - Customer lifespan in months
    3. Calculates important KPIs for analysis:
       - Recency (months since last order)
       - Average order value
       - Average monthly spend
===============================================================================
*/


--CUSTOMER REPORT
CREATE VIEW shp.report_customers as

WITH base_query as (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from tables
---------------------------------------------------------------------------*/
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
/*---------------------------------------------------------------------------
2) Customer Aggregations: Summarizes key metrics at the customer level
---------------------------------------------------------------------------*/
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