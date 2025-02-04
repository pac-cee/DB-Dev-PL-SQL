-- PL/SQL Practical Examples

-- 1. Create a simple employees table
CREATE TABLE employees (
    employee_id   NUMBER PRIMARY KEY,
    first_name    VARCHAR2(50),
    last_name     VARCHAR2(50),
    email         VARCHAR2(100),
    hire_date     DATE,
    salary        NUMBER(10,2)
);

-- 2. Procedure to add a new employee
CREATE OR REPLACE PROCEDURE add_employee(
    p_first_name IN VARCHAR2,
    p_last_name  IN VARCHAR2,
    p_email      IN VARCHAR2,
    p_salary     IN NUMBER
) IS
    v_employee_id NUMBER;
BEGIN
    -- Get next employee ID
    SELECT NVL(MAX(employee_id), 0) + 1
    INTO v_employee_id
    FROM employees;
    
    -- Insert new employee
    INSERT INTO employees (
        employee_id, first_name, last_name, 
        email, hire_date, salary
    ) VALUES (
        v_employee_id, p_first_name, p_last_name,
        p_email, SYSDATE, p_salary
    );
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Employee added successfully. ID: ' || v_employee_id);
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error adding employee: ' || SQLERRM);
END;
/

-- 3. Function to calculate annual salary with bonus
CREATE OR REPLACE FUNCTION calculate_annual_salary(
    p_employee_id IN NUMBER,
    p_bonus_percent IN NUMBER DEFAULT 10
) RETURN NUMBER IS
    v_annual_salary NUMBER;
    v_monthly_salary NUMBER;
BEGIN
    -- Get employee's monthly salary
    SELECT salary
    INTO v_monthly_salary
    FROM employees
    WHERE employee_id = p_employee_id;
    
    -- Calculate annual salary with bonus
    v_annual_salary := (v_monthly_salary * 12) * (1 + p_bonus_percent/100);
    
    RETURN v_annual_salary;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END;
/

-- 4. Procedure to give salary raises
CREATE OR REPLACE PROCEDURE give_salary_raise(
    p_min_salary IN NUMBER,
    p_raise_percent IN NUMBER
) IS
    v_employees_updated NUMBER := 0;
BEGIN
    -- Update salaries
    UPDATE employees
    SET salary = salary * (1 + p_raise_percent/100)
    WHERE salary <= p_min_salary;
    
    v_employees_updated := SQL%ROWCOUNT;
    
    COMMIT;
    DBMS_OUTPUT.PUT_LINE(v_employees_updated || ' employees received a raise.');
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        DBMS_OUTPUT.PUT_LINE('Error giving raises: ' || SQLERRM);
END;
/

-- 5. Example usage of the above objects
BEGIN
    -- Add some employees
    add_employee('John', 'Doe', 'john.doe@email.com', 5000);
    add_employee('Jane', 'Smith', 'jane.smith@email.com', 6000);
    add_employee('Bob', 'Johnson', 'bob.johnson@email.com', 4500);
    
    -- Calculate and display annual salary for an employee
    DBMS_OUTPUT.PUT_LINE('Annual salary with bonus: ' || 
        calculate_annual_salary(1, 15));
    
    -- Give raises to employees earning less than 5000
    give_salary_raise(5000, 10);
    
    -- Display all employees
    FOR emp IN (SELECT * FROM employees ORDER BY employee_id) LOOP
        DBMS_OUTPUT.PUT_LINE(
            'Employee: ' || emp.first_name || ' ' || emp.last_name || 
            ', Salary: ' || emp.salary
        );
    END LOOP;
END;
/

-- 6. Trigger example - Audit employee salary changes
CREATE TABLE salary_audit_log (
    audit_id     NUMBER PRIMARY KEY,
    employee_id  NUMBER,
    old_salary   NUMBER,
    new_salary   NUMBER,
    change_date  DATE,
    changed_by   VARCHAR2(30)
);

CREATE SEQUENCE salary_audit_seq;

CREATE OR REPLACE TRIGGER trg_audit_salary_change
AFTER UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
    INSERT INTO salary_audit_log (
        audit_id, employee_id, old_salary,
        new_salary, change_date, changed_by
    ) VALUES (
        salary_audit_seq.NEXTVAL,
        :OLD.employee_id,
        :OLD.salary,
        :NEW.salary,
        SYSDATE,
        USER
    );
END;
/

-- 7. Package for employee management
CREATE OR REPLACE PACKAGE emp_mgmt IS
    -- Public procedures and functions
    PROCEDURE add_employee(
        p_first_name IN VARCHAR2,
        p_last_name  IN VARCHAR2,
        p_email      IN VARCHAR2,
        p_salary     IN NUMBER
    );
    
    FUNCTION get_employee_details(
        p_employee_id IN NUMBER
    ) RETURN VARCHAR2;
    
    PROCEDURE update_salary(
        p_employee_id IN NUMBER,
        p_new_salary IN NUMBER
    );
END emp_mgmt;
/

CREATE OR REPLACE PACKAGE BODY emp_mgmt IS
    -- Implementation of add_employee
    PROCEDURE add_employee(
        p_first_name IN VARCHAR2,
        p_last_name  IN VARCHAR2,
        p_email      IN VARCHAR2,
        p_salary     IN NUMBER
    ) IS
    BEGIN
        add_employee(p_first_name, p_last_name, p_email, p_salary);
    END add_employee;
    
    -- Implementation of get_employee_details
    FUNCTION get_employee_details(
        p_employee_id IN NUMBER
    ) RETURN VARCHAR2 IS
        v_details VARCHAR2(200);
    BEGIN
        SELECT first_name || ' ' || last_name || ' (Salary: ' || salary || ')'
        INTO v_details
        FROM employees
        WHERE employee_id = p_employee_id;
        
        RETURN v_details;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 'Employee not found';
    END get_employee_details;
    
    -- Implementation of update_salary
    PROCEDURE update_salary(
        p_employee_id IN NUMBER,
        p_new_salary IN NUMBER
    ) IS
    BEGIN
        UPDATE employees
        SET salary = p_new_salary
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
END emp_mgmt;
/
