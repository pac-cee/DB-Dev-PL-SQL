# PL/SQL Procedures and Functions

## Introduction
Procedures and functions are named PL/SQL blocks that can be stored in the database and reused. They are the building blocks of modular PL/SQL programming.

## 1. Procedures

### Basic Procedure Structure
```sql
CREATE OR REPLACE PROCEDURE procedure_name 
    (parameter1 IN|OUT|IN OUT datatype,
     parameter2 IN|OUT|IN OUT datatype,
     ...)
IS|AS
    -- Declaration section
BEGIN
    -- Executable section
EXCEPTION
    -- Exception section
END procedure_name;
/
```

### Simple Procedure Example
```sql
CREATE OR REPLACE PROCEDURE update_salary
    (p_employee_id IN employees.employee_id%TYPE,
     p_increase_percent IN NUMBER)
IS
BEGIN
    UPDATE employees
    SET salary = salary * (1 + p_increase_percent/100)
    WHERE employee_id = p_employee_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Employee not found');
    END IF;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END update_salary;
/
```

### Procedure with OUT Parameter
```sql
CREATE OR REPLACE PROCEDURE get_employee_info
    (p_employee_id IN employees.employee_id%TYPE,
     p_name OUT VARCHAR2,
     p_salary OUT NUMBER)
IS
BEGIN
    SELECT first_name || ' ' || last_name, salary
    INTO p_name, p_salary
    FROM employees
    WHERE employee_id = p_employee_id;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20002, 'Employee not found');
END get_employee_info;
/
```

## 2. Functions

### Basic Function Structure
```sql
CREATE OR REPLACE FUNCTION function_name
    (parameter1 datatype,
     parameter2 datatype,
     ...)
RETURN return_datatype
IS|AS
    -- Declaration section
BEGIN
    -- Executable section
    RETURN value;
EXCEPTION
    -- Exception section
END function_name;
/
```

### Simple Function Example
```sql
CREATE OR REPLACE FUNCTION calculate_bonus
    (p_salary IN NUMBER,
     p_performance_rating IN VARCHAR2)
RETURN NUMBER
IS
    v_bonus_percent NUMBER;
BEGIN
    v_bonus_percent := CASE p_performance_rating
        WHEN 'A' THEN 20
        WHEN 'B' THEN 15
        WHEN 'C' THEN 10
        ELSE 5
    END;
    
    RETURN (p_salary * v_bonus_percent/100);
END calculate_bonus;
/
```

### Function with Complex Logic
```sql
CREATE OR REPLACE FUNCTION get_employee_level
    (p_employee_id IN employees.employee_id%TYPE)
RETURN VARCHAR2
IS
    v_salary employees.salary%TYPE;
    v_years_of_service NUMBER;
BEGIN
    SELECT salary, TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date)/12)
    INTO v_salary, v_years_of_service
    FROM employees
    WHERE employee_id = p_employee_id;
    
    RETURN CASE
        WHEN v_salary > 20000 OR v_years_of_service > 10 THEN 'SENIOR'
        WHEN v_salary > 10000 OR v_years_of_service > 5 THEN 'MID'
        ELSE 'JUNIOR'
    END;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END get_employee_level;
/
```

## 3. Using Procedures and Functions

### Calling a Procedure
```sql
-- Method 1: Anonymous block
BEGIN
    update_salary(100, 10);  -- Give employee 100 a 10% raise
END;
/

-- Method 2: EXECUTE statement
EXECUTE update_salary(100, 10);

-- Method 3: With OUT parameters
DECLARE
    v_name VARCHAR2(100);
    v_salary NUMBER;
BEGIN
    get_employee_info(100, v_name, v_salary);
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || v_salary);
END;
/
```

### Using Functions
```sql
-- In PL/SQL block
DECLARE
    v_bonus NUMBER;
BEGIN
    v_bonus := calculate_bonus(5000, 'A');
    DBMS_OUTPUT.PUT_LINE('Bonus: ' || v_bonus);
END;
/

-- In SQL statement
SELECT employee_id, 
       first_name,
       salary,
       calculate_bonus(salary, 'A') as bonus
FROM employees;
```

