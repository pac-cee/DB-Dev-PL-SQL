-- 1. DDL (Data Definition Language)
alter session set container = PACIFIQUE;
-- CREATE commands
CREATE TABLE employees (
    emp_id NUMBER PRIMARY KEY,
    name VARCHAR2(100),
    salary NUMBER(10,2),
    hire_date DATE DEFAULT SYSDATE
);

select * from employees;
drop table employees;

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



CREATE OR REPLACE PACKAGE emp_mgmt_pkg IS
  -- Public constants
  c_min_salary CONSTANT NUMBER := 30000;
  c_max_salary CONSTANT NUMBER := 150000;
  
  -- Public types
  TYPE emp_record_type IS RECORD (
    emp_id    employees.emp_id%TYPE,
    full_name employees.full_name%TYPE,
    salary    employees.salary%TYPE
  );
  
  -- Collection types
  TYPE emp_table_type IS TABLE OF emp_record_type INDEX BY PLS_INTEGER;
  
  -- Function declarations
  FUNCTION get_employee_salary(p_emp_id IN NUMBER) RETURN NUMBER;
  FUNCTION calculate_bonus(p_salary IN NUMBER, p_years_service IN NUMBER) RETURN NUMBER;
  
  -- Procedure declarations
  PROCEDURE update_employee_salary(
    p_emp_id IN NUMBER,
    p_new_salary IN NUMBER,
    p_effective_date IN DATE DEFAULT SYSDATE
  );
  
  PROCEDURE bulk_update_salaries(
    p_department_id IN NUMBER,
    p_increase_percent IN NUMBER
  );
END emp_mgmt_pkg;
/

CREATE OR REPLACE PACKAGE BODY emp_mgmt_pkg IS
  -- Private variables
  v_last_updated_by VARCHAR2(30);
  
  -- Private procedures
  PROCEDURE log_salary_change(
    p_emp_id IN NUMBER,
    p_old_salary IN NUMBER,
    p_new_salary IN NUMBER
  ) IS
  BEGIN
    INSERT INTO salary_change_log (
      emp_id, old_salary, new_salary, change_date, changed_by
    ) VALUES (
      p_emp_id, p_old_salary, p_new_salary, SYSDATE, v_last_updated_by
    );
  END log_salary_change;

  -- Function implementations
  FUNCTION get_employee_salary(p_emp_id IN NUMBER) RETURN NUMBER IS
    v_salary employees.salary%TYPE;
  BEGIN
    SELECT salary INTO v_salary
    FROM employees
    WHERE emp_id = p_emp_id;
    
    RETURN v_salary;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RAISE_APPLICATION_ERROR(-20001, 'Employee ID ' || p_emp_id || ' not found');
  END get_employee_salary;

  FUNCTION calculate_bonus(
    p_salary IN NUMBER, 
    p_years_service IN NUMBER
  ) RETURN NUMBER IS
    v_bonus_percent NUMBER;
  BEGIN
    v_bonus_percent := CASE
      WHEN p_years_service < 2 THEN 0.05
      WHEN p_years_service < 5 THEN 0.10
      WHEN p_years_service < 10 THEN 0.15
      ELSE 0.20
    END;
    
    RETURN ROUND(p_salary * v_bonus_percent, 2);
  END calculate_bonus;

  -- Procedure implementations
  PROCEDURE update_employee_salary(
    p_emp_id IN NUMBER,
    p_new_salary IN NUMBER,
    p_effective_date IN DATE DEFAULT SYSDATE
  ) IS
    v_old_salary employees.salary%TYPE;
  BEGIN
    -- Input validation
    IF p_new_salary < c_min_salary OR p_new_salary > c_max_salary THEN
      RAISE_APPLICATION_ERROR(-20002, 'Salary must be between ' || 
        c_min_salary || ' and ' || c_max_salary);
    END IF;
    
    -- Get current salary
    v_old_salary := get_employee_salary(p_emp_id);
    
    -- Update salary
    UPDATE employees
    SET salary = p_new_salary,
        last_updated_date = p_effective_date
    WHERE emp_id = p_emp_id;
    
    -- Log the change
    log_salary_change(p_emp_id, v_old_salary, p_new_salary);
    
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END update_employee_salary;

  PROCEDURE bulk_update_salaries(
    p_department_id IN NUMBER,
    p_increase_percent IN NUMBER
  ) IS
    -- Declare cursor
    CURSOR c_emp_salaries IS
      SELECT emp_id, salary
      FROM employees
      WHERE department_id = p_department_id
      FOR UPDATE OF salary;
    
    -- Collection to store updates
    v_updates emp_table_type;
    v_count PLS_INTEGER := 0;
  BEGIN
    -- Validate input
    IF p_increase_percent < 0 OR p_increase_percent > 25 THEN
      RAISE_APPLICATION_ERROR(-20003, 'Increase percentage must be between 0 and 25');
    END IF;
    
    -- Bulk collect and process
    FOR emp_rec IN c_emp_salaries LOOP
      v_count := v_count + 1;
      v_updates(v_count).emp_id := emp_rec.emp_id;
      v_updates(v_count).salary := emp_rec.salary * (1 + p_increase_percent/100);
      
      -- Update in batches of 100
      IF v_count = 100 THEN
        FORALL i IN 1..v_count
          UPDATE employees
          SET salary = v_updates(i).salary
          WHERE emp_id = v_updates(i).emp_id;
        
        v_count := 0;
      END IF;
    END LOOP;
    
    -- Process remaining records
    IF v_count > 0 THEN
      FORALL i IN 1..v_count
        UPDATE employees
        SET salary = v_updates(i).salary
        WHERE emp_id = v_updates(i).emp_id;
    END IF;
    
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      RAISE;
  END bulk_update_salaries;

