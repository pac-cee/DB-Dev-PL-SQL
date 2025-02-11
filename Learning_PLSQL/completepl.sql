-- 1. Basic PL/SQL Block Structure
DECLARE
    -- Declaration section
    v_name VARCHAR2(50);
    v_count NUMBER := 100;
BEGIN
    -- Executable section
    v_name := 'John Doe';
    v_count := 1000;
    DBMS_OUTPUT.PUT_LINE('Hello ' || v_name);
    DBMS_OUTPUT.PUT_LINE('HELLO' || v_count);
EXCEPTION
    -- Exception handling section
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred');
END;
/


-- 2. Variables and Data Types
DECLARE
    v_number NUMBER(10,2) := 123.45;
    v_text VARCHAR2(100) := 'Sample text';
    v_date DATE := SYSDATE;
    v_boolean BOOLEAN := TRUE;
    -- Constant declaration
    c_tax_rate CONSTANT NUMBER := 0.08;
    -- %TYPE attribute
    v_emp_salary employees.salary%TYPE;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Number: ' || v_number);
    DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(v_date, 'DD-MON-YYYY'));
END;
/

-- 3. Control Structures
DECLARE
    v_grade CHAR(1) := 'B';
    v_counter NUMBER := 1;
BEGIN
    -- IF-THEN-ELSIF
    IF v_grade = 'A' THEN
        DBMS_OUTPUT.PUT_LINE('Excellent!');
    ELSIF v_grade = 'B' THEN
        DBMS_OUTPUT.PUT_LINE('Good job!');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Keep trying!');
    END IF;
    
    -- CASE statement
    CASE v_grade
        WHEN 'A' THEN DBMS_OUTPUT.PUT_LINE('Excellent!');
        WHEN 'B' THEN DBMS_OUTPUT.PUT_LINE('Good job!');
        ELSE DBMS_OUTPUT.PUT_LINE('Keep trying!');
    END CASE;
    
    -- LOOP
    LOOP
        DBMS_OUTPUT.PUT_LINE('Counter: ' || v_counter);
        v_counter := v_counter + 1;
        EXIT WHEN v_counter > 5;
    END LOOP;
    
    -- FOR LOOP
    FOR i IN 1..5 LOOP
        DBMS_OUTPUT.PUT_LINE('Iteration ' || i);
    END LOOP;
    
    -- WHILE LOOP
    WHILE v_counter <= 10 LOOP
        DBMS_OUTPUT.PUT_LINE('While counter: ' || v_counter);
        v_counter := v_counter + 1;
    END LOOP;
END;
/

-- 4. Cursors
DECLARE
    -- Explicit cursor
    CURSOR emp_cursor IS
        SELECT employee_id, first_name, salary
        FROM employees
        WHERE department_id = 10;
    
    -- Record variable to store cursor data
    emp_record emp_cursor%ROWTYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO emp_record;
        EXIT WHEN emp_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Employee: ' || emp_record.first_name ||
                            ', Salary: ' || emp_record.salary);
    END LOOP;
    CLOSE emp_cursor;
    
    -- Cursor FOR loop (simpler syntax)
    FOR emp_rec IN emp_cursor LOOP
        DBMS_OUTPUT.PUT_LINE('Employee: ' || emp_rec.first_name);
    END LOOP;
END;
/

-- 5. Procedures
CREATE OR REPLACE PROCEDURE update_salary (
    p_employee_id IN employees.employee_id%TYPE,
    p_percentage IN NUMBER
) IS
    v_current_salary employees.salary%TYPE;
BEGIN
    -- Get current salary
    SELECT salary INTO v_current_salary
    FROM employees
    WHERE employee_id = p_employee_id;
    
    -- Update salary
    UPDATE employees
    SET salary = salary * (1 + p_percentage/100)
    WHERE employee_id = p_employee_id;
    
    COMMIT;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Employee not found');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE;
END update_salary;
/

-- 6. Functions
CREATE OR REPLACE FUNCTION calculate_bonus (
    p_salary IN NUMBER,
    p_years_service IN NUMBER
) RETURN NUMBER IS
    v_bonus_amount NUMBER;
BEGIN
    v_bonus_amount := CASE
        WHEN p_years_service >= 10 THEN p_salary * 0.20
        WHEN p_years_service >= 5 THEN p_salary * 0.15
        ELSE p_salary * 0.10
    END;
    
    RETURN v_bonus_amount;
EXCEPTION
    WHEN OTHERS THEN
        RETURN 0;
END calculate_bonus;
/

-- 7. Packages
CREATE OR REPLACE PACKAGE emp_mgmt AS
    -- Package specifications
    PROCEDURE update_salary (
        p_employee_id IN employees.employee_id%TYPE,
        p_percentage IN NUMBER
    );
    
    FUNCTION calculate_bonus (
        p_salary IN NUMBER,
        p_years_service IN NUMBER
    ) RETURN NUMBER;
    
    -- Package variables
    g_company_name CONSTANT VARCHAR2(50) := 'My Company';
END emp_mgmt;
/

CREATE OR REPLACE PACKAGE BODY emp_mgmt AS
    -- Procedure implementation
    PROCEDURE update_salary (
        p_employee_id IN employees.employee_id%TYPE,
        p_percentage IN NUMBER
    ) IS
        -- Implementation here
    BEGIN
        NULL;
    END update_salary;
    
    -- Function implementation
    FUNCTION calculate_bonus (
        p_salary IN NUMBER,
        p_years_service IN NUMBER
    ) RETURN NUMBER IS
        -- Implementation here
    BEGIN
        RETURN 0;
    END calculate_bonus;
END emp_mgmt;
/

-- 8. Triggers
CREATE OR REPLACE TRIGGER prevent_salary_decrease
BEFORE UPDATE OF salary ON employees
FOR EACH ROW
BEGIN
    IF :NEW.salary < :OLD.salary THEN
        RAISE_APPLICATION_ERROR(-20002, 'Salary cannot be decreased');
    END IF;
END;
/

-- 9. Exception Handling
DECLARE
    custom_exception EXCEPTION;
    PRAGMA EXCEPTION_INIT(custom_exception, -20999);
BEGIN
    -- User-defined exception
    RAISE_APPLICATION_ERROR(-20999, 'Custom error occurred');
EXCEPTION
    WHEN custom_exception THEN
        DBMS_OUTPUT.PUT_LINE('Caught custom exception');
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('No data found');
    WHEN TOO_MANY_ROWS THEN
        DBMS_OUTPUT.PUT_LINE('Too many rows');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Unexpected error: ' || SQLERRM);
END;
/

-- 10. Collections
DECLARE
    -- Associative array (Index-by table)
    TYPE name_list_type IS TABLE OF VARCHAR2(50)
        INDEX BY PLS_INTEGER;
    name_list name_list_type;
    
    -- Nested table
    TYPE number_list_type IS TABLE OF NUMBER;
    number_list number_list_type := number_list_type();
    
    -- VARRAY
    TYPE department_list_type IS VARRAY(5) OF NUMBER;
    department_list department_list_type := department_list_type();
BEGIN
    -- Using associative array
    name_list(1) := 'John';
    name_list(2) := 'Jane';
    
    -- Using nested table
    number_list.EXTEND;
    number_list(1) := 100;
    
    -- Using VARRAY
    department_list.EXTEND;
    department_list(1) := 10;
END;
/