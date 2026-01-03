# Sales Analytics SQL Project

## Overview

This repository contains a comprehensive **SQL-based sales analytics project** designed to provide actionable insights into customer behavior, product performance, and overall business trends. It demonstrates advanced SQL techniques including **window functions, aggregations, joins, subqueries, and CTEs**, while generating reports suitable for business intelligence and portfolio purposes.

The project is organized into multiple analyses covering **time trends, cumulative performance, product and customer insights, and proportional segmentation**.

---

## Project Structure

| Module                     | Description                                                                                                                                  |
| -------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------- |
| `change_over_time.sql`     | Tracks changes in sales, customer activity, and quantities over time using CTEs and subqueries.                                              |
| `cumulative_analysis.sql`  | Computes running totals and moving averages to monitor cumulative growth trends using subqueries and window functions.                       |
| `performance_analysis.sql` | Compares product performance to historical averages and previous periods using CTEs and window functions to identify increases or decreases. |
| `part_to_whole.sql`        | Performs proportional analysis to show how different product categories contribute to total sales.                                           |
| `data_segmentation.sql`    | Segments products and customers into meaningful categories based on price or spending behavior using CASE statements and GROUP BY.           |
| `report_customers.sql`     | Creates a **Customer Insights Report** with key KPIs and segments, using nested CTEs.                                                        |
| `report_products.sql`      | Creates a **Product Insights Report** with aggregated metrics and revenue-based segments, leveraging CTEs and subqueries.                    |

---

## Key Analyses

### 1. Change Over Time Analysis

* Purpose: Analyze how sales, customers, and product quantities evolve across different time periods.
* Techniques:

  * RIGHT JOINs between sales and orders
  * Date functions: `YEAR()`, `MONTH()`, `DATETRUNC()`
  * Aggregations: `SUM()`, `COUNT(DISTINCT)`
  * Subqueries for monthly aggregations
  * CTEs optional for organizing intermediate results

### 2. Cumulative Performance Analysis

* Purpose: Monitor cumulative growth trends and smooth short-term fluctuations.
* Techniques:

  * Window functions: `SUM() OVER()`, `AVG() OVER()`
  * Aggregations: `SUM()`, `AVG()`
  * Subqueries to calculate period-level totals and averages
  * CTEs for structuring complex queries

### 3. Product Performance Comparison

* Purpose: Compare product sales against historical averages and previous periods.
* Techniques:

  * CTEs to generate monthly product sales
  * Window functions: `LAG()`, `AVG() OVER()`
  * Conditional logic: `CASE`
  * Aggregation: `SUM()`
  * Date function: `MONTH()`

### 4. Part-to-Whole (Proportional) Analysis

* Purpose: Understand category-level contributions to overall sales.
* Techniques:

  * Aggregations: `SUM()`, `AVG()`
  * Window function: `SUM() OVER()`
  * Percentage calculations

### 5. Data Segmentation

* Purpose: Segment products and customers into meaningful categories for targeted analysis.
* Techniques:

  * Conditional logic: `CASE`
  * Aggregations: `SUM()`, `COUNT()`
  * Date functions: `DATEDIFF()`

### 6. Customer Insights Report

* Purpose: Consolidates key customer metrics, behavior, and KPIs.
* Highlights:

  * Segmentation by age and spending behavior (VIP, Regular, New)
  * Metrics: total orders, total sales, quantity, products purchased, lifespan
  * KPIs: recency, average order value, average monthly spend
  * Uses nested CTEs for base query and aggregation

### 7. Product Insights Report

* Purpose: Consolidates key product metrics and revenue performance.
* Highlights:

  * Revenue-based segmentation: High-Performer, Mid-Range, Low-Performer
  * Metrics: total orders, total sales, quantity sold, unique customers, lifespan
  * KPIs: recency, average order revenue, average monthly revenue
  * Leverages CTEs and subqueries for structured aggregation

---

## SQL Techniques Demonstrated

* **Joins:** `LEFT JOIN`, `RIGHT JOIN`
* **Window Functions:** `SUM() OVER()`, `AVG() OVER()`, `LAG()`
* **Conditional Logic:** `CASE` statements for segmentation and trend analysis
* **Aggregations:** `SUM()`, `AVG()`, `COUNT()`, `COUNT(DISTINCT)`
* **Date Functions:** `YEAR()`, `MONTH()`, `DATETRUNC()`, `DATEDIFF()`
* **Subqueries:** Nested queries for intermediate calculations
* **CTEs:** For organizing multi-step aggregations and calculations
* **Views:** Creation of consolidated customer and product reports

---

## How to Use

1. Load your sales, orders, products, and customers tables into a database (schema: `shp`).
2. Execute each SQL script in the order of dependency:

   1. `change_over_time.sql`
   2. `cumulative_analysis.sql`
   3. `performance_analysis.sql`
   4. `part_to_whole.sql`
   5. `data_segmentation.sql`
   6. `report_customers.sql`
   7. `report_products.sql`
3. Query the generated views (`shp.report_customers` and `shp.report_products`) for consolidated insights.

---

## Project Highlights

* Demonstrates **end-to-end SQL analytics** workflow from raw transactional data to high-level reporting.
* Uses **advanced SQL techniques** suitable for business intelligence and data analytics portfolios.
* Fully documented with **purpose, techniques, and KPIs**, highlighting use of **CTEs and subqueries**.

---

## Recommended Usage

* Can be adapted for **monthly, quarterly, or yearly trend analysis**.
* Supports **product and customer segmentation**, useful for marketing or sales strategy.
* Easily extendable to **regional, category, or other dimensions** for deeper insights.

---

## Author

[Charis Olawumi] – SQL Data Analytics Portfolio
