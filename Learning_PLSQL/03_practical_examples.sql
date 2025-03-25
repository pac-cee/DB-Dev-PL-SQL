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




-- Project: Employee Management System Database Package
-- Demonstrates comprehensive PL/SQL programming techniques

-- 1. Create a package specification for employee management
CREATE OR REPLACE PACKAGE emp_management AS
    -- Global constants
    c_max_salary CONSTANT NUMBER := 1000000;
    c_min_salary CONSTANT NUMBER := 30000;
    
    -- Custom exception for salary validation
    ex_salary_out_of_range EXCEPTION;
    
    -- Function to calculate employee bonus
    FUNCTION calculate_bonus(
        p_employee_id IN NUMBER, 
        p_performance_rating IN NUMBER
    ) RETURN NUMBER;
    
    -- Procedure to update employee salary
    PROCEDURE update_employee_salary(
        p_employee_id IN NUMBER,
        p_new_salary IN NUMBER
    );
    
    -- Procedure to insert new employee
    PROCEDURE insert_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_department_id IN NUMBER,
        p_salary IN NUMBER
    );
    
    -- Function to get department total salary
    FUNCTION get_department_total_salary(
        p_department_id IN NUMBER
    ) RETURN NUMBER;
END emp_management;
/

-- 2. Package Body Implementation
CREATE OR REPLACE PACKAGE BODY emp_management AS
    -- Bonus calculation function
    FUNCTION calculate_bonus(
        p_employee_id IN NUMBER, 
        p_performance_rating IN NUMBER
    ) RETURN NUMBER IS
        v_base_salary NUMBER;
        v_bonus NUMBER;
    BEGIN
        -- Retrieve base salary
        SELECT salary INTO v_base_salary
        FROM employees
        WHERE employee_id = p_employee_id;
        
        -- Calculate bonus based on performance
        v_bonus := CASE 
            WHEN p_performance_rating >= 4.5 THEN v_base_salary * 0.2
            WHEN p_performance_rating >= 3.5 THEN v_base_salary * 0.15
            WHEN p_performance_rating >= 2.5 THEN v_base_salary * 0.10
            ELSE 0
        END;
        
        RETURN v_bonus;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
        WHEN OTHERS THEN
            RAISE;
    END calculate_bonus;
    
    -- Salary update procedure with validation
    PROCEDURE update_employee_salary(
        p_employee_id IN NUMBER,
        p_new_salary IN NUMBER
    ) IS
    BEGIN
        -- Salary range validation
        IF p_new_salary < c_min_salary OR p_new_salary > c_max_salary THEN
            RAISE ex_salary_out_of_range;
        END IF;
        
        -- Update salary
        UPDATE employees
        SET salary = p_new_salary,
            last_updated = SYSDATE
        WHERE employee_id = p_employee_id;
        
        -- Log salary changes
        INSERT INTO salary_change_log(
            employee_id, 
            old_salary, 
            new_salary, 
            change_date
        )
        SELECT 
            employee_id, 
            salary, 
            p_new_salary, 
            SYSDATE
        FROM employees
        WHERE employee_id = p_employee_id;
        
        COMMIT;
    EXCEPTION
        WHEN ex_salary_out_of_range THEN
            RAISE_APPLICATION_ERROR(-20001, 'Salary outside allowed range');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END update_employee_salary;
    
    -- Insert new employee procedure
    PROCEDURE insert_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_department_id IN NUMBER,
        p_salary IN NUMBER
    ) IS
        v_employee_id NUMBER;
    BEGIN
        -- Validate salary
        IF p_salary < c_min_salary OR p_salary > c_max_salary THEN
            RAISE ex_salary_out_of_range;
        END IF;
        
        -- Get next employee ID
        SELECT employees_seq.NEXTVAL INTO v_employee_id FROM dual;
        
        -- Insert new employee
        INSERT INTO employees(
            employee_id, 
            first_name, 
            last_name, 
            department_id, 
            salary, 
            hire_date
        ) VALUES (
            v_employee_id,
            p_first_name,
            p_last_name,
            p_department_id,
            p_salary,
            SYSDATE
        );
        
        COMMIT;
    EXCEPTION
        WHEN ex_salary_out_of_range THEN
            RAISE_APPLICATION_ERROR(-20002, 'Salary outside allowed range');
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END insert_employee;
    
    -- Department total salary function
    FUNCTION get_department_total_salary(
        p_department_id IN NUMBER
    ) RETURN NUMBER IS
        v_total_salary NUMBER;
    BEGIN
        SELECT NVL(SUM(salary), 0) INTO v_total_salary
        FROM employees
        WHERE department_id = p_department_id;
        
        RETURN v_total_salary;
    EXCEPTION
        WHEN OTHERS THEN
            RETURN 0;
    END get_department_total_salary;
