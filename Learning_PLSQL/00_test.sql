-- Enable server output
SET SERVEROUTPUT ON;

-- Simple PL/SQL test block
DECLARE
    v_test VARCHAR2(100) := 'Hello from PL/SQL!';
BEGIN
    DBMS_OUTPUT.PUT_LINE(v_test);
END;
/

-- Test table creation
CREATE TABLE test_table (
    id NUMBER PRIMARY KEY,
    name VARCHAR2(100)
);

-- Test data insertion
BEGIN
    INSERT INTO test_table (id, name) VALUES (1, 'Test Entry');
    DBMS_OUTPUT.PUT_LINE('Data inserted successfully!');
    COMMIT;
END;
/

-- View the data
SELECT * FROM test_table;

-- Clean up
DROP TABLE test_table;
/
