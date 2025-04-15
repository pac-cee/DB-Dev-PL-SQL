-- Solutions to Window Functions Practice Questions

/*
Solution 1: Employees paid more than 1.5x department average
This solution demonstrates using window functions for salary comparison
*/

SELECT 
    department,
    first_name,
    salary,
    ROUND(AVG(salary) OVER (PARTITION BY department), 2) as dept_avg,
    ROUND(salary / AVG(salary) OVER (PARTITION BY department), 2) as ratio_to_avg
FROM employees
WHERE salary > 1.5 * AVG(salary) OVER (PARTITION BY department)
ORDER BY department, salary DESC;

/*
Solution 2: Monthly running totals
This solution shows how to reset running totals periodically
*/

SELECT 
    emp_id,
    sale_date,
    sale_amount,
    EXTRACT(MONTH FROM sale_date) as month,
    EXTRACT(YEAR FROM sale_date) as year,
    SUM(sale_amount) OVER (
        PARTITION BY emp_id, 
                     EXTRACT(YEAR FROM sale_date),
                     EXTRACT(MONTH FROM sale_date)
        ORDER BY sale_date
    ) as monthly_running_total
FROM sales
ORDER BY emp_id, sale_date;

/*
Solution 3: Salary comparison with predecessor and successor
This solution uses multiple window functions to compare values
*/

WITH SalaryComparison AS (
    SELECT 
        first_name,
        department,
        salary,
        hire_date,
        LAG(salary) OVER (PARTITION BY department ORDER BY hire_date) as prev_salary,
        LEAD(salary) OVER (PARTITION BY department ORDER BY hire_date) as next_salary
    FROM employees
)
SELECT 
    first_name,
    department,
    salary,
    hire_date
FROM SalaryComparison
WHERE salary > COALESCE(prev_salary, 0)
  AND salary > COALESCE(next_salary, 0);

/*
Solution 4: Highest paid employee per department per year
This solution combines window functions with row filtering
*/

WITH RankedSalaries AS (
    SELECT 
        first_name,
        department,
        salary,
        EXTRACT(YEAR FROM hire_date) as hire_year,
        RANK() OVER (
            PARTITION BY department, EXTRACT(YEAR FROM hire_date)
            ORDER BY salary DESC
        ) as salary_rank
    FROM employees
)
SELECT 
    hire_year,
    department,
    first_name,
    salary
FROM RankedSalaries
WHERE salary_rank = 1
ORDER BY hire_year, department;

/*
Solution 5: Median salary calculation
This solution shows how to calculate median using window functions
*/

WITH SalaryRanks AS (
    SELECT 
        department,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary) as row_num,
        COUNT(*) OVER (PARTITION BY department) as dept_count
    FROM employees
)
SELECT 
    department,
    ROUND(
        AVG(
            CASE 
                WHEN dept_count % 2 = 0 
                    AND row_num IN (dept_count/2, dept_count/2 + 1) THEN salary
                WHEN dept_count % 2 = 1 
                    AND row_num = (dept_count + 1)/2 THEN salary
            END
        ),
        2
    ) as median_salary
FROM SalaryRanks
GROUP BY department
ORDER BY department;

/*
Bonus Solution: Comprehensive Employee Analysis
This solution combines multiple window functions for deep insights
*/

SELECT 
    e.department,
    e.first_name,
    e.salary,
    e.hire_date,
    -- Ranking metrics
    RANK() OVER (PARTITION BY e.department ORDER BY e.salary DESC) as salary_rank,
    ROUND(
        PERCENT_RANK() OVER (PARTITION BY e.department ORDER BY e.salary),
        3
    ) as salary_percentile,
    
    -- Statistical calculations
    ROUND(AVG(e.salary) OVER (PARTITION BY e.department), 2) as dept_avg,
    ROUND(STDDEV(e.salary) OVER (PARTITION BY e.department), 2) as dept_stddev,
    
    -- Time-based analysis
    ROUND(
        AVG(e.salary) OVER (
            PARTITION BY e.department 
            ORDER BY e.hire_date 
            ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
        ),
        2
    ) as local_salary_avg,
    
    -- Relative comparisons
    ROUND(
        (e.salary - AVG(e.salary) OVER (PARTITION BY e.department)) /
        STDDEV(e.salary) OVER (PARTITION BY e.department),
        2
    ) as z_score,
    
    -- Salary growth analysis
    ROUND(
        (e.salary - FIRST_VALUE(e.salary) OVER (
            PARTITION BY e.department 
            ORDER BY e.hire_date
            ROWS UNBOUNDED PRECEDING
        )) / NULLIF(
            FIRST_VALUE(e.salary) OVER (
                PARTITION BY e.department 
                ORDER BY e.hire_date
                ROWS UNBOUNDED PRECEDING
            ),
            0
        ) * 100,
        2
    ) as pct_growth_from_first
FROM employees e
ORDER BY e.department, e.salary DESC;