-- PL/SQL Advanced Concepts

-- 1. Procedures
-- Procedures are subprograms that perform specific actions
CREATE OR REPLACE PROCEDURE greet_user(p_name IN VARCHAR2) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Hello, ' || p_name || '!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in greet_user: ' || SQLERRM);
END;
/

-- Execute the procedure
BEGIN
    greet_user('John');
END;

-- Example 1: Simple Procedure to Display a Message
CREATE OR REPLACE PROCEDURE greet_user (p_username VARCHAR2) AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('Hello, ' || p_username || '!');
END;
/

-- Calling the procedure:
BEGIN
  greet_user('Alice');
END;
/

-- Example 2: Procedure with IN, OUT, and IN OUT parameters
CREATE OR REPLACE PROCEDURE calculate_area (
  p_radius IN NUMBER,
  p_area OUT NUMBER,
  p_circumference OUT NUMBER
) AS
  pi CONSTANT NUMBER := 3.14159;
BEGIN
  p_area := pi * p_radius * p_radius;
  p_circumference := 2 * pi * p_radius;
END;
/

-- Calling the procedure:
DECLARE               
  v_radius NUMBER := 5;
  v_area NUMBER;
  v_circumference NUMBER;
BEGIN
  calculate_area(v_radius, v_area, v_circumference);
  DBMS_OUTPUT.PUT_LINE('Area: ' || v_area);
  DBMS_OUTPUT.PUT_LINE('Circumference: ' || v_circumference);
END;
/

-- Example 3: Procedure with exception handling
CREATE OR REPLACE PROCEDURE divide_numbers (
  p_numerator NUMBER,
  p_denominator NUMBER,
  p_result OUT NUMBER
) AS
BEGIN
  IF p_denominator = 0 THEN
    RAISE ZERO_DIVIDE;
  END IF;
  p_result := p_numerator / p_denominator;
EXCEPTION
  WHEN ZERO_DIVIDE THEN
    DBMS_OUTPUT.PUT_LINE('Error: Division by zero.');
    p_result := NULL;
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An unexpected error occurred.');
    p_result := NULL;
END;
/

-- Calling the procedure:
DECLARE
  v_numerator NUMBER := 10;
  v_denominator NUMBER := 0;
  v_result NUMBER;
BEGIN
  divide_numbers(v_numerator, v_denominator, v_result);
  IF v_result IS NOT NULL THEN
    DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
  END IF;
END;
/

-- Example 4: Procedure with a cursor and loop
CREATE OR REPLACE PROCEDURE display_employees AS
  CURSOR emp_cursor IS
    SELECT employee_id, last_name, salary
    FROM employees;
  v_employee_id employees.employee_id%TYPE;
  v_last_name employees.last_name%TYPE;
  v_salary employees.salary%TYPE;
BEGIN
  OPEN emp_cursor;
  LOOP
    FETCH emp_cursor INTO v_employee_id, v_last_name, v_salary;
    EXIT WHEN emp_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Employee ID: ' || v_employee_id || ', Last Name: ' || v_last_name || ', Salary: ' || v_salary);
  END LOOP;
  CLOSE emp_cursor;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    DBMS_OUTPUT.PUT_LINE('No employee data found.');
  WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred while fetching employee data.');
END;
/

-- Calling the procedure:
BEGIN
  display_employees;
END;
/

--Example 5: Procedure with an IN OUT parameter to increment a value.
CREATE OR REPLACE PROCEDURE increment_value(io_value IN OUT NUMBER) AS
BEGIN
    io_value := io_value + 1;
END;
/

--Calling the procedure
DECLARE
    my_value NUMBER := 10;
BEGIN
    increment_value(my_value);
    DBMS_OUTPUT.PUT_LINE('Incremented value: ' || my_value);
END;
/

--Example 6: Procedure demonstrating the use of a record type.
CREATE OR REPLACE PROCEDURE display_employee_record(p_employee_id employees.employee_id%TYPE) AS
    TYPE employee_record_type IS RECORD (
        last_name employees.last_name%TYPE,
        salary employees.salary%TYPE
    );
    employee_record employee_record_type;
