-- PL/SQL Tutorial

-- 1. Basic Block Structure
DECLARE
    -- Declaration section (optional)
    v_message VARCHAR2(100) := 'Hello, PL/SQL!';
BEGIN
    -- Executable section (required)
    DBMS_OUTPUT.PUT_LINE(v_message);
EXCEPTION
    -- Exception section (optional)
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('An error occurred!');
END;
/

-- 2. Variables and Data Types
DECLARE
    v_number        NUMBER(10,2) := 123.45;        -- Numeric with 10 digits, 2 decimal places
    v_integer       PLS_INTEGER := 42;             -- Integer (faster than NUMBER for integers)
    v_text         VARCHAR2(100) := 'Some text';   -- Variable-length string
    v_date         DATE := SYSDATE;                -- Current date and time
    v_boolean      BOOLEAN := TRUE;                -- Boolean (can be TRUE, FALSE, or NULL)
    v_character    CHAR(10) := 'Fixed     ';       -- Fixed-length string
BEGIN
    DBMS_OUTPUT.PUT_LINE('Number: ' || v_number);
    DBMS_OUTPUT.PUT_LINE('Integer: ' || v_integer);
    DBMS_OUTPUT.PUT_LINE('Text: ' || v_text);
    DBMS_OUTPUT.PUT_LINE('Date: ' || v_date);
    DBMS_OUTPUT.PUT_LINE('Boolean: ' || v_boolean);
    DBMS_OUTPUT.PUT_LINE('Character: ' || v_character);
END;
/

-- 3. Operators
DECLARE
    v_num1 NUMBER := 10;
    v_num2 NUMBER := 20;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Addition: ' || (v_num1 + v_num2));
    DBMS_OUTPUT.PUT_LINE('Subtraction: ' || (v_num1 - v_num2));
    DBMS_OUTPUT.PUT_LINE('Multiplication: ' || (v_num1 * v_num2));
    DBMS_OUTPUT.PUT_LINE('Division: ' || (v_num1 / v_num2));
    DBMS_OUTPUT.PUT_LINE('Modulus: ' || MOD(v_num1, v_num2));
END;
/

-- 4. Control Statements
DECLARE
    v_num NUMBER := 5;
BEGIN
    IF v_num = 5 THEN
        DBMS_OUTPUT.PUT_LINE('v_num is 5');
    ELSIF v_num = 10 THEN
        DBMS_OUTPUT.PUT_LINE('v_num is 10');
    ELSE
        DBMS_OUTPUT.PUT_LINE('v_num is not 5 or 10');
    END IF;
    
    WHILE v_num > 0 LOOP
        DBMS_OUTPUT.PUT_LINE('v_num is ' || v_num);
        v_num := v_num - 1;
    END LOOP;
    
    FOR i IN 1..5 LOOP
        DBMS_OUTPUT.PUT_LINE('i is ' || i);
    END LOOP;
END;
/

-- 5. Functions
CREATE OR REPLACE FUNCTION add_numbers(p_num1 IN NUMBER, p_num2 IN NUMBER)
RETURN NUMBER IS
BEGIN
    RETURN p_num1 + p_num2;
END add_numbers;
/

BEGIN
    DBMS_OUTPUT.PUT_LINE('Sum: ' || add_numbers(10, 20));
END;
/

-- 6. Procedures
CREATE OR REPLACE PROCEDURE greet_user(p_name IN VARCHAR2) IS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Hello, ' || p_name || '!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error in greet_user: ' || SQLERRM);
END greet_user;
/

BEGIN
    greet_user('John');
END;
/

-- 7. Packages
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

BEGIN
    DBMS_OUTPUT.PUT_LINE('Sum: ' || math_utils.add_numbers(10, 20));
    DBMS_OUTPUT.PUT_LINE('Product: ' || math_utils.multiply_numbers(10, 20));
END;
/

-- 8. Triggers
CREATE TABLE salary_audit_log (
    audit_id     NUMBER PRIMARY KEY,
    employee_id  NUMBER,
    old_salary   NUMBER,
    new_salary   NUMBER,
    change_date  DATE,
    changed_by   VARCHAR2(30)
);

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
END trg_audit_salary_change;
/
