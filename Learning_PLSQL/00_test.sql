-- 1. DDL (Data Definition Language)

-- CREATE commands
CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    salary NUMBER(10,2),
    hire_date DATE DEFAULT SYSDATE
);

-- ALTER commands
ALTER TABLE employees ADD (department VARCHAR2(50));
ALTER TABLE employees MODIFY (name VARCHAR2(150));
ALTER TABLE employees DROP COLUMN department;
ALTER TABLE employees RENAME COLUMN name TO full_name;

-- DROP commands
DROP TABLE employees;
DROP VIEW emp_view;
DROP SEQUENCE emp_seq;

-- TRUNCATE command
TRUNCATE TABLE employees;

-- RENAME command
ALTER TABLE employees RENAME TO staff;
/





2. DML (Data Manipulation Language)

-- INSERT commands
INSERT INTO employees (emp_id, name, salary) 
VALUES (1, 'John Doe', 50000);

INSERT INTO employees 
SELECT * FROM old_employees;

-- UPDATE commands
UPDATE employees 
SET salary = salary * 1.1
WHERE department = 'IT';

-- DELETE commands
DELETE FROM employees 
WHERE salary < 30000;

-- MERGE command
MERGE INTO target_table t
USING source_table s
ON (t.id = s.id)
WHEN MATCHED THEN
    UPDATE SET t.column1 = s.column1
WHEN NOT MATCHED THEN
    INSERT (id, column1) VALUES (s.id, s.column1);





     
--  3.DQL (Data Query Language)
-- Basic SELECT
SELECT * FROM employees;
SELECT name, salary FROM employees;

-- Filtering
SELECT * FROM employees 
WHERE salary > 50000 
AND department = 'IT';

-- Sorting
SELECT * FROM employees 
ORDER BY salary DESC, name ASC;

-- Aggregation
SELECT 
    department,
    COUNT(*) as emp_count,
    AVG(salary) as avg_salary,
    MAX(salary) as max_salary
FROM employees
GROUP BY department
HAVING COUNT(*) > 5;

-- Joins
SELECT e.name, d.dept_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;

LEFT JOIN departments d ON e.dept_id = d.dept_id;
RIGHT JOIN departments d ON e.dept_id = d.dept_id;
FULL OUTER JOIN departments d ON e.dept_id = d.dept_id;

-- Subqueries
SELECT * FROM employees 
WHERE salary > (SELECT AVG(salary) FROM employees);

-- 4. DCL (Data Control Language)
-- Grant permissions
GRANT SELECT, INSERT ON employees TO user1;
GRANT ALL PRIVILEGES ON employees TO user2;

-- Revoke permissions
REVOKE SELECT ON employees FROM user1;
REVOKE ALL PRIVILEGES ON employees FROM user2;

-- Create/alter roles
CREATE ROLE manager_role;
GRANT SELECT, INSERT, UPDATE ON employees TO manager_role;
GRANT manager_role TO user1;

-- Create user
CREATE USER new_user 
IDENTIFIED BY password123;

-- Set quotas
ALTER USER new_user QUOTA 100M ON users;

--5. TCL (Transaction Control Language)
-- Transaction control
COMMIT;
ROLLBACK;
SAVEPOINT save1;
ROLLBACK TO save1;
SET TRANSACTION READ ONLY;

-- 6. Additional Important Commands
-- Sequences
CREATE SEQUENCE emp_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Views
CREATE VIEW emp_dept_view AS
SELECT e.name, d.dept_name
FROM employees e
JOIN departments d ON e.dept_id = d.dept_id;

-- Indexes
CREATE INDEX idx_emp_name ON employees(name);
CREATE UNIQUE INDEX idx_emp_email ON employees(email);

-- Constraints
ALTER TABLE employees ADD CONSTRAINT fk_dept 
    FOREIGN KEY (dept_id) 
    REFERENCES departments(dept_id);

ALTER TABLE employees ADD CONSTRAINT chk_salary 
    CHECK (salary > 0);