BEGIN
    SELECT last_name, salary
    INTO employee_record
    FROM employees
    WHERE employee_id = p_employee_id;

    DBMS_OUTPUT.PUT_LINE('Employee Name: ' || employee_record.last_name || ', Salary: ' || employee_record.salary);
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        DBMS_OUTPUT.PUT_LINE('Employee with ID ' || p_employee_id || ' not found.');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred.');
END;
/

--Calling the procedure
BEGIN
    display_employee_record(100); --Replace 100 with an actual employee ID.
END;

/

-- 2. Functions
-- Functions are subprograms that return a value
CREATE OR REPLACE FUNCTION calculate_area(p_radius IN NUMBER)
RETURN NUMBER IS
    v_pi CONSTANT NUMBER := 3.14159;
BEGIN
    RETURN v_pi * POWER(p_radius, 2);
EXCEPTION
    WHEN OTHERS THEN
        RETURN NULL;
END;
/

-- Use the function
DECLARE
    v_area NUMBER;
BEGIN
    v_area := calculate_area(5);
    DBMS_OUTPUT.PUT_LINE('Area of circle: ' || v_area);
END;
/

-- 3. Packages
-- Packages are collections of related procedures and functions
CREATE OR REPLACE PACKAGE math_utils IS
    -- Package specification (header)
    FUNCTION add_numbers(p_num1 IN NUMBER, p_num2 IN NUMBER) RETURN NUMBER;
    FUNCTION multiply_numbers(p_num1 IN NUMBER, p_num2 IN NUMBER) RETURN NUMBER;
END math_utils;
/

