-- Window Functions Tutorial with Examples
-- First, let's create and populate sample tables

-- Create an employees table for our examples
CREATE TABLE employees (
    emp_id NUMBER,
    emp_name VARCHAR2(50),
    department VARCHAR2(50),
    salary NUMBER,
    hire_date DATE
);

-- Insert sample data
INSERT INTO employees VALUES (1, 'John Smith', 'IT', 75000, DATE '2020-01-15');
INSERT INTO employees VALUES (2, 'Mary Johnson', 'IT', 85000, DATE '2019-03-20');
INSERT INTO employees VALUES (3, 'Robert Brown', 'HR', 65000, DATE '2021-06-10');
INSERT INTO employees VALUES (4, 'Patricia Davis', 'HR', 72000, DATE '2020-09-15');
INSERT INTO employees VALUES (5, 'Michael Wilson', 'Finance', 90000, DATE '2018-12-01');
INSERT INTO employees VALUES (6, 'Linda Jones', 'Finance', 82000, DATE '2019-08-25');
INSERT INTO employees VALUES (7, 'James Miller', 'IT', 78000, DATE '2020-04-30');
INSERT INTO employees VALUES (8, 'Elizabeth Taylor', 'HR', 68000, DATE '2021-02-14');

-- 1. ROW_NUMBER, RANK, and DENSE_RANK
-- These functions are used for ranking rows within a partition

SELECT 
    emp_name,
    department,
    salary,
    ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) as row_num,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) as rank_num,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) as dense_rank_num
FROM employees;

-- 2. LAG and LEAD
-- These functions access data from previous or subsequent rows

SELECT 
    emp_name,
    department,
    salary,
    LAG(salary) OVER (PARTITION BY department ORDER BY hire_date) as previous_salary,
    LEAD(salary) OVER (PARTITION BY department ORDER BY hire_date) as next_salary
FROM employees;

-- 3. FIRST_VALUE and LAST_VALUE
-- Get the first and last values in a window

SELECT 
    emp_name,
    department,
    salary,
    FIRST_VALUE(salary) OVER (PARTITION BY department ORDER BY hire_date) as first_salary,
    LAST_VALUE(salary) OVER (
        PARTITION BY department 
        ORDER BY hire_date
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as last_salary
FROM employees;

-- 4. NTH_VALUE
-- Get the nth value in a window

SELECT 
    emp_name,
    department,
    salary,
    NTH_VALUE(salary, 2) OVER (
        PARTITION BY department 
        ORDER BY salary DESC
        RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) as second_highest_salary
FROM employees;

-- 5. NTILE
-- Divide rows into a specified number of groups

SELECT 
    emp_name,
    salary,
    NTILE(4) OVER (ORDER BY salary) as quartile
FROM employees;

-- 6. Aggregate Functions with OVER clause
SELECT 
    emp_name,
    department,
    salary,
    AVG(salary) OVER (PARTITION BY department) as dept_avg_salary,
    SUM(salary) OVER (PARTITION BY department) as dept_total_salary,
    COUNT(*) OVER (PARTITION BY department) as dept_employee_count,
    MAX(salary) OVER (PARTITION BY department) as dept_max_salary,
    MIN(salary) OVER (PARTITION BY department) as dept_min_salary,
    ROUND(salary / SUM(salary) OVER (PARTITION BY department) * 100, 2) as salary_percentage
FROM employees;

-- 7. Running Totals and Moving Averages
SELECT 
    emp_name,
    hire_date,
    salary,
    SUM(salary) OVER (ORDER BY hire_date) as running_total_salary,
    ROUND(AVG(salary) OVER (
        ORDER BY hire_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) as moving_avg_3months
FROM employees;

-- 8. Custom Window Frames
SELECT 
    emp_name,
    department,
    salary,
    ROUND(AVG(salary) OVER (
        PARTITION BY department 
        ORDER BY salary 
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ), 2) as sliding_avg
FROM employees;

-- Comments explaining each section:
/*
1. ROW_NUMBER: Assigns unique numbers (1, 2, 3, ...) to rows within a partition
   RANK: Assigns ranks with gaps for ties (1, 1, 3, ...)
   DENSE_RANK: Assigns ranks without gaps for ties (1, 1, 2, ...)

2. LAG: Accesses data from the previous row
   LEAD: Accesses data from the next row

3. FIRST_VALUE: Returns the first value in the window
   LAST_VALUE: Returns the last value in the window

4. NTH_VALUE: Returns the nth value in the window

5. NTILE: Divides rows into approximately equal groups

6. Aggregate Functions with OVER:
   - Shows how to use standard aggregate functions as window functions
   - Calculates department-level statistics alongside individual rows

7. Running Totals:
   - Demonstrates cumulative sums
   - Shows moving averages over 3-row windows

8. Custom Window Frames:
   - Shows how to define custom window frames
   - Calculates average of current row plus one row before and after
*/