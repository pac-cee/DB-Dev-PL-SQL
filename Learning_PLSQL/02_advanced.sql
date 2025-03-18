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