CREATE OR REPLACE PACKAGE BODY math_utils IS
    -- Package body (implementation)
    FUNCTION add_numbers(p_num1 IN NUMBER, p_num2 IN NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN p_num1 + p_num2;
    END add_numbers;
    
    FUNCTION multiply_numbers(p_num1 IN NUMBER, p_num2 IN NUMBER) RETURN NUMBER IS
    BEGIN
        RETURN p_num1 * p_num2;
    END multiply_numbers;
END math_utils;
/

-- Use the package
BEGIN
    DBMS_OUTPUT.PUT_LINE('Sum: ' || math_utils.add_numbers(10, 20));
    DBMS_OUTPUT.PUT_LINE('Product: ' || math_utils.multiply_numbers(10, 20));
END;
/

-- =============================================
-- Advanced PL/SQL Package Definition
-- =============================================

/*
Package: emp_mgmt_pkg
Purpose: Comprehensive employee management functionality
Features: 
- Salary management
- Bonus calculations
- Bulk updates
- Audit logging
Benefits:
- Encapsulation of related functionality
- State management across calls
- Better performance through caching
- Modular and maintainable code
*/

CREATE OR REPLACE PACKAGE emp_mgmt_pkg IS
    -- Constants section
    -- ----------------
    -- Defines business rules and limits
    c_min_salary CONSTANT NUMBER := 30000;  -- Minimum allowed salary
    c_max_salary CONSTANT NUMBER := 150000; -- Maximum allowed salary
    c_max_bonus_pct CONSTANT NUMBER := 0.20; -- Maximum bonus percentage
    
    -- Custom Types section
    -- -------------------
    -- Record type for employee data
    -- Benefits: 
    -- - Strong typing
    -- - Reduced parameter lists
    -- - Improved maintainability
    TYPE emp_record_type IS RECORD (
        emp_id    NUMBER,
        name      VARCHAR2(100),
        salary    NUMBER,
        dept_id   NUMBER
    );
    
    -- Collection type for bulk operations
    -- Benefits:
    -- - Efficient bulk processing
    -- - Reduced context switching
    -- - Better performance for large datasets
    TYPE emp_table_type IS TABLE OF emp_record_type;
    
    -- Function Declarations
    -- --------------------
    -- Calculate employee bonus based on performance and tenure
    -- Parameters:
    --   p_emp_id: Employee ID
    --   p_performance_rating: Rating from 1-5
    -- Returns: Calculated bonus amount
    FUNCTION calculate_bonus(
        p_emp_id IN NUMBER,
        p_performance_rating IN NUMBER
    ) RETURN NUMBER;
    
    -- Procedure Declarations
    -- ---------------------
    -- Updates employee salary with full audit trail
    -- Features:
    -- - Validation of salary ranges
    -- - Automatic audit logging
    -- - Transaction management
    -- - Error handling
    PROCEDURE update_salary(
        p_emp_id IN NUMBER,
        p_new_salary IN NUMBER,
        p_reason_code IN VARCHAR2,
        p_effective_date IN DATE DEFAULT SYSDATE
    );
END emp_mgmt_pkg;
/

-- Package Body Implementation
-- =========================
-- Contains the actual implementation of package components
CREATE OR REPLACE PACKAGE BODY emp_mgmt_pkg IS
    -- Private Variables
    -- ----------------
    -- Used for internal state management
    v_last_updated_by VARCHAR2(30);
    v_last_update_date DATE;
    
    -- Private Helper Functions
    -- -----------------------
    -- Validates salary against business rules
    -- Returns: TRUE if salary is valid, FALSE otherwise
    FUNCTION is_valid_salary(
        p_salary IN NUMBER,
        p_dept_id IN NUMBER
    ) RETURN BOOLEAN
    IS
        v_dept_avg NUMBER;
        v_max_allowed NUMBER;
    BEGIN
        -- Get department average for comparison
        SELECT AVG(salary) INTO v_dept_avg
        FROM employees
        WHERE department_id = p_dept_id;
        
        -- Calculate maximum allowed based on department average
        v_max_allowed := v_dept_avg * 2;
        
        -- Check against both absolute and relative limits
        RETURN (p_salary BETWEEN c_min_salary AND c_max_salary) AND
               (p_salary <= v_max_allowed);
    END is_valid_salary;
    
    -- Public Function Implementations
    -- -----------------------------
    FUNCTION calculate_bonus(
        p_emp_id IN NUMBER,
        p_performance_rating IN NUMBER
    ) RETURN NUMBER
    IS
        v_salary NUMBER;
        v_years_service NUMBER;
        v_bonus_pct NUMBER;
    BEGIN
        -- Input validation
        IF p_performance_rating NOT BETWEEN 1 AND 5 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Invalid performance rating');
        END IF;
        
        -- Get employee details
        SELECT salary, FLOOR(MONTHS_BETWEEN(SYSDATE, hire_date)/12)
        INTO v_salary, v_years_service
        FROM employees
        WHERE employee_id = p_emp_id;
        
        -- Calculate bonus percentage based on performance and tenure
        v_bonus_pct := (p_performance_rating/5) * 
                       (LEAST(v_years_service, 10)/10) * 
                       c_max_bonus_pct;
        
        RETURN ROUND(v_salary * v_bonus_pct, 2);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Employee not found');
        WHEN OTHERS THEN
            -- Log error and re-raise
            log_error(SQLCODE, SQLERRM, 'calculate_bonus');
            RAISE;
    END calculate_bonus;
    
    -- Public Procedure Implementations
    -- ------------------------------
    PROCEDURE update_salary(
        p_emp_id IN NUMBER,
        p_new_salary IN NUMBER,
        p_reason_code IN VARCHAR2,
        p_effective_date IN DATE DEFAULT SYSDATE
    ) IS
        v_old_salary NUMBER;
        v_dept_id NUMBER;
        
        -- Custom exception for invalid salary
        e_invalid_salary EXCEPTION;
        PRAGMA EXCEPTION_INIT(e_invalid_salary, -20003);
    BEGIN
        -- Get current employee details
        SELECT salary, department_id 
        INTO v_old_salary, v_dept_id
        FROM employees
        WHERE employee_id = p_emp_id;
        
        -- Validate new salary
        IF NOT is_valid_salary(p_new_salary, v_dept_id) THEN
            RAISE e_invalid_salary;
        END IF;
        
        -- Update salary
        UPDATE employees
        SET salary = p_new_salary,
            last_updated_date = p_effective_date,
            last_updated_by = v_last_updated_by
        WHERE employee_id = p_emp_id;
        
        -- Create audit record
        INSERT INTO salary_changes (
            employee_id,
            old_salary,
            new_salary,
            change_date,
            reason_code,
            changed_by
        ) VALUES (
            p_emp_id,
            v_old_salary,
            p_new_salary,
            p_effective_date,
            p_reason_code,
            v_last_updated_by
        );
        
        COMMIT;
        
    EXCEPTION
        WHEN e_invalid_salary THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20003, 
                'Invalid salary: Must be between ' || c_min_salary || 
                ' and ' || c_max_salary || ' and within department limits');
        WHEN OTHERS THEN
            ROLLBACK;
            log_error(SQLCODE, SQLERRM, 'update_salary');
            RAISE;
    END update_salary;
    
    -- Package Initialization
    -- --------------------
    -- Runs when package is first loaded into memory
    BEGIN
        v_last_updated_by := SYS_CONTEXT('USERENV', 'SESSION_USER');
        v_last_update_date := SYSDATE;