END emp_management;
/

-- 3. Advanced Cursor with Bulk Collect and Forall
CREATE OR REPLACE PROCEDURE process_employee_bonus IS
    -- Cursor with bulk collect for performance optimization
    CURSOR c_employee_performance IS
    SELECT employee_id, performance_rating
    FROM employee_performance
    WHERE bonus_processed = 'N';
    
    -- Collections for bulk processing
    TYPE t_emp_id_table IS TABLE OF NUMBER;
    TYPE t_bonus_table IS TABLE OF NUMBER;
    
    l_emp_ids t_emp_id_table;
    l_bonuses t_bonus_table;
BEGIN
    -- Bulk collect employee data
    SELECT 
        employee_id, 
        emp_management.calculate_bonus(employee_id, performance_rating)
    BULK COLLECT INTO l_emp_ids, l_bonuses
    FROM employee_performance
    WHERE bonus_processed = 'N';
    
    -- Bulk update using FORALL
    FORALL i IN 1..l_emp_ids.COUNT
        UPDATE employee_performance
        SET bonus_amount = l_bonuses(i),
            bonus_processed = 'Y'
        WHERE employee_id = l_emp_ids(i);
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        -- Log error
        INSERT INTO error_log(
            error_date, 
            error_code, 
            error_message
        ) VALUES (
            SYSDATE, 
            SQLCODE, 
            SQLERRM
        );
END process_employee_bonus;
/

-- 4. Complex Trigger Example
CREATE OR REPLACE TRIGGER trg_employee_audit
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
DECLARE
    v_action VARCHAR2(10);
BEGIN
    -- Determine the type of action
    v_action := 
        CASE 
            WHEN INSERTING THEN 'INSERT'
            WHEN UPDATING THEN 'UPDATE'
            WHEN DELETING THEN 'DELETE'
        END;
    
    -- Log changes to audit table
    INSERT INTO employee_audit_log(
        employee_id,
        action_type,
        old_salary,
        new_salary,
        action_date,
        changed_by
    ) VALUES (
        COALESCE(:NEW.employee_id, :OLD.employee_id),
        v_action,
        :OLD.salary,
        :NEW.salary,
        SYSDATE,
        USER
    );
END;
/

-- 5. Dynamic SQL Procedure
CREATE OR REPLACE PROCEDURE dynamic_query_executor(
    p_table_name IN VARCHAR2,
    p_where_clause IN VARCHAR2 DEFAULT NULL
) IS
    v_dynamic_query VARCHAR2(4000);
    v_cursor SYS_REFCURSOR;
BEGIN
    -- Construct dynamic SQL
    v_dynamic_query := 'SELECT * FROM ' || p_table_name;
    
    IF p_where_clause IS NOT NULL THEN
        v_dynamic_query := v_dynamic_query || ' WHERE ' || p_where_clause;
    END IF;
    
    -- Open cursor and return results
    OPEN v_cursor FOR v_dynamic_query;
    
    -- Can be used with application to fetch results
    DBMS_SQL.RETURN_RESULT(v_cursor);
END dynamic_query_executor;
/

-- Usage Examples:
-- 1. Insert new employee
-- BEGIN
--     emp_management.insert_employee('John', 'Doe', 10, 50000);
-- END;

-- 2. Update employee salary
-- BEGIN
--     emp_management.update_employee_salary(100, 55000);
-- END;

-- 3. Calculate bonus
-- DECLARE
--     v_bonus NUMBER;
-- BEGIN
--     v_bonus := emp_management.calculate_bonus(100, 4.7);
-- END;

-- 4. Execute dynamic query
-- BEGIN
--     dynamic_query_executor('employees', 'department_id = 10');
-- END;





