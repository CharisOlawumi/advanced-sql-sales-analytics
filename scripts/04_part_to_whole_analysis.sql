/*
===============================================================================
Part-to-Whole (Proportional) Analysis
===============================================================================
Purpose:
    - To compare performance across categories and see how each contributes
      to overall sales.
    - To highlight differences between product types.
    - Useful for understanding key contributors and supporting business decisions.

Techniques & SQL Functions Used:
    - Aggregate Functions: SUM(), AVG()
    - Window Functions: SUM() OVER() for overall totals
    - Percentage Calculations for proportional analysis
===============================================================================
*/

-- Categories that contribute the most to the overall sales
WITH product_type_sales as (
    SELECT
        product_type,
        SUM(total_price) total_sales
    FROM shp.sales s
    LEFT JOIN shp.products p
        ON s.product_id = p.product_id
    GROUP BY product_type
 )
 SELECT
     product_type,
     total_sales,
     SUM(total_sales) OVER () overall_sales,
     CONCAT(ROUND((CAST (total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') as percentage_of_total
 FROM product_type_sales
 ORDER BY total_sales DESC;