BEGIN
  -- Package initialization
  v_last_updated_by := SYS_CONTEXT('USERENV', 'SESSION_USER');
END emp_mgmt_pkg;
/

----2.advanced trigger example 

CREATE OR REPLACE TRIGGER trg_employee_audit
  AFTER INSERT OR UPDATE OR DELETE ON employees
  FOR EACH ROW
DECLARE
  v_action VARCHAR2(10);
  v_changed_fields XMLTYPE;
BEGIN
  -- Determine action type
  v_action := CASE
    WHEN INSERTING THEN 'INSERT'
    WHEN UPDATING THEN 'UPDATE'
    WHEN DELETING THEN 'DELETE'
  END;

  -- Build XML of changed fields for updates
  IF UPDATING THEN
    SELECT XMLELEMENT("changes",
      CASE WHEN :NEW.salary != :OLD.salary 
        THEN XMLELEMENT("salary", 
          XMLELEMENT("old", :OLD.salary),
          XMLELEMENT("new", :NEW.salary))
      END,
      CASE WHEN :NEW.department_id != :OLD.department_id 
        THEN XMLELEMENT("department", 
          XMLELEMENT("old", :OLD.department_id),
          XMLELEMENT("new", :NEW.department_id))
      END
    ) INTO v_changed_fields
    FROM dual;
  END IF;

  -- Insert audit record
  INSERT INTO employee_audit (
    audit_id,
    action_type,
    action_date,
    emp_id,
    changed_by,
    changed_fields
  ) VALUES (
    audit_seq.NEXTVAL,
    v_action,
    SYSTIMESTAMP,
    :NEW.emp_id,
    SYS_CONTEXT('USERENV', 'SESSION_USER'),
    v_changed_fields
  );
END;
/

-- 3. Advanced PL/SQL fucntion with custom types and exception handling 
-- Create custom types
CREATE TYPE address_type AS OBJECT (
  street VARCHAR2(100),
  city VARCHAR2(50),
  state VARCHAR2(2),
  zip VARCHAR2(10)
);
/

CREATE TYPE employee_details_type AS OBJECT (
  emp_id NUMBER,
  full_name VARCHAR2(100),
  address address_type,
  department VARCHAR2(50),
  salary NUMBER,
  hire_date DATE
);
/

-- Create table of type
CREATE TYPE employee_details_table AS TABLE OF employee_details_type;
/

-- Create function that returns complex data
CREATE OR REPLACE FUNCTION get_department_employees(
  p_dept_id IN NUMBER,
  p_include_inactive IN BOOLEAN DEFAULT FALSE
) RETURN employee_details_table 
  PIPELINED
  AUTHID CURRENT_USER
IS
  v_address address_type;
  v_employee employee_details_type;
  
  -- Custom exception
  e_invalid_department EXCEPTION;
  PRAGMA EXCEPTION_INIT(e_invalid_department, -20100);