-- Oracle PL/SQL Best Practices Project Template

-- 1. Package Design Pattern
CREATE OR REPLACE PACKAGE employee_management AS
    -- Type declarations
    TYPE employee_record IS RECORD (
        emp_id NUMBER,
        full_name VARCHAR2(200),
        salary NUMBER(10,2),
        department_id NUMBER
    );
    
    TYPE employee_table IS TABLE OF employee_record;
    
    -- Global constants
    g_base_salary CONSTANT NUMBER := 30000;
    g_max_salary CONSTANT NUMBER := 500000;
    
    -- Interface for procedures and functions
    PROCEDURE hire_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_department_id IN NUMBER,
        p_salary IN NUMBER
    );
    
    FUNCTION calculate_annual_bonus(
        p_employee_id IN NUMBER
    ) RETURN NUMBER;
    
    PROCEDURE update_employee_salary(
        p_employee_id IN NUMBER,
        p_new_salary IN NUMBER
    );
    
    -- Advanced cursor function to retrieve employee details
    FUNCTION get_employee_details(
        p_employee_id IN NUMBER
    ) RETURN employee_record;
END employee_management;
/

CREATE OR REPLACE PACKAGE BODY employee_management AS
    -- Logging utility (internal use)
    PROCEDURE log_action(
        p_action IN VARCHAR2,
        p_details IN VARCHAR2
    ) IS
    BEGIN
        INSERT INTO action_log (
            log_timestamp, 
            action_type, 
            action_details
        ) VALUES (
            SYSTIMESTAMP, 
            p_action, 
            p_details
        );
    END log_action;
    
    -- Hire employee procedure with error handling
    PROCEDURE hire_employee(
        p_first_name IN VARCHAR2,
        p_last_name IN VARCHAR2,
        p_department_id IN NUMBER,
        p_salary IN NUMBER
    ) IS
        v_employee_id NUMBER;
        v_validate_salary EXCEPTION;
    BEGIN
        -- Input validation
        IF p_salary < g_base_salary OR p_salary > g_max_salary THEN
            RAISE v_validate_salary;
        END IF;
        
        -- Generate unique employee ID
        SELECT employee_seq.NEXTVAL INTO v_employee_id FROM dual;
        
        -- Insert new employee
        INSERT INTO employees (
            employee_id, 
            first_name, 
            last_name, 
            department_id, 
            salary, 
            hire_date
        ) VALUES (
            v_employee_id,
            p_first_name,
            p_last_name,
            p_department_id,
            p_salary,
            SYSDATE
        );
        
        -- Log action
        log_action('HIRE', 'Employee ' || v_employee_id || ' hired');
        
        -- Commit transaction
        COMMIT;
    EXCEPTION
        WHEN v_validate_salary THEN
            RAISE_APPLICATION_ERROR(-20001, 'Salary out of valid range');
        WHEN OTHERS THEN
            ROLLBACK;
            log_action('ERROR', 'Hire failed: ' || SQLERRM);
            RAISE;
    END hire_employee;
    
    -- Advanced cursor function with error handling
    FUNCTION get_employee_details(
        p_employee_id IN NUMBER
    ) RETURN employee_record 
    IS
        v_employee employee_record;
        v_not_found EXCEPTION;
    BEGIN
        SELECT 
            employee_id,
            first_name || ' ' || last_name,
            salary,
            department_id
        INTO 
            v_employee.emp_id,
            v_employee.full_name,
            v_employee.salary,
            v_employee.department_id
        FROM employees
        WHERE employee_id = p_employee_id;
        
        RETURN v_employee;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE v_not_found;
        WHEN OTHERS THEN
            log_action('ERROR', 'Employee retrieval failed: ' || SQLERRM);
            RAISE;
    END get_employee_details;
    
    -- Performance-based bonus calculation
    FUNCTION calculate_annual_bonus(
        p_employee_id IN NUMBER
    ) RETURN NUMBER 
    IS
        v_performance_factor NUMBER;
        v_bonus NUMBER;
    BEGIN
        -- Complex bonus calculation logic
        SELECT 
            CASE 
                WHEN performance_rating >= 4.5 THEN 0.2
                WHEN performance_rating >= 3.5 THEN 0.15
                WHEN performance_rating >= 2.5 THEN 0.1
                ELSE 0.05
            END INTO v_performance_factor
        FROM employee_performance
        WHERE employee_id = p_employee_id;
        
        -- Retrieve base salary and calculate bonus
        SELECT salary * v_performance_factor 
        INTO v_bonus
        FROM employees
        WHERE employee_id = p_employee_id;
        
        RETURN v_bonus;
    EXCEPTION
        WHEN OTHERS THEN
            log_action('ERROR', 'Bonus calculation failed: ' || SQLERRM);
            RETURN 0;
    END calculate_annual_bonus;
    
    -- Salary update with audit trail
    PROCEDURE update_employee_salary(
        p_employee_id IN NUMBER,
        p_new_salary IN NUMBER
    ) IS
        v_old_salary NUMBER;
    BEGIN
        -- Retrieve current salary
        SELECT salary INTO v_old_salary
        FROM employees
        WHERE employee_id = p_employee_id;
        
        -- Update salary
        UPDATE employees
        SET salary = p_new_salary
        WHERE employee_id = p_employee_id;
        
        -- Create audit record
        INSERT INTO salary_history (
            employee_id,
            old_salary,
            new_salary,
            change_date
        ) VALUES (
            p_employee_id,
            v_old_salary,
            p_new_salary,
            SYSDATE
        );
        
        -- Log action
        log_action('SALARY_UPDATE', 
            'Employee ' || p_employee_id || 
            ' salary changed from ' || v_old_salary || 
            ' to ' || p_new_salary
        );
        
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            log_action('ERROR', 'Salary update failed: ' || SQLERRM);
            RAISE;
    END update_employee_salary;
