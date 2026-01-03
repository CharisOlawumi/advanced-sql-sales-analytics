/*
===============================================================================
Product Insights Report
===============================================================================
Purpose:
    - To consolidate key product metrics and transactional behavior in one view.
    - To segment products by revenue performance (High-Performer, Mid-Range, Low-Performer).
    - To summarize product activity and provide actionable KPIs for analysis.

Highlights:
    1. Retrieves core product and sales information (product name, type, price, order details).
    2. Aggregates metrics at the product level:
       - Total orders
       - Total sales
       - Total quantity sold
       - Unique customers
       - Product lifespan in months
    3. Calculates key performance indicators:
       - Recency (months since last sale)
       - Average order revenue (AOR)
       - Average monthly revenue
===============================================================================
*/


--PRODUCT REPORT
CREATE VIEW shp.report_products as

WITH base_query as (
/*---------------------------------------------------------------------------
1) Base Query: Retrieves core columns from sales and products
---------------------------------------------------------------------------*/
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
/*---------------------------------------------------------------------------
2) Product Aggregations: Summarizes key metrics at the product level
---------------------------------------------------------------------------*/
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

/*---------------------------------------------------------------------------
3) Final Query: Combine all product results into one output
---------------------------------------------------------------------------*/
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
