-- Enable server output
SET SERVEROUTPUT ON;

DECLARE
    -- Variables for employee management
    v_emp_id NUMBER;
    v_old_salary NUMBER;
    v_name VARCHAR2(100);
    v_department VARCHAR2(50);
    v_salary NUMBER;
    v_rating CHAR;
    v_bonus NUMBER;
BEGIN
    -- Test 1: Add new employee
    DBMS_OUTPUT.PUT_LINE('Test 1: Adding new employee');
    emp_mgmt.add_employee(
        p_first_name => 'John',
        p_last_name => 'Doe',
        p_email => 'john.doe@example.com',
        p_department_id => 10,
        p_job_title => 'Software Engineer',
        p_salary => 75000,
        p_manager_id => NULL,
        p_employee_id => v_emp_id
    );
    DBMS_OUTPUT.PUT_LINE('Added employee with ID: ' || v_emp_id);
    
    -- Test 2: Add performance rating
    DBMS_OUTPUT.PUT_LINE('Test 2: Adding performance rating');
    emp_mgmt.add_performance_rating(
        p_employee_id => v_emp_id,
        p_rating => 'A',
        p_comments => 'Excellent performance in first quarter'
    );
    DBMS_OUTPUT.PUT_LINE('Added performance rating');
    
    -- Test 3: Update salary
    DBMS_OUTPUT.PUT_LINE('Test 3: Updating salary');
    emp_mgmt.update_salary(
        p_employee_id => v_emp_id,
        p_new_salary => 80000,
        p_reason => 'Performance based increase',
        p_old_salary => v_old_salary
    );
    DBMS_OUTPUT.PUT_LINE('Updated salary from ' || v_old_salary || ' to 80000');
    
    -- Test 4: Transfer employee
    DBMS_OUTPUT.PUT_LINE('Test 4: Transferring employee');
    emp_mgmt.transfer_employee(
        p_employee_id => v_emp_id,
        p_new_dept_id => 20,
        p_new_job_title => 'Senior Software Engineer'
    );
    DBMS_OUTPUT.PUT_LINE('Transferred employee to new department');
    
    -- Test 5: Calculate bonus
    DBMS_OUTPUT.PUT_LINE('Test 5: Calculating bonus');
    v_bonus := emp_mgmt.calculate_bonus(v_emp_id);
    DBMS_OUTPUT.PUT_LINE('Calculated bonus: $' || v_bonus);
    
    -- Test 6: Get employee details
    DBMS_OUTPUT.PUT_LINE('Test 6: Getting employee details');
    emp_mgmt.get_employee_details(
        p_employee_id => v_emp_id,
        p_name => v_name,
        p_department => v_department,
        p_salary => v_salary,
        p_rating => v_rating
    );
    DBMS_OUTPUT.PUT_LINE('Employee Details:');
    DBMS_OUTPUT.PUT_LINE('Name: ' || v_name);
    DBMS_OUTPUT.PUT_LINE('Department: ' || v_department);
    DBMS_OUTPUT.PUT_LINE('Salary: $' || v_salary);
    DBMS_OUTPUT.PUT_LINE('Rating: ' || v_rating);

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
        ROLLBACK;
END;
/ 