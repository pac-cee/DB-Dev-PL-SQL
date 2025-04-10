/*
 * Analytical SQL Queries for Employee Analysis
 * Purpose: Demonstrate the use of various window functions and analytical features
 * Author: [Your Name]
 * Date: April 10, 2025
 */

-- 1. Salary Comparison Analysis
-- This query compares each employee's salary with the previous and next salary in the ordered list
-- Using LAG and LEAD window functions for salary comparison
SELECT 
    employee_id,
    salary,
    LAG(salary) OVER (ORDER BY salary) AS previous_salary, -- Gets the previous salary in the ordered list
    CASE 
        WHEN salary > LAG(salary) OVER (ORDER BY salary) THEN 'HIGHER'
        WHEN salary < LAG(salary) OVER (ORDER BY salary) THEN 'LOWER'
        ELSE 'EQUAL'
    END AS comparison_with_previous, -- Compares current salary with previous
    LEAD(salary) OVER (ORDER BY salary) AS next_salary -- Gets the next salary in the ordered list
FROM employees;

-- 2. Department-wise Salary Ranking
-- This query ranks employees within their departments based on salary
-- Demonstrates the difference between RANK and DENSE_RANK
SELECT 
    employee_id,
    department,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank, -- Includes gaps in ranking
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_salary_rank -- No gaps in ranking
FROM employees;

-- 3. Top 3 Earners by Department
-- Common Table Expression (CTE) to find the top 3 highest paid employees in each department
-- Uses ROW_NUMBER for unique ranking within departments
WITH RankedEmployees AS (
    SELECT 
        employee_id,
        department,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn -- Assigns unique numbers within each department
    FROM employees
)
SELECT 
    employee_id, 
    department, 
    salary
FROM RankedEmployees
WHERE rn <= 3; -- Filters to show only top 3

-- 4. First Two Employees to Join Each Department
-- CTE to identify the two earliest employees in each department based on join date
WITH EarliestEmployees AS (
    SELECT 
        employee_id,
        department,
        join_date,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY join_date ASC) AS rn -- Ranks by join date
    FROM employees
)
SELECT 
    employee_id, 
    department, 
    join_date
FROM EarliestEmployees
WHERE rn <= 2; -- Shows only the first two employees

-- 5. Salary Comparison with Department and Overall Maximum
-- Compares individual salaries with department maximum and company-wide maximum
SELECT 
    employee_id,
    department,
    salary,
    MAX(salary) OVER (PARTITION BY department) AS max_dept_salary, -- Maximum salary within each department
    MAX(salary) OVER () AS overall_max_salary -- Maximum salary across all departments
FROM employees;

/*
 * Key Concepts Demonstrated:
 * 1. Window Functions: LAG, LEAD, RANK, DENSE_RANK, ROW_NUMBER
 * 2. Common Table Expressions (CTEs)
 * 3. PARTITION BY for departmental analysis
 * 4. CASE expressions for conditional logic
 * 5. Aggregate functions with OVER clause
 */