BEGIN
  -- Validate department
  IF NOT department_exists(p_dept_id) THEN
    RAISE e_invalid_department;
  END IF;

  -- Cursor for employee processing
  FOR emp_rec IN (
    SELECT e.emp_id, e.full_name, e.salary, e.hire_date,
           e.street_address, e.city, e.state, e.zip_code,
           d.department_name
    FROM employees e
    JOIN departments d ON e.department_id = d.department_id
    WHERE e.department_id = p_dept_id
    AND (p_include_inactive = TRUE OR e.active_flag = 'Y')
  ) LOOP
    -- Create address object
    v_address := address_type(
      emp_rec.street_address,
      emp_rec.city,
      emp_rec.state,
      emp_rec.zip_code
    );
    
    -- Create employee details object
    v_employee := employee_details_type(
      emp_rec.emp_id,
      emp_rec.full_name,
      v_address,
      emp_rec.department_name,
      emp_rec.salary,
      emp_rec.hire_date
    );
    
    -- Pipeline the result
    PIPE ROW(v_employee);
  END LOOP;
  
  RETURN;
EXCEPTION
  WHEN e_invalid_department THEN
    RAISE_APPLICATION_ERROR(-20100, 'Invalid department ID: ' || p_dept_id);
  WHEN OTHERS THEN
    -- Log error
    log_error(SQLCODE, SQLERRM, 'get_department_employees');
    RAISE;
END get_department_employees;
/


--usage of example
-- Using the package
BEGIN
  -- Update single employee salary
  emp_mgmt_pkg.update_employee_salary(
    p_emp_id => 1001,
    p_new_salary => 75000
  );
  
  -- Bulk update department salaries
  emp_mgmt_pkg.bulk_update_salaries(
    p_department_id => 50,
    p_increase_percent => 5
  );
END;
/

-- Using the complex function
SELECT e.emp_id, e.full_name, 
       e.address.city as city,
       e.department,
       e.salary
FROM TABLE(get_department_employees(50, TRUE)) e
WHERE e.salary > 50000
ORDER BY e.salary DESC
FETCH FIRST 10 ROWS ONLY;
/



