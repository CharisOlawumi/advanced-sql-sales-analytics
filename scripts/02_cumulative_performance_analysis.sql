/*
===============================================================================
Cumulative Performance Analysis
===============================================================================
Purpose:
    - To evaluate how sales figures accumulate over time.
    - To observe overall growth patterns using running totals.
    - To smooth short-term fluctuations in pricing through moving averages.

Techniques & SQL Functions Used:
    - Window Functions: SUM() OVER(), AVG() OVER()
    - Date Functions: DATETRUNC()
    - Aggregate Functions: SUM(), AVG()
===============================================================================
*/

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
) t