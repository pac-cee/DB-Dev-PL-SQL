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
