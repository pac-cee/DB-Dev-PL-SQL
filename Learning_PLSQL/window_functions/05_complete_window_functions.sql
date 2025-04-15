-- Complete Window Functions Reference Guide
-- This file covers ALL window functions with examples for Oracle, PostgreSQL, and MySQL

/*
SECTION 1: RANKING FUNCTIONS
- ROW_NUMBER(): Assigns unique sequential numbers
- RANK(): Assigns ranks with gaps for ties
- DENSE_RANK(): Assigns ranks without gaps
- NTILE(): Divides rows into N groups
*/

-- 1.1 Comparison of all ranking functions
SELECT 
    first_name,
    department,
    salary,
    ROW_NUMBER() OVER (ORDER BY salary DESC) as row_num,
    RANK() OVER (ORDER BY salary DESC) as rank_with_gaps,
    DENSE_RANK() OVER (ORDER BY salary DESC) as rank_no_gaps,
    NTILE(4) OVER (ORDER BY salary DESC) as quartile
FROM employees;

/*
SECTION 2: OFFSET FUNCTIONS
- LAG(): Access data from previous rows
- LEAD(): Access data from subsequent rows
- FIRST_VALUE(): Get first value in window
- LAST_VALUE(): Get last value in window
- NTH_VALUE(): Get nth value in window
*/

-- 2.1 Complete offset function comparison
SELECT 
    first_name,
    department,
    salary,
    hire_date,
    LAG(salary) OVER (PARTITION BY department ORDER BY hire_date) as prev_salary,
    LEAD(salary) OVER (PARTITION BY department ORDER BY hire_date) as next_salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY hire_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as first_salary,
    LAST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY hire_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as last_salary,
    NTH_VALUE(salary, 2) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as second_highest_salary
FROM employees;

/*
SECTION 3: STATISTICAL FUNCTIONS
- PERCENT_RANK(): Relative rank (0-1)
- CUME_DIST(): Cumulative distribution
- RATIO_TO_REPORT(): Ratio of value to sum
*/

-- 3.1 Statistical analysis
SELECT 
    first_name,
    department,
    salary,
    ROUND(PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary), 3) as percent_rank,
    ROUND(CUME_DIST() OVER (PARTITION BY department ORDER BY salary), 3) as cume_dist,
    ROUND(
        salary / SUM(salary) OVER (PARTITION BY department),
        3
    ) as ratio_to_dept_total
FROM employees;

/*
SECTION 4: AGGREGATE WINDOW FUNCTIONS
Demonstrates all aggregate functions used as window functions
*/

-- 4.1 Comprehensive aggregates
SELECT 
    first_name,
    department,
    salary,
    COUNT(*) OVER (PARTITION BY department) as dept_count,
    SUM(salary) OVER (PARTITION BY department) as dept_total_salary,
    ROUND(AVG(salary) OVER (PARTITION BY department), 2) as dept_avg_salary,
    MIN(salary) OVER (PARTITION BY department) as dept_min_salary,
    MAX(salary) OVER (PARTITION BY department) as dept_max_salary,
    ROUND(STDDEV(salary) OVER (PARTITION BY department), 2) as dept_salary_stddev,
    ROUND(VARIANCE(salary) OVER (PARTITION BY department), 2) as dept_salary_variance
FROM employees;

/*
SECTION 5: WINDOW FRAMES
Demonstrates different window frame clauses
*/

-- 5.1 Frame types with sales data
SELECT 
    sale_date,
    sale_amount,
    -- Rows based frames
    SUM(sale_amount) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) as running_total_rows,
    
    -- Range based frames
    SUM(sale_amount) OVER (
        ORDER BY sale_date 
        RANGE BETWEEN INTERVAL '3' DAY PRECEDING AND CURRENT ROW
    ) as running_total_range,
    
    -- Unbounded frames
    SUM(sale_amount) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) as running_total_all,
    
    -- Sliding frame
    ROUND(AVG(sale_amount) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ), 2) as centered_avg
FROM sales;

/*
SECTION 6: ADVANCED PATTERNS
Common window function patterns and solutions
*/

-- 6.1 Running totals and moving averages
SELECT 
    sale_date,
    sale_amount,
    SUM(sale_amount) OVER (ORDER BY sale_date) as cumulative_total,
    ROUND(AVG(sale_amount) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 3 PRECEDING AND CURRENT ROW
    ), 2) as moving_avg_4days,
    sale_amount - LAG(sale_amount) OVER (ORDER BY sale_date) as day_over_day_change,
    ROUND(
        (sale_amount - LAG(sale_amount) OVER (ORDER BY sale_date)) / 
        LAG(sale_amount) OVER (ORDER BY sale_date) * 100,
        2
    ) as pct_change
FROM sales;

-- 6.2 Top N per group
WITH RankedEmployees AS (
    SELECT 
        department,
        first_name,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as salary_rank
    FROM employees
)
SELECT *
FROM RankedEmployees
WHERE salary_rank <= 2;

-- 6.3 Percentile calculations
SELECT 
    department,
    first_name,
    salary,
    ROUND(
        CUME_DIST() OVER (PARTITION BY department ORDER BY salary),
        3
    ) as percentile,
    CASE 
        WHEN CUME_DIST() OVER (PARTITION BY department ORDER BY salary) <= 0.25 THEN 'Bottom 25%'
        WHEN CUME_DIST() OVER (PARTITION BY department ORDER BY salary) <= 0.50 THEN '25-50%'
        WHEN CUME_DIST() OVER (PARTITION BY department ORDER BY salary) <= 0.75 THEN '50-75%'
        ELSE 'Top 25%'
    END as quartile_group
FROM employees;

/*
SECTION 7: DATABASE-SPECIFIC VARIATIONS
*/

-- PostgreSQL specific features
/*
-- Exclude current row
SELECT 
    sale_date,
    sale_amount,
    AVG(sale_amount) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING 
        EXCLUDE CURRENT ROW
    ) as avg_excluding_current
FROM sales;

-- Groups frame clause (PostgreSQL 13+)
SELECT 
    department,
    salary,
    AVG(salary) OVER (
        ORDER BY salary
        GROUPS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) as grouped_avg
FROM employees;
*/

-- MySQL specific features
/*
-- MySQL 8.0+ window functions
SELECT 
    sale_date,
    sale_amount,
    -- MySQL's simpler frame clause syntax
    AVG(sale_amount) OVER (
        ORDER BY sale_date
        ROWS 3 PRECEDING
    ) as moving_avg
FROM sales;
*/

-- Oracle specific features
/*
-- Oracle's analytic clause extensions
SELECT 
    department,
    first_name,
    salary,
    LISTAGG(first_name, ', ') WITHIN GROUP (ORDER BY salary DESC) 
        OVER (PARTITION BY department) as dept_employees_list
FROM employees;
*/

/*
SECTION 8: COMMON USE CASES AND PATTERNS
*/

-- 8.1 Year-over-year comparison
SELECT 
    EXTRACT(YEAR FROM sale_date) as year,
    SUM(sale_amount) as total_sales,
    LAG(SUM(sale_amount)) OVER (ORDER BY EXTRACT(YEAR FROM sale_date)) as prev_year_sales,
    ROUND(
        (SUM(sale_amount) - LAG(SUM(sale_amount)) OVER (ORDER BY EXTRACT(YEAR FROM sale_date))) /
        LAG(SUM(sale_amount)) OVER (ORDER BY EXTRACT(YEAR FROM sale_date)) * 100,
        2
    ) as yoy_growth_pct
FROM sales
GROUP BY EXTRACT(YEAR FROM sale_date)
ORDER BY year;