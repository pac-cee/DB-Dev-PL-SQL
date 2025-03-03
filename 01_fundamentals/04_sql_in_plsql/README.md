# SQL in PL/SQL

## Introduction
PL/SQL seamlessly integrates SQL statements within its procedural constructs. This integration is one of PL/SQL's most powerful features.

## 1. SELECT INTO Statement

### Single Row SELECT
```sql
DECLARE
    v_employee_name employees.first_name%TYPE;
    v_salary        employees.salary%TYPE;
BEGIN
    SELECT first_name, salary
    INTO v_employee_name, v_salary
    FROM employees
    WHERE employee_id = 100;
    
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_employee_name);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || v_salary);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee not found');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Multiple employees found');
END;
/
```

### Using %ROWTYPE
```sql
DECLARE
    v_emp_record employees%ROWTYPE;
BEGIN
    SELECT *
    INTO v_emp_record
    FROM employees
    WHERE employee_id = 100;
    
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_emp_record.first_name);
    DBMS_OUTPUT.PUT_LINE('Salary: ' || v_emp_record.salary);
END;
/
```

## 2. DML Operations

### INSERT Statement
```sql
DECLARE
    v_emp_id employees.employee_id%TYPE := 1000;
BEGIN
    INSERT INTO employees (
        employee_id,
        first_name,
        last_name,
        email,
        hire_date,
        job_id
    ) VALUES (
        v_emp_id,
        'John',
        'Doe',
        'JDOE',
        SYSDATE,
        'IT_PROG'
    );
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
```

### UPDATE Statement
```sql
DECLARE
    v_salary_increase NUMBER := 1000;
BEGIN
    UPDATE employees
    SET salary = salary + v_salary_increase
    WHERE department_id = 60;
    
    IF SQL%ROWCOUNT > 0 THEN
        DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' employees updated');
        COMMIT;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No employees updated');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
```

### DELETE Statement
```sql
DECLARE
    v_dept_id departments.department_id%TYPE := 10;
BEGIN
    DELETE FROM employees
    WHERE department_id = v_dept_id;
    
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT || ' employees deleted');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
```

## 3. Transaction Control

### SAVEPOINT Example
```sql
DECLARE
    v_emp_id employees.employee_id%TYPE := 100;
BEGIN
    -- First update
    UPDATE employees
    SET salary = salary * 1.1
    WHERE employee_id = v_emp_id;
    
    SAVEPOINT salary_update;
    
    -- Second update
    UPDATE employees
    SET commission_pct = commission_pct * 1.1
    WHERE employee_id = v_emp_id;
    
    IF SQL%ROWCOUNT = 0 THEN
        ROLLBACK TO salary_update;
    ELSE
        COMMIT;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
```

## 4. SQL Cursor Attributes

```sql
DECLARE
    v_salary employees.salary%TYPE;
BEGIN
    UPDATE employees
    SET salary = salary * 1.1
    WHERE department_id = 60;
    
    DBMS_OUTPUT.PUT_LINE('SQL%ROWCOUNT: ' || SQL%ROWCOUNT);
    DBMS_OUTPUT.PUT_LINE('SQL%FOUND: ' || CASE WHEN SQL%FOUND THEN 'TRUE' ELSE 'FALSE' END);
    DBMS_OUTPUT.PUT_LINE('SQL%NOTFOUND: ' || CASE WHEN SQL%NOTFOUND THEN 'TRUE' ELSE 'FALSE' END);
    
    COMMIT;
END;
/
```

## Practice Exercises

1. Write a PL/SQL block to insert a new department and handle potential errors
2. Create a block that updates employee salaries based on their performance rating
3. Implement a transaction that transfers an employee to a new department
4. Write a block that deletes old records with proper error handling

## Solutions

### Exercise 1: Insert New Department
```sql
DECLARE
    v_dept_id departments.department_id%TYPE;
    v_dept_name departments.department_name%TYPE := 'New Department';
BEGIN
    -- Get max department_id and add 10
    SELECT MAX(department_id) + 10
    INTO v_dept_id
    FROM departments;
    
    INSERT INTO departments (
        department_id,
        department_name,
        location_id
    ) VALUES (
        v_dept_id,
        v_dept_name,
        1700
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Department created successfully');
EXCEPTION
    WHEN DUP_VAL_ON_INDEX THEN
        DBMS_OUTPUT.PUT_LINE('Department already exists');
        ROLLBACK;
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/
```

### Exercise 2: Update Salaries
```sql
DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, salary, performance_rating
        FROM employees e
        JOIN performance_ratings p ON e.employee_id = p.employee_id;
    
    v_salary_increase NUMBER;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        v_salary_increase := CASE emp_rec.performance_rating
            WHEN 'A' THEN 0.15
            WHEN 'B' THEN 0.10
            WHEN 'C' THEN 0.05
            ELSE 0
        END;
        
        UPDATE employees
        SET salary = salary * (1 + v_salary_increase)
        WHERE employee_id = emp_rec.employee_id;
    END LOOP;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
```

### Exercise 3: Employee Transfer
```sql
DECLARE
    v_emp_id employees.employee_id%TYPE := 100;
    v_new_dept_id departments.department_id%TYPE := 60;
    v_old_dept_id departments.department_id%TYPE;
BEGIN
    -- Save current department
    SELECT department_id
    INTO v_old_dept_id
    FROM employees
    WHERE employee_id = v_emp_id;
    
    -- Update employee's department
    UPDATE employees
    SET department_id = v_new_dept_id
    WHERE employee_id = v_emp_id;
    
    -- Update department statistics
    UPDATE dept_employee_count
    SET employee_count = employee_count - 1
    WHERE department_id = v_old_dept_id;
    
    UPDATE dept_employee_count
    SET employee_count = employee_count + 1
    WHERE department_id = v_new_dept_id;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
```

### Exercise 4: Delete Old Records
```sql
DECLARE
    v_cutoff_date DATE := ADD_MONTHS(SYSDATE, -24);
    v_deleted_count NUMBER := 0;
BEGIN
    -- Delete old records in batches
    LOOP
        DELETE FROM order_history
        WHERE order_date < v_cutoff_date
        AND ROWNUM <= 1000;
        
        v_deleted_count := v_deleted_count + SQL%ROWCOUNT;
        EXIT WHEN SQL%ROWCOUNT = 0;
        
        COMMIT;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Deleted ' || v_deleted_count || ' records');
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END;
/
```

## Key Points to Remember

1. Always handle exceptions when performing DML operations
2. Use COMMIT and ROLLBACK appropriately
3. Utilize SQL%ROWCOUNT to verify the success of DML operations
4. Consider using %ROWTYPE for cleaner code when working with entire rows
5. Implement proper transaction management with SAVEPOINT when needed
6. Use parameterized queries instead of string concatenation
7. Handle NO_DATA_FOUND and TOO_MANY_ROWS exceptions for SELECT INTO

## Next Steps

After mastering SQL in PL/SQL:
1. Practice writing more complex transactions
2. Learn about cursors and bulk operations
3. Study performance optimization techniques
4. Move on to Procedures and Functions in the next section 