/*
Let's dive into advanced PL/SQL concepts with practical examples. I'll cover exception handling, functions, procedures, packages, and best practices.

### 1. Advanced Exception Handling

#### a. User-Defined Exceptions
```plsql
DECLARE
  negative_salary EXCEPTION;
  PRAGMA EXCEPTION_INIT(negative_salary, -20001);
  v_salary NUMBER := -5000;
BEGIN
  IF v_salary < 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Salary cannot be negative');
  END IF;
EXCEPTION
  WHEN negative_salary THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    ROLLBACK;
END;
/
```

#### b. Bulk Operation Exceptions (FORALL SAVE EXCEPTIONS)
```plsql
DECLARE
  TYPE emp_table IS TABLE OF employees%ROWTYPE;
  v_emps emp_table;
  
  ex_dml_errors EXCEPTION;
  PRAGMA EXCEPTION_INIT(ex_dml_errors, -24381);
BEGIN
  SELECT * BULK COLLECT INTO v_emps FROM employees;
  
  -- Intentionally create duplicate ID error
  FORALL i IN 1..v_emps.COUNT SAVE EXCEPTIONS
    INSERT INTO employees VALUES v_emps(i);
  
EXCEPTION
  WHEN ex_dml_errors THEN
    DBMS_OUTPUT.PUT_LINE('Number of errors: ' || SQL%BULK_EXCEPTIONS.COUNT);
    FOR j IN 1..SQL%BULK_EXCEPTIONS.COUNT LOOP
      DBMS_OUTPUT.PUT_LINE('Error ' || j || ': Index ' 
        || SQL%BULK_EXCEPTIONS(j).ERROR_INDEX || ' - Code ' 
        || SQL%BULK_EXCEPTIONS(j).ERROR_CODE);
    END LOOP;
END;
/
```

### 2. Advanced Functions

#### a. Deterministic Function
```plsql
CREATE OR REPLACE FUNCTION calculate_tax(
  p_salary NUMBER
) RETURN NUMBER DETERMINISTIC
IS
BEGIN
  RETURN p_salary * 0.2; -- 20% tax
END;
/

-- Usage in SQL
SELECT employee_id, calculate_tax(salary) AS tax
FROM employees;
```

#### b. Result-Cached Function
```plsql
CREATE OR REPLACE FUNCTION get_department_name(
  p_dept_id NUMBER
) RETURN VARCHAR2 RESULT_CACHE
IS
  v_dept_name departments.department_name%TYPE;
BEGIN
  SELECT department_name INTO v_dept_name
  FROM departments
  WHERE department_id = p_dept_id;
  
  RETURN v_dept_name;
END;
/
```

### 3. Advanced Procedures

#### a. Transaction Control
```plsql
CREATE OR REPLACE PROCEDURE update_salary(
  p_emp_id IN NUMBER,
  p_new_salary IN NUMBER
)
IS
BEGIN
  UPDATE employees
  SET salary = p_new_salary
  WHERE employee_id = p_emp_id;
  
  -- Explicit commit
  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/
```

#### b. Autonomous Transaction (For Logging)
```plsql
CREATE OR REPLACE PROCEDURE log_error(
  p_error_message VARCHAR2
) 
IS
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
  INSERT INTO error_log (error_date, error_message)
  VALUES (SYSDATE, p_error_message);
  
  COMMIT;
END;
/

-- Usage in main procedure
CREATE OR REPLACE PROCEDURE process_order IS
BEGIN
  -- Business logic here
  ...
EXCEPTION
  WHEN OTHERS THEN
    log_error(SQLERRM);
    RAISE;
END;
/
```

### 4. Packages

#### a. Package Specification
```plsql
CREATE OR REPLACE PACKAGE emp_pkg AS
  -- Global constant
  g_max_salary CONSTANT NUMBER := 100000;
  
  -- Function declaration
  FUNCTION get_employee_name(p_emp_id NUMBER) RETURN VARCHAR2;
  
  -- Procedure declaration
  PROCEDURE update_salary(p_emp_id NUMBER, p_new_salary NUMBER);
END emp_pkg;
/
```

#### b. Package Body
```plsql
CREATE OR REPLACE PACKAGE BODY emp_pkg AS
  -- Private variable
  v_audit_enabled BOOLEAN := TRUE;
  
  FUNCTION get_employee_name(p_emp_id NUMBER) RETURN VARCHAR2 IS
    v_full_name VARCHAR2(100);
  BEGIN
    SELECT first_name || ' ' || last_name
    INTO v_full_name
    FROM employees
    WHERE employee_id = p_emp_id;
    
    RETURN v_full_name;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      RETURN NULL;
  END;
  
  PROCEDURE update_salary(p_emp_id NUMBER, p_new_salary NUMBER) IS
  BEGIN
    IF p_new_salary > g_max_salary THEN
      RAISE_APPLICATION_ERROR(-20002, 'Salary exceeds maximum allowed');
    END IF;
    
    UPDATE employees
    SET salary = p_new_salary
    WHERE employee_id = p_emp_id;
    
    IF v_audit_enabled THEN
      INSERT INTO salary_audit 
      VALUES (p_emp_id, p_new_salary, SYSDATE, USER);
    END IF;
    
    COMMIT;
  END;
END emp_pkg;
/
```

### 5. Best Practices

1. **Error Handling**:
   - Always handle `NO_DATA_FOUND` and `TOO_MANY_ROWS` exceptions
   - Use `RAISE_APPLICATION_ERROR` for business rule violations
   - Log errors before re-raising them

2. **Parameter Modes**:
   - Use `IN` parameters for input-only values
   - Use `OUT` parameters sparingly - prefer function returns
   - Use `NOCOPY` hint for large `OUT` parameters
   ```plsql
   PROCEDURE process_data(
     p_input IN CLOB,
     p_output OUT NOCOPY CLOB
   )
   ```

3. **Performance**:
   - Use bulk operations (BULK COLLECT, FORALL) for batch processing
   - Use result-cached functions for frequently called, static data
   - Avoid context switching between SQL and PL/SQL engines

4. **Security**:
   - Use invoker's rights (`AUTHID CURRENT_USER`) when appropriate
   - Sanitize inputs to prevent SQL injection
   - Encrypt sensitive data in packages

### 6. Advanced Exception Propagation

```plsql
CREATE OR REPLACE PROCEDURE outer_proc IS
  e_custom_error EXCEPTION;
  
  PROCEDURE inner_proc IS
  BEGIN
    RAISE e_custom_error;
  END;
  
BEGIN
  inner_proc;
EXCEPTION
  WHEN e_custom_error THEN
    DBMS_OUTPUT.PUT_LINE('Custom error handled at outer level');
    log_error('Custom error occurred');
    RAISE;  -- Re-raise to calling environment
END;
/
```

This structure demonstrates how exceptions bubble up through nested procedures until handled or reach the calling environment.

Practice these concepts by:
1. Creating a package for employee management
2. Implementing complex business rules with error logging
3. Using bulk operations for data migration tasks
4. Creating result-cached functions for frequently accessed reference data

Remember to always test your code with both expected and unexpected input values, and consider edge cases in your exception handling.
*/