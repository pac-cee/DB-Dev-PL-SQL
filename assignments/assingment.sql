SELECT 
    employee_id,
    salary,
    LAG(salary) OVER (ORDER BY salary) AS previous_salary,
    CASE 
        WHEN salary > LAG(salary) OVER (ORDER BY salary) THEN 'HIGHER'
        WHEN salary < LAG(salary) OVER (ORDER BY salary) THEN 'LOWER'
        ELSE 'EQUAL'
    END AS comparison_with_previous,
    LEAD(salary) OVER (ORDER BY salary) AS next_salary
FROM employees;



SELECT 
    employee_id,
    department,
    salary,
    RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS salary_rank,
    DENSE_RANK() OVER (PARTITION BY department ORDER BY salary DESC) AS dense_salary_rank
FROM employees;


WITH RankedEmployees AS (
    SELECT 
        employee_id,
        department,
        salary,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY salary DESC) AS rn
    FROM employees
)
SELECT 
    employee_id, 
    department, 
    salary
FROM RankedEmployees
WHERE rn <= 3;


WITH EarliestEmployees AS (
    SELECT 
        employee_id,
        department,
        join_date,
        ROW_NUMBER() OVER (PARTITION BY department ORDER BY join_date ASC) AS rn
    FROM employees
)
SELECT 
    employee_id, 
    department, 
    join_date
FROM EarliestEmployees
WHERE rn <= 2;




SELECT 
    employee_id,
    department,
    salary,
    MAX(salary) OVER (PARTITION BY department) AS max_dept_salary,
    MAX(salary) OVER () AS overall_max_salary
FROM employees;