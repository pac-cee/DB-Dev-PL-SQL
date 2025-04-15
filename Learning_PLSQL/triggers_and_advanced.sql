-- =============================================
-- Advanced Triggers and Complex SQL Features
-- =============================================

/*
Section 1: Database Triggers
Purpose: Automatic execution of code in response to events
Benefits:
- Automatic data validation
- Audit trailing
- Event logging
- Business rule enforcement
- Maintaining derived data
*/

-- 1.1 Row-Level Trigger
-- --------------------
-- Purpose: Maintains audit trail for each row modification
-- Fires: Once for each row affected
-- Use Case: Detailed change tracking at record level
CREATE OR REPLACE TRIGGER trg_emp_audit_row
    AFTER UPDATE OF salary, department_id
    ON employees
    FOR EACH ROW
    WHEN (NEW.salary <> OLD.salary OR 
          NEW.department_id <> OLD.department_id)
DECLARE
    v_change_type VARCHAR2(100);
BEGIN
    -- Determine type of change
    v_change_type := CASE
        WHEN :NEW.salary <> :OLD.salary AND 
             :NEW.department_id <> :OLD.department_id 
        THEN 'Salary and Department'
        WHEN :NEW.salary <> :OLD.salary 
        THEN 'Salary Only'
        ELSE 'Department Only'
    END;
    
    -- Insert audit record
    INSERT INTO employee_audit (
        emp_id,
        change_date,
        change_type,
        old_salary,
        new_salary,
        old_dept_id,
        new_dept_id,
        modified_by
    ) VALUES (
        :NEW.employee_id,
        SYSDATE,
        v_change_type,
        :OLD.salary,
        :NEW.salary,
        :OLD.department_id,
        :NEW.department_id,
        SYS_CONTEXT('USERENV', 'SESSION_USER')
    );
END;
/

-- 1.2 Statement-Level Trigger
-- --------------------------
-- Purpose: Enforces business hours for data modifications
-- Fires: Once per SQL statement
-- Use Case: Global business rule enforcement
CREATE OR REPLACE TRIGGER trg_business_hours
    BEFORE INSERT OR UPDATE OR DELETE
    ON employees
BEGIN
    -- Check if operation is during business hours (8 AM to 6 PM)
    IF TO_NUMBER(TO_CHAR(SYSDATE, 'HH24')) NOT BETWEEN 8 AND 18 OR
       TO_CHAR(SYSDATE, 'DY') IN ('SAT', 'SUN') THEN
        RAISE_APPLICATION_ERROR(-20100, 
            'Data modifications only allowed during business hours (Mon-Fri, 8 AM - 6 PM)');
    END IF;
END;
/

/*
Section 2: Advanced SQL Features
Purpose: Complex data analysis and manipulation
Benefits:
- Enhanced data analysis
- Improved query performance
- Complex data relationships
*/

-- 2.1 Hierarchical Queries
-- -----------------------
-- Purpose: Handle tree-structured data
-- Use Case: Organization charts, parts explosions
CREATE OR REPLACE VIEW v_emp_hierarchy AS
SELECT 
    LEVEL as hierarchy_level,
    LPAD(' ', 2 * (LEVEL-1)) || emp_name as org_chart,
    emp_id,
    manager_id,
    salary,
    CONNECT_BY_ROOT emp_name as top_manager,
    SYS_CONNECT_BY_PATH(emp_name, '/') as emp_path
FROM employees
CONNECT BY PRIOR emp_id = manager_id
START WITH manager_id IS NULL;

-- 2.2 Materialized Views
-- ---------------------
-- Purpose: Pre-computed query results
-- Benefits: 
-- - Improved performance for complex queries
-- - Data replication
-- - Distributed databases
CREATE MATERIALIZED VIEW mv_dept_summary
    REFRESH ON COMMIT
AS
SELECT 
    d.department_id,
    d.department_name,
    COUNT(*) as emp_count,
    AVG(e.salary) as avg_salary,
    MIN(e.hire_date) as earliest_hire,
    MAX(e.hire_date) as latest_hire
