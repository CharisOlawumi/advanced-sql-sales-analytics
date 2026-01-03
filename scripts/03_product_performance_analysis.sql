/*
===============================================================================
Product Performance Comparison Analysis
===============================================================================
Purpose:
    - To evaluate how individual products perform across consecutive time
      periods.
    - To compare current sales results against each product’s typical sales
      level.
    - To highlight short-term increases or declines in product performance.

Techniques & SQL Functions Used:
    - Window Functions: LAG(), AVG() OVER()
    - Conditional Logic: CASE
    - Date Functions: MONTH()
    - Aggregations: SUM()
===============================================================================
*/


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
    -- Month-over-Month Analysis
    LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) as py_sales,
    current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) as diff_py,
    CASE 
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) > 0 THEN 'Increase'
        WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_month) < 0 THEN 'Decrease'
        ELSE 'No Change'
    END py_change
FROM monthly_product_sales
ORDER BY product_name, order_month;