END emp_mgmt_pkg;
/

-- 4. Cursors
-- Explicit cursor example
DECLARE
    CURSOR emp_cursor IS
        SELECT employee_id, first_name, salary 
        FROM hr.employees 
        WHERE salary > 5000; 
    
    v_emp_record emp_cursor%ROWTYPE;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_emp_record;
        EXIT WHEN emp_cursor%NOTFOUND;
        
        DBMS_OUTPUT.PUT_LINE('Employee: ' || v_emp_record.first_name || 
                            ', Salary: ' || v_emp_record.salary);
    END LOOP;
    CLOSE emp_cursor;
END;
/

-- 5. Exception Handling
DECLARE
    v_result NUMBER;
BEGIN
    -- Divide by zero will raise an exception
    v_result := 1/0;
    
EXCEPTION
    WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Error: Division by zero!');
    WHEN VALUE_ERROR THEN
        DBMS_OUTPUT.PUT_LINE('Error: Value error occurred!');
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
END;
/

-- 6. Collections
DECLARE
    -- Associative array (PL/SQL table)
    TYPE t_number_table IS TABLE OF NUMBER
        INDEX BY PLS_INTEGER;
    
    v_numbers t_number_table;
BEGIN
    -- Populate the array
    FOR i IN 1..5 LOOP
        v_numbers(i) := i * 10;
    END LOOP;
    
    -- Print the array
    FOR i IN v_numbers.FIRST..v_numbers.LAST LOOP
        DBMS_OUTPUT.PUT_LINE('Index ' || i || ': ' || v_numbers(i));
    END LOOP;
END;
/

-- 7. Records (Custom Data Types)
DECLARE
    -- Define record structure
    TYPE t_person IS RECORD (
        first_name VARCHAR2(50),
        last_name  VARCHAR2(50),
        age       NUMBER
    );
    
    -- Declare record variable
    v_person t_person;
BEGIN
    -- Assign values
    v_person.first_name := 'John';
    v_person.last_name := 'Doe';
    v_person.age := 30;
    
    -- Print record
    DBMS_OUTPUT.PUT_LINE('Person: ' || v_person.first_name || ' ' || 
                        v_person.last_name || ', Age: ' || v_person.age);
END;
/
-- First enable server output
SET SERVEROUTPUT ON;

-- Accept user input
ACCEPT p_amount PROMPT 'Enter amount: ';

DECLARE
    v_total_amount NUMBER := &p_amount;
    v_vat NUMBER;
    v_final_amount NUMBER;
BEGIN
    v_vat := v_total_amount * 0.18;
    v_final_amount := v_total_amount + v_vat;
    
    DBMS_OUTPUT.PUT_LINE('Amount: ' || v_total_amount);
    DBMS_OUTPUT.PUT_LINE('VAT: ' || v_vat);
    DBMS_OUTPUT.PUT_LINE('Final Amount: ' || v_final_amount);
END;
/