-- Advanced PL/SQL Practice Exercises

/*
Exercise 1: Cursor and Exception Handling
Create a procedure that gives salary raises based on years of service.
Use cursors to process employees and handle various exceptions.
*/
CREATE OR REPLACE PROCEDURE process_service_based_raises AS
    CURSOR emp_cursor IS
        SELECT employee_id, salary, hire_date
        FROM employees
        FOR UPDATE OF salary;
        
    v_years_of_service NUMBER;
    v_raise_percentage NUMBER;
    e_invalid_salary EXCEPTION;
BEGIN
    FOR emp_rec IN emp_cursor LOOP
        -- Calculate years of service
        v_years_of_service := TRUNC(MONTHS_BETWEEN(SYSDATE, emp_rec.hire_date) / 12);
        
        -- Determine raise percentage
        v_raise_percentage := 
            CASE 
                WHEN v_years_of_service >= 10 THEN 10
                WHEN v_years_of_service >= 5 THEN 7
                WHEN v_years_of_service >= 3 THEN 5
                ELSE 3
            END;
            
        -- Validate new salary
        IF emp_rec.salary * (1 + v_raise_percentage/100) > 150000 THEN
            RAISE e_invalid_salary;
        END IF;
        
        -- Update salary
        UPDATE employees
        SET salary = salary * (1 + v_raise_percentage/100)
        WHERE CURRENT OF emp_cursor;
        
    END LOOP;
    COMMIT;
EXCEPTION
    WHEN e_invalid_salary THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20101, 'Salary exceeds maximum limit');
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20102, 'Error: ' || SQLERRM);
END process_service_based_raises;
/

/*
Exercise 2: Package for Department Statistics
Create a package that manages department statistics with multiple functions and procedures.
*/
CREATE OR REPLACE PACKAGE dept_stats AS
    -- Get department average salary
    FUNCTION get_dept_avg_salary(p_dept_id NUMBER) RETURN NUMBER;
    
    -- Get department headcount
    FUNCTION get_dept_headcount(p_dept_id NUMBER) RETURN NUMBER;
    
    -- Get department performance summary
    PROCEDURE get_dept_performance_summary(
        p_dept_id IN NUMBER,
        p_avg_rating OUT NUMBER,
        p_top_performers OUT NUMBER,
        p_needs_improvement OUT NUMBER
    );
    
    -- Generate department report
    PROCEDURE generate_dept_report(p_dept_id IN NUMBER);
END dept_stats;
/

CREATE OR REPLACE PACKAGE BODY dept_stats AS
    -- Get department average salary
    FUNCTION get_dept_avg_salary(p_dept_id NUMBER) RETURN NUMBER IS
        v_avg_salary NUMBER;
    BEGIN
        SELECT AVG(salary)
        INTO v_avg_salary
        FROM employees
        WHERE department_id = p_dept_id;
        
        RETURN v_avg_salary;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END get_dept_avg_salary;
    
    -- Get department headcount
    FUNCTION get_dept_headcount(p_dept_id NUMBER) RETURN NUMBER IS
        v_count NUMBER;
    BEGIN
        SELECT COUNT(*)
        INTO v_count
        FROM employees
        WHERE department_id = p_dept_id;
        
        RETURN v_count;
    END get_dept_headcount;
    
    -- Get department performance summary
    PROCEDURE get_dept_performance_summary(
        p_dept_id IN NUMBER,
        p_avg_rating OUT NUMBER,
        p_top_performers OUT NUMBER,
        p_needs_improvement OUT NUMBER
    ) IS
    BEGIN
        -- Get average rating (A=4, B=3, C=2, D=1)
        SELECT AVG(CASE rating
                    WHEN 'A' THEN 4
                    WHEN 'B' THEN 3
                    WHEN 'C' THEN 2
                    WHEN 'D' THEN 1
                END)
        INTO p_avg_rating
        FROM employees e
        JOIN performance_ratings pr ON e.employee_id = pr.employee_id
        WHERE e.department_id = p_dept_id
        AND pr.rating_date = (
            SELECT MAX(rating_date)
            FROM performance_ratings
            WHERE employee_id = e.employee_id
        );
        
        -- Get count of top performers (A rating)
        SELECT COUNT(*)
        INTO p_top_performers
        FROM employees e
        JOIN performance_ratings pr ON e.employee_id = pr.employee_id
        WHERE e.department_id = p_dept_id
        AND pr.rating = 'A'
        AND pr.rating_date = (
            SELECT MAX(rating_date)
            FROM performance_ratings
            WHERE employee_id = e.employee_id
        );
        
        -- Get count of employees needing improvement (C or D rating)
        SELECT COUNT(*)
        INTO p_needs_improvement
        FROM employees e
        JOIN performance_ratings pr ON e.employee_id = pr.employee_id
        WHERE e.department_id = p_dept_id
        AND pr.rating IN ('C', 'D')
        AND pr.rating_date = (
            SELECT MAX(rating_date)
            FROM performance_ratings
            WHERE employee_id = e.employee_id
        );
    END get_dept_performance_summary;
    
    -- Generate department report
    PROCEDURE generate_dept_report(p_dept_id IN NUMBER) IS
        v_dept_name departments.department_name%TYPE;
        v_avg_salary NUMBER;
        v_headcount NUMBER;
        v_avg_rating NUMBER;
        v_top_performers NUMBER;
        v_needs_improvement NUMBER;
    BEGIN
        -- Get department name
        SELECT department_name
        INTO v_dept_name
        FROM departments
        WHERE department_id = p_dept_id;
        
        -- Get statistics
        v_avg_salary := get_dept_avg_salary(p_dept_id);
        v_headcount := get_dept_headcount(p_dept_id);
        
        get_dept_performance_summary(
            p_dept_id => p_dept_id,
            p_avg_rating => v_avg_rating,
            p_top_performers => v_top_performers,
            p_needs_improvement => v_needs_improvement
        );
        
        -- Print report
        DBMS_OUTPUT.PUT_LINE('Department Report: ' || v_dept_name);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Total Employees: ' || v_headcount);
        DBMS_OUTPUT.PUT_LINE('Average Salary: $' || ROUND(v_avg_salary, 2));
        DBMS_OUTPUT.PUT_LINE('Average Performance Rating: ' || ROUND(v_avg_rating, 2));
        DBMS_OUTPUT.PUT_LINE('Top Performers: ' || v_top_performers);
        DBMS_OUTPUT.PUT_LINE('Needs Improvement: ' || v_needs_improvement);
    END generate_dept_report;
