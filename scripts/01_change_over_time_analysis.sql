/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To analyze how key business metrics change across different time periods.
    - To evaluate trends in sales performance and customer activity over time.
    - To support flexible time-based analysis across multiple date granularities.

Techniques & SQL Functions Used:
    - JOIN Operations
    - Date Functions: YEAR(), MONTH(), DATETRUNC()
    - Aggregate Functions: SUM(), COUNT(DISTINCT)
    - Ordering: ORDER BY
===============================================================================
*/

-- Analyse sales performance over time
-- Quick Date Functions
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

-- DATETRUNC()
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
