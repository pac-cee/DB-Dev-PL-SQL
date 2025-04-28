-- Advanced Window Functions Examples

-- 1. FIRST_VALUE and LAST_VALUE
-- Get the highest and lowest salary in each department
SELECT 
    department,
    first_name,
    salary,
    FIRST_VALUE(salary) OVER (
        PARTITION BY department
         ORDER BY salary DESC
    ) as highest_dept_salary,
    LAST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as lowest_dept_salary
FROM employees;

-- 2. LAG and LEAD functions
-- Compare current salary with previous and next employee's salary in same department
SELECT 
    department,
    first_name,
    salary,
    LAG(salary) OVER (PARTITION BY department ORDER BY salary) as prev_salary,
    LEAD(salary) OVER (PARTITION BY department ORDER BY salary) as next_salary
FROM employees;

-- 3. NTILE function
-- Divide employees into 4 salary quartiles
SELECT 
    first_name,
    salary,
    NTILE(4) OVER (ORDER BY salary DESC) as salary_quartile
FROM employees;

-- 4. Cumulative Distribution
SELECT 
    first_name,
    department,
    salary,
    ROUND(
        CUME_DIST() OVER (PARTITION BY department ORDER BY salary),
        3
    ) as salary_percentile
FROM employees;

-- 5. Percent Rank
SELECT 
    first_name,
    department,
    salary,
    ROUND(
        PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary),
        3
    ) as relative_rank
FROM employees;

-- 6. Moving calculations with different frame specifications
SELECT 
    sale_date,
    emp_id,
    sale_amount,
    -- Previous 3 days average
    ROUND(AVG(sale_amount) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING
    ), 2) as prev_3_day_avg,
    -- Next 3 days average
    ROUND(AVG(sale_amount) OVER (
        ORDER BY sale_date 
        ROWS BETWEEN 1 FOLLOWING AND 3 FOLLOWING
    ), 2) as next_3_day_avg,
    -- Running total within a 7-day window
    SUM(sale_amount) OVER (
        ORDER BY sale_date 
        RANGE BETWEEN INTERVAL '3' DAY PRECEDING AND 
                     INTERVAL '3' DAY FOLLOWING
    ) as week_window_total
FROM sales
ORDER BY sale_date;