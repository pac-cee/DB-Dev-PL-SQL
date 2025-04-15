-- Window Functions Practical Exercises
-- These exercises progress from basic to advanced concepts

/*
Exercise 1: Employee Rankings
Task: Analyze employee salaries within departments
*/

-- 1.1 Create department salary analysis
SELECT 
    department,
    first_name,
    salary,
    -- Basic ranking
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dept_rank,
    -- Percentile within department
    ROUND(
        PERCENT_RANK() OVER (PARTITION BY department ORDER BY salary),
        3
    ) as salary_percentile,
    -- Salary comparison to department average
    ROUND(
        salary / AVG(salary) OVER (PARTITION BY department) * 100,
        2
    ) as pct_of_dept_avg
FROM employees
ORDER BY department, salary DESC;

/*
Exercise 2: Sales Analysis
Task: Calculate various sales metrics
*/

-- 2.1 Sales performance metrics
SELECT 
    sale_date,
    emp_id,
    sale_amount,
    -- Daily comparison
    sale_amount - LAG(sale_amount) OVER (
        PARTITION BY emp_id 
        ORDER BY sale_date
    ) as day_over_day_change,
    -- Running total per employee
    SUM(sale_amount) OVER (
        PARTITION BY emp_id 
        ORDER BY sale_date
    ) as running_total,
    -- 3-day moving average
    ROUND(
        AVG(sale_amount) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
        ),
        2
    ) as moving_avg
FROM sales
ORDER BY emp_id, sale_date;

/*
Exercise 3: Advanced Analytics
Task: Complex window calculations
*/

-- 3.1 Employee salary bands and rankings
WITH SalaryStats AS (
    SELECT 
        department,
        AVG(salary) as avg_salary,
        STDDEV(salary) as stddev_salary
    FROM employees
    GROUP BY department
),
EmployeeAnalysis AS (
    SELECT 
        e.department,
        e.first_name,
        e.salary,
        s.avg_salary,
        s.stddev_salary,
        CASE
            WHEN e.salary > s.avg_salary + s.stddev_salary THEN 'Above Range'
            WHEN e.salary < s.avg_salary - s.stddev_salary THEN 'Below Range'
            ELSE 'Within Range'
        END as salary_range,
        NTILE(4) OVER (PARTITION BY e.department ORDER BY e.salary) as salary_quartile
    FROM employees e
    JOIN SalaryStats s ON e.department = s.department
)
SELECT 
    department,
    first_name,
    salary,
    ROUND(avg_salary, 2) as dept_avg,
    ROUND(stddev_salary, 2) as dept_stddev,
    salary_range,
    salary_quartile,
    COUNT(*) OVER (PARTITION BY department, salary_range) as count_in_range
FROM EmployeeAnalysis
ORDER BY department, salary DESC;

/*
Exercise 4: Time Series Analysis
Task: Analyze sales patterns over time
*/

-- 4.1 Sales trends and patterns
WITH DailySales AS (
    SELECT 
        sale_date,
        SUM(sale_amount) as daily_total
    FROM sales
    GROUP BY sale_date
),
SalesAnalysis AS (
    SELECT 
        sale_date,
        daily_total,
        LAG(daily_total) OVER (ORDER BY sale_date) as prev_day,
        LEAD(daily_total) OVER (ORDER BY sale_date) as next_day,
        AVG(daily_total) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
        ) as weekly_avg,
        MAX(daily_total) OVER (
            ORDER BY sale_date 
            ROWS BETWEEN 30 PRECEDING AND CURRENT ROW
        ) as rolling_30day_high
    FROM DailySales
)
SELECT 
    sale_date,
    daily_total,
    ROUND(
        (daily_total - prev_day) / NULLIF(prev_day, 0) * 100,
        2
    ) as day_over_day_pct_change,
    ROUND(weekly_avg, 2) as seven_day_avg,
    CASE 
        WHEN daily_total = rolling_30day_high THEN 'New 30-Day High'
        ELSE 'Normal Day'
    END as day_type
FROM SalesAnalysis
ORDER BY sale_date;

/*
Practice Questions:
1. How would you identify employees who are paid more than 1.5 times their department's average?
2. Calculate the running total of sales for each employee, but reset the total at the start of each month
3. Find employees whose salary is higher than both their predecessor and successor in terms of hire date
4. Create a report showing the highest paid employee in each department for each year
5. Calculate the median salary for each department using window functions

Solutions are in 07_exercise_solutions.sql
*/