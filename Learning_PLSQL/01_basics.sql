-- Oracle PL/SQL

-- PL/SQL Basics Tutorial

/*
PL/SQL is Oracle's procedural extension to SQL.
It combines the data manipulation power of SQL with procedural features.
*/

-- 1. Basic Block Structure
DECLARE
    -- Declaration section (optional)
    v_message VARCHAR2(100) := 'Hello, PL/SQL!';
    v_number NUMBER := 42;
BEGIN
    -- Executable section (required)
    DBMS_OUTPUT.PUT_LINE(v_message);
    DBMS_OUTPUT.PUT_LINE('The number is: ' || v_number);
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
    -- Using variables
    DBMS_OUTPUT.PUT_LINE('Number: ' || v_number);
    DBMS_OUTPUT.PUT_LINE('Integer: ' || v_integer);
    DBMS_OUTPUT.PUT_LINE('Text: ' || v_text);
    DBMS_OUTPUT.PUT_LINE('Date: ' || TO_CHAR(v_date, 'DD-MON-YYYY HH24:MI:SS'));
    -- Note: Cannot directly print boolean values
    IF v_boolean THEN
        DBMS_OUTPUT.PUT_LINE('Boolean is TRUE');
    END IF;
END;
/

-- 3. Constants
DECLARE
    -- Constants must be initialized when declared
    c_pi CONSTANT NUMBER := 3.14159;
    c_max_length CONSTANT PLS_INTEGER := 100;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Pi value: ' || c_pi);
    DBMS_OUTPUT.PUT_LINE('Max length: ' || c_max_length);
END;
/

-- 4. Conditional Statements
DECLARE
    v_number NUMBER := 42;
BEGIN
    -- IF-THEN-ELSIF-ELSE
    IF v_number < 0 THEN
        DBMS_OUTPUT.PUT_LINE('Number is negative');
    ELSIF v_number = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Number is zero');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Number is positive');
    END IF;
    
    -- CASE statement
    CASE
        WHEN v_number < 0 THEN
            DBMS_OUTPUT.PUT_LINE('Negative');
        WHEN v_number = 0 THEN
            DBMS_OUTPUT.PUT_LINE('Zero');
        ELSE
            DBMS_OUTPUT.PUT_LINE('Positive');
    END CASE;
END;
/

-- 5. Loops
DECLARE
    v_counter NUMBER := 1;
BEGIN
    -- Basic loop
    LOOP
        DBMS_OUTPUT.PUT_LINE('Basic loop iteration: ' || v_counter);
        v_counter := v_counter + 1;
        EXIT WHEN v_counter > 3;
    END LOOP;
    
    -- While loop
    v_counter := 1;
    WHILE v_counter <= 3 LOOP
        DBMS_OUTPUT.PUT_LINE('While loop iteration: ' || v_counter);
        v_counter := v_counter + 1;
    END LOOP;
    
    -- For loop
    FOR i IN 1..3 LOOP
        DBMS_OUTPUT.PUT_LINE('For loop iteration: ' || i);
    END LOOP;
END;
/

-- Enable DBMS_OUTPUT before running these examples
SET SERVEROUTPUT ON;