END dept_stats;
/

/*
Exercise 3: Triggers for Audit Trail
Create triggers to maintain audit trail for employee data changes.
*/
-- Create audit trail table
CREATE TABLE employee_audit_trail (
    audit_id        NUMBER PRIMARY KEY,
    employee_id     NUMBER,
    action_type     VARCHAR2(10),
    action_date     DATE DEFAULT SYSDATE,
    old_salary      NUMBER,
    new_salary      NUMBER,
    old_dept_id     NUMBER,
    new_dept_id     NUMBER,
    old_job_title   VARCHAR2(50),
    new_job_title   VARCHAR2(50),
    changed_by      VARCHAR2(30)
);

-- Create sequence for audit trail
CREATE SEQUENCE audit_seq
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

-- Create trigger for employee changes
CREATE OR REPLACE TRIGGER trg_employee_audit
AFTER INSERT OR UPDATE OR DELETE ON employees
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO employee_audit_trail (
            audit_id, employee_id, action_type,
            new_salary, new_dept_id, new_job_title,
            changed_by
        ) VALUES (
            audit_seq.NEXTVAL, :NEW.employee_id, 'INSERT',
            :NEW.salary, :NEW.department_id, :NEW.job_title,
            USER
        );
    ELSIF UPDATING THEN
        INSERT INTO employee_audit_trail (
            audit_id, employee_id, action_type,
            old_salary, new_salary,
            old_dept_id, new_dept_id,
            old_job_title, new_job_title,
            changed_by
        ) VALUES (
            audit_seq.NEXTVAL, :OLD.employee_id, 'UPDATE',
            :OLD.salary, :NEW.salary,
            :OLD.department_id, :NEW.department_id,
            :OLD.job_title, :NEW.job_title,
            USER
        );
    ELSIF DELETING THEN
        INSERT INTO employee_audit_trail (
            audit_id, employee_id, action_type,
            old_salary, old_dept_id, old_job_title,
            changed_by
        ) VALUES (
            audit_seq.NEXTVAL, :OLD.employee_id, 'DELETE',
            :OLD.salary, :OLD.department_id, :OLD.job_title,
            USER
        );
    END IF;
END;
/

/*
Exercise 4: Complex Cursor Operations
Create a procedure that rebalances department workload using cursors.
*/
CREATE OR REPLACE PROCEDURE rebalance_departments AS
    -- Cursor for departments with too many employees
    CURSOR overstaffed_dept_cur IS
        SELECT d.department_id, d.department_name, COUNT(*) as emp_count
        FROM departments d
        JOIN employees e ON d.department_id = e.department_id
        GROUP BY d.department_id, d.department_name
        HAVING COUNT(*) > 10
        FOR UPDATE;
    
    -- Cursor for departments with few employees
    CURSOR understaffed_dept_cur IS
        SELECT d.department_id, d.department_name, COUNT(*) as emp_count
        FROM departments d
        JOIN employees e ON d.department_id = e.department_id
        GROUP BY d.department_id, d.department_name
        HAVING COUNT(*) < 5
        FOR UPDATE;
        
    -- Cursor for employees to transfer
    CURSOR transfer_emp_cur(p_dept_id NUMBER) IS
        SELECT employee_id, job_title
        FROM employees
        WHERE department_id = p_dept_id
        AND hire_date = (
            SELECT MAX(hire_date)
            FROM employees
            WHERE department_id = p_dept_id
        )
        FOR UPDATE;
        
    v_target_dept_id NUMBER;
BEGIN
    -- Process overstaffed departments
    FOR over_dept IN overstaffed_dept_cur LOOP
        -- Find understaffed department
        SELECT department_id
        INTO v_target_dept_id
        FROM (
            SELECT department_id
            FROM departments d
            WHERE department_id IN (
                SELECT department_id
                FROM understaffed_dept_cur
            )
            ORDER BY DBMS_RANDOM.VALUE
        )
        WHERE ROWNUM = 1;
        
        -- Transfer newest employee
        FOR emp IN transfer_emp_cur(over_dept.department_id) LOOP
            emp_mgmt.transfer_employee(
                p_employee_id => emp.employee_id,
                p_new_dept_id => v_target_dept_id
            );
        END LOOP;
    END LOOP;
    
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20103, 'Error rebalancing departments: ' || SQLERRM);
END rebalance_departments;
/

-- Test script for all exercises
CREATE OR REPLACE PROCEDURE test_advanced_features AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Testing Service-Based Raises...');
    process_service_based_raises;
    
    DBMS_OUTPUT.PUT_LINE('Testing Department Statistics...');
    FOR dept IN (SELECT department_id FROM departments) LOOP
        dept_stats.generate_dept_report(dept.department_id);
        DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Testing Department Rebalancing...');
    rebalance_departments;
    
    DBMS_OUTPUT.PUT_LINE('All tests completed successfully!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Error during testing: ' || SQLERRM);
END test_advanced_features;
/ 