END employee_management;
/

-- 2. Advanced Trigger Design
CREATE OR REPLACE TRIGGER trg_employee_audit
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
DECLARE
    v_action VARCHAR2(10);
BEGIN
    -- Determine the type of action
    CASE
        WHEN INSERTING THEN v_action := 'INSERT';
        WHEN UPDATING THEN v_action := 'UPDATE';
        WHEN DELETING THEN v_action := 'DELETE';
    END CASE;
    
    -- Log audit trail
    INSERT INTO employee_audit_log (
        audit_timestamp,
        employee_id,
        action_type,
        old_value,
        new_value
    ) VALUES (
        SYSTIMESTAMP,
        COALESCE(:OLD.employee_id, :NEW.employee_id),
        v_action,
        CASE v_action 
            WHEN 'UPDATE' THEN TO_CHAR(:OLD.salary)
            WHEN 'DELETE' THEN TO_CHAR(:OLD.salary)
            ELSE NULL 
        END,
        CASE v_action 
            WHEN 'UPDATE' THEN TO_CHAR(:NEW.salary)
            WHEN 'INSERT' THEN TO_CHAR(:NEW.salary)
            ELSE NULL 
        END
    );
END;
/

-- 3. Advanced Cursor with Performance Optimization
CREATE OR REPLACE PROCEDURE process_monthly_payroll IS
    -- Cursor with parameterized complexity
    CURSOR c_employee_payroll (
        p_min_salary NUMBER, 
        p_department_id NUMBER
    ) IS
    SELECT 
        employee_id,
        salary,
        department_id
    FROM employees
    WHERE salary >= p_min_salary 
    AND department_id = p_department_id
    FOR UPDATE OF salary NOWAIT;
    
    v_bonus NUMBER;
BEGIN
    -- Bulk processing with performance considerations
    FOR emp_rec IN c_employee_payroll(50000, 10) LOOP
        BEGIN
            -- Calculate performance bonus
            v_bonus := employee_management.calculate_annual_bonus(emp_rec.employee_id);
            
            -- Update salary with bonus
            UPDATE employees
            SET salary = salary + v_bonus
            WHERE CURRENT OF c_employee_payroll;
        EXCEPTION
            WHEN OTHERS THEN
                -- Log error, continue processing
                employee_management.log_action(
                    'PAYROLL_ERROR', 
                    'Failed to process employee ' || emp_rec.employee_id
                );
        END;
    END LOOP;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        employee_management.log_action('PAYROLL_FATAL', SQLERRM);
END process_monthly_payroll;
/