## Practice Exercises

1. Create a procedure to transfer an employee to a new department
2. Write a function to calculate years of service for an employee
3. Create a procedure with both IN and OUT parameters to process salary updates
4. Write a function to determine if an employee is eligible for promotion

## Solutions

### Exercise 1: Employee Transfer Procedure
```sql
CREATE OR REPLACE PROCEDURE transfer_employee
    (p_employee_id IN employees.employee_id%TYPE,
     p_new_dept_id IN departments.department_id%TYPE,
     p_new_job_id IN jobs.job_id%TYPE DEFAULT NULL)
IS
    v_old_dept_id departments.department_id%TYPE;
BEGIN
    -- Get current department
    SELECT department_id
    INTO v_old_dept_id
    FROM employees
    WHERE employee_id = p_employee_id;
    
    -- Update employee
    UPDATE employees
    SET department_id = p_new_dept_id,
        job_id = NVL(p_new_job_id, job_id)
    WHERE employee_id = p_employee_id;
    
    -- Update department counts
    UPDATE dept_employee_count
    SET employee_count = employee_count - 1
    WHERE department_id = v_old_dept_id;
    
    UPDATE dept_employee_count
    SET employee_count = employee_count + 1
    WHERE department_id = p_new_dept_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END transfer_employee;
/
```

### Exercise 2: Years of Service Function
```sql
CREATE OR REPLACE FUNCTION calculate_years_of_service
    (p_employee_id IN employees.employee_id%TYPE)
RETURN NUMBER
IS
    v_years NUMBER;
BEGIN
    SELECT TRUNC(MONTHS_BETWEEN(SYSDATE, hire_date)/12)
    INTO v_years
    FROM employees
    WHERE employee_id = p_employee_id;
    
    RETURN v_years;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
END calculate_years_of_service;
/
```

### Exercise 3: Salary Update Procedure
```sql
CREATE OR REPLACE PROCEDURE process_salary_update
    (p_employee_id IN employees.employee_id%TYPE,
     p_increase_percent IN NUMBER,
     p_old_salary OUT NUMBER,
     p_new_salary OUT NUMBER)
IS
BEGIN
    -- Get current salary
    SELECT salary
    INTO p_old_salary
    FROM employees
    WHERE employee_id = p_employee_id;
    
    -- Calculate and update new salary
    p_new_salary := p_old_salary * (1 + p_increase_percent/100);
    
    UPDATE employees
    SET salary = p_new_salary
    WHERE employee_id = p_employee_id;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Employee not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END process_salary_update;
/
```

### Exercise 4: Promotion Eligibility Function
```sql
CREATE OR REPLACE FUNCTION is_eligible_for_promotion
    (p_employee_id IN employees.employee_id%TYPE)
RETURN BOOLEAN
IS
    v_years_of_service NUMBER;
    v_performance_rating CHAR(1);
    v_current_level VARCHAR2(10);
BEGIN
    -- Get years of service
    v_years_of_service := calculate_years_of_service(p_employee_id);
    
    -- Get performance rating
    SELECT performance_rating
    INTO v_performance_rating
    FROM performance_ratings
    WHERE employee_id = p_employee_id;
    
    -- Get current level
    v_current_level := get_employee_level(p_employee_id);
    
    -- Determine eligibility
    RETURN (v_years_of_service >= 2 AND 
            v_performance_rating IN ('A', 'B') AND
            v_current_level != 'SENIOR');
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN FALSE;
END is_eligible_for_promotion;
/
```

## Key Points to Remember

1. Procedures are used for performing actions (DML operations)
2. Functions must return a value and can be used in SQL statements
3. Use IN parameters for input values
4. Use OUT parameters to return multiple values from procedures
5. Always include proper exception handling
6. Use meaningful parameter names with p_ prefix
7. Keep functions free from DML operations if they'll be used in SQL
8. Use RETURN statement in all possible paths of a function

## Next Steps

After mastering procedures and functions:
1. Learn about packages to group related procedures and functions
2. Study triggers for automatic execution of procedures
3. Explore advanced parameter features
4. Move on to Packages in the next section 