FROM departments d
JOIN employees e ON d.department_id = e.department_id
GROUP BY d.department_id, d.department_name;

-- 2.3 Advanced Analytical Functions
-- ------------------------------
-- Purpose: Complex statistical analysis
-- Use Case: Business intelligence and reporting
CREATE OR REPLACE VIEW v_emp_analytics AS
SELECT 
    department_id,
    emp_name,
    salary,
    hire_date,
    -- Statistical analysis
    STDDEV(salary) OVER (PARTITION BY department_id) as dept_salary_stddev,
    VARIANCE(salary) OVER (PARTITION BY department_id) as dept_salary_variance,
    CORR(salary, MONTHS_BETWEEN(SYSDATE, hire_date)) 
        OVER (PARTITION BY department_id) as salary_tenure_correlation,
    
    -- Relative statistics
    PERCENT_RANK() OVER (PARTITION BY department_id ORDER BY salary) as salary_percentile,
    CUME_DIST() OVER (PARTITION BY department_id ORDER BY salary) as salary_distribution,
    
    -- Moving calculations
    AVG(salary) OVER (
        PARTITION BY department_id 
        ORDER BY hire_date 
        ROWS BETWEEN 3 PRECEDING AND 3 FOLLOWING
    ) as rolling_avg_salary
FROM employees;

/*
Section 3: Advanced Exception Handling
Purpose: Robust error management
Benefits:
- Graceful error handling
- Detailed error logging
- Better debugging
*/

-- 3.1 Custom Exception Handler
-- --------------------------
-- Purpose: Centralized error handling
CREATE OR REPLACE PACKAGE error_handler IS
    -- Custom exceptions
    e_invalid_department EXCEPTION;
    PRAGMA EXCEPTION_INIT(e_invalid_department, -20200);
    
    -- Error handling procedure
    PROCEDURE handle_error(
        p_error_code IN NUMBER,
        p_error_msg IN VARCHAR2,
        p_procedure_name IN VARCHAR2,
        p_additional_info IN VARCHAR2 DEFAULT NULL
    );
    
    -- Error logging function
    FUNCTION log_error(
        p_error_info IN VARCHAR2
    ) RETURN NUMBER;
END error_handler;
/

CREATE OR REPLACE PACKAGE BODY error_handler IS
    PROCEDURE handle_error(
        p_error_code IN NUMBER,
        p_error_msg IN VARCHAR2,
        p_procedure_name IN VARCHAR2,
        p_additional_info IN VARCHAR2 DEFAULT NULL
    ) IS
        v_error_id NUMBER;
    BEGIN
        -- Log the error
        v_error_id := log_error(
            'Code: ' || p_error_code || CHR(10) ||
            'Message: ' || p_error_msg || CHR(10) ||
            'Procedure: ' || p_procedure_name || CHR(10) ||
            'Additional Info: ' || NVL(p_additional_info, 'None')
        );
        
        -- Send alert if critical error
        IF ABS(p_error_code) > 20000 THEN
            send_alert(v_error_id);
        END IF;
        
        -- Raise to calling environment
        RAISE_APPLICATION_ERROR(p_error_code, p_error_msg);
    END handle_error;
    
    FUNCTION log_error(
        p_error_info IN VARCHAR2
    ) RETURN NUMBER IS
        v_error_id NUMBER;
        PRAGMA AUTONOMOUS_TRANSACTION;  -- Independent transaction
    BEGIN
        -- Insert error log
        INSERT INTO error_logs (
            error_date,
            error_info,
            user_id,
            session_id
        ) VALUES (
            SYSTIMESTAMP,
            p_error_info,
            SYS_CONTEXT('USERENV', 'SESSION_USER'),
            SYS_CONTEXT('USERENV', 'SID')
        ) RETURNING error_id INTO v_error_id;
        
        COMMIT;
        RETURN v_error_id;
    END log_error;
END error_handler;
/